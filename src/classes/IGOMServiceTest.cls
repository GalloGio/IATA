@IsTest
private class IGOMServiceTest {
	@TestSetup
	static void makeData() {
		List<Account> accountList = TestDataFactory_Accounts.createDefaultAccounts(1);
		insert accountList;
		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(2);
		contactList.get(0).AccountId = accountList.get(0).Id;
		contactList.get(1).AccountId = accountList.get(0).Id;
		insert contactList;
		insert TestDataFactory_PortalApplications.createDefaultPortalApplication(1);		
	}

	@IsTest
	static void testManageUserOnboardingOk() {
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);

		Test.startTest();

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

		IGOMService.manageUserOnboarding(portalServiceAccessList);

		Test.stopTest();

		// Contact role assignment
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = new Map<Id, Account_Contact_Role__c>(AccountContactRoleSelector.selectMapByServiceAndContactIdSet(IGOMService.FUNCTIONALROLE, new Set<Id>{contact.Id, contact2.Id}).values());
		System.assertEquals(2, accountContactRoleMap.size(), 'Expected 2 Account Contact Roles');
		// Contact detail assignment
		List<IGOM_Contact_Role_Detail__c> contactRoleDetailList = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__c IN :accountContactRoleMap.keySet()];
		System.assertEquals(2, contactRoleDetailList.size(), 'Expected 2 IGOM Contact Role Details');
		// Account role assignment
		Map<Id, Account_Role__c> accountRoleMap = new Map<Id, Account_Role__c>(AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, IGOMService.FUNCTIONALROLE));
		System.assertEquals(1, accountRoleMap.size(), 'Expected 1 Account Role');
		// Account detail assignment
		List<IGOM_Account_Role_Detail__c> accountRoleDetailList = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c IN :accountRoleMap.keySet()];
		System.assertEquals(1, accountRoleDetailList.size(), 'Expected 1 IGOM Account Role Detail');
	}

	@IsTest
	static void testManageUserOffboardingOk() {
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);

		Test.startTest();

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

		IGOMService.manageUserOnboarding(portalServiceAccessList);

		portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSDENIED;
		portalServiceAccessList.add(portalServiceAccess1);
		IGOMService.manageUserOnboarding(portalServiceAccessList);
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = new Map<Id, Account_Contact_Role__c>([SELECT Id, Account__c, Account_Role__c, Contact__c, Status__c FROM Account_Contact_Role__c WHERE Contact__c IN :(new Set<Id>{contact.Id, contact2.Id})]);
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, IGOMService.FUNCTIONALROLE);
		List<IGOM_Contact_Role_Detail__c> contactRoleDetailList = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__c IN :accountContactRoleMap.keySet()];
		List<IGOM_Account_Role_Detail__c> accountRoleDetailList = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c IN :accountRoleList];

		portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		portalServiceAccess2.accessStatus = portalApplicationRights.ACCESSDENIED;
		portalServiceAccessList.add(portalServiceAccess2);
		IGOMService.manageUserOnboarding(portalServiceAccessList);
		Map<Id,Account_Contact_Role__c> accountContactRoleMap2 = new Map<Id, Account_Contact_Role__c>([SELECT Id, Account__c, Account_Role__c, Contact__c, Status__c FROM Account_Contact_Role__c WHERE Contact__c IN :(new Set<Id>{contact.Id, contact2.Id})]);
		List<Account_Role__c> accountRoleList2 = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, IGOMService.FUNCTIONALROLE);
		List<IGOM_Contact_Role_Detail__c> contactRoleDetailList2 = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__c IN :accountContactRoleMap2.keySet()];
		List<IGOM_Account_Role_Detail__c> accountRoleDetailList2 = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c IN :accountRoleList2];

		Test.stopTest();

		System.assertEquals(2, accountContactRoleMap.size(), 'There should still be 2 account contact roles');
		Map<Id, Account_Contact_Role__c> contactToAccountContactRole = new Map<Id, Account_Contact_Role__c>();
		for (Account_Contact_Role__c accountContactRole : accountContactRoleMap.values()) {
			contactToAccountContactRole.put(accountContactRole.Contact__c, accountContactRole);
		}
		System.assertEquals(accountContactRoles.STATUSINACTIVE, contactToAccountContactRole.get(contact.Id).Status__c);
		System.assertEquals(accountContactRoles.STATUSACTIVE, contactToAccountContactRole.get(contact2.Id).Status__c);
		System.assertEquals(1, accountRoleList.size(), 'There should still be 1 account roles');
		System.assertEquals(accountContactRoles.STATUSACTIVE, accountRoleList.get(0).Status__c);
		System.assertEquals(1, contactRoleDetailList.size(), 'Expected 1 IGOM Contact Role Detail');
		System.assertEquals(1, accountRoleDetailList.size(), 'Expected 1 IGOM Account Role Detail');
		
		System.assertEquals(2, accountContactRoleMap2.size(), 'There should still be 2 account contact roles');
		Map<Id, Account_Contact_Role__c> contactToAccountContactRole2 = new Map<Id, Account_Contact_Role__c>();
		for (Account_Contact_Role__c accountContactRole : accountContactRoleMap2.values()) {
			contactToAccountContactRole2.put(accountContactRole.Contact__c, accountContactRole);
		}
		System.assertEquals(accountContactRoles.STATUSINACTIVE, contactToAccountContactRole2.get(contact.Id).Status__c);
		System.assertEquals(accountContactRoles.STATUSINACTIVE, contactToAccountContactRole2.get(contact2.Id).Status__c);
		System.assertEquals(1, accountRoleList2.size(), 'There should still be 1 account roles');
		System.assertEquals(accountContactRoles.STATUSINACTIVE, accountRoleList2.get(0).Status__c);
		System.assertEquals(0, contactRoleDetailList2.size(), 'Expected 0 IGOM Contact Role Detail');
		System.assertEquals(0, accountRoleDetailList2.size(), 'Expected 0 IGOM Account Role Detail');
	}

	@IsTest
	static void testManageUserOnboardingIndividually() {
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);

		Test.startTest();


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

		IGOMService.manageUserOnboarding(portalServiceAccessList);

		Test.stopTest();

		// Contact role assignment
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = new Map<Id, Account_Contact_Role__c>(AccountContactRoleSelector.selectMapByServiceAndContactIdSet(IGOMService.FUNCTIONALROLE, new Set<Id>{contact.Id, contact2.Id}).values());
		System.assertEquals(2, accountContactRoleMap.size(), 'Expected 2 Account Contact Roles');
		// Contact detail assignment
		List<IGOM_Contact_Role_Detail__c> contactRoleDetailList = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__c IN :accountContactRoleMap.keySet()];
		System.assertEquals(2, contactRoleDetailList.size(), 'Expected 2 IGOM Contact Role Details');
		// Account role assignment
		Map<Id, Account_Role__c> accountRoleMap = new Map<Id, Account_Role__c>(AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, IGOMService.FUNCTIONALROLE));
		System.assertEquals(1, accountRoleMap.size(), 'Expected 1 Account Role');
		// Account detail assignment
		List<IGOM_Account_Role_Detail__c> accountRoleDetailList = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c IN :accountRoleMap.keySet()];
		System.assertEquals(1, accountRoleDetailList.size(), 'Expected 1 IGOM Account Role Detail');
	}
}