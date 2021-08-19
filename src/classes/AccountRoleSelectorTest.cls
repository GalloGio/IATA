@IsTest
private class AccountRoleSelectorTest {
	@TestSetup
	static void makeData(){
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		List<Account> accountList = TestDataFactory_Accounts.createDefaultAccounts(1);
		insert accountList;
		List<Account_Role__c> accountRoleList = TestDataFactory_AccountRoles.createBaseAccountRoles(accountList);
		for(Account_Role__c accountRole : accountRoleList){
			accountRole.Functional_Role__c = functionalRole;
		}
		insert accountRoleList;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(accountList.get(0).Id, 1).get(0);
		insert contact;
		Account_Contact_Role__c accountContactRole = TestDataFactory_AccountContactRoles.createDefaultAccountContactRole(contact.Id, accountRoleList.get(0).Id);
		accountContactRole.Functional_Role__c = functionalRole;
		insert accountContactRole;
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
	static void testSelectByAccountIdSetAndRole(){
		Test.startTest();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		List<Account_Role__c> accountRoleList = AccountRoleSelector.selectByAccountIdSetAndRole(new Set<Id>{account.Id}, '');
		Test.stopTest();

		System.assertEquals(1, accountRoleList.size(), 'Expected 1 Account_Role__c record');
		System.assert(accountRoleList.get(0).Account__c != null);
	}

	@IsTest
	static void testSelectAccountRoleWithRelatedAccountRolesByFunctionalRoleSet(){
		Set<String> functionalRoleSet = new Set<String>{SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue()};
		Map<Id, Account_Role__c> accountRoleMap = AccountRoleSelector.selectAccountRoleWithRelatedAccountRolesByFunctionalRoleSet(functionalRoleSet);

		Account_Role__c accountRole = [SELECT Id, Functional_Role__c, (SELECT Id, Account_Role__c, Functional_Role__c FROM Account_Contacts_Role__r WHERE Functional_Role__c IN :functionalRoleSet) FROM Account_Role__c WHERE Functional_Role__c IN :functionalRoleSet LIMIT 1];
		System.assert(!accountRoleMap.isEmpty());
		System.assertEquals(accountRole.Id, accountRoleMap.get(accountRole.Id).Id);
		System.assert(!accountRole.Account_Contacts_Role__r.isEmpty());
		System.assertEquals(accountRole.Account_Contacts_Role__r.get(0).Account_Role__c, accountRoleMap.get(accountRole.Id).Id);
	}


	@IsTest
	static void testSelectAccountRoleWithRelatedAccountRolesByAccountRoleIdSet(){
		Map<Id, Account_Role__c> accountRoleMap = new Map<Id, Account_Role__c>([SELECT Id FROM Account_Role__c]);
		Map<Id, Account_Role__c> retreivedAccountRoleMap = AccountRoleSelector.selectAccountRoleWithRelatedAccountRolesByAccountRoleIdSet(accountRoleMap.keySet());

		Account_Role__c retreivedAccountRole = retreivedAccountRoleMap.values().get(0);
		System.assert(retreivedAccountRole != null);
		System.assert(!retreivedAccountRole.Account_Contacts_Role__r.isEmpty());
		System.assert(accountRoleMap.keySet().contains(retreivedAccountRole.Account_Contacts_Role__r.get(0).Account_Role__c));
	}
}