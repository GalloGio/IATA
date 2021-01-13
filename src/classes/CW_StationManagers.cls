public without sharing class CW_StationManagers {

	@AuraEnabled(cacheable = false)
	public static string getAllAccountContactRoles(String accountRoleDetailId){
		return (JSON.serialize(CW_Utilities.getStationManagersContactRoleDetails(accountRoleDetailId)));
	}

	@AuraEnabled(cacheable = false)
	public static string deleteAccountContactRole(String contactRoleDetailId, Boolean isCompanyAdmin){
		try {
			List<String> notificationReceiversCA = new List<String>();
			List<String> notificationReceiversRequestor = new List<String>();
			List<String> notificationReceiversIATA = new List<String>();

			String status =  isCompanyAdmin ? 'Removed' : 'Pending for Removal';
			ICG_Contact_Role_Detail__c cRd = [Select Id, ContactId__c, status__c, Contact_Role_Remove_Requestor__c, Account_Contact_Role__r.Contact__r.Email, ICG_Account_Role_Detail__r.Account_Role__r.Account__c from ICG_Contact_Role_Detail__c where Id=:contactRoleDetailId];  
			cRd.status__c = status;
			cRd.Contact_Role_Remove_Requestor__c = UserInfo.getUserId();
			upsert cRd;

			if(status.equals('Pending for Removal')){
				List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();

				String templateName;

				//Send remove confirmation to removed station manager
				String subject = 'Station Manager removal request sent';
				templateName = 'Station_Manager_to_requestor_req_sent';
				Set<Id> whoEmails = new Set<Id>{cRd.Account_Contact_Role__r.Contact__c};
				for(Id ca : whoEmails){
					notificationReceiversRequestor.add(ca);
				}
				emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateName, cRd.Id, whoEmails));
				CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested', notificationReceiversRequestor, cRd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);

				//Send remove confirmation to CompanyAdmins
				subject = 'New request to REMOVE Station Manager rights pending approval';
				templateName = 'Approve_Reject_Remov_to_comp_adm';
				Set<Id> whoIdsCompanyAdmins = CW_EmailManager.getCompanyAdminsIds(cRd.ICG_Account_Role_Detail__r.Account_Role__r.Account__c);
				for(Id ca : whoIdsCompanyAdmins){
					notificationReceiversCA.add(ca);
				}
				emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateName, cRd.Id, whoIdsCompanyAdmins));
				CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested',notificationReceiversCA, cRd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);


				if(whoIdsCompanyAdmins.isEmpty()){
					//Send remove confirmation to IATA
					templateName = 'Approve_Reject_Remov_to_IATA_no_comp_adm';
					emailsToBeSent.addAll(CW_EmailManager.prepareInternalEmails(templateName, cRd.Id, CW_EmailManager.getIataAdminsIds()));

					//Send notifications
					for(Id iata :  CW_EmailManager.getIataAdminsIds()){
						notificationReceiversIATA.add(iata);
					}
					CW_NotificationsController.setNotificationCustom(subject, subject, 'Requested',notificationReceiversIATA, cRd.ICG_Account_Role_Detail__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA);
				}

				CW_EmailManager.sendInternalEmails(emailsToBeSent);
			}

			return status;
		} catch (Exception  exc) {
			throw new AuraHandledException('exception: ' + exc);
		} 
	}


	@AuraEnabled(cacheable = true)
	public static string getContactsToAdd(String stationId){
		Set<Id> relatedAccounts = CW_Utilities.getRelatedAccountsByStation(stationId);
		List<Contact> contacts = [Select Id, Name from Contact WHERE AccountId in :relatedAccounts];
		return JSON.serialize(contacts);
	}

}