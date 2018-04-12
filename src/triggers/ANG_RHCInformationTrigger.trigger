trigger ANG_RHCInformationTrigger on ANG_RHC_Information__c (before insert, after insert, before update, after update, before delete, after delete) {

	ANG_RHCInformationTriggerHandler handler = new ANG_RHCInformationTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	if(Trigger.isAfter && Trigger.isUpdate) handler.onAfterUpdate();
	if(Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();
	if(Trigger.isAfter && Trigger.isDelete) handler.onAfterDelete();
}