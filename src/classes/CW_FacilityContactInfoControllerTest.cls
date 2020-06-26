@isTest
private class CW_FacilityContactInfoControllerTest {
	@TestSetup
	private static void setup() {
		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		IATA_ISO_State__c state = new IATA_ISO_State__c(
			IEC_Valid_SAP__c = true,
			IATA_ISO_Country__c = country.Id,
			Name = 'Ontario',
			ISO_Code__c = 'CA-ON'
		);
		insert state;

		IATA_ISO_City__c city = new IATA_ISO_City__c(
			Name = 'Madrid',
			IATA_ISO_State__c = state.id,
			Status__c = 'Verified',
			GeonameName__c = 'Madrid'
		);
		insert city;



		Account acc = new Account(
			Name = 'Qatar Airways (Test)',
			Account_Type__c = 'Airline',
			Sector__c = 'Airline',
			Category__c = 'General Aviation',
			Payment_Term__c = 'Z001',
			Reason_for_creation__c = 'New agent',
			Business_City__c = city.Id
		);
		acc.RecordTypeId = CW_TestDataFactory.getRecTypesNotStandard().Id;
		insert acc;
		Account_Role__c ar = CW_TestDataFactory.testAccountRole(
			acc.Id,
			'Test Account Role'
		);
		insert ar;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		ICG_Account_Role_Detail__c ard = new ICG_Account_Role_Detail__c();
		ard.IATA_ISO_Country__c = country.Id;
		ard.Nearest_Airport__c = airport.Id;
		ard.Account_Role__c = ar.Id;
		ard.Available_Languages__c = 'ESP;GER';
		ard.Status__c = 'Approved';
		ard.Opening_Hours__c = '{"dataImport":{"name":"dataImport","label":"Import Opening Hours","days":[{"startAtKey":"dataImport_monday_startAt","startAt":"07:30:00.000Z","openKey":"dataImport_monday_open","open":true,"name":"monday","label":"Monday","endAtKey":"dataImport_monday_endAt","endAt":"19:30:00.000Z"},{"startAtKey":"dataImport_tuesday_startAt","startAt":"07:30:00.000Z","openKey":"dataImport_tuesday_open","open":true,"name":"tuesday","label":"Tuesday","endAtKey":"dataImport_tuesday_endAt","endAt":"15:30:00.000Z"},{"startAtKey":"dataImport_wednesday_startAt","startAt":"07:30:00.000Z","openKey":"dataImport_wednesday_open","open":true,"name":"wednesday","label":"Wednesday","endAtKey":"dataImport_wednesday_endAt","endAt":"19:30:00.000Z"},{"startAtKey":"dataImport_thursday_startAt","startAt":"07:30:00.000Z","openKey":"dataImport_thursday_open","open":true,"name":"thursday","label":"Thursday","endAtKey":"dataImport_thursday_endAt","endAt":"15:30:00.000Z"},{"startAtKey":"dataImport_friday_startAt","startAt":"08:00:00.000Z","openKey":"dataImport_friday_open","open":true,"name":"friday","label":"Friday","endAtKey":"dataImport_friday_endAt","endAt":"15:00:00.000Z"},{"startAtKey":"dataImport_saturday_startAt","startAt":"10:00:00.000Z","openKey":"dataImport_saturday_open","open":false,"name":"saturday","label":"Saturday","endAtKey":"dataImport_saturday_endAt","endAt":"14:00:00.000Z"},{"startAtKey":"dataImport_sunday_startAt","startAt":"10:00:00.000Z","openKey":"dataImport_sunday_open","open":false,"name":"sunday","label":"Sunday","endAtKey":"dataImport_sunday_endAt","endAt":"14:00:00.000Z"}]},"dataExport":{"name":"dataExport","label":"Export Opening Hours","days":[{"startAtKey":"dataExport_monday_startAt","startAt":"00:00:00.000Z","openKey":"dataExport_monday_open","open":true,"name":"monday","label":"Monday","endAtKey":"dataExport_monday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataExport_tuesday_startAt","startAt":"00:00:00.000Z","openKey":"dataExport_tuesday_open","open":true,"name":"tuesday","label":"Tuesday","endAtKey":"dataExport_tuesday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataExport_wednesday_startAt","startAt":"00:00:00.000Z","openKey":"dataExport_wednesday_open","open":true,"name":"wednesday","label":"Wednesday","endAtKey":"dataExport_wednesday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataExport_thursday_startAt","startAt":"00:00:00.000Z","openKey":"dataExport_thursday_open","open":true,"name":"thursday","label":"Thursday","endAtKey":"dataExport_thursday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataExport_friday_startAt","startAt":"08:00:00.000Z","openKey":"dataExport_friday_open","open":true,"name":"friday","label":"Friday","endAtKey":"dataExport_friday_endAt","endAt":"15:00:00.000Z"},{"startAtKey":"dataExport_saturday_startAt","startAt":"00:00:00.000Z","openKey":"dataExport_saturday_open","open":false,"name":"saturday","label":"Saturday","endAtKey":"dataExport_saturday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataExport_sunday_startAt","startAt":"00:00:00.000Z","openKey":"dataExport_sunday_open","open":false,"name":"sunday","label":"Sunday","endAtKey":"dataExport_sunday_endAt","endAt":"00:00:00.000Z"}]},"dataCustoms":{"name":"dataCustoms","label":"Customs Opening Hours","days":[{"startAtKey":"dataCustoms_monday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_monday_open","open":true,"name":"monday","label":"Monday","endAtKey":"dataCustoms_monday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataCustoms_tuesday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_tuesday_open","open":true,"name":"tuesday","label":"Tuesday","endAtKey":"dataCustoms_tuesday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataCustoms_wednesday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_wednesday_open","open":true,"name":"wednesday","label":"Wednesday","endAtKey":"dataCustoms_wednesday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataCustoms_thursday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_thursday_open","open":true,"name":"thursday","label":"Thursday","endAtKey":"dataCustoms_thursday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataCustoms_friday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_friday_open","open":true,"name":"friday","label":"Friday","endAtKey":"dataCustoms_friday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataCustoms_saturday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_saturday_open","open":false,"name":"saturday","label":"Saturday","endAtKey":"dataCustoms_saturday_endAt","endAt":"00:00:00.000Z"},{"startAtKey":"dataCustoms_sunday_startAt","startAt":"00:00:00.000Z","openKey":"dataCustoms_sunday_open","open":false,"name":"sunday","label":"Sunday","endAtKey":"dataCustoms_sunday_endAt","endAt":"00:00:00.000Z"}]}}';
		insert ard;

		/* NOTE: this code is commented because in sprint 11 will be used
		
		ICG_Account_Role_Detail__c ardBlank = new ICG_Account_Role_Detail__c();
		ardBlank.IATA_ISO_Country__c = country.Id;
		ardBlank.Nearest_Airport__c = airport.Id;
		ardBlank.Account_Role__c = ar.Id;
		ardBlank.Status__c = 'Approved';
		insert ardBlank;

		ICG_Account_Role_Detail__c ardInvalidHoursJson = new ICG_Account_Role_Detail__c();
		ardInvalidHoursJson.IATA_ISO_Country__c = country.Id;
		ardInvalidHoursJson.Nearest_Airport__c = airport.Id;
		ardInvalidHoursJson.Account_Role__c = ar.Id;
		ardInvalidHoursJson.Available_Languages__c = 'ESP;GER';
		ardInvalidHoursJson.Status__c = 'Approved';
		ardInvalidHoursJson.Opening_Hours__c = '{"import":{"days":[{"endAt":"17:15:00.000Z","endAtKey":"import_monday_endAt","startAt":"06:15:00.000Z","startAtKey":"import_monday_startAt","label":"Monday","name":"monday"}],"label":"Import Opening Hours"}}';
		insert ardInvalidHoursJson;

		ICG_Account_Role_Detail__c ardInvalidHoursValue = new ICG_Account_Role_Detail__c();
		ardInvalidHoursValue.IATA_ISO_Country__c = country.Id;
		ardInvalidHoursValue.Nearest_Airport__c = airport.Id;
		ardInvalidHoursValue.Account_Role__c = ar.Id;
		ardInvalidHoursValue.Available_Languages__c = 'ESP;GER';
		ardInvalidHoursValue.Status__c = 'Approved';
		ardInvalidHoursValue.Opening_Hours__c = '{"dataImport": {"name": null,"label":null,"days": null},"dataExport": {"name": null,"label":null,"days": null},"dataCustoms": {"name": null,"label":null,"days": null}}';
		insert ardInvalidHoursValue;*/
	}

	/*
	 * @author
	 * Description: set data in facility Cargo Comodity
	 */
	@isTest
	private static void setFacilityComodityInfoInvalid() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'exception',
			new Map<String, String>{ 'message' => 'Key not valid', 'trace' => '' }
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'dummyKey',
			'dummyValue'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityComodityInfoGeneralCargo() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'generalCargo','value' => 'true'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'generalCargo',
			'true'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityComodityInfoLiveAnimals() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'liveAnimals','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'liveAnimals',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityComodityInfoDangerousGoods() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'dangerousGoods','value' => 'true'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'dangerousGoods',
			'true'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityComodityInfoAirmail() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'airmail','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'airmail',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityComodityInfoPerishables() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'perishables','value' => 'true'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'perishables',
			'true'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityComodityInfoPharmaceuticals() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'pharmaceuticals','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'pharmaceuticals',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
    }
    
	@isTest
	private static void setFacilityComodityInfoPilotInformation() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'pilotInformation','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'pilotInformation',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}

	@isTest
	private static void setFacilityComodityInfoSecondAddress() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'secondAddress','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'secondAddress',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
    }

	@isTest
	private static void setFacilityComodityInfoElse() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'exception',
			new Map<String, String>{'message' => 'Key not valid', 'trace' => ''}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'else',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
    }
    
	/*
	 * @author
	 * Description: set data in facility Overview
	 */
	@isTest
	private static void setFacilityOverviewInfoInvalid() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'exception',
			new Map<String, String>{ 'message' => 'Key not valid', 'trace' => '' }
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'dummyKey',
			'dummyValue'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoNumberEmployees() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'NumberEmployees','value' => '1234'}
		);
		Map<String, Object> expectedResult2 = new Map<String, Object>();
		expectedResult2.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'NumberEmployees','value' => null}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'NumberEmployees',
			'1234'
		);
		Map<String, Object> result2 = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'NumberEmployees',
			null
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertEquals(expectedResult2, result2);
		System.assertNotEquals(0, result.Size());
		System.assertNotEquals(0, result2.Size());
	}
	@isTest
	private static void setFacilityInfoFacilitySize() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'FacilitySize','value' => '543'}
		);
		Map<String, Object> expectedResult2 = new Map<String, Object>();
		expectedResult2.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'FacilitySize','value' => ''}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'FacilitySize',
			'543'
		);
		Map<String, Object> result2 = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'FacilitySize',
			''
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertEquals(expectedResult2, result2);
		System.assertNotEquals(0, result.Size());
		System.assertNotEquals(0, result2.Size());
	}
	@isTest
	private static void setFacilityInfoOverallAirportSize() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'overallAirportSize','value' => '543'}
		);
		Map<String, Object> expectedResult2 = new Map<String, Object>();
		expectedResult2.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'overallAirportSize','value' => ''}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'overallAirportSize',
			'543'
		);
		Map<String, Object> result2 = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'overallAirportSize',
			''
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertEquals(expectedResult2, result2);
		System.assertNotEquals(0, result.Size());
		System.assertNotEquals(0, result2.Size());
	}
	@isTest
	private static void setFacilityInfoFleet() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'fleet','value' => '543'}
		);
		Map<String, Object> expectedResult2 = new Map<String, Object>();
		expectedResult2.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'fleet','value' => ''}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'fleet',
			'543'
		);
		Map<String, Object> result2 = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'fleet',
			''
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertEquals(expectedResult2, result2);
		System.assertNotEquals(0, result.Size());
		System.assertNotEquals(0, result2.Size());
	}

	@isTest
	private static void setFacilityInfoIsOnAirport() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'IsOnAirport','value' => 'true'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'IsOnAirport',
			'true'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoDirectRampAccess() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'DirectRampAccess','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'DirectRampAccess',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoRoadFeederServices() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'roadFeederServices','value' => 'false'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'roadFeederServices',
			'false'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	/*
	 * @author
	 * Description: set data in facility contact info
	 */
	@isTest
	private static void setFacilityContactInfoInvalid() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'exception',
			new Map<String, String>{ 'message' => 'Key not valid', 'trace' => '' }
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'dummyKey',
			'dummyValue'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoEmail() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'email','value' => 'dummy@dummy.es'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'email',
			'dummy@dummy.es'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoPhone() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'phone','value' => 'dummy'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'phone',
			'dummy'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoWebsite() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'website','value' => 'https://www.dummy.es'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'website',
			'https://www.dummy.es'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoOnlineBooking() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'onlineBooking','value' => 'https://www.dummyOnlineBooking.es'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'onlineBooking',
			'https://www.dummyOnlineBooking.es'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void setFacilityInfoSupportedLanguages() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Map<String, Object> expectedResult = new Map<String, Object>();
		expectedResult.put(
			'result',
			new Map<String, String>{'status' => 'OK','key' => 'supportedLanguages','value' => 'ESP;ENG'}
		);
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'supportedLanguages',
			'ESP;ENG'
		);
		Test.stopTest();
		System.assertEquals(expectedResult, result);
		System.assertNotEquals(0, result.Size());
	}

	/*
	 * @author
	 * Description: setHourTest
	 */
	@isTest
	private static void setHourTestOpen() {
		ICG_Account_Role_Detail__c identifi = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setHour(
			identifi.Id,
			'CW_FacilityContactInfoController.OPENING_HOUR_TYPE_IMPORT',
			'dummy'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}

	/*
	 * @author
	 * Description: setHourTest
	 */
	@isTest
	private static void setHourTestStartAt() {
		ICG_Account_Role_Detail__c identifi = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setHour(
			identifi.Id,
			'DataExport_Friday_startAt',
			'true'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}

	/*
	 * @author
	 * Description: setHourTest
	 */
	@isTest
	private static void setHourTestEndAt() {
		ICG_Account_Role_Detail__c identifi = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setHour(
			identifi.Id,
			'DataCustoms_Sunday_endAt',
			'dummy'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}

	/*
	 * @author
	 * Description: setHourTest
	 */
	@isTest
	private static void setHourTestInvalidDataType() {
		ICG_Account_Role_Detail__c identifi = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setHour(
			identifi.Id,
			'DataC_Sunday_Open',
			'false'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}

	/*
	 * @author
	 * Description: setHourTest
	 */
	@isTest
	private static void setHourTestInvalidField() {
		ICG_Account_Role_Detail__c identifi = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setHour(
			identifi.Id,
			'DataCustoms_Sunday_aaa',
			'dummy'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}

	@isTest
	private static void setFacilityInfoNumberEmployeesWithException() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			facility.Id,
			'NumberEmployees',
			'12345678901234567890.1234567890123456789912345678901234567899'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}

	@isTest
	private static void setFacilityInfoNumberEmployeesWithInvalidId() {
		Test.startTest();
		Map<String, Object> result = CW_FacilityContactInfoController.setFacilityInfo(
			'abdcde13',
			'NumberEmployees',
			'123.12'
		);
		Test.stopTest();
		System.assert(result.containsKey('exception'));
		System.assertNotEquals(0, result.Size());
	}
	@isTest
	private static void getFacilityOpeningHour() {
		ICG_Account_Role_Detail__c facility = [
			SELECT id, Opening_Hours__c
			FROM ICG_Account_Role_Detail__c
			WHERE City_FOR__c = 'Madrid'
			LIMIT 1
		];

		CW_FacilityContactInfoController.OpeningHours newHours = null;
		newHours = CW_FacilityContactInfoController.stringToOpeningHours(
			facility.Opening_Hours__c
		);
		CW_FacilityContactInfoController.OpeningHourType expectedResultImport = new CW_FacilityContactInfoController.OpeningHourType();
		expectedResultImport.name='import';
		CW_FacilityContactInfoController.OpeningHourType expectedResultExport = new CW_FacilityContactInfoController.OpeningHourType();
		expectedResultExport.name='export';
		CW_FacilityContactInfoController.OpeningHourType expectedResultCustom = new CW_FacilityContactInfoController.OpeningHourType();
		expectedResultCustom.name='customs';
		
		Test.startTest();
		CW_FacilityContactInfoController.OpeningHourType resultImport = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_IMPORT
		);
		CW_FacilityContactInfoController.OpeningHourType resultExport = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_EXPORT
		);
		CW_FacilityContactInfoController.OpeningHourType resultCustom = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_CUSTOM
		);
		CW_FacilityContactInfoController.OpeningHourType resultOffice = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_OFFICE
		);
		CW_FacilityContactInfoController.OpeningHourType resultOperating = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_OPERATING
		);
		CW_FacilityContactInfoController.OpeningHourType resultAirport = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_AIRPORT
		);
		CW_FacilityContactInfoController.OpeningHourType resultFlight = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_FLIGHT
		);
		CW_FacilityContactInfoController.OpeningHourType resultRamp = CW_FacilityContactInfoController.getOpeningHourTypeByPropertyName(
			newHours,
			CW_FacilityContactInfoController.OPENING_HOUR_TYPE_RAMP
		);
		Test.stopTest();
		System.assertNotEquals(
			resultImport,
			null,
			'Opening Hours dataImport error scructure'
		);
		System.assertEquals(expectedResultImport.name, resultImport.name);

		System.assertNotEquals(
			resultExport,
			null,
			'Opening Hours dataExport error scructure'
		);
		System.assertEquals(expectedResultExport.name, resultExport.name);

		System.assertNotEquals(
			resultCustom,
			null,
			'Opening Hours dataCustoms error scructure'
		);
		System.assertEquals(expectedResultCustom.name, resultCustom.name);
		
		System.assertNotEquals(
			resultOffice,
			null,
			'Opening Hours dataOffice error scructure'
		);
		System.assertNotEquals(
			resultOperating,
			null,
			'Opening Hours dataOperating error scructure'
		);
		System.assertNotEquals(
			resultAirport,
			null,
			'Opening Hours dataAirport error scructure'
		);
		System.assertNotEquals(
			resultFlight,
			null,
			'Opening Hours dataFlight error scructure'
		);
		System.assertNotEquals(
			resultRamp,
			null,
			'Opening Hours dataRamp error scructure'
		);
	}
}