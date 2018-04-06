trigger Contacts on Contact (after delete, after insert, after undelete,
    after update, before delete, before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountDomainContactHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            AccountDomainContactHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

    if (Trigger.isAfter) {
        EF_ContactHandler.handleAfterUpdate();
        if (Trigger.isInsert) {
            ContactHandler.afterInsert(Trigger.new);
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Insert', 'Contact__e', 'Contact');
        }
        if (Trigger.isUpdate) {
            ContactHandler.afterUpdate(Trigger.new, Trigger.old);
            //manage critical field notifications on after update
            EF_ContactHandler.manageCriticalFieldChanges(trigger.new, trigger.oldMap);
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Update', 'Contact__e', 'Contact');
        }
        if (Trigger.isDelete) {
            ContactHandler.afterDelete(Trigger.old);
            PlatformEvents_Helper.publishEvents(Trigger.oldMap, 'Delete', 'Contact__e', 'Contact');
        }
        if (Trigger.isUndelete) {
            ContactHandler.afterUndelete(Trigger.new);
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Undelete', 'Contact__e', 'Contact');
        }
    }

    if (Utility.getNumericSetting('Stop Trigger:Contact') == 1) return;
    Contact_Dom.triggerHandler();

}