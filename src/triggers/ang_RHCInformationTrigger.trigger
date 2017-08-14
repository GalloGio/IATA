trigger ang_RHCInformationTrigger on ANG_RHC_Information__c (before insert, after insert, before update, after update) {

	ang_RHCInformationTriggerHandler handler = new ang_RHCInformationTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
	if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();



}