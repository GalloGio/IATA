trigger AMS_AgencyRegulationTrigger on AMS_Agency_Regulation__c (before insert, before update) {

    if(trigger.isBefore && trigger.isInsert){
        AMS_AgencyRegulationTriggerHandler.handleBeforeInsert();
    }else if(trigger.isBefore && trigger.isUpdate){
        AMS_AgencyRegulationTriggerHandler.handleBeforeUpdate();
    }

}