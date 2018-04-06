trigger Accounts on Account (after delete, after insert, after undelete,
    after update, before delete, before insert, before update) {

    if ( Trigger.isAfter ) {
        if (Trigger.isInsert) {
            AccountHandler.afterInsert(Trigger.new);
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Insert', 'Account__e', 'Account');
        }
        if (Trigger.isUpdate) {
            AccountHandler.afterUpdate(Trigger.new, Trigger.old);
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Update', 'Account__e', 'Account');
        }
        if (Trigger.isDelete) {
            AccountHandler.afterDelete(Trigger.old);
            PlatformEvents_Helper.publishEvents(Trigger.oldMap, 'Delete', 'Account__e', 'Account');
        }
        if (Trigger.isUndelete) {
            AccountHandler.afterUndelete(Trigger.new);
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Undelete', 'Account__e', 'Account');
        }
    }

    if ( Trigger.isAfter && Trigger.isUpdate) {
        if (Utility.getNumericSetting('Stop Trigger:Account') == 1) return;
        Account_Dom.triggerHandler();
    }
}