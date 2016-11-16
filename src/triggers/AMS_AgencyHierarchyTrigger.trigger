trigger AMS_AgencyHierarchyTrigger on AMS_Agencies_Hierarchy__c (after update) {
	if(Trigger.isUpdate){
		//FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyRelathionshipUpdate(Trigger.new);
	}
    
}