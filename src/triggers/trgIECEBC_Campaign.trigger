trigger trgIECEBC_Campaign on EBC_Campaign__c (before update) {
	trgIECEBC_CampaignHandler.updateScheduledDateValidUntil(Trigger.new);
}
