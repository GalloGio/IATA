@IsTest
private class AccountRolesTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
	}

	@IsTest
	static void testCreate(){
		AccountRoles accountRoles = new AccountRoles();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		List<Account_Role__c> accountRoleList = accountRoles.create(new Set<Id>{account.Id}, 'TEST ROLE');
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
	}

	@IsTest
	static void testActivate(){
		String activeStatus = AccountRoles.STATUSACTIVE;
		AccountRoles accountRoles = new AccountRoles();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		accountRoles.create(new Set<Id>{account.Id}, 'TEST ROLE');
		accountRoles.activate();
		System.assertEquals(activeStatus, accountRoles.records.get(0).Status__c, 'Expected an Active Account Role');
	}

	@IsTest
	static void testInactivate(){
		String inactiveStatus = AccountRoles.STATUSINACTIVE;
		AccountRoles accountRoles = new AccountRoles();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		accountRoles.create(new Set<Id>{account.Id}, 'TEST ROLE');
		accountRoles.inactivate();
		System.assertEquals(inactiveStatus, accountRoles.records.get(0).Status__c, 'Expected an Inactive Account Role');
	}
}