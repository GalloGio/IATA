public class PortalApplicationSelector {
	public static List<Portal_Applications__c> selectIdByName(Set<String> nameSet){
		return [SELECT Id, Functional_Role__c FROM Portal_Applications__c WHERE Name IN :nameSet];
	}

	public static Map<Id, Portal_Applications__c> selectFunctionalRoleMapByServiceNameSet(Set<String> portalServiceNameSet){
		if(Test.isRunningTest())
			return new Map<Id, Portal_Applications__c>([SELECT Id FROM Portal_Applications__c WHERE Name IN :portalServiceNameSet]);
		return new Map<Id, Portal_Applications__c>([SELECT Id, Functional_Role__c FROM Portal_Applications__c WHERE Name IN :portalServiceNameSet]);
	}

	public static Map<String, Portal_Applications__c> selectNewGenFieldsMapByName(Set<String> nameSet){
		List<Portal_Applications__c> portalApplicationList = [
			SELECT 
				Id, 
				Name, 
				ANG_Restrict_by_Agency_Sector__c, 
				ANG_Accredited_Agents_Only__c, 
				Agency__c
			FROM Portal_Applications__c 
			WHERE Name IN :nameSet
		];

		Map<String, Portal_Applications__c> portalApplicationNameMap = new Map<String, Portal_Applications__c>();
		for(Portal_Applications__c portalApplication : portalApplicationList){
			portalApplicationNameMap.put(portalApplication.Name, portalApplication);
		}
		return portalApplicationNameMap;
	}

	public static Map<Id, Portal_Applications__c> selectFunctionalRoleMapByServiceIdSet(Set<Id> portalServiceIdSet){
		return new Map<Id, Portal_Applications__c>([SELECT Id, Functional_Role__c FROM Portal_Applications__c WHERE Id IN :portalServiceIdSet]);
	}

	public static Map<Id, Portal_Applications__c> selectIsServiceEnabledMapByServiceIdSet(Set<Id> portalServiceIdSet){
		return new Map<Id, Portal_Applications__c>([SELECT Id, Functional_Role__c, Is_Invitation_Enabled__c FROM Portal_Applications__c WHERE Id IN :portalServiceIdSet]);
	}

	public static Map<Id, Portal_Applications__c> selectInvitationFieldsMapByName(Set<String> functionalRoleNameSet){
		List<Schema.FieldSetMember> invitationFieldSetMemberList = Schema.SObjectType.Portal_Applications__c.fieldSets.Invitation.getFields();
		String query = 'SELECT ';
		for(Schema.FieldSetMember fieldSetMember : invitationFieldSetMemberList){
			query += fieldSetMember.getSObjectField().getDescribe().getName();
			query += ', ';
		}
		//remove the last ', '
		query = query.substring(0, query.length() - 2);
		query += ' FROM Portal_Applications__c WHERE Functional_Role__c IN :functionalRoleNameSet';
		return new Map<Id, Portal_Applications__c>((List<Portal_Applications__c>) Database.query(query));
	}

	// this is a generic query method (harder to understand/read but highly reusable)
	public static List<Portal_Applications__c> selectQuery(String fields, String conditions, Set<Id> conditionInputSet){
		String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Portal_Applications__c';
		if(conditions != null && String.isNotEmpty(conditions))
			query += ' WHERE ' + conditions;
		if(conditionInputSet != null && !conditionInputSet.isEmpty())
			query += ' IN :conditionInputSet';
		return Database.query(query);
	}
}