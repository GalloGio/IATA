public with sharing class CW_ICG_Capability_Asgmt_Group_Handler {
	public static void handleAfterInsert(List<ICG_Capability_Assignment_Group__c> newList) {
		CW_ICG_Capability_Asgmt_Group_Helper.updateCargoCommodities(newList);
	}
	public static void handleAfterUpdate(List<ICG_Capability_Assignment_Group__c> newList) {
		CW_ICG_Capability_Asgmt_Group_Helper.updateCargoCommodities(newList);
	}
}