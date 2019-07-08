trigger GADM_AccountServiceDetailTrigger on GADM_Account_Service_Detail__c (before insert, after insert, before update, after update, after delete) {

    if(Trigger.isInsert) {

        if(Trigger.isBefore) {
            GADM_AccountServiceDetailTriggerHelper.checkGadmDuplicates(Trigger.isInsert, Trigger.isUpdate, null, Trigger.new);
        }

        if(Trigger.isAfter) {
            GADM_AccountServiceDetailTriggerHelper.publishEvents(null, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
    }

    if(Trigger.isUpdate) {

        if(Trigger.isBefore) {
            GADM_AccountServiceDetailTriggerHelper.checkGadmDuplicates(Trigger.isInsert, Trigger.isUpdate, Trigger.oldMap, Trigger.new);
        }

        if(Trigger.isAfter) {
            GADM_AccountServiceDetailTriggerHelper.publishEvents(Trigger.oldMap, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }

    }

    if(Trigger.isDelete) {

        if(Trigger.isAfter) {
            GADM_AccountServiceDetailTriggerHelper.publishEvents(Trigger.oldMap, null, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }

    }

}