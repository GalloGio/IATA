trigger AMS_AgencyAirportTrigger on AMS_Agency_Airport__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Airport__c.getSObjectType(), 'AMS_AgencyAirportTrigger')) { return; }
    
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}