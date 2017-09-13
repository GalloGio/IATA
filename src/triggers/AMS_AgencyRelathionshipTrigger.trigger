trigger AMS_AgencyRelathionshipTrigger on AMS_Agencies_relationhip__c (after insert, after update, after delete) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agencies_relationhip__c.getSObjectType(), 'AMS_AgencyRelathionshipTrigger')) { return; }
    
    if(!AMS_AgencyRelationshipTriggerHandler.isToRunTrigger)
    	return;

    if (Trigger.isAfter && Trigger.isInsert) {
        AMS_AgencyRelationshipTriggerHandler.handleAfterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        AMS_AgencyRelationshipTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }else if (Trigger.isAfter && Trigger.isDelete) {
        AMS_AgencyRelationshipTriggerHandler.handleAfterDelete(Trigger.old);
    }

}