public class ContactRoleDetail_mdt_Selector {
	// returns Contact_Role_Detail__mdt matching id provided
	public static List<Contact_Role_Detail__mdt> selectIdById(Set<Id> contactRoleDetailIdSet){
		return [SELECT Id FROM Contact_Role_Detail__mdt WHERE Id IN :contactRoleDetailIdSet];
	}

	public static List<Contact_Role_Detail__mdt> selectRolesByFunctionalRole(String functionalRole){
		return [SELECT Id, Functional_Role__c, Role_Name__c 
			FROM Contact_Role_Detail__mdt 
			WHERE Functional_Role__r.DeveloperName = :functionalRole
		];
	}

	// this is a generic query method (harder to understand/read but highly reusable)
	public static List<Contact_Role_Detail__mdt> selectQuery(String fields, String conditions, Set<Id> conditionInputSet){
		String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Contact_Role_Detail__mdt';
		if(conditions != null && String.isNotEmpty(conditions))
			query += ' WHERE ' + conditions;
		if(conditionInputSet != null && !conditionInputSet.isEmpty())
			query += ' IN :conditionInputSet';
		return Database.query(query);
	}
}