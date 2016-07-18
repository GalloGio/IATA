trigger Contacts on Contact (after delete, after insert, after update, before delete, before insert, before update) {
	Contact_Dom.triggerHandler();
}