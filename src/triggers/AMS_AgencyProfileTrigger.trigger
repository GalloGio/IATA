trigger AMS_AgencyProfileTrigger on AMS_Agency_Profile__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Profile__c.getSObjectType(), 'AMS_AgencyProfileTrigger')) { return; }
    
	//FM - 22-09-2016 - stop creating "agency update" Records
    //if(Trigger.isUpdate)
    //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}