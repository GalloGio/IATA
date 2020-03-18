trigger AddressTrigger on Address__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	AddressTriggerHandler handler = new AddressTriggerHandler();

	if (Trigger.isUpdate && Trigger.isAfter) {
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
}