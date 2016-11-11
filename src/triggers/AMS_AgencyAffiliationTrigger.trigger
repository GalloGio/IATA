trigger AMS_AgencyAffiliationTrigger on AMS_Agency_Affiliation__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Affiliation__c.getSObjectType(), 'AMS_AgencyAffiliationTrigger')) { return; }
    
	//FM - 22-09-2016 - stop creating "agency update" Records
    //if(Trigger.isUpdate)
    //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}