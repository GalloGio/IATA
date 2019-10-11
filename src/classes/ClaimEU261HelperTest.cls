@isTest
private class ClaimEU261HelperTest {

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

		Case cse = new Case();
		cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261');
		cse.Status = 'New';
		cse.Origin = 'Phone';
		cse.Subject = 'Test Case Claim EU261';
		insert cse;

	}
	
	@isTest static void testGetFlightInformationSuccess() {
		
		//test with 2 inserted airports
		List<Object> result = new List<Object>();

		Test.startTest();
		result = ClaimEU261Helper.getFlightInformation('LIS','HKG');
		Test.stopTest();

		Location loc1 = Location.newInstance(38.77116,-9.13383);
		Location loc2 = Location.newInstance(22.28552,114.15769);
		Decimal dist = Location.getDistance(loc1, loc2, 'km');

		System.assertEquals(dist, (Decimal)result.get(0)); //distance between both airports
		System.assertEquals('Y', (String)result.get(1)); //the departure airport is in Europe
		System.assertEquals('N', (String)result.get(2)); //the arrival airport is not in Europe

	}

	@isTest static void testGetFlightInformationError() {
		
		//test with 2 airports not inserted
		List<Object> result = new List<Object>();

		Test.startTest();
		result = ClaimEU261Helper.getFlightInformation('GVA','BCN');
		Test.stopTest();

		System.assertEquals(0.0, (Decimal)result.get(0)); //distance between both airports
		System.assertEquals('N', (String)result.get(1)); //the departure airport is in Europe
		System.assertEquals('N', (String)result.get(2)); //the arrival airport is not in Europe

	}
	
	@isTest static void testGetFinalResultSuccess() {

		//test inputs for an existent custom setting
		Map<String,Object> inputs = new Map<String,Object>();
        inputs.put('Delayed_Flight_Time', 'More than 4 hours');
        inputs.put('Extraordinary_Circumstances', 'No');
        inputs.put('Flight_Distance', 1000.000000);
        inputs.put('isDeparture_Airport_EU', 'Y');
        inputs.put('isConnecting_Airport_EU', 'Z');
        inputs.put('isArrival_Airport_EU', 'N');
        inputs.put('isCarrier_EU', 'Yes');
        inputs.put('claimType', 'Delay');
        inputs.put('DelayFlightSection', '2');

        List<Object> result = new List<Object>();
        Test.startTest();
        result = ClaimEU261Helper.getFinalResult(inputs);
        Test.stopTest();

        System.assertEquals('EUR 250', ((ClaimEU261__c)result.get(0)).CompensationAmount__c);
        System.assertEquals('Compensation due: EUR250. Delay of more than 3 hours and flight distance less than 1500kms', ((ClaimEU261__c)result.get(0)).Description__c);

	}

	@isTest static void testGetFinalResultError() {
		
		//test inputs for a non existent custom setting
		Map<String,Object> inputs = new Map<String,Object>();
        inputs.put('Delayed_Flight_Time', 'More than 4 hours');
        inputs.put('Extraordinary_Circumstances', 'No');
        inputs.put('Flight_Distance', 2000.000000);
        inputs.put('isDeparture_Airport_EU', 'Y');
        inputs.put('isConnecting_Airport_EU', 'Z');
        inputs.put('isArrival_Airport_EU', 'N');
        inputs.put('isCarrier_EU', 'Yes');
        inputs.put('claimType', 'Delay');
        inputs.put('DelayFlightSection', '2');

        List<Object> result = new List<Object>();
        Test.startTest();
        result = ClaimEU261Helper.getFinalResult(inputs);
        Test.stopTest();

        System.assertEquals(0, result.size());
	}

	@isTest static void testUpdateCaseOwner() {

		//As the case assignment rules are available in the test class, there is no need to add them
		
		Case cse = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Test Case Claim EU261'];

		Test.startTest();
		ClaimEU261Helper.updateCaseOwner(cse.Id);
		Test.stopTest();

		Case cseAfter = [SELECT Id, OwnerId FROM Case WHERE Subject = 'Test Case Claim EU261'];

		System.assertNotEquals(cse.OwnerId, cseAfter.OwnerId); //the method should change the owner of the case
	}
}