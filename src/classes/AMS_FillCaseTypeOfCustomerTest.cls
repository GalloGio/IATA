@isTest
private class AMS_FillCaseTypeOfCustomerTest {


	static testmethod void AMS_FillCaseTypeOfCustomerTestCase1() {

	  	Test.startTest();

		Map<String,Object> inputParams = new Map<String,Object>();

		inputParams.put('Category_Input', 'IATA Passenger Sales Agent');
		inputParams.put('LocationType_Input', 'SA');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		AMS_FillCaseTypeOfCustomer plugin = new AMS_FillCaseTypeOfCustomer();
		plugin.invoke(request);

		plugin.describe();

		Test.stopTest();

	}

}
