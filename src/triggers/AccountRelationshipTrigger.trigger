trigger AccountRelationshipTrigger on Account_Relationship__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	AccountRelationshipTriggerHandler handler = new AccountRelationshipTriggerHandler();

	if (Trigger.isInsert && Trigger.isAfter) {
		handler.OnAfterInsert(Trigger.new);
	}
	else if (Trigger.isUpdate && Trigger.isAfter) {
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
	else if (Trigger.isDelete && Trigger.isBefore) {
		handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	}
}