trigger AddressRoleBusinessContextEventTrigger on AddressRoleBusinessContext__e (after insert) {
	new AddressRoleBusinessContextEventHandler().OnAfterInsert(Trigger.new);
}