@IsTest
private class AirportISServiceTest {
	@TestSetup
	static void makeData(){
		List<Account> accountList = TestDataFactory_Accounts.createStandardAccounts(1);
		insert accountList;
		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(accountList.get(0).Id, 2);
		insert contactList;
		insert TestDataFactory_PortalApplications.createDefaultPortalApplication(1);		
	}

	@IsTest
	static void testManageUserOnboarding(){
		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);
		Test.stopTest();

		//test onboarding
		AirportISService.manageUserOnboarding(new Set<Contact>{contact, contact2}, PortalApplicationRights.ACCESSGRANTED);
		//test contact role assignment
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(AirportISService.FUNCTIONALROLE, new Set<Id>{contact.Id, contact2.Id});
		System.assertEquals(2, accountContactRoleMap.size(), 'Expected 2 Account Contact Roles');
		//test account role assignment
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectAccountIdByAccountsAndRole(new Set<Id>{account.Id}, AirportISService.FUNCTIONALROLE);
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
	}

	@IsTest
	static void testManageUserOffboarding(){
		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contact contact2 = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '1'}).get(0);
		AirportISService.manageUserOnboarding(new Set<Contact>{contact, contact2}, PortalApplicationRights.ACCESSGRANTED);
		Test.stopTest();

		//test offboarding
		AirportISService.manageUserOnboarding(new Set<Contact>{contact}, PortalApplicationRights.ACCESSDENIED);
		//test account contact role unassignment
		Map<Id,Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(AirportISService.FUNCTIONALROLE, new Set<Id>{contact.Id, contact2.Id});
		System.assertEquals(1, accountContactRoleMap.size(), 'There should still be 1 Contact with the role');
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectAccountIdByAccountsAndRole(new Set<Id>{account.Id}, AirportISService.FUNCTIONALROLE);
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
		AirportISService.manageUserOnboarding(new Set<Contact>{contact2}, PortalApplicationRights.ACCESSDENIED);
		accountContactRoleMap = AccountContactRoleSelector.selectMapByServiceAndContactIdSet(AirportISService.FUNCTIONALROLE, new Set<Id>{contact.Id, contact2.Id});
		System.assertEquals(0, accountContactRoleMap.size(), 'There should still be no Contacts with the role');
		//test account role unassignment
		accountRoleList = AccountRoleSelector.selectAccountIdByAccountsAndRole(new Set<Id>{account.Id}, AirportISService.FUNCTIONALROLE);
		System.assertEquals(0, accountRoleList.size(), 'Expected 0 Account Roles');
	}
}