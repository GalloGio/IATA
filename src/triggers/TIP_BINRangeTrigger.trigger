trigger TIP_BINRangeTrigger on TIP_BIN_Range__c (before insert, before update) {

	TIP_BINRangeTriggerHandler handler = new TIP_BINRangeTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
}