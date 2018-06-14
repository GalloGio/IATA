trigger AMS_AgencyRegulationTrigger on AMS_Agency_Regulation__c (before insert, before update, after insert, after update, after delete) {

    if(trigger.isBefore && trigger.isInsert){
        AMS_AgencyRegulationTriggerHandler.handleBeforeInsert();
    }else if(trigger.isBefore && trigger.isUpdate){
        AMS_AgencyRegulationTriggerHandler.handleBeforeUpdate();
    }else if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        AMS_AgencyRegulationTriggerHandler.countAccountDGR(Trigger.new);
    }else if(trigger.isAfter && trigger.isDelete ){
        AMS_AgencyRegulationTriggerHandler.countAccountDGR(Trigger.old);
    }

}