trigger AddressRoleTrigger on Address_Role__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	AddressRoleTriggerHandler handler = new AddressRoleTriggerHandler();

	if (Trigger.isUpdate && Trigger.isAfter) {
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
}