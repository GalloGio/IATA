public class PortalApplicationSelector {
	public static List<Portal_Applications__c> selectIdByName(Set<String> nameSet){
		return [SELECT Id FROM Portal_Applications__c WHERE Name IN :nameSet];
	}

	public static List<Portal_Applications__c> selectAutoGrantAccountRoleByName(Set<String> nameSet){
		return [SELECT Id, Auto_grant_Account_Role__c FROM Portal_Applications__c WHERE Name IN :nameSet];
	}
}