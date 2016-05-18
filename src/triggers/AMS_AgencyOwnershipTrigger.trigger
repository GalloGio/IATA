trigger AMS_AgencyOwnershipTrigger on AMS_Agency_Ownership__c (after update) {
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}