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
	static void testCreate(){
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		List<Account_Contact_Role__c> accountContactRoleList = accountContactRoles.create(new Set<Contact>{contact}, functionalRole);
		System.assertEquals(1, accountContactRoleList.size(), 'Expected 1 Account Role');
	}
}