trigger AMS_AgencyRelathionshipTrigger on AMS_Agencies_relationhip__c (after insert, after update, after delete) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agencies_relationhip__c.getSObjectType(), 'AMS_AgencyRelathionshipTrigger')) { return; }
    
    if(!AMS_AgencyRelationshipTriggerHandler.isToRunTrigger)
    	return;

    if (Trigger.isAfter && Trigger.isInsert) {

        List<AMS_Agencies_relationhip__c> triggerRels = AMS_AgencyRelationshipTriggerHandler.filterRelationsByAMS(Trigger.new);

        if(triggerRels.isEmpty()){
            System.debug('[AMS_AgencyRelathionshipTrigger] Nothing to do on this trigger.');
            return;
        }

        AMS_AgencyRelationshipTriggerHandler.handleAfterInsert(triggerRels);
        
    } else if (Trigger.isAfter && Trigger.isUpdate) {

        List<AMS_Agencies_relationhip__c> triggerRels = AMS_AgencyRelationshipTriggerHandler.filterRelationsByAMS(Trigger.new);

        if(triggerRels.isEmpty()){
            System.debug('[AMS_AgencyRelathionshipTrigger] Nothing to do on this trigger.');
            return;
        }

        AMS_AgencyRelationshipTriggerHandler.handleAfterUpdate(triggerRels, Trigger.oldMap);

    }else if (Trigger.isAfter && Trigger.isDelete) {
        //AMS_AgencyRelationshipTriggerHandler.handleAfterDelete(Trigger.old);
    }

}