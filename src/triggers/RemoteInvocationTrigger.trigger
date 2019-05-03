trigger RemoteInvocationTrigger on Remote_Invocation__c (before insert, before update, after insert, after update, after delete, after undelete) {

	if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            new RemoteInvocationTriggerHandler().handleBeforeInsert();
        }
         if (Trigger.isUpdate) {
            new RemoteInvocationTriggerHandler().handleBeforeUpdate();
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            new RemoteInvocationTriggerHandler().handleAfterInsert();
        }
         if (Trigger.isUpdate) {
            new RemoteInvocationTriggerHandler().handleAfterUpdate();
        }
        if (Trigger.isDelete) {
            new RemoteInvocationTriggerHandler().handleAfterDelete();
        }
         if (Trigger.isUndelete) {
            new RemoteInvocationTriggerHandler().handleAfterUndelete();
        }
    }
}