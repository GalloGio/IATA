trigger PortalServiceAssignmentTrigger on Portal_Service_Assignment__c (after delete, after insert, after undelete, after update) {
	Set<Id> apps = new Set<Id>();
	if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
		for(Portal_Service_Assignment__c assignment : Trigger.new){
			apps.add(assignment.ANG_Portal_Service__c);
		}
	}

	if(Trigger.isUpdate || Trigger.isDelete){
		for(Portal_Service_Assignment__c assignment : Trigger.old){
			apps.add(assignment.ANG_Portal_Service__c);
		}
	}
	if(!apps.isEmpty()) PortalServiceAssignmentTriggerHandler.updatePortalServices(apps);
}