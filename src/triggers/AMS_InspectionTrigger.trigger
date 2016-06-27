trigger AMS_InspectionTrigger on AMS_Inspection__c (before insert, before update, after insert, after update) {
    
	if(!AMS_TriggerExecutionManager.checkExecution(AMS_Inspection__c.getSObjectType(), 'AMS_InspectionTrigger')) { return; }
	
	if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
        	List<AMS_Inspection__c> toUpdateList = new List<AMS_Inspection__c>();
        	for(AMS_Inspection__c insp : Trigger.new)
        	{
	        	AMS_Inspection__c oldInsp = Trigger.oldMap.get(insp.Id);
				if(AMS_InspectionHelper.compareAmsInspectionRecords_IgnoringLastSyncDate(insp, oldInsp))
				{
					toUpdateList.add(insp);
				}
			}
        	
        	if(toUpdateList.size() > 0)
			{
            	AMS_AgencyUpdateHelper.agencyUpdate(toUpdateList);
			}
        }
        
        AMS_InspectionHelper.setStatusCodeOnAgency(Trigger.new);
    	AMS_InspectionHelper.setRecertExpiryDateOnAccount(Trigger.oldMap, Trigger.newMap);
    }

}