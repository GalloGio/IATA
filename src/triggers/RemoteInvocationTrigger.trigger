trigger RemoteInvocationTrigger on Remote_Invocation__c (before insert, before update) {

	if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            RemoteInvocationTriggerHandler.handleBeforeInsert();
        }
         if (Trigger.isUpdate) {
            RemoteInvocationTriggerHandler.handleBeforeUpdate();
        }
    }
}