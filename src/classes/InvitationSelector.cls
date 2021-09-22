public class InvitationSelector {	
	public static List<Invitation__c> selectIdById(Set<Id> invitationIdSet){
		return [SELECT Id FROM Invitation__c WHERE Id IN :invitationIdSet];
	}

	public static List<Invitation__c> selectByServiceIdAndEmailSetOrAccountSet(Id serviceId, Set<String> emailAddressSet, Set<Id> accountIdSet){
		return [SELECT Id, ServiceId__c, Email__c, Account__c, Role_Name__c, Status__c, Functional_Role__c 
			FROM Invitation__c 
			WHERE ServiceId__c = :serviceId
			AND (Email__c IN :emailAddressSet OR Account__c IN :accountIdSet)
		];
	}

	public static List<Invitation__c> selectMapByServiceIdEmailSetAndStatus(Id serviceId, Set<String> emailAddressSet, String status){
		String query = buildSelectString() + ' WHERE ServiceId__c = :serviceId AND Status__c = :status AND Email__c IN :emailAddressSet';
		return Database.query(query);
	}

	public static Map<Id, Invitation__c> selectInvitationsByEmailSetAndStatus(Set<String> emailSet, String status){
		Invitations invitations = new Invitations();

		String emailSetString = '(';
		for(String email : emailSet){
			emailSetString += '\'' + email + '\',';
		}
		//remove the last ','
		emailSetString = emailSetString.substring(0, emailSetString.length() - 1) + ')';

		String query = buildSelectString() + '  WHERE Status__c = \'' + status  + '\' AND Email__c IN ' + emailSetString + ' ORDER BY LastModifiedDate DESC';
		return new Map<Id, Invitation__c>((List<Invitation__c>) Database.query(query));
	}
	
	private static String buildSelectString(){
		List<Schema.FieldSetMember> invitationFieldSetMemberList = Schema.SObjectType.Invitation__c.fieldSets.Invitation.getFields();
		String query = 'SELECT ';
		for(Schema.FieldSetMember fieldSetMember : invitationFieldSetMemberList){
			query += fieldSetMember.getSObjectField().getDescribe().getName();
			query += ', ';
		}
		//remove the last ', '
		query = query.substring(0, query.length() - 2);
		query += ' FROM Invitation__c';
		return query;
	}

	// this is a generic query method (harder to understand/read but highly reusable)
	public static List<Invitation__c> selectQuery(String fields, String conditions, Set<Id> conditionInputSet){
		String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Invitation__c';
		if(conditions != null && String.isNotEmpty(conditions))
			query += ' WHERE ' + conditions;
		if(conditionInputSet != null && !conditionInputSet.isEmpty())
			query += ' IN :conditionInputSet';
		return Database.query(query);
	}
}