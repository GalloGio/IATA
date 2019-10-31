trigger LeadTrigger on Lead (before insert, before update, after delete) {

    if(!AMS_TriggerExecutionManager.checkExecution(Lead.getSObjectType(), 'LeadTrigger')) { return; }

    LeadTriggerHandler handler = new LeadTriggerHandler();

    if(Trigger.isBefore && Trigger.isInsert){
        handler.onBeforeInsert();
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        handler.onBeforeUpdate();
    }

    if(Trigger.isAfter && Trigger.isDelete){
        handler.onAfterDelete();
    }
    	
}