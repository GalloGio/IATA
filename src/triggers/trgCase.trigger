trigger trgCase on Case (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            SidraLiteManager.insertSidraLiteCases(Trigger.new);
        }
        if (Trigger.isUpdate) {
            SidraLiteManager.updateSidraLiteCases(Trigger.new, Trigger.old);
        }
        if (Trigger.isDelete) {

        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SidraLiteManager.afterInsertSidraLiteCases(Trigger.new);
            //AMS_CaseTriggerHandler.handleAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            //SidraLiteManager.afterUpdateSidraLiteCases(Trigger.new, Trigger.old);
        }
        if (Trigger.isDelete) {

        }
        if (Trigger.isUndelete) {

        }
    }
}