trigger AddressRoleBusinessContextEventTrigger on AddressRoleBusinessContext__e (after insert) {
	AddressRoleBusinessContextEventHandler handler = new AddressRoleBusinessContextEventHandler();

	if (Trigger.isInsert && Trigger.isAfter) {
		handler.OnAfterInsert(Trigger.new);
	}
}