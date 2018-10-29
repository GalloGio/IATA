trigger RemoteInvocationTrigger on Remote_Invocation__c (before insert, before update) {

	if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            new RemoteInvocationTriggerHandler().handleBeforeInsert();
        }
         if (Trigger.isUpdate) {
            new RemoteInvocationTriggerHandler().handleBeforeUpdate();
        }
    }
}