trigger ISSOperationTrigger on AMS_Settlement_System__c (before insert, before update, before delete,  
														after insert, after update, after delete, after undelete) {
	
	if(trigger.isInsert && trigger.isAfter) ISSOperationTriggerhandler.handleAfterInsert(trigger.new, trigger.oldMap);
	if(trigger.isUpdate && trigger.isAfter) ISSOperationTriggerhandler.handleAfterUpdate(trigger.new, trigger.oldMap);

}