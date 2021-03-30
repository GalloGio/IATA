public with sharing class PortalServiceAccessService {

	private static Portal_Applications__c getPortalApplication(String functionalRole){
		Portal_Applications__c portalApplication;
		if(Test.isRunningTest()){
			portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
			portalApplication.Auto_grant_Account_Role__c = TRUE;
			portalApplication.Functional_Role__c = functionalRole;

		}else
			portalApplication = PortalApplicationSelector.selectAutoGrantAccountRoleByFunctionalRole(new Set<String>{functionalRole}).get(0);
		return portalApplication;
	}

	public static void manageUserOnboarding (Set<Contact> contactSet, String accessStatus, String functionalRole){
		final Portal_Applications__c portalApplication = getPortalApplication(functionalRole);

		//create contact Id, Contact map from set<contact>
		Map<Id, Contact> inputContactIdMap = new Map<Id, Contact>();
		for(Contact contact : contactSet)
			inputContactIdMap.put(contact.Id, contact);

		//get assigned roles for input contacts
		List<Account_Contact_Role__c> accountContactRoleList = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(functionalRole, inputContactIdMap.keySet()).values();	
		if(accessStatus.equals(PortalApplicationRights.ACCESSGRANTED)){
			//get contact ids that need contact roles created == inputContactIdMap
			for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
				inputContactIdMap.remove(accountContactRole.Contact__c);
			}
			
			//need to get account roles before contact roles can be created
			//get existing account roles for all contactSet
			Set<Id> accountIdSet = new Set<Id>();
			for(Contact contact : contactSet){
				accountIdSet.add(contact.AccountId);
			}

			List<Account_Role__c> existingAccountRoleList = new List<Account_Role__c>();
			//get account roles that need to be created = accountIdSet
			for(Account_Role__c accountRole : AccountRoleSelector.selectByAccountIdSetAndRole(accountIdSet, functionalRole)){
				if(accountIdSet.contains(accountRole.Account__c)){
					accountIdSet.remove(accountRole.Account__c);
					existingAccountRoleList.add(accountRole);
				}
			}

			//if service does NOT allow auto account role management (accountIdSet contains the Account Ids that need account roles created)
			//	throw error
			if(portalApplication.Auto_grant_Account_Role__c != true && accountIdSet.size() > 0)
				throw new PortalServiceAccessServiceException('Cannot grant Account Role because Service is configured not to auto grant account role');

			//create account roles
			AccountRoles accountRoles = new AccountRoles();
			//add newly created account roles to the records list in accountRoles domain class
			List<Account_Role__c> newAccountRoles = accountRoles.create(accountIdSet, functionalRole);

			SavePoint savePoint = Database.setSavePoint();
			try{
				//add existing account roles to the records list in the accountRoles domain class
				accountRoles.records.addAll(existingAccountRoleList);
				//activate and upsert both new and created account roles
				upsert accountRoles.activate();
				//create map of account id and account role id (needed to upsert contact roles)
				Map<Id, Id> accountIdAccountRoleIdMap = new Map<Id, Id>();
				for(Account_Role__c accountRole : accountRoles.records){
					accountIdAccountRoleIdMap.put(accountRole.Account__c, accountRole.Id);
				}

				//create contact roles that don't exist	
				AccountContactRoles accountContactRoles = new AccountContactRoles();
				List<Account_Contact_Role__c> newAccountContactRoleList = accountContactRoles.create(new Set<Contact>(inputContactIdMap.values()), functionalRole, accountIdAccountRoleIdMap);			
				accountContactRoles.records.addAll(accountContactRoleList);
				upsert accountContactRoles.activate();
			}catch(Exception e){
				Database.rollback(savePoint);
				throw new PortalServiceAccessServiceException('Error inserting roles', e);
			}
		} else if(accessStatus.equals(PortalApplicationRights.ACCESSDENIED)){					
			//create map <contact Id> using accountContactRoleList
			Set<Id> contactWithRolesIdSet = new Set<Id>();
			for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
				contactWithRolesIdSet.add(accountContactRole.Contact__c);
			}

			//remove contact from input contact map if they do not have a role assigned (nothing to remove)
			for(Contact contact : inputContactIdMap.values()){
				if(!contactWithRolesIdSet.contains(contact.Id))
					inputContactIdMap.remove(contact.Id);
			}

			SavePoint savePoint = Database.setSavePoint();
			try{
				String activeAccountContactRole = AccountContactRoles.STATUSACTIVE;
				AccountContactRoles accountContactRoles = new AccountContactRoles(accountContactRoleList);
				accountContactRoleList = accountContactRoles.inactivate();
				upsert accountContactRoleList;

				//check if there are no more contacts on account for same functional role
				//if the service is auto grant account role and there are no more contacts with the role
				//the account role must be inactivated
				if(portalApplication.Auto_grant_Account_Role__c == true){
					//create a unique set of Accounts from contacts that had role unassigned
					Set<Id> inputAccountIdSet = new Set<Id>();
					for(Contact contact : inputContactIdMap.values()){
						inputAccountIdSet.add(contact.AccountId);
					}

					//get a unique set of accounts for contacts that were inactivated == inputAccountIdSet
					//get the related account contact roles
					Map<Id, Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByAccountIdSetAndFunctionalRole(inputAccountIdSet, functionalRole);

					for(Account_Contact_Role__c accountContactRole : accountContactRoleMap.values()){
						if(accountContactRole.Status__c.equals(activeAccountContactRole)){
							inputAccountIdSet.remove(accountContactRole.Contact__r.AccountId);
							break;
						}
					}
					List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(inputAccountIdSet, functionalRole);
					AccountRoles accountRoles = new AccountRoles(accountRoleList); 
					accountRoleList = accountRoles.inactivate();
					update accountRoleList;
				}
			}
			catch(Exception e){
				Database.rollback(savePoint);
				throw new PortalServiceAccessServiceException('Error inserting roles', e);
			}
		}
	}

	//must be called with individual List<PortalServiceAccess> per combination of FunctionalRole AND Access Status
	//e.g. List<PortalServiceAccess> grantAccessToServiceX 
	//do not use a list with different values for FunctionalRole and Access Status
	//these must be the same for each PortaServiceAccess in the list
	@InvocableMethod(label='Portal Service Access' description='Manages Portal Service Access Operations' category='Portal Services Access')
	public static void processPortalServiceAccessService(List<PortalServiceAccess> portalServiceAccessList){
		if(portalServiceAccessList == null || portalServiceAccessList.isEmpty())
			throw new PortalServiceAccessServiceException('Portal Service Access List not specified');
		
		//get the portal service (functional role)
		String functionalRoleName = portalServiceAccessList.get(0).functionalRoleName;
		//get the operation to be performed (e.g. access granted)
		String accessStatus = portalServiceAccessList.get(0).accessStatus;
		//populate set of contacts
		Set<Contact> contactSet = new Set<Contact>();
		for(PortalServiceAccess portalServiceAccess : portalServiceAccessList){
			contactSet.add(portalServiceAccess.contact);
		}

		if(functionalRoleName.equals(AirportISService.FUNCTIONALROLE)){
			try{
				AirportISService.manageUserOnboarding(contactSet, accessStatus);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + AirportISService.FUNCTIONALROLE, e);
			}
		} else if(functionalRoleName.equals(IATAPayService.FUNCTIONALROLE)){
			try{
				IATAPayService.manageUserOnboarding(contactSet, accessStatus);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + IATAPayService.FUNCTIONALROLE, e);
			}	
        } else if (functionalRoleName.equals(IGOMService.FUNCTIONALROLE)) {
            try{
				IGOMService.manageUserOnboarding(contactSet, accessStatus);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + IGOMService.FUNCTIONALROLE, e);
			}
        }
	}

	// represents a single contact for the functional role and access status specified
	// to bulkify, create seperate lists of PortalServiceAccess 
	// with the same functional role AND access status
	public class PortalServiceAccess {
		@InvocableVariable (label = 'Functional Role' required = true)
		public String functionalRoleName;
		@InvocableVariable (label = 'Access Status' required = true)
		public String accessStatus;
		@InvocableVariable (label = 'Contact' required = true)
		public Contact contact;
	}

	public class PortalServiceAccessServiceException extends Exception {}
}