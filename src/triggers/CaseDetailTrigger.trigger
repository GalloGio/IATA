trigger CaseDetailTrigger on Case_Detail__c(before insert, before update) {

    CaseDetailTriggerHandler handler = new CaseDetailTriggerHandler();

    if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
    //if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
    if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
    //if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
    //if(Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();
    //if(Trigger.isAfter && Trigger.isDelete) handler.onAfterDelete();

}