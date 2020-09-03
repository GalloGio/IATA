public with sharing class CaseItems {
	public static String integrationUserProfileName = 'System Administrator - automated processes';

	public Map<Id, Case_Item__c> recordsMap { get; private set; }

	public CaseItems(Map<Id,Case_Item__c> caseItemMap){
		recordsMap = caseItemMap;
	}

	public void onBeforeDelete(){
		// cannot delete a case item that is NOT closed
		for(Case_Item__c caseItem : recordsMap.values()){
			if(caseItem.Status__c != 'Closed (Closed)'){
				caseItem.addError('Cannot delete a Case Item unless it is Closed');
			}
		}
	}

	public void onAfterInsert(){
		publishCaseItemsPlatformEvent(recordsMap, true, false, false, false);
	}

	public void onAfterUpdate(){
		publishCaseItemsPlatformEvent(recordsMap, false, true, false, false);
	}

	public void onAfterDelete(){
		publishCaseItemsPlatformEvent(recordsMap, false, false, true, false);
	}

	public void onAfterUndelete(){
		publishCaseItemsPlatformEvent(recordsMap, false, false, false, true);
	}

	public static void publishCaseItemsPlatformEvent(Map<Id, Case_Item__c> recordsMap, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isUndelete){
		//only fire platform event if user is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			PlatformEvents_Helper.publishEvents(recordsMap, 'Case_PE__e', 'Case_Item__c', isInsert, isUpdate, isDelete, isUndelete);
		}
	}

	//get the profile id for the integration user
	public static boolean getIsIntegrationUser(){
		return UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = :CaseItems.integrationUserProfileName LIMIT 1].get(0).Id ? true : false;
	}
}