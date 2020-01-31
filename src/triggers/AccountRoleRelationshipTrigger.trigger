trigger AccountRoleRelationshipTrigger on Account_Role_Relationship__c (after insert, after delete) {
	new AccRoleRelationshipTriggerHandler().handle();
}
