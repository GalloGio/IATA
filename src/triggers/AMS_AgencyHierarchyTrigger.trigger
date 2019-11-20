trigger AMS_AgencyHierarchyTrigger on AMS_Agencies_Hierarchy__c (before insert, before update, before delete) {
	
	if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agencies_Hierarchy__c.getSObjectType(), 'AMS_AgencyHierarchyTrigger')) { return; }

	AMS_AgencyHierarchyTriggerHandler.runHandler('AMS_AgencyHierarchyTriggerHandler');
	
}