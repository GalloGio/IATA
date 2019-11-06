/**
 * Created by LBERB on 22/10/2019.
 */

public with sharing class ContactTriggerHandler {
	public void OnAfterUpdate(List<Contact> oldObjects, List<Contact> updatedObjects, Map<Id, Contact> updatedObjectsMap) {
		ContactSyncUtils utils = new ContactSyncUtils();
		utils.doSynchronisation(
				utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
				Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
		);
	}
}