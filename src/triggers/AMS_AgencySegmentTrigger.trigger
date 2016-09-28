trigger AMS_AgencySegmentTrigger on AMS_Agency_Segment__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Segment__c.getSObjectType(), 'AMS_AgencySegmentTrigger')) { return; }
    
	//FM - 22-09-2016 - stop creating "agency update" Records
    //if(Trigger.isUpdate)
    //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}