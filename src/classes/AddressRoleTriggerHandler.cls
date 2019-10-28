/**
 * Created by LBERB on 17/10/2019.
 */

public with sharing class AddressRoleTriggerHandler {
	public void OnAfterUpdate(List<Address_Role__c> oldObjects, List<Address_Role__c> updatedObjects, Map<Id, Address_Role__c> updatedObjectsMap) {
		CustomerSyncUtils utils = new CustomerSyncUtils();
		utils.doSynchronisation(
			new List<CustomerSyncUtils.Context>{
				CustomerSyncUtils.Context.Standard,
				CustomerSyncUtils.Context.Branch
			},
			utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
			SObjectSyncUtils.TYPE_UPDATE
		);
	}
}