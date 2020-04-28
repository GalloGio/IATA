public class ContentVersionTriggerHandler {

	private class ContentVersionTriggerException extends Exception{}

	public List<ContentVersion> triggerNew = (List<ContentVersion>) Trigger.new;
	public Map<Id, ContentVersion> oldMap = (Map<Id,ContentVersion>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	/* */
	public static Set<Id> getAllActiveCurrencyCenterContactIds() {
		Set<Id> setOfContacts = new Set<Id>();

		List<Portal_Application_Right__c> parList = [SELECT Id, Name, Contact__c FROM Portal_Application_Right__c WHERE Right__c = 'Access Granted' AND Portal_Application__r.ServiceName__c = 'Currency Center' AND Contact__r.Status__c = 'Active' AND Contact__r.isEmailBounced = false AND (NOT Contact__r.Email LIKE '%.inactive') AND Contact__r.Account.recordType.developerName = 'iata_airline'];
		System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> parList ' + parList);

		for (Portal_Application_Right__c par : parList){
			setOfContacts.add(par.Contact__c);
		}

		System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> setOfContacts ' + setOfContacts);
		return setOfContacts;
	}

	/*All the logic for after insert should go into this*/

	public void afterInsertContentVersionTriggerHandler() {

		String orgWideEmail = 'IATA Noreply';

		for (ContentVersion cv:  (List<ContentVersion>)Trigger.new) {
			String emailReportTemplate = '';
			if (cv.Title.contains('CurrencyCenterCurrencyRepatriation')) {
				emailReportTemplate = 'Currency_Center_New_Monthly_Report_Notification';
			}
			else if (cv.Title.contains('CurrencyCenterAnnualRBF')) {
				emailReportTemplate = 'Currency_Center_New_Annual_Report_Notification';
			}

			if (emailReportTemplate.equals('Currency_Center_New_Monthly_Report_Notification') || emailReportTemplate.equals('Currency_Center_New_Annual_Report_Notification')) {

				Set<Id> setOfContactIds = getAllActiveCurrencyCenterContactIds();

				if(!setOfContactIds.isEmpty()) {

					List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :orgWideEmail LIMIT 1];
					List<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :emailReportTemplate LIMIT 1];

					if(!owa.isEmpty() && !et.isEmpty()) {
					 	Messaging.Email[] mailMsgs = new Messaging.Email[]{};
					 	List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();

						for(Id cid : setOfContactIds) {
							Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
							mailMsg.setOrgWideEmailAddressId(owa[0].Id);
							mailMsg.setTargetObjectId(cid);
							mailMsg.setTemplateID(et[0].Id);
							mailMsg.setSaveAsActivity(false);
							mailMsgs.add(mailMsg);
						}

						if(!mailMsgs.isEmpty()){
							try {
								sendEmailResults = Messaging.sendEmail(mailMsgs);
								for(Messaging.SendEmailResult ser: sendEmailResults) {
									if(!ser.isSuccess()) {
										System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> errorMessage: ' + ser.getErrors()[0].getMessage() + ' - TargetObjectId:' + ser.getErrors()[0].getTargetObjectId());
									}
								}
							}
							catch (Exception ex){
								System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> error: ' + ex.getMessage());
							}
						}

					}
					else if (owa.isEmpty()){
						System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> Couldn\'t find OrgWideEmailAddress \'IATA Noreply\'');
					}
					else if(et.isEmpty()){
						System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> Couldn\'t find EmailTemplate \'Currency_Center_Annual_Survey_Initial_Notification\'');
					}
				}
				else{
					System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> No contacts with access to Currency Center service');
				}
			}


			if(cv.createdDate <= cv.sent_date__c){
				notifyUsers(cv.ContentDocumentId,cv.title);
			}
		}	
	}


	
	public void afterUpdateContentVersionTriggerHandler() {
		for (ContentVersion cv: triggerNew) {
			if(cv.isLatest==true && (cv.sent_date__c!= oldMap.get(cv.id).sent_date__c) && cv.createdDate <= cv.sent_date__c){
				ContentVersionTriggerHandler.notifyUsers(cv.ContentDocumentId,cv.title);
			}
		}
	}


	//Once a new version in uploaded to salesforce the system needs to notify users that have the document bookmarked in the CS Portal
	//@param docId: Content Document Id of the document that has a new version uploaded
	//@param docTitle: Title of the document
	//Class covered in: PortalDocumentsCtrlTest
	@future
	private static void notifyUsers(id docId,string docTitle){
		set<id> usrIdSubscribedSet =new set<id>();
		//get all users that have this file bookmarked
		for(EntitySubscription es: [Select SubscriberId from EntitySubscription where parentId =:docId]){
			usrIdSubscribedSet.add(es.SubscriberId);
		}

		//get contactInformation from the users
		list<Contact> contactList= [SELECT id,Preferred_Language__c FROM Contact WHERE id in (select contactid from user  where id in:usrIdSubscribedSet)];
		
		Notification_template__c templ;
		try{
			//Get notification template
			templ=[SELECT id,Subject__c,Message__c,Expire_in_days__c,Alert_Contact_By_Email__c,Type__c,CriticalNotification__c,Language__C,Notification_color__c,
			( SELECT id,Subject__c,Message__c,Expire_in_days__c,Alert_Contact_By_Email__c,Type__c,CriticalNotification__c,Language__C,Notification_color__c FROM Notification_templates__r)
			FROM Notification_template__c WHERE Identifier__c='New_Doc_Version_Available'];
		}catch(DMLException e){
			throw new ContentVersionTriggerException('No Email Template found');		
		}			
				
		Map<String, list<String>> fieldBindingByGroupMap = new Map<String, list<String>>();
			fieldBindingByGroupMap.put(null,new list<String>{docTitle});
		//Trigger mechanism to generate and send the portal notifications
		ISSP_NotificationUtilities.sendNotification(contactList, templ,null, fieldBindingByGroupMap,null);
	}

}