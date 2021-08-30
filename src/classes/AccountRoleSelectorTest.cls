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
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = accountList.get(0).Id;
		insert contact;
		Account_Contact_Role__c accountContactRole = TestDataFactory_AccountContactRoles.createDefaultAccountContactRole(contact.Id, accountRoleList.get(0).Id);
		accountContactRole.Functional_Role__c = functionalRole;
		insert accountContactRole;
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
	static void testSelectByAccountIdSet(){
		Account account = [SELECT Id FROM Account LIMIT 1];
		System.assertEquals(1, AccountRoleSelector.selectByAccountIdSet(new Set<Id>{account.Id}).size());
	}

	@IsTest
	static void testSelectAccountContactRoles(){
		Account_Role__c accountRole = [SELECT Id, Account__c, (SELECT Id, Contact__c FROM Account_Contacts_Role__r) FROM Account_Role__c LIMIT 1];
		Account_Role__c retreivedAccountRole = AccountRoleSelector.selectAccountContactRoles(new Set<Id>{accountRole.Id}).get(0);
		System.assertEquals(accountRole.Account_Contacts_Role__r.get(0).Contact__c, retreivedAccountRole.Account_Contacts_Role__r.get(0).Contact__c);
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

	@IsTest
	static void testSelectQuery(){
		System.assertEquals(1, AccountRoleSelector.selectQuery('Id', '', null).size());
	}
}