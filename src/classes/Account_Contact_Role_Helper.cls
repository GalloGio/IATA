public without sharing class Account_Contact_Role_Helper {

    public static void checkForGadmUserRole(List<Account_Contact_Role__c> accountContactRoles) {

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        List<Contact_Roles__c> gadmRoles = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];
        Contact_Roles__c gadmRole = null;
        if(gadmRoles == null || gadmRoles.size() == 0){
            return;
        } else {
            gadmRole = gadmRoles[0];
        }

        Set<Id> contactIds = new Set<Id>();
        for(Account_Contact_Role__c role : accountContactRoles) {
            contactIds.add(role.Contact__c);
        }

        //check among existing Account Contact Roles
        List<Account_Contact_Role__c> existingAccountContactRoles = [SELECT Id, Contact__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact__c = :contactIds AND Contact_Roles__c = :gadmRole.Id];
        Map<Id, Account_Contact_Role__c> existingContactIdToRoleMap = new Map<Id, Account_Contact_Role__c>();
        for(Account_Contact_Role__c existingRole : existingAccountContactRoles) {
            existingContactIdToRoleMap.put(existingRole.Contact__c, existingRole);
        }

        for(Account_Contact_Role__c newRole : accountContactRoles) {
            if(newRole.RecordTypeId == functionalRecordTypeId && newRole.Contact_Roles__c == gadmRole.Id) {
                if(existingContactIdToRoleMap.get(newRole.Contact__c)!= null) {
                    if(existingContactIdToRoleMap.get(newRole.Contact__c).Id != newRole.Id) {
                        newRole.addError(System.Label.GADM_account_contact_role_gadm_user + '[' + existingContactIdToRoleMap.get(newRole.Contact__c).Id + ']');
                    }
                }
            }

        }


        //check among new objects
        Map<Id, List<Account_Contact_Role__c>> newContactIdToRoleMap = new Map<Id, List<Account_Contact_Role__c>>();
        for(Account_Contact_Role__c newAccountContactRole : accountContactRoles) {
            if(newAccountContactRole.RecordTypeId == functionalRecordTypeId && newAccountContactRole.Contact_Roles__c == gadmRole.Id) {
                if(newContactIdToRoleMap.get(newAccountContactRole.Contact__c) == null) {
                    newContactIdToRoleMap.put(newAccountContactRole.Contact__c, new List<Account_Contact_Role__c>{newAccountContactRole});
                }else{
                    newContactIdToRoleMap.get(newAccountContactRole.Contact__c).add(newAccountContactRole);
                }
            }

        }

        for(Id contactId : newContactIdToRoleMap.keySet()) {
            List<Account_Contact_Role__c> newAccountContactRoles = newContactIdToRoleMap.get(contactId);

            if(newAccountContactRoles.size() > 1) {
                newAccountContactRoles[0].addError(System.Label.GADM_account_contact_role_gadm_user);
            }
        }
    }

}