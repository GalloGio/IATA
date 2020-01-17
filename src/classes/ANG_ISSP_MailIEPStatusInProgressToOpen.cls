global class ANG_ISSP_MailIEPStatusInProgressToOpen {
	@InvocableMethod
	public static void SendMailInProgressToOpen(List<SendMailInProgressToOpenRequest> requests) {

		final Set<String> models = new Set<String>{'Model A','Model B'};
		Id templateIdA;
		Id templateIdB;

		Set<Id>accountIDsIepAux = new Set<Id>();
		for (SendMailInProgressToOpenRequest request : requests) {
			accountIDsIepAux.add(String.valueOf(request.accountId).substring(0, 15));
		}

		Map<Id,Account> accsMap = new Map<Id,Account> ([SELECT Id, IATA_Iso_country__r.ANG_IEP_Model__c FROM Account WHERE Id IN :accountIDsIepAux AND IATA_Iso_country__r.ANG_IEP_Model__c IN :models]);
		Set<String> existingModels = new Set<String>();

		// we need to know which templates
		for(Account a : accsMap.values()){
			existingModels.add(a.IATA_ISo_country__r.ANG_IEP_Model__c);
			if(existingModels.size() == models.size()) break;
		}

		if(existingModels.contains('Model A'))
			templateIdA = PortalServiceAccessTriggerHandler.getEmailTemplateIdByName(ENV.EmailTemplateData.ISSPChangeIEPStatusInProgressToOpenA);
		if(existingModels.contains('Model B'))
			templateIdB = PortalServiceAccessTriggerHandler.getEmailTemplateIdByName(ENV.EmailTemplateData.ISSPChangeIEPStatusInProgressToOpen);

		Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPDefaultRoles();
		Map<String, Set<Id>> accIdToUserIdMapIepAux = ANG_ISSP_IEPMailRecipientsUtils.getRecipients(accountIDsIepAux, roles);

		Set<Id> allUserIds = new Set<Id>();
		for(Set<Id> idsPerAccount : accIdToUserIdMapIepAux.values())
			allUserIds.addAll(idsPerAccount);

		Map<Id,User> accIdToUserIdMapIep = new Map<Id,User>([SELECT Id FROM User WHERE isActive = true AND Contact.IsEmailBounced = false]);

		// Send emails

		list<Messaging.SingleEmailMessage> msgList = new list<Messaging.SingleEmailMessage>();

		for (SendMailInProgressToOpenRequest request : requests) {

			String auxId = String.valueOf(request.accountId).substring(0, 15);

			Set<ID> portalAdminUserIDs = new Set<ID>();
			portalAdminUserIDs = accIdToUserIdMapIepAux.get(auxId);

			if(portalAdminUserIDs == null) {
				continue;
			}

			for(ID userId : portalAdminUserIDs) {

				if(!accsMap.containsKey(auxId) || !accIdToUserIdMapIep.containsKey(userId)) continue;

				Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
				emailMsg.setTemplateId(accsMap.get(auxId).IATA_Iso_country__r.ANG_IEP_Model__c == 'Model A' ? templateIdA : templateIdB);
				emailMsg.setTargetObjectId(userId);
				emailMsg.saveAsActivity = false;
				emailMsg.setReplyTo(ENV.Reply_Email);
				emailMsg.setSenderDisplayName(ENV.AccessToApplicationServiceRequested_Email_Subject);

				msgList.add(emailMsg);
			}
		}

		if(!msgList.isEmpty()) {
			system.debug(LoggingLevel.ERROR, 'Emails sent --> ' + msgList.size());
			Messaging.sendEmail(msgList);
		} else {
			system.debug(LoggingLevel.ERROR, 'Emails not sent ! -->');
		}

	}

	global class SendMailInProgressToOpenRequest {
		@InvocableVariable(required=true)
		global ID accountId;
	}
}
