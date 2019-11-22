public with sharing class AccountContactRoleTriggerHandler {
	public void OnAfterInsert(List<Account_Contact_Role__c> newObjects) {
		new ContactSyncUtils().doSynchronisation(newObjects, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
	}

	public void OnAfterUpdate(List<Account_Contact_Role__c> oldObjects, List<Account_Contact_Role__c> updatedObjects, Map<Id, Account_Contact_Role__c> updatedObjectsMap) {
		ContactSyncUtils utils = new ContactSyncUtils();
		utils.doSynchronisation(
				utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
				Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
		);
	}

	public void OnBeforeDelete(List<Account_Contact_Role__c> deletedObjects, Map<Id, Account_Contact_Role__c> deletedObjectsMap) {
		new ContactSyncUtils().doSynchronisation(deletedObjects, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
	}
}