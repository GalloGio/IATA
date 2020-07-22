@isTest
public without sharing class CW_HandledAirlinesControllerTEST {
	private static final Boolean TRACEIT = true;
	private static final string PREFIX = 'CW_HandledAirlines:: ';

	@TestSetup
	static void makeData(){
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;
		handleTrace(PREFIX + 'IATA_ISO_Country__c insert');

		List<RecordType> recTypes = getRecTypes();
		handleTrace(PREFIX + 'recTypes => ' + recTypes);

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		acc.RecordTypeId = recTypes[Integer.valueof((Math.random() * 1))].Id;
		acc.Name = 'TEST Airline HQ/operator';
		acc.Airline_designator__c = 'AA';
		acc.ICAO_designator__c = 'SSV';
		insert acc;
		handleTrace(PREFIX + 'HQ/operator insert');
				
		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;

		string rectypeId = recTypes[Integer.valueof((Math.random() * 1))].Id;
		List<Account> airlines = new List<Account>();
		Account acc1 = CW_TestDataFactory.createAirline(isoCode.Id, rectypeId, 'Air Canada', 'AB', 'SSV');
		airlines.add(acc1);
		
		Account acc2 = CW_TestDataFactory.createAirline(isoCode.Id, rectypeId, 'Iberia', 'AC', 'SSV');
		airlines.add(acc2);
		
		Account acc3 = CW_TestDataFactory.createAirline(isoCode.Id, rectypeId, 'Alitalia', 'AD', 'SSV');
		airlines.add(acc3);

		insert airlines;
		handleTrace(PREFIX + 'Airlines insert');
		
		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;
		handleTrace(PREFIX + 'Account_Role__c insert');

		List<ICG_Account_Role_Detail__c> lstARD = new List<ICG_Account_Role_Detail__c>();
		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		lstARD.add(ard);
		ICG_Account_Role_Detail__c ard2 = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		ard2.RecordTypeId = Schema.SObjectType.ICG_Account_Role_Detail__c.getRecordTypeInfosByDeveloperName().get('Cargo_Handling_Facility').getRecordTypeId();
		ard2.Status__c = 'Approved';
		lstARD.add(ard2);
		insert lstARD;
		handleTrace(PREFIX + 'ICG_Account_Role_Detail__c insert');
		handleTrace(PREFIX + 'ICG_Account_Role_Detail_Relationship__c insert');
	}

	@isTest
	static void testGetAllAirlines(){
		test.startTest();
		string result = CW_HandledAirlinesController.getAllAirlines();
		test.stopTest();

		handleTrace(PREFIX + 'testGetAllAirlines result = > ' + result);

		System.assertEquals(false, String.isBlank(result), 'getAllAirlines validation');
	}
	@isTest
	static void testGetAirlinesByRT(){
		test.startTest();
		string result = CW_HandledAirlinesController.getAirlinesByRT('Cargo Handling Facility');
		test.stopTest();

		handleTrace(PREFIX + 'getAirlinesByRT result = > ' + result);

		System.assertEquals(false, String.isBlank(result), 'getAirlinesByRT validation');
	}
	@isTest
	/**@descrip Validates the Addition of entries */
	static void testSaveAirlinesHandledAdd(){
		List<Account> airlines = [SELECT Id FROM Account WHERE Airline_designator__c != 'AA'];
		handleTrace(PREFIX + 'SaveAirlinesHandledAdd::airlines => ' + airlines);

		List<ICG_Account_Role_Detail__c> ard = [SELECT Id FROM ICG_Account_Role_Detail__c];

		List<string> ids = new List<string>();
		for(Account item :airlines) { ids.add(item.Id); } 

		if(ard.size() > 0){
			test.startTest();
			CW_HandledAirlinesController.saveAirlinesHandled(JSON.serialize(ids), null, ard[0].Id);
			test.stopTest();
		}
		
		//Assert creation
		List<ICG_Account_Role_Detail_Relationship__c> results = [SELECT Id, Handled_Airline__c FROM ICG_Account_Role_Detail_Relationship__c WHERE Handled_Airline__c in :ids ];
		system.assertEquals(airlines.size(), results.size(), 'Record count validation');

		if(results.size() > 0){ System.assert(ids.contains(results[0].Handled_Airline__c), 'Content validation'); }
	}

	@isTest
	/**@descrip Validates the Deletion of entries */
	static void testSaveAirlinesHandledDelete(){
		List<Account> airlines = [SELECT Id FROM Account WHERE Airline_designator__c != 'AA'];
		handleTrace(PREFIX + 'SaveAirlinesHandledDelete::airlines => ' + airlines);

		List<ICG_Account_Role_Detail__c> ard = [SELECT Id FROM ICG_Account_Role_Detail__c];

		List<string> ids = new List<string>();
		for(Account item :airlines) { ids.add(item.Id); } 

		if(ard.size() > 0){
			test.startTest();
			CW_HandledAirlinesController.saveAirlinesHandled(JSON.serialize(ids), null, ard[0].Id);
			handleTrace(PREFIX + 'SaveAirlinesHandledDelete::airlines inserted => ' + airlines);

			CW_HandledAirlinesController.saveAirlinesHandled(null, JSON.serialize(ids), ard[0].Id);
			test.stopTest();
		}

		//Assert Deletion
		List<ICG_Account_Role_Detail_Relationship__c> results = [SELECT Id, Handled_Airline__c FROM ICG_Account_Role_Detail_Relationship__c  WHERE Handled_Airline__c in :ids];
		system.assertEquals(0, results.size(), 'Record count validation');
	}

	/**@description Gest test related valid Account Record types */
	private static List<RecordType> getRecTypes(){
		return [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name in ('Airline Headquarters', 'Operator')];
	}

    private static void handleTrace(String traceMsg){ if(TRACEIT) { system.debug(traceMsg); } }
    
    @isTest
	/**@descrip Validates the Deletion of entries */
	static void testSaveHiddenOperatingStations(){
        test.startTest();
		Id stationId = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
        Boolean result = CW_HandledAirlinesController.saveHiddenOperatingStations('', stationId );
        system.assertEquals(true, result, 'erro on saveHiddenOperatingStations');
		test.stopTest();
	}

}