trigger Locations on Location__c (after delete, after insert, after update, before delete, before insert, before update) {
	if (Utility.getNumericSetting('Stop Trigger:Location') == 1) return;
	Location_dom.triggerHandler();
}
