trigger AMS_OSCARTrigger on AMS_OSCAR__c (before insert, before update, after insert, after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_OSCAR__c.getSObjectType(), 'AMS_OSCARTrigger')) { return; }
	

    if (Trigger.isBefore && Trigger.isInsert) {
			AMS_OSCARTriggerHandler.handleBeforeInsert();
    }	else if (Trigger.isBefore && Trigger.isUpdate) {
        	AMS_OSCARTriggerHandler.handleBeforeUpdate(Trigger.new);
    }	else if(trigger.isAfter && trigger.isInsert){
        	AMS_OSCARTriggerHandler.handleAfterInsert();
        	new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
    }	else if(trigger.isAfter && trigger.isUpdate){
        	AMS_OSCARTriggerHandler.handleAfterUpdate();
        	new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
    }

}