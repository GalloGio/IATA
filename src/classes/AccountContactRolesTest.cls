@IsTest
private class AccountContactRolesTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = account.Id;
		insert contact;
	}

	@IsTest
	static void testConstructors(){
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		System.assertEquals(0, accountContactRoles.records.size());

		Contact contact = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0' LIMIT 1];
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		List<Account_Contact_Role__c> accountContactRoleList = accountContactRoles.create(new Set<Contact>{contact}, functionalRole);

		accountContactRoles = new AccountContactRoles(accountContactRoleList);
		System.assertEquals(1, accountContactRoles.records.size());
	}

	@IsTest
	static void testActivate(){
		Contact contact = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0' LIMIT 1];
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		List<Account_Contact_Role__c> accountContactRoleList = accountContactRoles.create(new Set<Contact>{contact}, functionalRole);
		accountContactRoleList.get(0).Status__c = accountContactRoles.STATUSINACTIVE;

		accountContactRoles = new AccountContactRoles(accountContactRoleList);
		accountContactRoleList = accountContactRoles.activate();
		System.assertEquals(accountContactRoles.STATUSACTIVE, accountContactRoleList.get(0).Status__c);
	}

	@IsTest
	static void testInactivate(){
		Contact contact = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0' LIMIT 1];
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		List<Account_Contact_Role__c> accountContactRoleList = accountContactRoles.create(new Set<Contact>{contact}, functionalRole);
		accountContactRoleList.get(0).Status__c = accountContactRoles.STATUSACTIVE;

		accountContactRoles = new AccountContactRoles(accountContactRoleList);
		accountContactRoleList = accountContactRoles.inactivate();
		System.assertEquals(accountContactRoles.STATUSINACTIVE, accountContactRoleList.get(0).Status__c);
	}

	@IsTest
	static void testCreate(){
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		List<Account_Contact_Role__c> accountContactRoleList = accountContactRoles.create(new Set<Contact>{contact}, functionalRole);
		System.assertEquals(1, accountContactRoleList.size(), 'Expected 1 Account Role');
	}
}