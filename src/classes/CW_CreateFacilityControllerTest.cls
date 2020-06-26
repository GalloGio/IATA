/**
 * @description	tests class of CW_CreateFacilityController
 */
@isTest
public class CW_CreateFacilityControllerTest {
	/**
		 * @description		Test Setup: to precharge necesaries data
	 */
	@testSetup
	private static void createData(){
		Profile pf= [Select Id from profile where Name LIKE '%IATA Customer Community%' limit 1]; 
		String orgId=UserInfo.getOrganizationId(); 
		String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
		Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
		String uniqueName=orgId+dateString+RandomId;

		ISSP_CS__c icgid = new ISSP_CS__c();
		icgid.Name = 'ICG_URL_Base';
		icgid.Value__c = 'https://theurl.com/s/';
		insert icgid;
		
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;
		
		IATA_ISO_Country_Set__c cSetting = new IATA_ISO_Country_Set__c (Name = 'ES', Country_Name__c = isoCode.Name, Portal_URL__c = 'http://test.com');
		insert cSetting;

		Account acc = new Account (Name = 'Account01', IATA_ISO_Country__c = isoCode.Id);
			   
		Account acc2 = new Account (Name = 'Account02', IATA_ISO_Country__c = isoCode.Id);
		
		List <Account> accs = new List <Account> ();
		accs.add(acc);
		accs.add(acc2);
		insert accs;
		
		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;
		
		Contact con1 = new Contact(FirstName = 'Test', LastName='Test', Email = 'Test@Test.com',AccountId = acc.id);
		insert con1;
		
		Account_Role__c accRole = new Account_Role__c(Account_Role_Name__c = 'Test', Account__c = acc.Id);
		Account_Role__c accRole2 = new Account_Role__c(Account_Role_Name__c = 'Test2', Account__c = acc2.Id);
	   	List <Account_Role__c> accRoles = new List <Account_Role__c> ();
		accRoles.add(accRole);
		accRoles.add(accRole2);
		insert accRoles;
		
		Account_Role_Relationship__c arr = new Account_Role_Relationship__c (From__c = accRole.Id, To__c = accRole2.Id, Ops_Hierarchy_Group__c = 'Test');
		insert arr;
		
		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard;
		
		User uu=new User(firstname = 'IATAICGABCUnique', 
						 lastName = 'IATAICGXYZUnique', 
						 email = uniqueName + '@test' + orgId + '.org', 
						 Username = uniqueName + '@test' + orgId + '.org', 
						 EmailEncodingKey = 'ISO-8859-1', 
						 Alias = uniqueName.substring(18, 23), 
						 TimeZoneSidKey = 'America/Los_Angeles', 
						 LocaleSidKey = 'en_US', 
						 LanguageLocaleKey = 'en_US', 
						 ProfileId = pf.Id,
						 contactId = con1.id
						);
		
		insert uu;
	}
	
	
	/**
	 * @description		test method for CW_CreateFacilityController.createFacility method First ERROR
	 */    
	@isTest private static void createFacilityErrorTest(){
		Test.startTest();
		CW_CreateFacilityController.LogoInfo info = new CW_CreateFacilityController.LogoInfo ();
		info.fileName = 'Test';
		info.base64Data = 'Test';
		info.contentType = 'Test';
		system.assert((CW_CreateFacilityController.createFacility('Test', 'Test', JSON.serialize(info), 'Test', 'Test', false,false, false,'[]','[]')).containsIgnoreCase('false'));
		Test.stopTest();
	}
	
	@isTest private static void createFacilityTest(){
        List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZUnique1'];
        CW_CreateFacilityController.LogoInfo info = new CW_CreateFacilityController.LogoInfo ();
		info.fileName = 'Test';
		info.base64Data = 'Test';
        info.contentType = 'Test';
        
        Airport_Detail__c airport = [Select Id, IATA_ISO_Country__c, Code__c from Airport_Detail__c limit 1];
		Account acc = [Select Id from Account limit 1];
		Account_Role__c accRole = [Select Id, Account__c from Account_Role__c limit 1];

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(
			accRole.Id,
			airport
		);
        
		List <IATA_ISO_Country__c> isoCodes = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
		Account accNew = new Account (Name = 'Account03', IATA_ISO_Country__c = isoCodes[0].Id);
        List <Account_Role__c> ar = [SELECT Id FROM Account_Role__c LIMIT 2];
        
        Test.startTest();

        CW_CreateFacilityController.createFacility(accRole.Account__c, JSON.serialize(accRoleDetail), JSON.serialize(info), accRoleDetail.Id, airport.Code__c, true,false, false,'[]','[]');
        CW_CreateFacilityController.createFacility(accNew.Id, JSON.serialize(accRoleDetail), JSON.serialize(info), accRoleDetail.Id, airport.Code__c, true,false, false,'[]','[]');
    
        Test.stopTest();
	}
	/**
	 * @description		test method for CW_CreateFacilityController.createDummyCompany complete OK
	 */    
	@isTest
	private static void createDummyCompanyTest(){
		List <IATA_ISO_Country__c> isoCodes = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
		Account acc = new Account (Name = 'Account03', IATA_ISO_Country__c = isoCodes[0].Id);
		List <Account_Role__c> ar = [SELECT Id FROM Account_Role__c LIMIT 2];
		
		Test.startTest();
		Map <String, Object> result = (Map <String, Object>)JSON.deserializeUntyped(CW_CreateFacilityController.createDummyCompany(JSON.serialize(acc), 'Test'));
		System.assert(result.get('success') == true, 'Test: CreateDummyCompany FAILED');
		Test.stopTest();
	}

	/**
	 * @description		test method for CW_CreateFacilityController.updateFacility
	 */    
	@isTest
	private static void updateFacility(){
		Airport_Detail__c airport = [Select Id, IATA_ISO_Country__c from Airport_Detail__c limit 1];
		Account_Role__c accRole = [Select Id from Account_Role__c limit 1];

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(
			accRole.Id,
			airport
		);
        insert accRoleDetail;
        
        CW_CreateFacilityController.LogoInfo info = new CW_CreateFacilityController.LogoInfo ();
		info.fileName = 'Test';
		info.base64Data = 'Test';
        info.contentType = 'Test';
        String logoJson = JSON.serialize(info);

		String id = accRoleDetail.Id;
		String jsonInput = '{"Number_of_Employees__c":25001,"Overall_Facility_Size_m2__c":5410,"Overall_Airport_Size__c":2560,"Fleet__c":1500,"Is_On_Airport__c":true,"Is_Direct_Ramp_Access__c":true,"Road_Feeder_Services__c":true,"Customer_Service_Email__c":"info@genericcompany.com","Customer_Service_Phone_Number__c":"+34 900902902","Website__c":"www.genericairline.com","Online_Booking_System_Link__c":"www.genericairline.com","Available_Languages__c":"English;German;Spanish","General_Cargo__c":true,"Live_Animals__c":true,"Dangerous_Goods__c":true,"Airmail__c":true,"Perishables__c":false,"Pharmaceuticals__c":true,"second_address__c":"test","Id":"' + id +'"}';
		Test.startTest();
		CW_CreateFacilityController.updateFacility(jsonInput, null);
		Map<String, Object> result = CW_CreateFacilityController.updateFacility(jsonInput, logoJson);
		Test.stopTest();
		System.assert(!result.isEmpty(), 'The result is lacking attributes');
		Map<String, String> resultValues = (Map<String, String>)result.get('result');
		System.assertEquals('OK', resultValues.get('status'), 'Returned status is not "OK"');
		ICG_Account_Role_Detail__c ardUpdated = [Select Id, Number_of_Employees__c, Overall_Facility_Size_m2__c, Overall_Airport_Size__c, Fleet__c, Is_On_Airport__c, Is_Direct_Ramp_Access__c, Road_Feeder_Services__c, Customer_Service_Email__c, Customer_Service_Phone_Number__c, Website__c, Online_Booking_System_Link__c, Available_Languages__c, General_Cargo__c, Live_Animals__c, Dangerous_Goods__c, Airmail__c, Perishables__c, Pharmaceuticals__c, second_address__c from ICG_Account_Role_Detail__c where Id=:id];
		System.assertEquals(25001, ardUpdated.Number_of_Employees__c, 'Number_of_Employees__c is not as expected');
		System.assertEquals(5410, ardUpdated.Overall_Facility_Size_m2__c, 'Overall_Facility_Size_m2__c is not as expected');
		System.assertEquals(2560, ardUpdated.Overall_Airport_Size__c, 'Overall_Airport_Size__c is not as expected');
		System.assertEquals(1500, ardUpdated.Fleet__c, 'Fleet__c is not as expected');
		System.assert(ardUpdated.Is_On_Airport__c, 'Is_On_Airport__c is not as expected');
		System.assert(ardUpdated.Is_Direct_Ramp_Access__c, 'Is_Direct_Ramp_Access__c is not as expected');
		System.assert(ardUpdated.Road_Feeder_Services__c, 'Road_Feeder_Services__c is not as expected');
		System.assertEquals('info@genericcompany.com', ardUpdated.Customer_Service_Email__c, 'Customer_Service_Email__c is not as expected');
		System.assertEquals('+34 900902902', ardUpdated.Customer_Service_Phone_Number__c, 'Customer_Service_Phone_Number__c is not as expected');
		System.assertEquals('www.genericairline.com', ardUpdated.Website__c, 'Website__c is not as expected');
		System.assertEquals('www.genericairline.com', ardUpdated.Online_Booking_System_Link__c, 'Online_Booking_System_Link__c is not as expected');
		System.assert(ardUpdated.Available_Languages__c.contains('English'), 'Available_Languages__c is not as expected');
		System.assert(ardUpdated.Available_Languages__c.contains('German'), 'Available_Languages__c is not as expected');
		System.assert(ardUpdated.Available_Languages__c.contains('Spanish'), 'Available_Languages__c is not as expected');
		System.assert(ardUpdated.General_Cargo__c, 'General_Cargo__c is not as expected');
		System.assert(ardUpdated.Live_Animals__c, 'Live_Animals__c is not as expected');
		System.assert(ardUpdated.Dangerous_Goods__c, 'Dangerous_Goods__c is not as expected');
		System.assert(ardUpdated.Airmail__c, 'Airmail__c is not as expected');
		System.assert(!ardUpdated.Perishables__c, 'Perishables__c is not as expected');
		System.assert(ardUpdated.Pharmaceuticals__c, 'Pharmaceuticals__c is not as expected');
		System.assertEquals('test', ardUpdated.second_address__c, 'second_address__c is not as expected');
	}

	/**
	 * @description		test method for CW_CreateFacilityController.updateFacility WRONG ID
	 */ 
	@isTest
	private static void updateFacilityWrongId(){
        CW_CreateFacilityController.LogoInfo info = new CW_CreateFacilityController.LogoInfo ();
		info.fileName = 'Test';
		info.base64Data = 'Test';
        info.contentType = 'Test';
        String logoJson = JSON.serialize(info);

		String id = 'Id';
		String jsonInput = '{"Number_of_Employees__c":25001,"Overall_Facility_Size_m2__c":5410,"Overall_Airport_Size__c":2560,"Fleet__c":1500,"Is_On_Airport__c":true,"Is_Direct_Ramp_Access__c":true,"Road_Feeder_Services__c":true,"Customer_Service_Email__c":"info@genericcompany.com","Customer_Service_Phone_Number__c":"+34 900902902","Website__c":"www.genericairline.com","Online_Booking_System_Link__c":"www.genericairline.com","Available_Languages__c":"English;German;Spanish","General_Cargo__c":true,"Live_Animals__c":true,"Dangerous_Goods__c":true,"Airmail__c":true,"Perishables__c":false,"Pharmaceuticals__c":true,"second_address__c":"test","Id":"' + id +'"}';
		Test.startTest();
		Map<String, Object> result = CW_CreateFacilityController.updateFacility(jsonInput, logoJson);
		Test.stopTest();
		System.assert(!result.isEmpty(), 'The result is lacking attributes');
		Map<String, String> resultValues = (Map<String, String>)result.get('exception');
		System.assert(resultValues.get('message').contains('MALFORMED_ID'), 'Returned message is not about invalid id');
    }
    
	@isTest
	private static void testUpdateAccountCoordinates(){
		String acid = [SELECT id FROM Account LIMIT 1].id;
		
        Test.startTest();
        CW_CreateFacilityController.updateAccountCoordinates(acid, 1, 1);
		Test.stopTest();
	}
	
	@isTest private static void getOnAirportStationsTest(){
        List<ICG_Account_Role_Detail__c> ards = [Select id, Nearest_Airport__r.Code__c from ICG_Account_Role_Detail__c];
        
        Account acc = new Account(Name = 'Qatar Airways (Test)', Account_Type__c = 'Airline', Sector__c = 'Airline', Category__c = 'General Aviation', Payment_Term__c = 'Z001', Reason_for_creation__c = 'New agent');
		insert acc;

		Account_Role__c ar = CW_TestDataFactory.testAccountRole(acc.Id, 'Test Account Role');
        insert ar;
        
        String countryId = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1].Id;

		Airport_Detail__c airport = new Airport_Detail__c(Code__c = 'BAR', City__c = 'Barcelna', IATA_ISO_Country__c = countryId, Account__c = acc.Id);
		insert airport;

		ICG_Account_Role_Detail__c ard = new ICG_Account_Role_Detail__c();
		ard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Cargo_Handling_Facility');
		ard.IATA_ISO_Country__c = countryId;
		ard.Nearest_Airport__c = airport.Id;
		ard.Account_Role__c = ar.Id;
		ard.Available_Languages__c = 'ESP;GER';
		ard.Summary_Detail_Check_JSON__c = '{"capabilitiesMap":{"ground_service_equipment":{"summary":false,"detail":true},"screening_equipment":{"summary":true,"detail":true},"security_equipment_and_measures":{"summary":true,"detail":true},"weight_volume_and_dimension_equipment":{"summary":true,"detail":true},"safety_personal_and_protective_equipment":{"summary":true,"detail":true},"scanners":{"summary":true,"detail":true},"active_uld_equipment":{"summary":true,"detail":true},"delivery_pickup_infrastructure":{"summary":true,"detail":true},"cold_room_standard_temperature_ranges":{"summary":true,"detail":true},"cold_room_freezers_custom_temperature_ranges":{"summary":true,"detail":true},"temperature_controlled_handling_areas":{"summary":true,"detail":true},"pre_cooling":{"summary":true,"detail":true},"other_temperature_control_equipment_infrastructure":{"summary":true,"detail":true},"live_animals_capacities":{"summary":true,"detail":true},"build_up_break_down_areas":{"summary":true,"detail":true},"temporary_storage_and_working_areas":{"summary":true,"detail":true},"uld_storage":{"summary":true,"detail":true},"veterinary_phytosanitary_and_pest_control":{"summary":true,"detail":true}}}';
        ard.Is_On_Airport__c = true;
        insert ard;

        ICG_Account_Role_Detail_Relationship__c ardr = new ICG_Account_Role_Detail_Relationship__c();
		ardr.ICG_Account_Role_Detail__c = ards[0].Id;
		ardr.Handled_Airline__c = acc.Id;
        insert ardr;
        
        ards[0].Is_On_Airport__c = true;
        update ards[0];

        Test.startTest();
		CW_CreateFacilityController.getOnAirportStations('Airline', acc.Name, ards[0].Nearest_Airport__r.Code__c, acc.Id);
		CW_CreateFacilityController.getOnAirportStations('Airline', acc.Name, ards[0].Nearest_Airport__r.Code__c, null);
		Test.stopTest();
	}
	
}