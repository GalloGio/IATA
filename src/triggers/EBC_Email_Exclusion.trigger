trigger EBC_Email_Exclusion on EBC_Email_Exclusion__c (after insert) {
	if (trigger.IsAfter && trigger.IsInsert) {
		EBC_Email_Exclusion_TriggerHandler.creditHardBounce(Trigger.new);
	}
}
