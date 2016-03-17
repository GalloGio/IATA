trigger AMS_AgencySegmentTrigger on AMS_Agency_Segment__c (after update) {
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}