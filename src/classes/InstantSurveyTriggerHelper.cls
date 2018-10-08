public class InstantSurveyTriggerHelper {
	
	// Prevents the creation of more than one instant survey linked to the same case by
	// throwing an error on subsequent insertion attempts.
	public static void PreventMultipleSurveysOnSameCase(list<Instant_Surveys__c> triggerNew) {
		set<Id> setParentCasesIds = new set<Id>();
		for (Instant_Surveys__c is : triggerNew) {
			setParentCasesIds.add(is.Relationship_to_Case__c);
		}
		
		// get all current instant surveys related to these cases and put them in a map, per case
		map<Id, Instant_Surveys__c> mapInstantSurveysPerCaseId = new map<Id, Instant_Surveys__c>();
		set<String> setExceptedCaseRecordTypes = new set<String>{'Application_Change_Request_Salesforce'};
		for (Instant_Surveys__c is : [SELECT Id, Relationship_to_Case__c FROM Instant_Surveys__c WHERE Relationship_to_Case__c IN :setParentCasesIds AND Relationship_to_Case__r.RecordType.DeveloperName NOT IN :setExceptedCaseRecordTypes and recordType.developername != 'Live_Agent_Chat']) {
			mapInstantSurveysPerCaseId.put(is.Relationship_to_Case__c, is);
		}
		
		// check if the new surveys are added to cases with existing surveys; if so, save the email address to send a notification email to the contact 
		//set<String> setEmailsToReceiveNotification = new set<String>();
		for (Instant_Surveys__c is : triggerNew) {
			if (mapInstantSurveysPerCaseId.get(is.Relationship_to_Case__c) != null) {
				is.addError('The contact has already replied to the survey for this case.');
				
				/*
				if (is.X2015_Email__c != null) {
					setEmailsToReceiveNotification.add(is.X2015_Email__c);
				}*/
			} else {
				// add the new survey to the map, to cover the situation where there are several new surveys added to the same case in the same batch operation
				 mapInstantSurveysPerCaseId.put(is.Relationship_to_Case__c, is);
			}
		}
		
		
		// send notifications to the contacts
		/*
		if (!setEmailsToReceiveNotification.isEmpty()) {
			EmailTemplate et = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Instant_Surveys_Already_Replied'];
			OrgWideEmailAddress noreply = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply'];
			
			list<Messaging.SingleEmailMessage> lstNotificationEmails = new list<Messaging.SingleEmailMessage>();
			
			for (String email : setEmailsToReceiveNotification) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				
				mail.setOrgWideEmailAddressId(noreply.Id);
        		mail.setToAddresses(new String[] {email});
        		mail.setSubject(et.Subject);
        		mail.setHtmlBody(et.HtmlValue);
        		
        		lstNotificationEmails.add(mail);
			}
			
			Messaging.sendEmail(lstNotificationEmails);
		} */
	}
}