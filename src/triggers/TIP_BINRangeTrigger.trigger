trigger TIP_BINRangeTrigger on TIP_BIN_Range__c (after delete, after insert, after undelete,
    after update, before delete, before insert, before update) {

	TIP_BINRangeTriggerHandler handler = new TIP_BINRangeTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	
	if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Insert', 'Product_Bin_Range__e', 'TIP_BIN_Range__c');
        }
        if (Trigger.isUpdate) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Update', 'Product_Bin_Range__e', 'TIP_BIN_Range__c');
        }
        if (Trigger.isDelete) {
            PlatformEvents_Helper.publishEvents(Trigger.oldMap, 'Delete', 'Product_Bin_Range__e', 'TIP_BIN_Range__c');
        }
        if (Trigger.isUndelete) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Undelete', 'Product_Bin_Range__e', 'TIP_BIN_Range__c');
        }
    }
}