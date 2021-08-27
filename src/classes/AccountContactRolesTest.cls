@IsTest
private class AccountContactRolesTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Account_Role__c accountRole = TestDataFactory_AccountRoles.createBaseAccountRoles(new List<Account>{account}).get(0);
		insert accountRole;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(account.Id, 1).get(0);
		insert contact;
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

	@IsTest
	static void fakeMethod(){
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		accountContactRoles.fakemethod();
	}	
}