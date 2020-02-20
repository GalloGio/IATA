global with sharing class WSJavascript {

	webservice static void refreshSignaturitEvents (String signaturitid) {
		Tracked_Email__c te = [
			Select Id, Signaturit_Id__c, Signaturit_Certificate_Ids__c, FromName__c, Email__c, Status__c
			From Tracked_Email__c
			where id = :signaturitid
		];


		List<Tracked_Email_Event__c> events = SignaturitRest.updateEventList(te);

		Database.insert(events, false);

		SignaturitRest.updateEmailStatus(new List<Tracked_Email__c>{te});
	}

	/**
		Send an email to the input case suign the input template
	**/
	webservice static void sendEmail(Id caseId, String templateName) {
		List<Case> cseList = [SELECT Id, ContactId FROM Case WHERE Id = :caseId AND Contact.IsEmailBounced = false AND (NOT Contact.Email LIKE '%.inactive')];
		if(cseList.isEmpty()) return;
		EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName];
		OrgWideEmailAddress orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setOrgWideEmailAddressId(orgAddress.Id);
		mail.setTemplateId(template.Id);
		mail.setTargetObjectId(cseList.get(0).ContactId);
		mail.setWhatId(cseList.get(0).Id);
		mail.setTreatTargetObjectAsRecipient(true);
		mail.setSaveAsActivity(true);
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}
