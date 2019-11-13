public without sharing class AirlineInputHandler {

	// to prevent the trigger from running twice (because of the WF rules changing the record)
	private static boolean blnAlreadyDone = false;

	/*
	 *  Every time that the Airline Input field on the Airline Input record is changed (or newly inserted), create a comment to the parent case
	 *  with the content of the Airline Input field as the comment body
	 */
	public static void CopyAirlineInputToCaseComments (Map<Id, Airline_Input__c> mapTriggerNew, Map<Id, Airline_Input__c> mapTriggerOld, Boolean isUpdate, Boolean isInsert) {

		// to prevent the trigger from running twice (because of the WF rules changing the record)
		if (blnAlreadyDone) return;

		blnAlreadyDone = true;

		list<CaseComment> lstCommentsToInsert = new list<CaseComment>();
		list<Messaging.SingleEmailMessage> lstNotificationEmails = new list<Messaging.SingleEmailMessage>();

		EmailTemplate template;

		try {
			template = [SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = 'New_Case_Comment_APEX'];
		} catch (Exception e) {
			system.debug('ERROR: Email template for case comment notifications not found!');
		}

		list<Id> lstAccountIds = new list<Id>();
		list<Id> lstCaseIds = new list<Id>();
		for (Airline_Input__c ai : mapTriggerNew.values()) {
			lstAccountIds.add(ai.Airline__c);
			lstCaseIds.add(ai.Parent_Case__c);
		}

		map<Id, Account> mapRelatedAccountsPerId = new map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :lstAccountIds]);
		map<Id, Case> mapRelatedCasesPerId = new map<Id, Case>([SELECT Id, Owner.Email, CaseNumber, Subject FROM Case WHERE Id IN :lstCaseIds]);

		for (Airline_Input__c ai : mapTriggerNew.values()) {
			if ( ai.Airline_Input__c != null &&
				( ( isUpdate && mapTriggerOld.get(ai.Id).Airline_Input__c != ai.Airline_Input__c ) ||
					isInsert ) ) {

				CaseComment cc = new CaseComment();
				cc.ParentId = ai.Parent_Case__c;

				String tempStr = mapRelatedAccountsPerId.get(ai.Airline__c).Name + ' input - ' + ai.Airline_Input__c;
				cc.CommentBody = tempStr.length() > 4000 ? tempStr.substring(0,4000) : tempStr;

				lstCommentsToInsert.add(cc);

				if (template != null ) {
					Case rc = mapRelatedCasesPerId.get(ai.Parent_Case__c);
					// build the notification email to be sent to the case owner
					String body = template.Body.replace('{!Case.Subject}', rc.Subject);
					body = body.replace('{!Case.CaseNumber}', rc.CaseNumber);
					body = body.replace('{!Case.Last_Case_Comment}', cc.CommentBody);
					body = body.replace('{!Case.Link}', 'https://iata.my.salesforce.com/' + rc.Id);

					Messaging.SingleEmailMessage notif = new Messaging.SingleEmailMessage();
					notif.setTargetObjectId(rc.OwnerId);
					notif.setPlainTextBody(body );
					notif.setSubject(template.subject.replace('{!Case.Subject}', rc.Subject).replace('{!Case.CaseNumber}', rc.CaseNumber));
					notif.saveAsActivity = false;

					lstNotificationEmails.add(notif);
				}
			}
		}

		if ( !lstCommentsToInsert.isEmpty() ) {

			insert lstCommentsToInsert;
			if (template != null ) {
				Messaging.SendEmailResult [] r = Messaging.sendEmail(lstNotificationEmails, false);

				/*system.debug('r size: ' + r.size());
				for(integer i=0; i<r.size(); i++){
				   system.debug('Send email result ' + i + ': ' + r[i].isSuccess() + '; Errors: ' + (r[i].getErrors().isEmpty() ? 'no errors' : r[i].getErrors()[0].getMessage()));
				}*/
			}
		}
	}
}
