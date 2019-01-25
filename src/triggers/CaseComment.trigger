trigger CaseComment on CaseComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CaseCommentHandler handler = new CaseCommentHandler();
    
    
    if ( Trigger.isAfter ) {
        if (Trigger.isInsert) {
            handler.doAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
        }
        if (Trigger.isDelete) {
        }
        if (Trigger.isUndelete) {
        }
    } else if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseCommentHandler.doBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
        }
        if (Trigger.isDelete) {
        }
    }
}