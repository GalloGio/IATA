trigger EBC_Resource on EBC_Resource__c (after insert) {
	if (trigger.IsAfter && trigger.IsInsert) {
		EBC_Resource_TriggerHandler.triggerExactTargetDownloadRequest(Trigger.new);
	}
}
