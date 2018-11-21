global class AMS_MajorDefaultCommunicationEmailSender implements Database.Batchable<sObject>, Database.Stateful {
	
	global Set<Id> contactIds {get;set;}
	global Map<Id,List<Id>> mapContactToCase {get;set;}
	global Map<Id,Id> mapContactToTemplate {get;set;}
	global List<String> errors {get;set;}
	
	global AMS_MajorDefaultCommunicationEmailSender(Set<Id> contactIds, Map<Id,List<Id>> mapContactToCase, Map<Id,Id> mapContactToTemplate) {
		this.contactIds = contactIds;
		this.mapContactToCase = mapContactToCase;
		this.mapContactToTemplate = mapContactToTemplate;
		this.errors = new List<String>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id FROM Contact WHERE Id IN :contactIds');
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
   		try {
			List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();
			Id orgEmailAddressId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'agencymanagement@iata.org'].Id;
			for(Contact c : scope) {
				for(Id caseId : mapContactToCase.get(c.Id)) {
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.setTargetObjectId(c.Id);
					mail.setWhatId(caseId);
					mail.setToAddresses(new String[] {c.Id});
					mail.setOrgWideEmailAddressId(orgEmailAddressId);
					mail.setSaveAsActivity(true);
					mail.setTemplateId(mapContactToTemplate.get(c.Id));	
					notifications.add(mail);
				}				
			}

			if(!notifications.isEmpty()) {
				Messaging.sendEmail(notifications);
			}
		} catch(Exception e) {
			errors.add(e.getMessage());
			errors.add(e.getStackTraceString());
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		List<SalesforceSupportEmails__c> cs = SalesforceSupportEmails__c.getAll().values();
		List<String> receivers = new List<String>();
		if(!errors.isEmpty() && !cs.isEmpty()) {			
			for(SalesforceSupportEmails__c sp_email : cs) {
				receivers.add(sp_email.Support_Email__c);
			}

			sendErrorMessage(receivers, errors);
		}
	}

	public static void sendErrorMessage(List<String> receivers, List<String> errors) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('Default Agency Batch Errors');
		mail.setPlainTextBody(String.join(errors, '\n'));
		mail.setToAddresses(receivers);
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail}); 
	}
	
}