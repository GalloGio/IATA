trigger AMS_AgencyAffiliationTrigger on AMS_Agency_Affiliation__c (after update) {
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}