trigger ContentVersionTrigger on ContentVersion (after insert, before insert, before update) {

    /* After Insert */
    if(trigger.isInsert && trigger.isAfter) {
        ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler();
    }

    if(trigger.isInsert && trigger.isBefore) {
        GADM_FileSharing.assignGadmRecordType(trigger.New);
    }
}