trigger ISSP_UserTrigger on User (before insert, before update) {
    
    if(ISSP_UserTriggerHandler.preventTrigger)
        return;
        
    if(trigger.isBefore && trigger.isInsert)
        ISSP_UserTriggerHandler.onBeforeInsert(trigger.new, trigger.newMap); 
    if(trigger.isBefore && trigger.isUpdate) 
        ISSP_UserTriggerHandler.onBeforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);

}