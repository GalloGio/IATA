public  class PortalApplicationRightSelector {
	public static Id selectIdByContactIdAndServiceId(Id contactId, Id portalApplicationId){
		return [SELECT Id FROM Portal_Application_Right__c WHERE Contact__c = :contactId AND Portal_Application__c = :portalApplicationId].get(0).Id;
	}

	public static Portal_Application_Right__c selectByContactIdAndServiceId(Id contactId, Id portalApplicationId){
		return [SELECT Id FROM Portal_Application_Right__c WHERE Contact__c = :contactId AND Portal_Application__c = :portalApplicationId LIMIT 1];
	}
}