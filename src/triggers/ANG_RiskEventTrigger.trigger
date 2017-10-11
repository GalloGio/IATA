trigger ANG_RiskEventTrigger on ANG_Agency_Risk_Event__c (before insert, after insert, before update, after update, before delete, after delete) {

	if(!AMS_TriggerExecutionManager.checkExecution(ANG_Agency_Risk_Event__c.getSObjectType(), 'ANG_RiskEventTrigger')) { return; }

	ANG_RiskEventTriggerHandler handler = new ANG_RiskEventTriggerHandler();

	//add other validations if necessary (and add on the trigger declaration as well)
	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
	if(Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();
	if(Trigger.isAfter && Trigger.isDelete) handler.onAfterDelete();

}
