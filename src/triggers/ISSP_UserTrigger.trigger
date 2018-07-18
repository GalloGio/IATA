trigger ISSP_UserTrigger on User (before insert, before update, after insert,after update) {
    
    if(ANG_UserTriggerHandler.doNotRun) return;

	if(AMS_TriggerExecutionManager.checkExecution(User.getSObjectType(), 'ISSP_UserTrigger')) { 
		ANG_UserTriggerHandler handler = new ANG_UserTriggerHandler();

		//add other validations if necessary (and add on the trigger declaration as well)
		if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
		if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
		if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
        if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
	}
    
    if(ISSP_UserTriggerHandler.preventTrigger)
        return;
        
    if(trigger.isBefore && trigger.isInsert)
        ISSP_UserTriggerHandler.onBeforeInsert(trigger.new, trigger.newMap); 
    if(trigger.isBefore && trigger.isUpdate) 
        ISSP_UserTriggerHandler.onBeforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

}