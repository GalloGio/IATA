/**
 * Created by LBERB on 22/10/2019.
 */

public with sharing class ContactTriggerHandler {

    public void OnAfterUpdate(List<Contact> oldObjects, List<Contact> updatedObjects, Map<Id, Contact> updatedObjectsMap) {
        ContactSyncUtils utils = new ContactSyncUtils();

        // Synchronize to SAP/DMS
        utils.doSynchronisation(
                utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
                SObjectSyncUtils.TYPE_UPDATE
        );
    }
}