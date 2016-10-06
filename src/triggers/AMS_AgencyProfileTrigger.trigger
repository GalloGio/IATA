trigger AMS_AgencyProfileTrigger on AMS_Agency_Profile__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Profile__c.getSObjectType(), 'AMS_AgencyProfileTrigger')) { return; }
    
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}