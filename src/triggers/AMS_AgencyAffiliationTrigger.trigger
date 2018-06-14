trigger AMS_AgencyAffiliationTrigger on AMS_Agency_Affiliation__c (after update, after delete) {
	
	if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Affiliation__c.getSObjectType(), 'AMS_AgencyAffiliationTrigger')) { return; }
	
	//Delete ASsoc Affiliations created by AMS Agency Affiliation
    if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.crossDeleteAssocAffiliations(Trigger.old);

   /* if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Affiliation__c.getSObjectType(), 'AMS_AgencyAffiliationTrigger')) { return; }
    
	if(Trigger.isUpdate)
        AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);  */
}