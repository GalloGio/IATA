public class AccountSelector {
	public static final String NEWGENFIELDSET = 'NewGen_Selector';

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

	public static Map<String,Account> selectNewGenFieldsMapByName(String conditions, Set<String> nameLimiterSet, Set<Id> idLimiterSet){
		List<Account> accountList = Database.query(buildQuery(NEWGENFIELDSET, conditions, nameLimiterSet, idLimiterSet));
		return createNameMap(accountList);
	}

	private static Map<String,Account> createNameMap(List<Account> accountList){
		Map<String,Account> accountNameMap = new Map<String,Account>();
		for(Account account : accountList){
			accountNameMap.put(account.Name, account);
		}
		return accountNameMap;
	}

	//only fieldSetName is mandatory (NOTE: Id, Name, RecordTypeId and RecordType.Name are returned by default)
	private static String buildQuery(String fieldSetName, String conditions, Set<String> nameLimiterSet, Set<Id> idConditionLimiterSet){
		List<Schema.FieldSetMember> fieldSetMemberList = Schema.SObjectType.Account.fieldSets.getMap().get(fieldSetName).getFields();
		String query = 'SELECT ';
		for(Schema.FieldSetMember field : fieldSetMemberList){
			query += field.getFieldPath() + ', ';
		}
		query += 'Id, Name, RecordTypeId, RecordType.Name FROM Account';
		if(conditions != null)
			query += ' WHERE ' + conditions;
		if(nameLimiterSet != null){
			if(conditions != null)
				query += ' AND Name IN :nameLimiterSet';
			else
				query += ' WHERE Name IN :nameLimiterSet';
		}
		if(idConditionLimiterSet != null){
			if(conditions != null || nameLimiterSet != null)
				query += ' AND Id IN :idConditionLimiterSet';
			else
				query += ' WHERE Id IN :idConditionLimiterSet';
		}
		return query;
	}
}