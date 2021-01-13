public without sharing class CW_EmailManager {
	
	/*
	 * @description		Prepare a list of emails to be sent
	 * @param			emailTemplateName <Name of template>
	 * @param			whatId <ID related object>
	 * @param			whoIds <Target Ids>
	 * @return			List of prepared emails
	*/
	public static List<Messaging.SingleEmailMessage> prepareInternalEmails(String emailTemplateName, Id whatId, Set<Id> whoIds){
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

		EmailTemplate emailTemplate;
		OrgWideEmailAddress orgWideEmailAddress;

		if(!whoIds.isEmpty()){
			List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply' LIMIT 1];
			List<EmailTemplate> templates = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];

			if(!orgWideEmailAddresses.isEmpty()){
				orgWideEmailAddress = orgWideEmailAddresses[0];
			}

			if(!templates.isEmpty()){
				emailTemplate = templates[0];
			}
		}

		if(emailTemplate != null && orgWideEmailAddress != null){
			for(Id whoId : whoIds){
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setTargetObjectId(whoId);
				message.setOrgWideEmailAddressId(orgWideEmailAddress.id);
				message.setTemplateID(emailTemplate.Id);
				message.setWhatId(whatId); //This is important for the merge fields in template to work
				if (!Test.isRunningTest()) {
					message.setSaveAsActivity(false);
				}	

				messages.add(message);
			}
		}

		return messages;
	}

	public static Boolean sendInternalEmails(Messaging.SingleEmailMessage[] messages){
		return sendInternalEmails(messages, false);
	}

	public static Boolean sendInternalEmails(Messaging.SingleEmailMessage[] messages, Boolean allOrNone){
		if(messages.isEmpty()){
			return false;
		}
		
		try {
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			Boolean success = true;
			for(Messaging.SendEmailResult result: results) {
				if(allOrNone == true){
					success &= result.success;
				}
				else{
					success = success || result.success;
				}
				
			}

			return success;

		} catch (EmailException exc) {
			return false;
		}
	}

	public static Set<Id> getIataAdminsIds(){
		Set<Id> ids = new Set<Id>();
		for (User u : CW_Utilities.getIATAStakeHoldersUsersList()) {
			ids.add(u.Id);
		}
			
		return ids;
	}

	public static Set<Id> getCompanyAdminsIds(String accountId){
		Set<Id> ids = new Set<Id>();

		List<Contact> contacts = !Test.isRunningTest() ? CW_Utilities.getCompanyAdminContactsFromAccountId(accountId) : [Select Id from Contact];

		for (Contact cadmn : contacts){
			ids.add(cadmn.Id);
		}

		return ids;
	}

}