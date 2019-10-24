/**
 * Created by LBERB on 17/10/2019.
 */

public with sharing class AddressTriggerHandler {

    public void OnAfterUpdate(List<Address__c> oldObjects, List<Address__c> updatedObjects, Map<Id, Address__c> updatedObjectsMap) {
        CustomerSyncUtils utils = new CustomerSyncUtils();

        // Synchronize to SAP/DMS
        utils.doSynchronisation(
                new List<CustomerSyncUtils.Context>{
                        CustomerSyncUtils.Context.Standard,
                        CustomerSyncUtils.Context.Branch,
                        CustomerSyncUtils.Context.Airport
                },
                utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
                SObjectSyncUtils.TYPE_UPDATE
        );
    }
}