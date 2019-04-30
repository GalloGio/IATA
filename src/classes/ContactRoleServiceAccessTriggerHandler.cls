public with sharing class ContactRoleServiceAccessTriggerHandler {

    public void OnBeforeInsert(List<Contact_Role_Service_Access__c> newObjects) {
        for(Contact_Role_Service_Access__c newObject : newObjects) {
            newObject.UniqueKey__c = String.ValueOf(newObject.Service__c).left(15) + '_' + String.valueOf(newObject.Contact_Role__c).left(15);
        }
    }

    public void OnBeforeUpdate(List<Contact_Role_Service_Access__c> oldObjects, List<Contact_Role_Service_Access__c> updatedObjects, Map<Id, Contact_Role_Service_Access__c> oldMap) {
        for(Contact_Role_Service_Access__c newObject : updatedObjects) {
            Contact_Role_Service_Access__c oldObject = oldMap.get(newObject.Id);
            if((oldObject.Service__c != newObject.Service__c) || (oldObject.Contact_Role__c != newObject.Contact_Role__c)) {
                newObject.UniqueKey__c = String.ValueOf(newObject.Service__c).left(15) + '_' + String.valueOf(newObject.Contact_Role__c).left(15);
            }
        }
    }

}