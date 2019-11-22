public with sharing class AddressRoleBusinessContextTriggerHandler {
    public void OnAfterInsert(List<Address_Role_Business_Context__c> newObjects) {
	new CustomerSyncUtils().doSynchronisation(
		new List<CustomerSyncUtils.Context>{
			CustomerSyncUtils.Context.Standard,
			CustomerSyncUtils.Context.Branch
		},
		newObjects,
		Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
	);
    }

    public void OnAfterUpdate(List<Address_Role_Business_Context__c> oldObjects, List<Address_Role_Business_Context__c> updatedObjects, Map<Id, Address_Role_Business_Context__c> updatedObjectsMap) {
	CustomerSyncUtils customerSUtils = new CustomerSyncUtils();
	customerSUtils.doSynchronisation(
		new List<CustomerSyncUtils.Context>{
			CustomerSyncUtils.Context.Standard,
			CustomerSyncUtils.Context.Branch
		},
		customerSUtils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
		Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
	);
	ContactSyncUtils contactSyncUtils = new ContactSyncUtils();
	contactSyncUtils.doSynchronisation(
		contactSyncUtils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
		Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
	);
    }

    public void OnBeforeDelete(List<Address_Role_Business_Context__c> deletedObjects, Map<Id, Address_Role_Business_Context__c> deletedObjectsMap) {
	new CustomerSyncUtils().doSynchronisation(
		new List<CustomerSyncUtils.Context>{
			CustomerSyncUtils.Context.Standard,
			CustomerSyncUtils.Context.Branch
		},
		deletedObjects,
		Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
	);
    }
}