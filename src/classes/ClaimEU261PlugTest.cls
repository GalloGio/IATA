@isTest
private class ClaimEU261PlugTest {

	@testSetup static void testSetup() {

		//insert 2 countries for the airports
		List<IATA_ISO_Country__c> countries = new IATA_ISO_Country__c[2];
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Portugal';
		country.ISO_Code__c = 'PT';
		country.Region__c = 'Europe';
		countries.set(0, country);

		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c();
		country2.Name = 'Hong Kong SAR, China';
		country2.ISO_Code__c = 'HK';
		country2.Region__c = 'China & North Asia';
		countries.set(1, country2);

		insert countries;

		//insert 2 airports
		List<Address__c> airports = new List<Address__c>();
		Address__c airport1 = new Address__c();
		airport1.Description__c = 'Lisbon Airport';
		airport1.Code__c = 'LIS';
		airport1.Coordinates__latitude__s = 38.77116;
		airport1.Coordinates__longitude__s = -9.13383;
		airport1.IATA_ISO_Country__c = countries.get(0).Id;
		airport1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Address__c', 'Airport');
		airports.add(airport1);

		Address__c airport2 = new Address__c();
		airport2.Description__c = 'Kai Tak International Airport';
		airport2.Code__c = 'HKG';
		airport2.Coordinates__latitude__s = 22.28552;
		airport2.Coordinates__longitude__s = 114.15769;
		airport2.IATA_ISO_Country__c = countries.get(1).Id;
		airport2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Address__c', 'Airport');
		airports.add(airport2);

		insert airports;

	}
	
	@isTest static void testPlugin() {

		Map<String,Object> inputParams = new Map<String,Object>();
		inputParams.put('Departure_Airport', 'LIS');
		inputParams.put('Arrival_Airport', 'HKG');
		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		ClaimEU261Plug plugin = new ClaimEU261Plug();
		Process.PluginDescribeResult result;

		Test.startTest();
		plugin.invoke(request);
		result = plugin.describe();
		Test.stopTest();

		System.assertEquals('Flight Information', result.Name);
		System.assertEquals('Claim EU261', result.Tag);

	}
	
}