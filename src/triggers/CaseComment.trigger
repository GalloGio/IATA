trigger CaseComment on CaseComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if ( Trigger.isAfter ) {
        if (Trigger.isInsert) {
            Unbabel_CaseCommentRequestTranslation.requestTranslation(Trigger.new);
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