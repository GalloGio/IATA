public class ContactRoleServiceAccessTriggerHandler {

    public void OnBeforeInsert(List<Contact_Role_Service_Access__c> newObjects) {
        /*for(Contact_Role_Service_Access__c newObject : newObjects) {
            newObject.UniqueKey__c = String.ValueOf(newObject.Service__c).left(15) + '_' + String.valueOf(newObject.Contact_Role__c).left(15);

        }*/
        fillUniqueKey(newObjects);
        fillAccountAndContact(newObjects);
    }

    public void OnBeforeUpdate(List<Contact_Role_Service_Access__c> oldObjects, List<Contact_Role_Service_Access__c> updatedObjects, Map<Id, Contact_Role_Service_Access__c> oldMap) {
        /*for(Contact_Role_Service_Access__c newObject : updatedObjects) {
            Contact_Role_Service_Access__c oldObject = oldMap.get(newObject.Id);
            if((oldObject.Service__c != newObject.Service__c) || (oldObject.Contact_Role__c != newObject.Contact_Role__c)) {
                newObject.UniqueKey__c = String.ValueOf(newObject.Service__c).left(15) + '_' + String.valueOf(newObject.Contact_Role__c).left(15);
            }
        }*/
        fillUniqueKey(updatedObjects);
        fillAccountAndContact(updatedObjects);
    }


    private void fillUniqueKey(List<Contact_Role_Service_Access__c> newObjects) {
        for(Contact_Role_Service_Access__c newObject : newObjects) {
            newObject.UniqueKey__c = String.ValueOf(newObject.Service__c).left(15) + '_' + String.valueOf(newObject.Contact_Role__c).left(15);
        }
    }



    private void fillAccountAndContact(List<Contact_Role_Service_Access__c> newObjects) {
        Set<Id> accountContactRoleIds = new Set<Id>();
        for(Contact_Role_Service_Access__c serviceAccess : newObjects) {
            accountContactRoleIds.add(serviceAccess.Contact_Role__c);
        }
        //fill Contact and Account
        Map<Id, Account_Contact_Role__c> contactRoleToContactMap = new Map<Id, Account_Contact_Role__c>([SELECT Id, Contact__c, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Id = :accountContactRoleIds]);
        for(Contact_Role_Service_Access__c serviceAccess : newObjects) {
            if(contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Contact__c != null) {
                serviceAccess.Contact__c = contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Contact__c;
            }
            if(contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Account_Role__r.Account__c != null) {
                serviceAccess.Account__c = contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Account_Role__r.Account__c;
            }

        }

    }

}