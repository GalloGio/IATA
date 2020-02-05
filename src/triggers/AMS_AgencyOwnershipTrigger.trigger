trigger AMS_AgencyOwnershipTrigger on AMS_Agency_Ownership__c (after update) {
	/* #AMSFTS moved into AMS_AccountRoleTrigger

	if(Trigger.isUpdate)
		AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);*/
}
