trigger ANG_RiskAlertTrigger on ANG_Risk_Alert__c (before insert,before update,before Delete, after Insert, after update, after delete) {
	ang_rhcAlertTriggerHandler handler = new ang_rhcAlertTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
	if(Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();
	if(Trigger.isAfter && Trigger.isDelete) handler.onAfterDelete();

}