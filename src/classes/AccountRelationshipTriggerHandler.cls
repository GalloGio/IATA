/**
 * Created by LBERB on 17/10/2019.
 */

public with sharing class AccountRelationshipTriggerHandler {
    public void OnAfterInsert(List<Account_Relationship__c> newObjects) {
        new CustomerSyncUtils().doSynchronisation(
                new List<CustomerSyncUtils.Context>{
                        CustomerSyncUtils.Context.Airport
                },
                newObjects,
                Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
        );
    }

    public void OnAfterUpdate(List<Account_Relationship__c> oldObjects, List<Account_Relationship__c> updatedObjects, Map<Id, Account_Relationship__c> updatedObjectsMap) {
        CustomerSyncUtils utils = new CustomerSyncUtils();
        utils.doSynchronisation(
                new List<CustomerSyncUtils.Context>{
                        CustomerSyncUtils.Context.Airport
                },
                utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
                Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
        );
    }


    public void OnBeforeDelete(List<Account_Relationship__c> deletedObjects, Map<Id, Account_Relationship__c> deletedObjectsMap) {
        new CustomerSyncUtils().doSynchronisation(
                new List<CustomerSyncUtils.Context>{
                        CustomerSyncUtils.Context.Airport
                },
                deletedObjects,
                Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
        );
    }
}