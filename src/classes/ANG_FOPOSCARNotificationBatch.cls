global class ANG_FOPOSCARNotificationBatch implements Database.Batchable<Case>, Database.Stateful  {
	/*
	 Will run every day and send email and Portal notification if:
		a) The FOP OSCAR is not submitted by the agent within 15 days (creation date + 15 days) => Reminder
		b) The FOP OSCAR is not submitted by the agent within 30 days (creation date + 30 days) => Non Compliance
	*/

	// FOP OSCAR was mass created if Origin is the following: 
	private static final String MASSIVE_FOP_ORIGIN = 'Massive FOP Creation';

	private static final String RECTYPE_OSCARCOMM = AMS_Utils.RECTYPE_OSCARCOMM;
	private static final String RECTYPE_NEWGENFOP = AMS_Utils.RECTYPE_NEWGENFOP;
	private static final Set<String> MASS_FOP_QUEUES = AMS_Utils.MASS_FOP_QUEUES;

	// Portal Notification and Email templates identifiers
	public static final String FOP_REMINDER_TEMPLATE_ID = 'ANG_Mass_FOP_OSCAR_Reminder'; 
	public static final String FOP_NONCOMPLIANCE_TEMPLATE_ID = 'ANG_Mass_FOP_OSCAR_NonCompliance'; 

	//Templates Names to use
	private Map<String,String> notificationTemplates;
	// static dates:
	private static Date dateReminder; //15 days ago
	private static Date dateNonCompliance; //30 days ago

	List<String> errors = new List<String>();

	
	global ANG_FOPOSCARNotificationBatch() {
		
	}
	
	global Iterable<Case> start(Database.BatchableContext BC) {

		dateReminder = Date.today().addDays(-15);
		dateNonCompliance = Date.today().addDays(-30);

		notificationTemplates = new Map<String,String>();

		for (Notification_template__c nt :[SELECT Id,Name, Identifier__c FROM Notification_Template__c WHERE Identifier__c = :FOP_REMINDER_TEMPLATE_ID OR Identifier__c = :FOP_NONCOMPLIANCE_TEMPLATE_ID]){
			notificationTemplates.put(nt.Identifier__c,nt.Name);
		}

		String query = 'SELECT Id, ContactId, ContactEmail, Contact.Name, OSCAR__c, OSCAR__r.createdDate, Contact.Account.IataCode__c, '+ 
			'Contact.Preferred_Language__c, Contact.BSP_CASS_Payment_contact__c, Contact.Financial_Assessment_Contact__c, '+
			'OSCAR__r.Sanity_check_deadline__c, CreatedDate, OSCAR__r.OSCAR_Deadline__c '+
			'FROM Case '+
			'WHERE RecordtypeID = :RECTYPE_OSCARCOMM '+ 
			'AND OSCAR__r.RecordTypeId = :RECTYPE_NEWGENFOP '+ 
			'AND Origin = :MASSIVE_FOP_ORIGIN '+
			'AND Owner.Name IN :MASS_FOP_QUEUES '+
			'AND (DAY_ONLY(CreatedDate) = :dateReminder '+
				'OR DAY_ONLY(CreatedDate) = :dateNonCompliance)';

		return (Iterable<Case>) Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Case> scope) {
   		Map<Id,Case> reminderCases = new Map<Id,Case>();
   		Map<Id,Case> nonComplianceCases = new Map<Id,Case>();
   		Map<String,Map<Id,Case>> casesByTemplateName =  new Map<String,Map<Id,Case>>();
   		Map<String,Set<Id>> templateContIdMap = new Map<String,Set<Id>>();

   		Date dt;

   		for (Case cse :scope){

   			dt = Date.newInstance(cse.CreatedDate.year(), cse.CreatedDate.month(), cse.CreatedDate.day());

   			if (dt == dateReminder){
   				reminderCases.put(cse.id,cse);
   				if(templateContIdMap.keySet().contains(FOP_REMINDER_TEMPLATE_ID) ){
   					templateContIdMap.get(FOP_REMINDER_TEMPLATE_ID).add(cse.ContactId);
   				}else{
   					templateContIdMap.put(FOP_REMINDER_TEMPLATE_ID,new Set<Id>{cse.ContactId});
   				}
   			}else if(dt == dateNonCompliance){
   				nonComplianceCases.put(cse.id,cse);
   				if(templateContIdMap.keySet().contains(FOP_NONCOMPLIANCE_TEMPLATE_ID) ){
   					templateContIdMap.get(FOP_NONCOMPLIANCE_TEMPLATE_ID).add(cse.ContactId);
   				}else{
   					templateContIdMap.put(FOP_NONCOMPLIANCE_TEMPLATE_ID,new Set<Id>{cse.ContactId});
   				}
   			} 		
   		}

   		if (!reminderCases.isEmpty() || !nonComplianceCases.isEmpty()){

	   		if(!reminderCases.isEmpty())
	   			casesByTemplateName.put(notificationTemplates.get(FOP_REMINDER_TEMPLATE_ID),reminderCases);
	   		
	   		if(!nonComplianceCases.isEmpty())
	   			casesByTemplateName.put(notificationTemplates.get(FOP_NONCOMPLIANCE_TEMPLATE_ID),nonComplianceCases);	   		

	   		try{
	   			System.debug('## sending casesByTemplateName: '+casesByTemplateName);
                System.debug('## sending templateContIdMap: '+templateContIdMap);
		   		ANG_OscarProcessHelper.sendFOPPortalNotificationAndEmail(casesByTemplateName, templateContIdMap);	   		
	   		}catch(Exception e){
	   			errors.add(e.getMessage());
	   		}	
   		}
	}	
	
	global void finish(Database.BatchableContext BC) {
		if(!errors.isEmpty()){
			String errorMsg = 'Error(s) running ANG_FOPOSCARNotificationBatch on '+DateTime.now()+':/n'+String.join(errors,',');
			//send email w/ errors ??
			System.debug('## Error Message: '+errorMsg);
		}
	
	}
	
}