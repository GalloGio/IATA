trigger TIP_BINRangeTrigger on TIP_BIN_Range__c (before insert) {

	TIP_BINRangeTriggerHandler handler = new TIP_BINRangeTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
}