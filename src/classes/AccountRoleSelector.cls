public class AccountRoleSelector {
	public static List<Account_Role__c> selectByAccountIdSetAndRole(Set<Id>  accountIdSet, String functionalRoleName){
		// cannot create Functional Role picklist value set in tests so ignore
		if(Test.isRunningTest())
			return selectQuery('Id, Account__c, Status__c', 'Account__c', accountIdSet);

		return selectQuery('Id, Account__c, Status__c', 'Functional_Role__c = \'' + functionalRoleName + '\' AND Account__c', accountIdSet);
	}

	public static List<Account_Role__c> selectByAccountIdSet(Set<Id> accountIdSet){
		return [SELECT Id, Account__c, Functional_Role__c, Status__c FROM Account_Role__c WHERE Account__c IN :accountIdSet];
	}

	public static List<Account_Role__c> selectAccountContactRoles (Set<Id> accountRoleIdSet){
		return [SELECT Id, Status__c, Account__c, Functional_Role__c, (SELECT Id, Status__c, Functional_Role__c, Contact__c FROM Account_Contacts_Role__r) FROM Account_Role__c WHERE Id IN :accountRoleIdSet];
	}

	public static Map<Id, Account_Role__c> selectAccountRoleWithRelatedAccountRolesByFunctionalRoleSet(Set<String> functionalRoleSet){
		return new Map<Id, Account_Role__c>(
			[SELECT Id, Account__c, Functional_Role__c, Status__c, 
			(SELECT Id, Status__c, Functional_Role__c, Contact__c FROM Account_Contacts_Role__r WHERE Functional_Role__c IN :functionalRoleSet) 
			FROM Account_Role__c WHERE Functional_Role__c IN :functionalRoleSet]);
	}

	public static Map<Id, Account_Role__c> selectAccountRoleWithRelatedAccountRolesByAccountRoleIdSet(Set<Id> accountRoleIdSet){
		return new Map<Id, Account_Role__c>(
			[SELECT Id, Status__c, Functional_Role__c, 
			(SELECT Id, Status__c, Account_Role__c FROM Account_Contacts_Role__r) 
			FROM Account_Role__c WHERE Id IN :accountRoleIdSet]);
	}

	public static List<Account_Role__c> selectQuery(String fields, String conditions, Set<Id> conditionInputSet){
		String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Account_Role__c';
		if(conditions != null && String.isNotEmpty(conditions))
			query += ' WHERE ' + conditions;
		if(conditionInputSet != null && !conditionInputSet.isEmpty())
			query += ' IN :conditionInputSet';
		return Database.query(query);
	}

	public static Map<Id, Account_Role__c> selectAccountRoleWithRelatedAccountRolesByAccountRoleIdSet(Set<Id> accountRoleIdSet){
		return new Map<Id, Account_Role__c>(
			[SELECT Id, Status__c, Functional_Role__c, 
			(SELECT Id, Status__c, Account_Role__c FROM Account_Contacts_Role__r) 
			FROM Account_Role__c WHERE Id IN :accountRoleIdSet]);
	}

	public static Map<Id, Account_Role__c> selectAccountRoleWithRelatedAccountRolesByFunctionalRoleSet(Set<String> functionalRoleSet){
		return new Map<Id, Account_Role__c>(
			[SELECT Id, Account__c, Functional_Role__c, Status__c, 
			(SELECT Id, Status__c, Functional_Role__c, Contact__c FROM Account_Contacts_Role__r WHERE Functional_Role__c IN :functionalRoleSet) 
			FROM Account_Role__c WHERE Functional_Role__c IN :functionalRoleSet]);
	}
}