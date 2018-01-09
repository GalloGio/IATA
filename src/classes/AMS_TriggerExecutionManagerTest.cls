@isTest
private class AMS_TriggerExecutionManagerTest {
	
	static testMethod void test_checkExecution() {

		//test no Custom Setting created
		System.assert(AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'SomeTest'));

		//test ALL
		AMS_Trigger_Execution_Manager__c defaults = AMS_Trigger_Execution_Manager__c.getOrgDefaults();
		defaults.All__c = true;
		insert defaults;

		System.assert(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'SomeTest'));

		//test no triggers
		defaults.All__c = false;
		update defaults;

		System.assert(AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'SomeTest'));

		//test triggers set
		defaults.Account_Triggers__c = 'SomeTest';
		update defaults;

		System.assert(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'SomeTest'));

		//test unsupported object (exception)
		System.assert(AMS_TriggerExecutionManager.checkExecution(Case.getSObjectType(), 'SomeTest'));
	}
	
}