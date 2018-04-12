trigger Accounts on Account (after delete, after insert, after undelete,
    after update, before delete, before insert, before update) {

    if ( Trigger.isAfter ) {
        if (Trigger.isInsert) {
            AccountHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AccountHandler.afterUpdate(Trigger.new, Trigger.old);
        }
        if (Trigger.isDelete) {
            AccountHandler.afterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            AccountHandler.afterUndelete(Trigger.new);
        }
    }

    if ( Trigger.isAfter && Trigger.isUpdate) {
        if (Utility.getNumericSetting('Stop Trigger:Account') == 1) return;
        Account_Dom.triggerHandler();
    }
}