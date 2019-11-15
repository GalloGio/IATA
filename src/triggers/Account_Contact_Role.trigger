trigger Account_Contact_Role on Account_Contact_Role__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AccountContactRoleTriggerHandler handler = new AccountContactRoleTriggerHandler();

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        //handler.OnBeforeInsert(Trigger.new);
    }
    /* After Insert */ else if (Trigger.isInsert && Trigger.isAfter) {
        handler.OnAfterInsert(Trigger.new);
    }
//    /* Before Update */ else if (Trigger.isUpdate && Trigger.isBefore) {
//        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
//    }
    /* After Update */ else if (Trigger.isUpdate && Trigger.isAfter) {
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    /* Before Delete */ else if (Trigger.isDelete && Trigger.isBefore) {
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
//    /* After Delete */ else if (Trigger.isDelete && Trigger.isAfter) {
//        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
//    }
//    /* After Undelete */ else if (Trigger.isUnDelete) {
//        handler.OnUndelete(Trigger.new);
//    }


    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            Id tipRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Payment_Provider_Contact');
            for(Account_Contact_Role__c acr:trigger.new){
                if(acr.RecordTypeId == tipRT){
                    acr.UniqueKey__c = TIP_Utils.AccountContactRoleGenerateUniquekey(acr);
                }
            }

            Account_Contact_Role_Helper.generateGadmUniqueKey(Trigger.new);
            Account_Contact_Role_Helper.checkForGadmUserRole(Trigger.new);
        }
    }
    
    //Trigger the platform events    
    if(trigger.isAfter){
        ShareObjectsToExternalUsers.shareObjectsByRoleOnAccountContactRoleChange(Trigger.new ,Trigger.oldMap);
        if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0 && !System.isFuture() && !System.isBatch()) {
            System.enqueueJob(new PlatformEvents_Helper((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete));
        } else {
            PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
        }
    }
}