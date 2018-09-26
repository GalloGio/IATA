trigger TIP_BINRangeTrigger on TIP_BIN_Range__c (after delete, after insert, after undelete,
    after update, before delete, before insert, before update) {

	TIP_BINRangeTriggerHandler handler = new TIP_BINRangeTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	if(Trigger.isAfter  && Trigger.isInsert)  handler.onAfterInsert();
	if(Trigger.isAfter  && Trigger.isUpdate)  handler.onAfterUpdate();
	
	if (Trigger.isAfter) {
        //Publish the platform events
        PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Product_Bin_Range__e', 'TIP_BIN_Range__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    }
}