trigger AMS_IATAISOCountryTrigger on IATA_ISO_Country__c (after insert, after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(IATA_ISO_Country__c.getSObjectType(), 'AMS_IATAISOCountryTrigger')) { return; }

    AMS_IATAISOCountryTriggerHandler handler = new AMS_IATAISOCountryTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert();
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate();
    }
}