@IsTest
private class AirportISServiceTest {
	@TestSetup
	static void makeData(){
		List<Account> accountList = TestDataFactory_Accounts.createDefaultAccounts(1);
		insert accountList;
		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(2);
		contactList.get(0).AccountId = accountList.get(0).Id;
		contactList.get(1).AccountId = accountList.get(0).Id;
		insert contactList;
		insert TestDataFactory_PortalApplications.createDefaultPortalApplication(1);		
	}

	@IsTest
	static void fakeMethod(){
		AirportISService airportISService = new AirportISService();
		airportISService.fakemethod();
	}

	@IsTest
	static void testManageUserOnboarding(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);
		Test.stopTest();

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();

		PortalServiceAccessService.PortalServiceAccess portalServiceAccess1 = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess1.functionalRoleName = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		portalServiceAccess1.contact = contact;
		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccessList.add(portalServiceAccess1);

		PortalServiceAccessService.PortalServiceAccess portalServiceAccess2 = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess2.functionalRoleName = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		portalServiceAccess2.contact = contact2;
		portalServiceAccess2.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccessList.add(portalServiceAccess2);

		//test onboarding
		AirportISService.manageUserOnboarding(portalServiceAccessList);

		//test contact role assignment
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(AirportISService.FUNCTIONALROLE, new Set<Id>{contact.Id, contact2.Id});
		System.assertEquals(2, accountContactRoleMap.size(), 'Expected 2 Account Contact Roles');
		//test account role assignment
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, AirportISService.FUNCTIONALROLE);
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
	}

	@IsTest
	static void testManageUserOffboarding(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		AccountRoles accountRoles = new AccountRoles();

		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess1 = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess1.functionalRoleName = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		portalServiceAccess1.contact = contact;
		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccessList.add(portalServiceAccess1);
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess2 = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess2.functionalRoleName = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		portalServiceAccess2.contact = contact2;
		portalServiceAccess2.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccessList.add(portalServiceAccess2);
		//test onboarding
		AirportISService.manageUserOnboarding(portalServiceAccessList);
		Test.stopTest();

		portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSDENIED;
		portalServiceAccessList.add(portalServiceAccess1);
		//test offboarding
		AirportISService.manageUserOnboarding(portalServiceAccessList);
		//test account contact role unassignment
		List<Account_Contact_Role__c> activeAccountContactRoleList = [SELECT Id FROM Account_Contact_Role__c WHERE Status__c = :accountContactRoles.STATUSACTIVE];
		System.assertEquals(1, activeAccountContactRoleList.size(), 'There should still be 1 Contact with an active role');
		List<Account_Role__c> accountRoleList = [SELECT Id FROM Account_Role__c];
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
		
		portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		portalServiceAccess2.accessStatus = portalApplicationRights.ACCESSDENIED;
		portalServiceAccessList.add(portalServiceAccess2);
		AirportISService.manageUserOnboarding(portalServiceAccessList);

		activeAccountContactRoleList = [SELECT Id FROM Account_Contact_Role__c WHERE Status__c = :accountContactRoles.STATUSACTIVE];
		System.assertEquals(0, activeAccountContactRoleList.size(), 'There should be no Contacts with an active role');
		//test account role unassignment
		accountRoleList = [SELECT Id FROM Account_Role__c WHERE Status__c = :accountRoles.STATUSACTIVE];
		System.assertEquals(0, accountRoleList.size(), 'Expected 0 Account Roles');
	}
}