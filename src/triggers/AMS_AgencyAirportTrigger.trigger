trigger AMS_AgencyAirportTrigger on AMS_Agency_Airport__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Airport__c.getSObjectType(), 'AMS_AgencyAirportTrigger')) { return; }
    
	//FM - 22-09-2016 - stop creating "agency update" Records
    //if(Trigger.isUpdate)
    //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}