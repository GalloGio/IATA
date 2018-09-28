trigger RemoteInvocationTrigger on Remote_Invocation__c (after update) {

	if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            RemoteInvocationTriggerHandler.handleBeforeInsert();
        }
    }

	if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            RemoteInvocationTriggerHandler.handleAfterUpdate();
        }
    }
}