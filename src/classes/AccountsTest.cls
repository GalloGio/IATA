@IsTest
private class AccountsTest {
	@TestSetup
	static void makeData(){
		
	}

	@IsTest
	static void testInitialisation(){
		Accounts accounts = new Accounts();
		System.assertEquals(0, accounts.records.size());

		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		accounts = new Accounts(new List<Account>{account});
		System.assertEquals(1, accounts.records.size());
	}

	@IsTest
	static void testCreateDefaultAccount(){
		Accounts accounts = new Accounts();
		List<Account> accountList = accounts.createDefaultAccount(1);
		System.assertEquals(1, accountList.size());
	}
}