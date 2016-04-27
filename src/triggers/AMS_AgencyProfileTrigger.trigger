trigger AMS_AgencyProfileTrigger on AMS_Agency_Profile__c (after update) {
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}