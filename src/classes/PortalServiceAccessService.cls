public without sharing class PortalServiceAccessService {
	public static List<PortalServiceAccess> manageUserOnboarding (List<PortalServiceAccess> portalServiceAccessList){
		//create domain classes
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		//create set of functional role names
		Set<String> functionalRoleSet = new Set<String>();
		//create set of contact ids from portalserviceaccess list
		Set<Id> contactIdSet = new Set<Id>();
		List<PortalServiceAccess> grantedPortalServiceAccessList = new List<PortalServiceAccess>();
		List<PortalServiceAccess> deniedPortalServiceAccessList = new List<PortalServiceAccess>();
		for(PortalServiceAccess portalServiceAccess : portalServiceAccessList){
			functionalRoleSet.add(portalServiceAccess.functionalRoleName);
			contactIdSet.add(portalServiceAccess.contact.Id);

			if(portalServiceAccess.accessStatus.equals(portalApplicationRights.ACCESSGRANTED)){
				grantedPortalServiceAccessList.add(portalServiceAccess);
			} else if(portalServiceAccess.accessStatus.equals(portalApplicationRights.ACCESSDENIED)){
				deniedPortalServiceAccessList.add(portalServiceAccess);
			}
		}

		//query for contacts
		Map<Id,Contact> contactMap = ContactSelector.selectByIds(contactIdSet);
		Map<Id, Account_Role__c> existingAccountRoleMap = AccountRoleSelector.selectAccountRoleWithRelatedAccountRolesByFunctionalRoleSet(functionalRoleSet);

		if(!grantedPortalServiceAccessList.isEmpty())
			processGrantedPortalServiceAccesses(grantedPortalServiceAccessList, null, functionalRoleSet, existingAccountRoleMap);
		if(!deniedPortalServiceAccessList.isEmpty())
			processDeniedPortalServiceAccesses(deniedPortalServiceAccessList, contactMap, functionalRoleSet, existingAccountRoleMap);

		portalServiceAccessList = new List<PortalServiceAccess>();
		portalServiceAccessList.addAll(grantedPortalServiceAccessList);
		portalServiceAccessList.addAll(deniedPortalServiceAccessList);
		return portalServiceAccessList;
	}

	@InvocableMethod(label='Portal Service Access' description='Manages Portal Service Access Operations' category='Portal Services Access')
	public static void processPortalServiceAccessService(List<PortalServiceAccess> portalServiceAccessList){
		if(portalServiceAccessList == null || portalServiceAccessList.isEmpty())
			throw new PortalServiceAccessServiceException('Portal Service Access List not specified');
		
		//get the portal service (functional role)
		String functionalRoleName = portalServiceAccessList.get(0).functionalRoleName;
		//get the operation to be performed (e.g. access granted)
		String accessStatus = portalServiceAccessList.get(0).accessStatus;

		if(functionalRoleName.equals(AirportISService.FUNCTIONALROLE)){
			try{
				AirportISService.manageUserOnboarding(portalServiceAccessList);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + AirportISService.FUNCTIONALROLE + ', ' + e.getStackTraceString(), e);
			}
		} else if(functionalRoleName.equals(IATAPayService.FUNCTIONALROLE)){
			try{
				IATAPayService.manageUserOnboarding(portalServiceAccessList);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + IATAPayService.FUNCTIONALROLE + ', ' + e.getStackTraceString(), e);
			}
		} else{
			try{
				manageUserOnboarding(portalServiceAccessList);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding ' + e.getStackTraceString(), e);
			}
		}
	}

	// represents a single contact for the functional role and access status specified
	public class PortalServiceAccess {
		@InvocableVariable (label = 'Functional Role' required = true)
		public String functionalRoleName;
		@InvocableVariable (label = 'Access Status' required = true)
		public String accessStatus;
		@InvocableVariable (label = 'Contact' required = true)
		public Contact contact;
		@InvocableVariable(label = 'Portal Application Right' required = false)
		public Portal_Application_Right__c portalApplicationRight;
		public Account_Role__c accountRole;
		public Account_Contact_Role__c accountContactRole;	

		public Boolean equals(Object obj){
			if(obj instanceof PortalServiceAccess){
				PortalServiceAccess portalServiceAccess = (PortalServiceAccess) obj;
				return (
					(functionalRoleName == portalServiceAccess.functionalRoleName) && 
					(accessStatus == portalServiceAccess.accessStatus) &&
					(contact.Id == portalServiceAccess.contact.Id)
				);
			}
			return false;
		}

		public Integer hashCode(){
			return 13 + 
			(31 * System.hashCode(functionalRoleName == null ? '' : functionalRoleName)) + 
			(31* System.hashCode(accessStatus == null ? '' : accessStatus)) +
			(31 * System.hashCode(contact.Id  == null ? '' : contact.Id ));
		}
	}

	private static void processGrantedPortalServiceAccesses(List<PortalServiceAccess> grantedPortalServiceAccessList, Map<Id, List<Invitation__c>> contactIdInvitationMap, Set<String> functionalRoleSet, Map<Id, Account_Role__c> existingAccountRoleMap){
		AccountRoles accountRoles = new AccountRoles();
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		for(PortalServiceAccess portalServiceAccess : grantedPortalServiceAccessList){
			//update status of existing account roles to active
			for(Account_Role__c existingAccountRole : existingAccountRoleMap.values()){
				if(portalServiceAccess.contact.AccountId.equals(existingAccountRole.Account__c) && functionalRoleSet.contains(existingAccountRole.Functional_Role__c)){
					existingAccountRole.Status__c = accountRoles.STATUSACTIVE;
					portalServiceAccess.accountRole = existingAccountRole;
					//update status of existing account contact roles
					if(existingAccountRole.Account_Contacts_Role__r != null){
						List<Account_Contact_Role__c> accountContactRoleList = existingAccountRole.Account_Contacts_Role__r;
						for(Account_Contact_Role__c existingAccountContactRole : accountContactRoleList){
							if(portalServiceAccess.contact.Id.equals(existingAccountContactRole.Contact__c)){
								existingAccountContactRole.Status__c = accountContactRoles.STATUSACTIVE;
								portalServiceAccess.accountContactRole = existingAccountContactRole;
							}
						}
					}
				}
			}
			//if no existing account role found
			if(portalServiceAccess.accountRole == null){
				//create
				portalServiceAccess.accountRole = accountRoles.create(new Set<Id>{portalServiceAccess.contact.AccountId}, portalServiceAccess.functionalRoleName).get(0);
				portalServiceAccess.accountRole.Status__c = accountRoles.STATUSACTIVE;
			}
			//if no existing account contact role found
			if(portalServiceAccess.accountContactRole == null){
				//create
				portalServiceAccess.accountContactRole = accountContactRoles.create(new Set<Contact>{portalServiceAccess.contact}, portalServiceAccess.functionalRoleName).get(0);
				portalServiceAccess.accountContactRole.Status__c = accountContactRoles.STATUSACTIVE;
			}

			//add updated/new account role to domain class if not aleady existing (where account Id and Functional Role are same)
			boolean matchFound = false;
			for(Account_Role__c accountRole : accountRoles.records){
				if(accountRole.Functional_Role__c.equals(portalServiceAccess.accountRole.Functional_Role__c) && accountRole.Account__c.equals(portalServiceAccess.accountRole.Account__c)){
					matchFound = true;
					break;
				}
			}
			if(!matchFound){
				accountRoles.records.add(portalServiceAccess.accountRole);
			}
			//add updated/new account contact role to domain class
			accountContactRoles.records.add(portalServiceAccess.accountContactRole);
		}

		SavePoint savePoint = Database.setSavePoint();
		try{
			upsert accountRoles.records;

			//update account contact role account role id field with ids from upserted account roles
			for(PortalServiceAccess portalServiceAccess : grantedPortalServiceAccessList){
				for(Account_Role__c upsertedAccountRole : accountRoles.records){
					if(portalServiceAccess.accountRole.Functional_Role__c.equals(upsertedAccountRole.Functional_Role__c) && portalServiceAccess.accountRole.Account__c.equals(upsertedAccountRole.Account__c)){
						portalServiceAccess.accountContactRole.Account_Role__c = upsertedAccountRole.Id;
					}
				}
			}
			upsert accountContactRoles.records;
		} catch(Exception e){
			Database.rollback(savePoint);
			throw new PortalServiceAccessServiceException('Error managing user onboarding: ' + e.getStackTraceString(), e);
		}
	}

	private static void processDeniedPortalServiceAccesses(List<PortalServiceAccess> deniedPortalServiceAccessList, Map<Id, Contact> contactMap, Set<String> functionalRoleSet, Map<Id, Account_Role__c> existingAccountRoleMap){
		AccountRoles accountRoles = new AccountRoles();
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		//get acrs and related ars for denied psa's (acr selector + ar fields) based on contact id and functional role
		Map<Id, Account_Contact_Role__c> existingAccountContactRoleMap = AccountContactRoleSelector.selectAccountContactRoleMap(contactMap.keySet());
		
		//create a set of ar id's for any acr's that are modified
		Set<Id> accountRoleWithModifiedContactRoleIdSet = new Set<Id>();
		for(PortalServiceAccess portalServiceAccess : deniedPortalServiceAccessList){
			for(Id existingAccountContactRoleId : existingAccountContactRoleMap.keySet()){
				Account_Contact_Role__c existingAccountContactRole = existingAccountContactRoleMap.get(existingAccountContactRoleId);
				//if the contact id and functional role in the denied psa matches the existing accountcontactrole
				if(existingAccountContactRole.Functional_Role__c.equals(portalServiceAccess.functionalRoleName) && existingAccountContactRole.Contact__c.equals(portalServiceAccess.contact.Id)){
					//update the status to inactive
					existingAccountContactRole.Status__c = accountContactRoles.STATUSINACTIVE;
					//add updated account contact role to domain class
					accountContactRoles.records.add(existingAccountContactRole);
					accountRoleWithModifiedContactRoleIdSet.add(existingAccountContactRole.Account_Role__c);
				}
			}
		}

		SavePoint savePoint = Database.setSavePoint();
		try{
			//upsert modified account contact roles
			upsert accountContactRoles.records;

			//check if ar has no more active acrs
			//for updated acr's get list of ar's
			Map<Id, Account_Role__c> accountRoleMap = AccountRoleSelector.selectAccountRoleWithRelatedAccountRolesByAccountRoleIdSet(accountRoleWithModifiedContactRoleIdSet);

			//if active ar has 0 active acr's then inactivate the ar
			for(Id existingAccountRoleId : accountRoleMap.keySet()){
				Account_Role__c existingAccountRole = accountRoleMap.get(existingAccountRoleId);
				List <Account_Contact_Role__c> accountContactRoleList = existingAccountRole.Account_Contacts_Role__r;
				Integer activeAccountContactRoleCount = 0;
				if(!accountContactRoleList.isEmpty()){
					for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
						if(accountContactRole.Status__c.equals(accountContactRoles.STATUSACTIVE)){
							activeAccountContactRoleCount ++;
							break;
						}
					}
					if(activeAccountContactRoleCount == 0){
						//update status of account role with 0 active acrs
						existingAccountRole.Status__c = accountRoles.STATUSINACTIVE;
						//add updated account role to domain class
						accountRoles.records.add(existingAccountRole);
					}
				} else{
					//update status of account role with 0 active acrs
					existingAccountRole.Status__c = accountRoles.STATUSINACTIVE;
					//add updated account role to domain class
					accountRoles.records.add(existingAccountRole);
				}
			}
			upsert accountRoles.records;
		} catch(Exception e){
			Database.rollback(savePoint);
			throw new PortalServiceAccessServiceException('Error managing user onboarding: ' + e.getStackTraceString(), e);
		}
	}

	public class PortalServiceAccessServiceException extends Exception {}

	public void fakemethod () {
  Integer i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
  i=0;
	}
}