global class ANG_ISSP_MailIEPStatusInProgressToOpen {
	@InvocableMethod
	public static void SendMailInProgressToOpen(List<SendMailInProgressToOpenRequest> requests) {

		Set<Id>accountIDsIepAux = new Set<Id>();
		for (SendMailInProgressToOpenRequest request : requests) {
			accountIDsIepAux.add(String.valueOf(request.accountId).substring(0, 15));
		}

		ID templateId = PortalServiceAccessTriggerHandler.getEmailTemplateIdByName(ENV.EmailTemplateData.ISSPChangeIEPStatusInProgressToOpen);

		Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPDefaultRoles();
        Map<String, Set<Id>> accIdToUserIdMapIep = ANG_ISSP_IEPMailRecipientsUtils.getRecipients(accountIDsIepAux, roles);

        // Send emails

		list<Messaging.SingleEmailMessage> msgList = new list<Messaging.SingleEmailMessage>();

		for (SendMailInProgressToOpenRequest request : requests) {

			String auxId = String.valueOf(request.accountId).substring(0, 15);

			Set<ID> portalAdminUserIDs = new Set<ID>();
			portalAdminUserIDs = accIdToUserIdMapIep.get(auxId);

			if(portalAdminUserIDs == null) {
				continue;
			}

	        for(ID userId : portalAdminUserIDs) {
	            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage(); 
	            emailMsg.setTemplateId(templateId);
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