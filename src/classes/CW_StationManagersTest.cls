@isTest
public class CW_StationManagersTest {

	@TestSetup
	private static void setup(){
		Account acc = new Account(
			Name='Qatar Airways (Test)',
			Account_Type__c='Airline',
			Sector__c='Airline',
			Category__c='General Aviation',
			Payment_Term__c='Z001',
			Reason_for_creation__c='New agent',
			Global_Ultimate_Account_Global_ID__c='00001'
		);
		insert acc;

		Account_Role__c ar = CW_TestDataFactory.testAccountRole(acc.Id, 'Test Account Role');
		ar.Functional_Role__c = 'One Source';
		insert ar;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;
		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		ICG_Account_Role_Detail__c ard = new ICG_Account_Role_Detail__c();
		ard.RecordTypeId =  RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Cargo_Handling_Facility');
		ard.IATA_ISO_Country__c = country.Id;
		ard.Account_Role__c = ar.Id;
		ard.Available_Languages__c = 'ESP;GER';
		ard.Summary_Detail_Check_JSON__c = '{"capabilitiesMap":{"ground_service_equipment":{"summary":false,"detail":true},"screening_equipment":{"summary":true,"detail":true},"security_equipment_and_measures":{"summary":true,"detail":true},"weight_volume_and_dimension_equipment":{"summary":true,"detail":true},"safety_personal_and_protective_equipment":{"summary":true,"detail":true},"scanners":{"summary":true,"detail":true},"active_uld_equipment":{"summary":true,"detail":true},"delivery_pickup_infrastructure":{"summary":true,"detail":true},"cold_room_standard_temperature_ranges":{"summary":true,"detail":true},"cold_room_freezers_custom_temperature_ranges":{"summary":true,"detail":true},"temperature_controlled_handling_areas":{"summary":true,"detail":true},"pre_cooling":{"summary":true,"detail":true},"other_temperature_control_equipment_infrastructure":{"summary":true,"detail":true},"live_animals_capacities":{"summary":true,"detail":true},"build_up_break_down_areas":{"summary":true,"detail":true},"temporary_storage_and_working_areas":{"summary":true,"detail":true},"uld_storage":{"summary":true,"detail":true},"veterinary_phytosanitary_and_pest_control":{"summary":true,"detail":true},"electronic_system_capacities":{"summary":true,"detail":true}}}';
		insert ard;

		Contact cto = CW_TestDataFactory.testContact(acc.Id);
		insert cto;

		Account_Contact_Role__c accountContactRole = CW_TestDataFactory.testAccountContactRole(ar.Id, acc.Id, cto.Id);
		insert accountContactRole;

		ICG_Contact_Role_Detail__c contactRoleDetail = CW_TestDataFactory.testICGContactRoleDetail(accountContactRole.Id, ard.Id);
        contactRoleDetail.Account_Role__c = ar.Id;
        contactRoleDetail.ICG_Role__c = 'Facility Manager';
		insert contactRoleDetail;
		
		Contact cto2 = new Contact();
		cto2.FirstName = 'Test2';
		cto2.LastName = 'Test2';
		cto2.AccountId = acc.Id;
		cto2.Email = 'OneSourceTest2@Test.com';
		insert cto2;

	}
	@isTest public static void getAllAccountContactRolesTest(){
		Test.startTest();
			List<ICG_Account_Role_Detail__c> aRdList = [SELECT Id FROM ICG_Account_Role_Detail__c];
			System.assertNotEquals('', CW_StationManagers.getAllAccountContactRoles(aRdList[0].Id),'Unable to get all Account Contact Roles');
		Test.stopTest();
	}
	@isTest public static void deleteAccountContactRoleTest(){
		List<ICG_Contact_Role_Detail__c> contactRoleDetailList = [SELECT Id FROM ICG_Contact_Role_Detail__c];
		Test.startTest();
		System.assertEquals('Removed', CW_StationManagers.deleteAccountContactRole(contactRoleDetailList[0].Id, true), 'Failed removal by company admin');
		List<ICG_Contact_Role_Detail__c> contactRoleDetailListRemoved = [SELECT Id, Status__c FROM ICG_Contact_Role_Detail__c];
		System.assertEquals('Removed', contactRoleDetailListRemoved[0].Status__c, 'Status was not updated correctly');

		System.assertEquals('Pending for Removal', CW_StationManagers.deleteAccountContactRole(contactRoleDetailList[0].Id, false), 'Failed requesting removal by station manager');
		List<ICG_Contact_Role_Detail__c> contactRoleDetailListPending = [SELECT Id, Status__c FROM ICG_Contact_Role_Detail__c];
		System.assertEquals('Pending for Removal', contactRoleDetailListPending[0].Status__c, 'Status was not updated correctly');
		Test.stopTest();
	}
	@isTest public static void getContactsToAddTest(){
		List<ICG_Account_Role_Detail__c> aRdList = [SELECT Id FROM ICG_Account_Role_Detail__c]; 
		List<ICG_Contact_Role_Detail__c> contactRoleDetailList = [SELECT Id, Status__c, ICG_Role__c, ICG_Account_Role_Detail__c FROM ICG_Contact_Role_Detail__c]; 
		
		Test.startTest();
		String returnValue = CW_StationManagers.getContactsToAdd(aRdList[0].Id);
		Test.stopTest();		
		List<Contact> contactList = (List<Contact>) JSON.deserialize(returnValue, List<Contact>.class);
		System.assertEquals(2, contactList.size(), 'Unable to retrieve the other account contact');
	}
	
}