trigger FinancialInstitution on Financial_Institution__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if ( Trigger.isAfter ) {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
            FinancialInstitutionHandler.doAfterUpdate(Trigger.new);
        }
        if (Trigger.isDelete) {
        }
        if (Trigger.isUndelete) {
        }
    } else if (Trigger.isBefore) {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
            FinancialInstitutionHandler.doBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
        }
    }
}