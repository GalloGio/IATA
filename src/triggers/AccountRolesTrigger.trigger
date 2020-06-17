trigger AccountRolesTrigger on Account_Roles__c (before insert, before update) {
	if (!AMS_TriggerExecutionManager.checkExecution(Account_Roles__c.getSObjectType(), 'AccountRolesTrigger')) { return; }
	new AccountRolesTriggerHandler().handle();
}
