@IsTest
private class PortalServiceAccessServiceTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(account.Id, 2);
		insert contactList;
		List<Portal_Applications__c> portalApplicationsList = TestDataFactory_PortalApplications.createDefaultPortalApplication(1);
		insert portalApplicationsList;	
	}

	@IsTest static void testProcessPortalServiceAccessService(){
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		portalServiceAccess.contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		portalServiceAccess.accessStatus = PortalApplicationRights.ACCESSGRANTED;

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>{portalServiceAccess};
		try {
			PortalServiceAccessService.processPortalServiceAccessService(portalServiceAccessList);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, 'PortalServiceAccessService.processPortalServiceAccessService caused an error');
		}
	}

	@IsTest
	static void testManageUserOnboarding(){
		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);
		Test.stopTest();

		//test onboarding
		PortalServiceAccessService.manageUserOnboarding(new Set<Contact>{contact, contact2}, PortalApplicationRights.ACCESSGRANTED, 'TEST ROLE');
		//test contact role assignment
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByServiceAndContactIdSet('TEST ROLE', new Set<Id>{contact.Id, contact2.Id});
		System.assertEquals(2, accountContactRoleMap.size(), 'Expected 2 Account Contact Roles');
		//test account role assignment
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, 'TEST ROLE');
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
		System.assertEquals(AccountRoles.STATUSACTIVE, accountRoleList.get(0).Status__c);
	}

	@IsTest
	static void testManageUserOffboarding(){
		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);
		PortalServiceAccessService.manageUserOnboarding(new Set<Contact>{contact, contact2}, PortalApplicationRights.ACCESSGRANTED, 'TEST ROLE');
		Test.stopTest();
		//test offboarding
		PortalServiceAccessService.manageUserOnboarding(new Set<Contact>{contact}, PortalApplicationRights.ACCESSDENIED,'TEST ROLE');
		//test account contact role unassignment
		List<Account_Contact_Role__c> accountContactRoleList = AccountContactRoleSelector.selectListByContactId(new Set<Id>{contact.Id, contact2.Id});
		Integer activeCount = 0;
		Integer inactiveCount = 0;

		for(Account_Contact_Role__c accountRole : accountContactRoleList){
			if(accountRole.Status__c.equals(AccountContactRoles.STATUSACTIVE))
				activeCount ++;
			else if(accountRole.Status__c.equals(AccountContactRoles.STATUSINACTIVE))
				inactiveCount ++;
		}
		System.assertEquals(1, activeCount, 'There should be 1 ACTIVE Account Contact Role');
		System.assertEquals(1, inactiveCount, 'There should be 1 INACTIVE Account Contact Role');
		
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, 'TEST ROLE');
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
		PortalServiceAccessService.manageUserOnboarding(new Set<Contact>{contact2}, PortalApplicationRights.ACCESSDENIED, 'TEST ROLE');
		accountContactRoleList = AccountContactRoleSelector.selectListByContactId(new Set<Id>{contact.Id, contact2.Id});
		activeCount = 0;
		inactiveCount = 0;

		for(Account_Contact_Role__c accountRole : accountContactRoleList){
			if(accountRole.Status__c.equals(AccountContactRoles.STATUSACTIVE))
				activeCount ++;
			else if(accountRole.Status__c.equals(AccountContactRoles.STATUSINACTIVE))
				inactiveCount ++;
		}
		System.assertEquals(0, activeCount, 'There should be 0 ACTIVE Account Contact Role');
		System.assertEquals(2, inactiveCount, 'There should be 2 INACTIVE Account Contact Role');
		
		//test account role unassignment
		accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, 'TEST ROLE');
		System.assertEquals(AccountRoles.STATUSINACTIVE, accountRoleList.get(0).Status__c, 'Expected 1 INACTIVE Account Roles');
	}
}