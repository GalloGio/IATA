trigger ContentVersionTrigger on ContentVersion (after insert) {

    /* After Insert */
    if(trigger.isInsert && trigger.isAfter) {
        ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler();
    }

}