public with sharing class IGOMService {
    
    public static final String FUNCTIONALROLE = 'IGOM';

	public static void manageUserOnboarding(Set<Contact> contactSet, String accessStatus) {
		SavePoint savePoint = Database.setSavePoint();

		Set<Id> contactIds = new Set<Id>();
		Set<Id> accountIds = new Set<Id>();
		for (Contact contact : contactSet) {
			contactIds.add(contact.Id);
			accountIds.add(contact.AccountId);
		}

		// Call the manageUserOnboarding on PortalServiceAccessService
		PortalServiceAccessService.manageUserOnboarding(contactSet, accessStatus, FUNCTIONALROLE);

		Map<Id, Account_Role__c> accountRoleIdToAccountRole = new Map<Id, Account_Role__c>(AccountRoleSelector.selectByAccountIdSetAndRole(accountIds, FUNCTIONALROLE));
		Map<Id, Account_Contact_Role__c> contactIdToContactRole = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(FUNCTIONALROLE, contactIds);

		if (accessStatus.equals(PortalApplicationRights.ACCESSGRANTED)) {

			// Get the new account roles, to create account roles and grant admin on these
			Map<Id, Account_Role__c> accountIdToAccountRole = new Map<Id, Account_Role__c>();
			for (Account_Role__c accountRole : accountRoleIdToAccountRole.values()) {
				accountIdToAccountRole.put(accountRole.Account__c, accountRole);
			}

			// Query all the account role details (created and new ones)
			Map<Id, IGOM_Account_Role_Detail__c> accountRoleIdToAccountRoleDetail = new Map<Id, IGOM_Account_Role_Detail__c>();
			Set<Id> newAccountRoleIds = new Set<Id>(accountRoleIdToAccountRole.keySet());
			for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__c FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c = :(accountRoleIdToAccountRole.keySet())]) {
				accountRoleIdToAccountRoleDetail.put(accountRoleDetail.Account_Role__c, accountRoleDetail);
				newAccountRoleIds.remove(accountRoleDetail.Account_Role__c);
			}

			// Create the detail records
			try{
				// Create the IGOM Account Role Details when needed
				List<IGOM_Account_Role_Detail__c> accountRoleDetails = new List<IGOM_Account_Role_Detail__c>();

				for (Id accountRoleId : newAccountRoleIds) {
					final IGOM_Account_Role_Detail__c accountRoleDetail = new IGOM_Account_Role_Detail__c(
						Account_Role__c = accountRoleId
					);
					accountRoleDetails.add(accountRoleDetail);
					accountRoleIdToAccountRoleDetail.put(accountRoleId, accountRoleDetail);
				}
				
				insert accountRoleDetails;

				// Create the IGOM Contact Role Details
				List<IGOM_Contact_Role_Detail__c> contactRoleDetails = new List<IGOM_Contact_Role_Detail__c>();

				for(Account_Contact_Role__c accountContactRole : contactIdToContactRole.values()) {
					final IGOM_Account_Role_Detail__c relatedAccountRoleDetail = accountRoleIdToAccountRoleDetail.get(accountContactRole.Account_Role__c);
					contactRoleDetails.add(new IGOM_Contact_Role_Detail__c(
						Account_Contact_Role__c = accountContactRole.Id,
						Account_Role_Detail__c = relatedAccountRoleDetail.Id,
						Role__c = newAccountRoleIds.contains(relatedAccountRoleDetail.Account_Role__c) ? IGOMConstants.ROLES.ADMIN : null
					));
				}

				insert contactRoleDetails;

			} catch(Exception e) {
				Database.rollback(savePoint);
				throw new IGOMServiceException('Error creating detail roles', e);
			}
		} else if (accessStatus.equals(PortalApplicationRights.ACCESSDENIED)) {

			try {
				// Remove all the contact's role details
				// Remove the account role details if they don't have any contact assigned (the last user(s) left)
				List<IGOM_Account_Role_Detail__c> accountRoleDetailsToDelete = new List<IGOM_Account_Role_Detail__c>();
				List<IGOM_Contact_Role_Detail__c> contactRoleDetailsToDelete = new List<IGOM_Contact_Role_Detail__c>();
				for (IGOM_Account_Role_Detail__c accountRoleDetail : 
					 [SELECT Id, 
					 	(SELECT Id, Account_Contact_Role__r.Contact__c 
						FROM IGOM_Contact_Role_Details__r) 
					 FROM IGOM_Account_Role_Detail__c 
					 WHERE Account_Role__r.Account__c IN :accountIds]) 
				{
					Boolean accountRoleIsEmpty = true;
					for (IGOM_Contact_Role_Detail__c contactRoleDetail : accountRoleDetail.IGOM_Contact_Role_Details__r) {
						if (contactIds.contains(contactRoleDetail.Account_Contact_Role__r.Contact__c)) {
							contactRoleDetailsToDelete.add(contactRoleDetail);
						} else {
							accountRoleIsEmpty = false;
						}
					}
					if (accountRoleIsEmpty) {
						accountRoleDetailsToDelete.add(accountRoleDetail);
					}
				}
				List<SObject> recordsToDelete = new List<SObject>();
				recordsToDelete.addAll(contactRoleDetailsToDelete);
				recordsToDelete.addAll(accountRoleDetailsToDelete);
				delete recordsToDelete;

			} catch(Exception e) {
				Database.rollback(savePoint);
				throw new IGOMServiceException('Error removing roles', e);
			}
			
		}

	}

	public class IGOMServiceException extends Exception {}

}