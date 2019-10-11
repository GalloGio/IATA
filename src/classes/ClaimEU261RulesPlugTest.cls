@isTest
private class ClaimEU261RulesPlugTest {
	
	@testSetup static void testSetup() {

		//insert custom setting
		ClaimEU261__c claimCS = new ClaimEU261__c();
		claimCS.Name = '1flt_Delay_250_In/Out_short';
		claimCS.Claim_type__c = 'Delay; Xncl';
		claimCS.CompensationAmount__c = 'EUR 250';
		claimCS.DelayFlightSection__c = '123';
		claimCS.DelayTime__c = '3 to 4 hours/More than 4 hours';
		claimCS.Description__c = 'Compensation due: EUR250. Delay of more than 3 hours and flight distance less than 1500kms';
		claimCS.ExtraCircun__c = 'No';
		claimCS.Is_Arrival_Airport_EU__c = 'N';
		claimCS.Is_Carrier_from_EU__c = 'Yes/No';
		claimCS.Is_Connecting_Airport_EU__c = 'Z';
		claimCS.Is_Departure_Airline_EU__c = 'Y';
		claimCS.Max_Distance__c = 1500.000000;
		claimCS.Min_Distance__c = 0.000000;
		insert claimCS;
	}
	
	@isTest static void testPluginSuccess() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put('Delayed_Flight_Time', 'More than 4 hours');
        inputParams.put('Extraordinary_Circumstances', 'No');
        inputParams.put('Flight_Distance', 1000.000000);
        inputParams.put('isDeparture_Airport_EU', 'Y');
        inputParams.put('isConnecting_Airport_EU', 'Z');
        inputParams.put('isArrival_Airport_EU', 'N');
        inputParams.put('isCarrier_EU', 'Yes');
        inputParams.put('claimType', 'Delay');
        inputParams.put('DelayFlightSection', '2');
		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		ClaimEU261RulesPlug plugin = new ClaimEU261RulesPlug();
		Process.PluginDescribeResult result;

		Test.startTest();
		plugin.invoke(request);
		result = plugin.describe();
		Test.stopTest();

		System.assertEquals('Claim Compensation', result.Name);
		System.assertEquals('Claim EU261', result.Tag);

	}

	@isTest static void testPluginError() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put('Delayed_Flight_Time', 'More than 4 hours');
        inputParams.put('Extraordinary_Circumstances', 'No');
        inputParams.put('Flight_Distance', 2000.000000);
        inputParams.put('isDeparture_Airport_EU', 'Y');
        inputParams.put('isConnecting_Airport_EU', 'Z');
        inputParams.put('isArrival_Airport_EU', 'N');
        inputParams.put('isCarrier_EU', 'Yes');
        inputParams.put('claimType', 'Delay');
        inputParams.put('DelayFlightSection', '2');
		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		ClaimEU261RulesPlug plugin = new ClaimEU261RulesPlug();
		Process.PluginDescribeResult result;

		Test.startTest();
		plugin.invoke(request);
		result = plugin.describe();
		Test.stopTest();

		System.assertEquals('Claim Compensation', result.Name);
		System.assertEquals('Claim EU261', result.Tag);

	}
	
}