/*
* Company    : HARDIS Bordeaux
* Created on : 21-10-2019
* Author     : BTH
*/
trigger IntegrationLogTrigger on Integration_Log__c (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            IntegrationLogTriggerHandler.OnAfterUpdate((List<Integration_Log__c>)Trigger.new, (Map<Id, Integration_Log__c>)Trigger.oldMap);
        }
    }
}