trigger AMS_AgencyAffiliationTrigger on AMS_Agency_Affiliation__c (after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Affiliation__c.getSObjectType(), 'AMS_AgencyAffiliationTrigger')) { return; }
    
	//if(Trigger.isUpdate)
    //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
}