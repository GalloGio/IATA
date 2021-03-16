@IsTest
private class AccountRolesTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
	}

	@IsTest
	static void testAssignRole(){
		Test.startTest();
		Set<Id> accountIdSet = AccountSelector.selectIdMapByName(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).keySet();
		Test.stopTest();

		AccountRoles accountRoles = new AccountRoles();
		try{
			accountRoles.assignRole(accountIdSet, 'FAKE ROLE');
		} catch(Exception e){
			System.assertEquals('AccountRoles.AccountRoleDomainException', e.getTypeName(), 'Expected AccountRoleDomainException to be thrown but instead got ' + e.getTypeName());
		}
	}

	@IsTest
	static void testUnassignRole(){
		Test.startTest();
		Set<Id> accountIdSet = AccountSelector.selectIdMapByName(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).keySet();
		AccountRoles accountRoles = new AccountRoles();
		insert accountRoles.assignRole(accountIdSet, 'FAKE ROLE');
		Test.stopTest();

		try{
			List<Account_Role__c> accountRoleList = accountRoles.unAssignRole(accountIdSet , 'FAKE ROLE');
			System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
		} catch(Exception e){
			System.assertEquals('AccountRoles.AccountRoleDomainException', e.getTypeName(), 'Expected AccountRoleDomainException to be thrown but instead got ' + e.getTypeName());
		}
	}
}