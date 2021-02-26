@IsTest
private class AccountRoleSelectorTest {
	@TestSetup
	static void makeData(){
		List<Account> accountList = TestDataFactory_Accounts.createStandardAccounts(1);
		insert accountList;
		List<Account_Role__c> accountRole = TestDataFactory_AccountRoles.createDefaultAccountRoles(accountList);
		insert accountRole;
	}

	@IsTest
	static void testSelectByAccountsAndRole(){
		Test.startTest();
		List<Account> accountList = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'});
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountsAndRole(accountList, '');
		Test.stopTest();

		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account_Role__c record');
	}

	@IsTest
	static void testSelectAccountIdByAccountsAndRole(){
		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectAccountIdByAccountsAndRole(new Set<Id>{account.Id}, '');
		Test.stopTest();

		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account_Role__c record');
		System.assert(accountRoleList.get(0).Account__c != null);
	}
}