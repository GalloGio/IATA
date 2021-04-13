@IsTest
private class AccountSelectorTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
	}

	@IsTest
	static void testSelectIdByNames(){
		List<Account> accountList = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'});
		System.assertEquals(1, accountList.size(), 'Expected Account was not returned by AccountSelector.selectByIds');
	}

	@IsTest
	static void testSelectById(){
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		List<Account> accountList = AccountSelector.selectById(new Set<Id>{account.Id});
		System.assertEquals(1, accountList.size(), 'Expected Account was not returned by AccountSelector.selectByIds');
	}

	@IsTest
	static void testSelectIdMapByName(){
		Account account = AccountSelector.selectIdMapByName(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).values().get(0);
		List<Account> accountList = AccountSelector.selectById(new Set<Id>{account.Id});
		System.assertEquals(1, accountList.size(), 'Expected 1 Account');
	}
}