trigger AMS_InspectionTrigger on AMS_Inspection__c (before insert, before update, after insert, after update, after delete) {

	   
    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Inspection__c.getSObjectType(), 'AMS_InspectionTrigger')) { return; }

     //Delete Agency Owner created by AMS AccountRole
    //if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.crossDeleteAccreditations(Trigger.old);
    

    if(Trigger.isAfter && Trigger.isInsert){

        AMS_InspectionTriggerHandler.handleAfterInsert(Trigger.old, Trigger.new);

    }

    if(Trigger.isAfter && Trigger.isUpdate){

        AMS_InspectionTriggerHandler.handleAfterUpdate(Trigger.old, Trigger.new);

    }

}