trigger PortalServiceAssignmentTrigger on Portal_Service_Assignment__c (after delete, after insert, after undelete, after update) {
	PortalServiceAssignmentTriggerHandler handler = new PortalServiceAssignmentTriggerHandler();
	handler.handle();
}