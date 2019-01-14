trigger AMS_AgencyAirportTrigger on AMS_Agency_Airport__c (after update, after delete) {
	
	 if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Airport__c.getSObjectType(), 'AMS_AgencyAirportTrigger')) { return; }
	//Cross delete Adjacent Airports
  	if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.crossDeleteAdjacentAirports(Trigger.old);

  /*  if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Airport__c.getSObjectType(), 'AMS_AgencyAirportTrigger')) { return; }
    
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);*/
}