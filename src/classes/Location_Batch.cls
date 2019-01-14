global class Location_Batch implements Database.Batchable<Location__c>, Database.AllowsCallouts 
{
	Set<Id> locationIds;
	Set<Id> soldToLocationIds2CreateFirst;
	
	global Location_Batch(Set<Id> locationIds_x) 
	{
		//-- If batch called with one param then just call SAP
		locationIds = locationIds_x; 	
	}

	global Location_Batch(Set<Id> locationIds_x, Set<Id> soldToLocationIds2CreateFirst_x) 
	{
		//-- If batch called with 2 params, Sync SoldTo first then Bill To & Ship To
		locationIds = locationIds_x; 
		soldToLocationIds2CreateFirst = soldToLocationIds2CreateFirst_x;
	}
	
	global List<Location__c> start(Database.BatchableContext BC) 
	{
		//return (soldToLocationIds2CreateFirst != null) 
		//	?	(List<Location__c>) new Location_Sel().selectSObjectById(soldToLocationIds2CreateFirst)	
		//	:	(List<Location__c>) new Location_Sel().selectSObjectById(locationIds);
		List<Id> lstLocationId = new List<Id>();
		if (locationIds != null)
			lstLocationId.addAll(locationIds);
		if (soldToLocationIds2CreateFirst != null)
			lstLocationId.addAll(soldToLocationIds2CreateFirst);
		return Location_Sel.getLocationToSyncSAP(lstLocationId, null, null, null, null).values();
	}

   	global void execute(Database.BatchableContext BC, List<Location__c> locations) 
   	{
		IECAddress_Svc.syncCustomerMasterWithSAP(locations);
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		return;   //*** no need anymore
		if(soldToLocationIds2CreateFirst != null) 
		{
			Database.executeBatch(new Location_Batch(locationIds));
		}	
	}
}