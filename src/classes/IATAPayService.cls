public with sharing class IATAPayService {
	public static final String FUNCTIONALROLE = 'IATA Pay';

	public static void manageUserOnboarding (Set<Contact> contactSet, String accessStatus){
		final Portal_Applications__c portalApplication;
		if(Test.isRunningTest()){
			portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
			portalApplication.Auto_grant_Account_Role__c = TRUE;
			portalApplication.Functional_Role__c = FUNCTIONALROLE;
		}else
			portalApplication = PortalApplicationSelector.selectAutoGrantAccountRoleByFunctionalRole(new Set<String>{FUNCTIONALROLE}).get(0);
		
		//create contact Id, Contact map
		Map<Id, Contact> inputContactIdMap = new Map<Id, Contact>();
		for(Contact contact : contactSet)
			inputContactIdMap.put(contact.Id, contact);

		//get assigned roles for input contacts
		List<Account_Contact_Role__c> accountContactRoleList = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(FUNCTIONALROLE, inputContactIdMap.keySet()).values();

		if(accessStatus.equals(PortalApplicationRights.ACCESSGRANTED)){
			//remove contact ids from input map if they already have a role assigned
			for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
				if(inputContactIdMap.containsKey(accountContactRole.Contact__c))
					inputContactIdMap.remove(accountContactRole.Contact__c);
			}

			//create a unique set of Accounts from contacts requiring contact role assignment
			Set<Id> inputAccountIdSet = new Set<Id>();
			for(Contact contact : inputContactIdMap.values()){
				inputAccountIdSet.add(contact.AccountId);
			}

			// get account roles already assigned for inputAccountIdSet
			List<Account_Role__c> accountRoleList = AccountRoleSelector.selectAccountIdByAccountsAndRole(inputAccountIdSet, FUNCTIONALROLE);
			// create map<Id,Id> of accountIdAccountRoleIdMap
			Map<Id,Id> accountIdAccountRoleIdMap = new Map<Id,Id>();
			//remove accounts with role already assigned
			for(Account_Role__c accountRole : accountRoleList){
				accountIdAccountRoleIdMap.put(accountRole.Account__c, accountRole.Id);
				if(inputAccountIdSet.contains(accountRole.Account__c))
					inputAccountIdSet.remove(accountRole.Account__c);
			}
			
			//throw error if there are accounts that need role assigned but service doesn't allow auto granting of the role
			if(portalApplication.Auto_grant_Account_Role__c != true && inputAccountIdSet.size() > 0)
				throw new IATAPayServiceException('Cannot grant Account Role because Service is configure not to auto grant account role');
			
			SavePoint savePoint = Database.setSavePoint();
			try{
				//assign account roles in inputAccountIdSet set<Id>
				AccountRoles accountRoles = new AccountRoles();
				accountRoleList = accountRoles.assignRole(inputAccountIdSet, FUNCTIONALROLE);
				
				insert accountRoleList;

				//add roles to accountIdAccountRoleIdMap
				for(Account_Role__c accountRole : accountRoleList){
					accountIdAccountRoleIdMap.put(accountRole.Account__c, accountRole.Id);
				}

				//assign account contact roles in inputContactIdMap Map<Id, Contact>
				AccountContactRoles accountContactRoles = new AccountContactRoles();
				accountContactRoleList = accountContactRoles.assignRole(inputContactIdMap.values(), FUNCTIONALROLE, accountIdAccountRoleIdMap);

				insert accountContactRoleList;
			}
			catch(Exception e){
				Database.rollback(savePoint);
				throw new IATAPayServiceException('Error inserting roles', e);
			}
		} else if(accessStatus.equals(PortalApplicationRights.ACCESSDENIED)){			
			//remove contact from input contact may if they do not already have a role assigned
			for(Contact contact : inputContactIdMap.values()){
				boolean alreadyAssigned = false;
				for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
					if(accountContactRole.Contact__c.equals(contact.Id)){
						alreadyAssigned = TRUE;
						break;
					}
				}
				if(!alreadyAssigned){
					inputContactIdMap.remove(contact.Id);
				}
			}
			SavePoint savePoint = Database.setSavePoint();
			try{
				//assign account contact roles in inputContactIdMap Map<Id, Contact>
				AccountContactRoles accountContactRoles = new AccountContactRoles();
				accountContactRoleList = accountContactRoles.unassignRole(inputContactIdMap.values(), FUNCTIONALROLE);
				delete accountContactRoleList;

				//check if there are no more contacts on account for same functional role
				//if the service is auto grant account role and there are no more contacts with the role
				//the account role must be deleted
				if(portalApplication.Auto_grant_Account_Role__c == true){
					//create a unique set of Accounts from contacts that had role unassigned
					Set<Id> inputAccountIdSet = new Set<Id>();
					for(Contact contact : inputContactIdMap.values()){
						inputAccountIdSet.add(contact.AccountId);
					}

					//get map account Id, account contact role for each input account
					Map<Id, Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByAccountIdSetAndFunctionalRole(inputAccountIdSet, FUNCTIONALROLE);

					for(Id accountId : accountContactRoleMap.keySet()){
						if(inputAccountIdSet.contains(accountId))
							inputAccountIdSet.remove(accountId);
					}
					AccountRoles accountRoles = new AccountRoles();
					delete accountRoles.unAssignRole(inputAccountIdSet, FUNCTIONALROLE);
				}
			}
			catch(Exception e){
				Database.rollback(savePoint);
				throw new IATAPayServiceException('Error inserting roles', e);
			}
		}
	}

	public class IATAPayServiceException extends Exception{}
}