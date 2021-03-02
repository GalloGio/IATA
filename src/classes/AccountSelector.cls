public class AccountSelector {
	public static List<Account> selectIdByNames (Set<String> accountNameSet){
		return [SELECT Id FROM Account WHERE Name IN :accountNameSet];
	}

	public static Map<Id,Account> selectIdMapByName (Set<String> accountNameSet){
		Map<Id,Account> accountIdMap = new Map<Id,Account>([SELECT Id FROM Account WHERE Name IN :accountNameSet]);
		return accountIdMap;
	}

	// use to return an List<Account> from an Account Id
	public static List<Account> selectById (Set<Id> accountIdSet){
		return [SELECT Id FROM Account WHERE Id IN :accountIdSet];
	}
}