/**
 * Created by LBERB on 22/10/2019.
 */

public with sharing class AccountContactRoleTriggerHandler {

    public void OnAfterInsert(List<Account_Contact_Role__c> newObjects) {
        ContactSyncUtils utils = new ContactSyncUtils();

        // Synchronize to SAP/DMS
        utils.doSynchronisation(
                newObjects,
                SObjectSyncUtils.TYPE_INSERT
        );
    }

    public void OnAfterUpdate(List<Account_Contact_Role__c> oldObjects, List<Account_Contact_Role__c> updatedObjects, Map<Id, Account_Contact_Role__c> updatedObjectsMap) {
        ContactSyncUtils utils = new ContactSyncUtils();

        // Synchronize to SAP/DMS
        utils.doSynchronisation(
                utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
                SObjectSyncUtils.TYPE_UPDATE
        );
    }

    public void OnBeforeDelete(List<Account_Contact_Role__c> deletedObjects, Map<Id, Account_Contact_Role__c> deletedObjectsMap) {
        ContactSyncUtils utils = new ContactSyncUtils();

        // Synchronize to SAP/DMS
        utils.doSynchronisation(
                deletedObjects,
                SObjectSyncUtils.TYPE_DELETE
        );
    }
}