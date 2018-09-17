global class ANG_FOPOSCARNotificationBatch implements Database.Batchable<Case>, Database.Stateful  {
	/*
	 Will run every day and send email and Portal notification if:
		a) The FOP OSCAR is not submitted by the agent within 15 days (creation date + 15 days) => Reminder
		b) The FOP OSCAR is not submitted by the agent within 30 days (creation date + 30 days) => Non Compliance
	*/

	// FOP OSCAR was mass created if Origin is the following: 
	private static final String MASSIVE_FOP_ORIGIN = 'Massive FOP Creation';
	private static final String AUTOMATIC_RENEWAL_FOP_ORIGIN = 'FoP automatic renewal';

	private static final String RECTYPE_OSCARCOMM = AMS_Utils.RECTYPE_OSCARCOMM;
	private static final String RECTYPE_NEWGENFOP = AMS_Utils.RECTYPE_NEWGENFOP;
	private static final Set<String> MASS_FOP_QUEUES = AMS_Utils.MASS_FOP_QUEUES;

	// Portal Notification and Email templates identifiers
	public static final String FOP_REMINDER_TEMPLATE_ID = 'ANG_Mass_FOP_OSCAR_Reminder'; 
	public static final String FOP_NONCOMPLIANCE_TEMPLATE_ID = 'ANG_Mass_FOP_OSCAR_NonCompliance';	
	public static final String RENEWAL_FOP_REMINDER_TEMPLATE_ID = 'ANG_PCI_RENEWAL_Reminder'; 
	public static final String RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID = 'ANG_PCI_RENEWAL_NonCompliance'; 

	//Templates Names to use
	private Map<String,String> notificationTemplates;
	private Map<String,String> notificationTemplatesInverted;
	//dates:
	Date dateReminder; //15 days ago
	Date dateNonCompliance; //30 days ago

	List<String> errors = new List<String>();

	
	global ANG_FOPOSCARNotificationBatch() {
		
	}
	
	global Iterable<Case> start(Database.BatchableContext BC) {

		dateReminder = Date.today().addDays(-15);
		dateNonCompliance = Date.today().addDays(-30);

		System.debug('## dateReminder: '+dateReminder);
		System.debug('## dateNonCompliance: '+dateNonCompliance);

		notificationTemplates = new Map<String,String>();
		notificationTemplatesInverted = new Map<String,String>();

		for (Notification_template__c nt :[SELECT Id,Name, Identifier__c FROM Notification_Template__c WHERE Identifier__c = :FOP_REMINDER_TEMPLATE_ID OR Identifier__c = :FOP_NONCOMPLIANCE_TEMPLATE_ID or Identifier__c = :RENEWAL_FOP_REMINDER_TEMPLATE_ID OR Identifier__c =:RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID]){
			notificationTemplates.put(nt.Identifier__c,nt.Name);
			notificationTemplatesInverted.put(nt.Name,nt.Identifier__c);
		}

		String query;
		//cannot access owner.name while test is running
		if (Test.isRunningTest()){
			query = 'SELECT Id, ContactId, ContactEmail, Contact.Name, OSCAR__c, OSCAR__r.createdDate, Contact.Account.IataCode__c, Origin,'+ 
				'Contact.Preferred_Language__c, Contact.BSP_CASS_Payment_contact__c, Contact.Financial_Assessment_Contact__c, CreatedDate '+
				'FROM Case '+
				'WHERE RecordtypeID = :RECTYPE_OSCARCOMM '+ 
				'AND OSCAR__r.RecordTypeId = :RECTYPE_NEWGENFOP '+ 
				'AND (Origin = :MASSIVE_FOP_ORIGIN OR Origin = :AUTOMATIC_RENEWAL_FOP_ORIGIN)'+
				'AND (DAY_ONLY(CreatedDate) = :dateReminder '+
					'OR DAY_ONLY(CreatedDate) = :dateNonCompliance)';
		}else{
			query = 'SELECT Id, ContactId, ContactEmail, Contact.Name, OSCAR__c, OSCAR__r.createdDate, Contact.Account.IataCode__c, Origin,'+ 
				'Contact.Preferred_Language__c, Contact.BSP_CASS_Payment_contact__c, Contact.Financial_Assessment_Contact__c, CreatedDate '+
				'FROM Case '+
				'WHERE RecordtypeID = :RECTYPE_OSCARCOMM '+ 
				'AND OSCAR__r.RecordTypeId = :RECTYPE_NEWGENFOP '+ 
				'AND (Origin = :MASSIVE_FOP_ORIGIN OR Origin = :AUTOMATIC_RENEWAL_FOP_ORIGIN)'+
				'AND Owner.Name IN :MASS_FOP_QUEUES '+
				'AND (DAY_ONLY(CreatedDate) = :dateReminder '+
					'OR DAY_ONLY(CreatedDate) = :dateNonCompliance)';
		}

		return (Iterable<Case>) Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Case> scope) {
   		Map<Id,Case> reminderCases = new Map<Id,Case>();
   		Map<Id,Case> nonComplianceCases = new Map<Id,Case>();
   		Map<Id,Case> renewalReminderCases = new Map<Id,Case>();
   		Map<Id,Case> renewalNonComplianceCases = new Map<Id,Case>();
   		Map<String,Map<Id,Case>> casesByTemplateName =  new Map<String,Map<Id,Case>>();
   		Map<String,Set<Id>> templateContIdMap = new Map<String,Set<Id>>();

   		Date dt;

   		for (Case cse :scope){

   			dt = Date.newInstance(cse.CreatedDate.year(), cse.CreatedDate.month(), cse.CreatedDate.day());

   			if (dt == dateReminder){
   				if(cse.origin == MASSIVE_FOP_ORIGIN){   					
   					reminderCases.put(cse.id,cse);
	   				if(templateContIdMap.keySet().contains(notificationTemplates.get(FOP_REMINDER_TEMPLATE_ID))) templateContIdMap.get(notificationTemplates.get(FOP_REMINDER_TEMPLATE_ID)).add(cse.ContactId);
	   				else templateContIdMap.put(notificationTemplates.get(FOP_REMINDER_TEMPLATE_ID),new Set<Id>{cse.ContactId});
	   				
   				}else if(cse.origin == AUTOMATIC_RENEWAL_FOP_ORIGIN){
   					renewalReminderCases.put(cse.id,cse);
   					if(templateContIdMap.keySet().contains(notificationTemplates.get(RENEWAL_FOP_REMINDER_TEMPLATE_ID))) templateContIdMap.get(notificationTemplates.get(RENEWAL_FOP_REMINDER_TEMPLATE_ID)).add(cse.ContactId);
	   				else templateContIdMap.put(notificationTemplates.get(RENEWAL_FOP_REMINDER_TEMPLATE_ID),new Set<Id>{cse.ContactId});	   				
   				}
   			}else if(dt == dateNonCompliance){
   				nonComplianceCases.put(cse.id,cse);
   				if(cse.origin == MASSIVE_FOP_ORIGIN){
   					nonComplianceCases.put(cse.id,cse);   
	   				if(templateContIdMap.keySet().contains(notificationTemplates.get(FOP_NONCOMPLIANCE_TEMPLATE_ID))) templateContIdMap.get(notificationTemplates.get(FOP_NONCOMPLIANCE_TEMPLATE_ID)).add(cse.ContactId);
	   				else templateContIdMap.put(notificationTemplates.get(FOP_NONCOMPLIANCE_TEMPLATE_ID),new Set<Id>{cse.ContactId});
	   	
	   			}else if(cse.origin ==AUTOMATIC_RENEWAL_FOP_ORIGIN){
	   				renewalNonComplianceCases.put(cse.id,cse);
	   				if(templateContIdMap.keySet().contains(notificationTemplates.get(RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID))) templateContIdMap.get(notificationTemplates.get(RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID)).add(cse.ContactId);
	   				else templateContIdMap.put(notificationTemplates.get(RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID),new Set<Id>{cse.ContactId});	   				
	   			}
   			} 		
   		}

   		if (!reminderCases.isEmpty() || !nonComplianceCases.isEmpty() || !renewalReminderCases.isEmpty() || !renewalNonComplianceCases.isEmpty()){

	   		if(!reminderCases.isEmpty()) casesByTemplateName.put(notificationTemplates.get(FOP_REMINDER_TEMPLATE_ID),reminderCases);	   		
	   		
	   		if(!nonComplianceCases.isEmpty()) casesByTemplateName.put(notificationTemplates.get(FOP_NONCOMPLIANCE_TEMPLATE_ID),nonComplianceCases);

			if(!renewalReminderCases.isEmpty()) casesByTemplateName.put(notificationTemplates.get(RENEWAL_FOP_REMINDER_TEMPLATE_ID),renewalReminderCases);	   		
	   		
	   		if(!renewalNonComplianceCases.isEmpty()) casesByTemplateName.put(notificationTemplates.get(RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID),renewalNonComplianceCases);	   		

	   		try{
		   		ANG_OscarProcessHelper.sendFOPPortalNotificationAndEmail(casesByTemplateName, templateContIdMap,notificationTemplatesInverted);	   		
	   		}catch(Exception e){
	   			errors.add('Error running batch containing Case IDs: '+String.join(templateContIdMap.values(),',')+' - '+e.getMessage()+' - '+e.getStackTraceString()+'/n');
	   		}	
   		}
	}	
	
	global void finish(Database.BatchableContext BC) {
		if(!errors.isEmpty()){
			String errorMsg = 'Error(s) running ANG_FOPOSCARNotificationBatch:/n'+String.join(errors,',');

			//send email w/ errors
			List<String> emailAddresses = new List<String>();
			for (SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){ 
                emailAddresses.add(supportEmail.Support_Email__c);
                //add more email addresses if needed
            }

            if (!emailAddresses.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddresses);    
                mail.setSubject('ANG_FOPOSCARNotificationBatch Completed With Errors');
                mail.setSenderDisplayName('Batch Processing Completed');
                mail.setPlainTextBody('Batch Process has been completed. EndTime ' + system.now() + '\n\nERRORS:\n' +errorMsg);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }

			System.debug(+errorMsg);
		}
	
	}
	
}