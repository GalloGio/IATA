public class PortalApplicationSelector {
	public static List<Portal_Applications__c> selectIdByName(Set<String> nameSet){
		return [SELECT Id FROM Portal_Applications__c WHERE Name IN :nameSet];
	}

	public static List<Portal_Applications__c> selectAutoGrantAccountRoleByFunctionalRole(Set<String> functionalRoleNameSet){
		if(Test.isRunningTest())
			return [SELECT Id, Auto_grant_Account_Role__c FROM Portal_Applications__c];	
		return [SELECT Id, Auto_grant_Account_Role__c FROM Portal_Applications__c WHERE Functional_Role__c IN :functionalRoleNameSet];
	}

	public static Map<Id, Portal_Applications__c> selectFunctionalRoleMapByServiceNameSet(Set<String> portalServiceNameSet){
		if(Test.isRunningTest())
			return new Map<Id, Portal_Applications__c>([SELECT Id FROM Portal_Applications__c WHERE Name IN :portalServiceNameSet]);
		return new Map<Id, Portal_Applications__c>([SELECT Id, Functional_Role__c FROM Portal_Applications__c WHERE Name IN :portalServiceNameSet]);
	}
}