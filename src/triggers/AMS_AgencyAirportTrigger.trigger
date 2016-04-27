trigger AMS_AgencyAirportTrigger on AMS_Agency_Airport__c (after update) {
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}