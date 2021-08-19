@IsTest
private class PortalServiceAccessServiceTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(account.Id, 2);
		insert contactList;
		List<Portal_Applications__c> portalApplicationsList = TestDataFactory_PortalApplications.createDefaultPortalApplication(1);
		insert portalApplicationsList;	
	}

	@IsTest
	static void fakeMethod(){
		PortalServiceAccessService portalServiceAccessService = new PortalServiceAccessService();
		portalServiceAccessService.fakemethod();
	}

	@IsTest 
	static void testProcessPortalServiceAccessService(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
		Portal_Applications__c portalApplication = [SELECT Id FROM Portal_Applications__c LIMIT 1];

		Portal_Application_Right__c portalApplicationRight = portalApplicationRights.createDefaultPortalApplicationRight(1).get(0);
		portalApplicationRight.Contact__c = contact.Id;
		portalApplicationRight.Portal_Application__c = portalApplication.Id;

		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		portalServiceAccess.contact = contact;
		portalServiceAccess.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess.portalApplicationRight = portalApplicationRight;

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>{portalServiceAccess};
		try {
			PortalServiceAccessService.processPortalServiceAccessService(portalServiceAccessList);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, 'PortalServiceAccessService.processPortalServiceAccessService caused an error');
		}
	}

	@IsTest
	static void testRoleAssignment(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		AccountRoles accountRoles = new AccountRoles();
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Portal_Applications__c portalApplication = [SELECT Id FROM Portal_Applications__c LIMIT 1];

		Portal_Application_Right__c portalApplicationRight = portalApplicationRights.createDefaultPortalApplicationRight(1).get(0);
		portalApplicationRight.Contact__c = contact.Id;
		portalApplicationRight.Portal_Application__c = portalApplication.Id;

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();

		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = functionalRole;
		portalServiceAccess.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess.contact = contact;
		portalServiceAccess.portalApplicationRight = portalApplicationRight;
		portalServiceAccessList.add(portalServiceAccess);
		PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);

		Account_Role__c accountRole = [SELECT Id, Status__c, Account__c FROM Account_Role__c LIMIT 1];
		System.assertNotEquals(null, accountRole);
		System.assertEquals(accountRoles.STATUSACTIVE, accountRole.Status__c);
		System.assertEquals(contact.AccountId, accountRole.Account__c);

		Account_Contact_Role__c accountContactRole = [SELECT Id, Status__c, Account_Role__c FROM Account_Contact_Role__c LIMIT 1];
		System.assertNotEquals(null, accountContactRole);
		System.assertEquals(accountContactRoles.STATUSACTIVE, accountContactRole.Status__c);
		System.assertEquals(accountRole.Id, accountContactRole.Account_Role__c);
	}

	@IsTest
	static void testRoleUnassignment(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		AccountRoles accountRoles = new AccountRoles();
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = functionalRole;
		portalServiceAccess.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess.contact = contact;
		portalServiceAccessList.add(portalServiceAccess);
		PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);

		portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = functionalRole;
		portalServiceAccess.accessStatus = portalApplicationRights.ACCESSDENIED;
		portalServiceAccess.contact = contact;
		portalServiceAccessList.add(portalServiceAccess);
		PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);

		Account_Role__c accountRole = [SELECT Id, Status__c, Account__c FROM Account_Role__c LIMIT 1];
		System.assertNotEquals(null, accountRole);
		System.assertEquals(accountRoles.STATUSINACTIVE, accountRole.Status__c);
		System.assertEquals(contact.AccountId, accountRole.Account__c);

		Account_Contact_Role__c accountContactRole = [SELECT Id, Status__c, Account_Role__c FROM Account_Contact_Role__c LIMIT 1];
		System.assertNotEquals(null, accountContactRole);
		System.assertEquals(accountContactRoles.STATUSINACTIVE, accountContactRole.Status__c);
		System.assertEquals(accountRole.Id, accountContactRole.Account_Role__c);
	}

	@IsTest
	static void testRoleAssignmentWithExistingRoles(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		AccountRoles accountRoles = new AccountRoles();
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();

		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = functionalRole;
		portalServiceAccess.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess.contact = contact;
		portalServiceAccessList.add(portalServiceAccess);
		PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);

		portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		Contact contact1 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess1 = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess1.functionalRoleName = functionalRole;
		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess1.contact = contact1;
		portalServiceAccessList.add(portalServiceAccess1);
		PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);

		List<Account_Role__c> accountRoleList = [SELECT Id, Status__c, Account__c FROM Account_Role__c];
		System.assertEquals(1, accountRoleList.size());
		System.assertNotEquals(null, accountRoleList.get(0));
		System.assertEquals(accountRoles.STATUSACTIVE, accountRoleList.get(0).Status__c);
		System.assertEquals(contact.AccountId, accountRoleList.get(0).Account__c);

		List<Account_Contact_Role__c> accountContactRoleList = [SELECT Id, Status__c, Account_Role__c FROM Account_Contact_Role__c];
		System.assertEquals(2, accountContactRoleList.size());
		System.assertNotEquals(null, accountContactRoleList.get(0));
		System.assertEquals(accountContactRoles.STATUSACTIVE, accountContactRoleList.get(0).Status__c);
		System.assertEquals(accountRoleList.get(0).Id, accountContactRoleList.get(0).Account_Role__c);
	}

	@IsTest
	static void testRoleUnassignmentWithExistingRoles(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		AccountRoles accountRoles = new AccountRoles();
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact1 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>();
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = functionalRole;
		portalServiceAccess.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess.contact = contact;
		portalServiceAccessList.add(portalServiceAccess);
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess1 = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess1.functionalRoleName = functionalRole;
		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSGRANTED;
		portalServiceAccess1.contact = contact1;
		portalServiceAccessList.add(portalServiceAccess1);
		PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);

		portalServiceAccess1.accessStatus = portalApplicationRights.ACCESSDENIED;
		PortalServiceAccessService.manageUserOnboarding(new List<PortalServiceAccessService.PortalServiceAccess>{portalServiceAccess1});
		
		List<Account_Role__c> accountRoleList = [SELECT Id, Status__c, Account__c, Functional_Role__c FROM Account_Role__c];
		System.assertEquals(1, accountRoleList.size());
		System.assertNotEquals(null, accountRoleList.get(0));
		System.assertEquals(accountRoles.STATUSACTIVE, accountRoleList.get(0).Status__c);
		System.assertEquals(contact.AccountId, accountRoleList.get(0).Account__c);

		List<Account_Contact_Role__c> accountContactRoleList = [SELECT Id, Status__c, Account_Role__c FROM Account_Contact_Role__c];
		System.assertEquals(2, accountContactRoleList.size());
		Integer activeCount = 0;
		for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
			if(accountContactRole.Status__c.equals(accountContactRoles.STATUSACTIVE))
				activeCount ++;
		}
		System.assertEquals(1, activeCount);
		System.assertNotEquals(null, accountContactRoleList.get(0));
		System.assertEquals(accountRoleList.get(0).Id, accountContactRoleList.get(0).Account_Role__c);
	}
}