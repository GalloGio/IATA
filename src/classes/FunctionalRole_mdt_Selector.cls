public class FunctionalRole_mdt_Selector {
    // returns FunctionalRole_mdt_Selector matching id provided
	public static List<Functional_Role__mdt> selectIdById(Set<Id> functionalRoleIdSet){
		return [SELECT Id FROM Functional_Role__mdt WHERE Id IN :functionalRoleIdSet];
	}

	//select id by name
	public static List<Functional_Role__mdt> selectIdByName(String functionalRole){
		return [SELECT Id, MasterLabel 
			FROM Functional_Role__mdt 
			WHERE MasterLabel = :functionalRole
		];
	}

	// this is a generic query method (harder to understand/read but highly reusable)
	public static List<Functional_Role__mdt> selectQuery(String fields, String conditions, Set<Id> conditionInputSet){
		String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Functional_Role__mdt';
		if(conditions != null && String.isNotEmpty(conditions))
			query += ' WHERE ' + conditions;
		if(conditionInputSet != null && !conditionInputSet.isEmpty())
			query += ' IN :conditionInputSet';
		return Database.query(query);
	}
}