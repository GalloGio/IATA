trigger AMS_TerritoryTrigger on AMS_Territory__c (after delete) 
{
	//Delete GSA Territory created by AMS Territory
    if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.crossDeleteGSATerritory(Trigger.old);
}