public with sharing class CW_ICGContactRoleDetailHandler {
	public static void handleAfterInsert(List<ICG_Contact_Role_Detail__c> newList) {
		CW_OneSourceGxAProvision.provisionOrDeprovisionRolesAndContacts(newList, null);
	}
	public static void handleAfterUpdate(List<ICG_Contact_Role_Detail__c> newList, Map<Id,ICG_Contact_Role_Detail__c> oldMap) {
		CW_OneSourceGxAProvision.provisionOrDeprovisionRolesAndContacts(newList, oldMap);
		if(newList.size()==1) CW_Utilities.sendApproveOrRejectMailsContactRole(newList[0], oldMap.values()[0]);
	}
	public static void handleAfterDelete(Map<Id,ICG_Contact_Role_Detail__c> oldMap) {
		CW_OneSourceGxAProvision.provisionOrDeprovisionRolesAndContacts(null, oldMap);
	}
}