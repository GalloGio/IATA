@isTest
private class CaseAssignRulesPlugTest {

	@testSetup static void testSetup() {

		Case cse = new Case();
		cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cse.Status = 'New';
		cse.Origin = 'Phone';
		cse.Subject = 'Test Case Claim EU261';
		insert cse;

	}
	
	@isTest static void testPlugin() {

		//As the case assignment rules are available in the test class, there is no need to add them

		Case cse = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Test Case Claim EU261'];

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put('CaseId', cse.Id);
		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		CaseAssignRulesPlug plugin = new CaseAssignRulesPlug();
		Process.PluginDescribeResult result;

		Test.startTest();
		plugin.invoke(request);
		result = plugin.describe();
		Test.stopTest();

		System.assertEquals('Case Assignment Rules', result.Name);
		System.assertEquals('APEX', result.Tag);

		Case cseAfter = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Test Case Claim EU261'];

		System.assertNotEquals(cse.OwnerId, cseAfter.OwnerId); //the method should change the owner of the case

	}
	
}