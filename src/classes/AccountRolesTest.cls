@IsTest
private class AccountRolesTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
	}

	@IsTest
	static void testCreate(){
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		AccountRoles accountRoles = new AccountRoles();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		List<Account_Role__c> accountRoleList = accountRoles.create(new Set<Id>{account.Id}, functionalRole);
		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account Role');
	}

	@IsTest
	static void testActivate(){
		AccountRoles accountRoles = new AccountRoles();
		String activeStatus = AccountRoles.STATUSACTIVE;
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		accountRoles.records.addAll(accountRoles.create(new Set<Id>{account.Id}, functionalRole));
		accountRoles.activate();
		System.assertEquals(activeStatus, accountRoles.records.get(0).Status__c, 'Expected an Active Account Role');
	}

	@IsTest
	static void testInactivate(){
		AccountRoles accountRoles = new AccountRoles();
		String inactiveStatus = AccountRoles.STATUSINACTIVE;
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		accountRoles.records.addAll(accountRoles.create(new Set<Id>{account.Id}, functionalRole));
		accountRoles.inactivate();
		System.assertEquals(inactiveStatus, accountRoles.records.get(0).Status__c, 'Expected an Inactive Account Role');
	}
}