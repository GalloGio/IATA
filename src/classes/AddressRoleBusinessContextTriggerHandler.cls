/**
 * Created by LBERB on 11/10/2019.
 */

public with sharing class AddressRoleBusinessContextTriggerHandler {

	public void OnAfterInsert(List<Address_Role_Business_Context__c> newObjects) {
		CustomerSyncUtils customerSUtils = new CustomerSyncUtils();

		// Synchronize to SAP/DMS
		customerSUtils.doSynchronisation(
				new List<CustomerSyncUtils.Context>{
						CustomerSyncUtils.Context.Standard,
						CustomerSyncUtils.Context.Branch
				},
				newObjects,
				SObjectSyncUtils.TYPE_INSERT
		);
	}

	public void OnAfterUpdate(List<Address_Role_Business_Context__c> oldObjects, List<Address_Role_Business_Context__c> updatedObjects, Map<Id, Address_Role_Business_Context__c> updatedObjectsMap) {
		CustomerSyncUtils customerSUtils = new CustomerSyncUtils();

		// Synchronize to SAP/DMS
		customerSUtils.doSynchronisation(
				new List<CustomerSyncUtils.Context>{
						CustomerSyncUtils.Context.Standard,
						CustomerSyncUtils.Context.Branch
				},
				customerSUtils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
				SObjectSyncUtils.TYPE_UPDATE
		);

		ContactSyncUtils contactSyncUtils = new ContactSyncUtils();

		// Synchronize to SAP/DMS
		contactSyncUtils.doSynchronisation(
				contactSyncUtils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
				SObjectSyncUtils.TYPE_UPDATE
		);
	}

	public void OnBeforeDelete(List<Address_Role_Business_Context__c> deletedObjects, Map<Id, Address_Role_Business_Context__c> deletedObjectsMap) {
		CustomerSyncUtils customerSUtils = new CustomerSyncUtils();

		// Synchronize to SAP/DMS
		customerSUtils.doSynchronisation(
				new List<CustomerSyncUtils.Context>{
						CustomerSyncUtils.Context.Standard,
						CustomerSyncUtils.Context.Branch
				},
				deletedObjects,
				SObjectSyncUtils.TYPE_DELETE
		);
	}
}