trigger AMS_AgencySegmentTrigger on AMS_Agency_Segment__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Segment__c.getSObjectType(), 'AMS_AgencySegmentTrigger')) { return; }
    
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}