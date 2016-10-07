trigger AMS_AgencyHierarchyTrigger on AMS_Agencies_Hierarchy__c (after update) {
	if(Trigger.isUpdate){
		AMS_AgencyUpdateHelper.agencyRelathionshipUpdate(Trigger.new);
	}
    
}