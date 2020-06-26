@isTest
public class CW_FacilityCapabilitiesControllerTest {
	@TestSetup
	private static void setup() {
		Account acc = new Account(Name = 'Qatar Airways (Test)', Account_Type__c = 'Airline', Sector__c = 'Airline', Category__c = 'General Aviation', Payment_Term__c = 'Z001', Reason_for_creation__c = 'New agent');
		insert acc;

		Account_Role__c ar = CW_TestDataFactory.testAccountRole(acc.Id, 'Test Account Role');
		insert ar;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		ICG_Account_Role_Detail__c ard = new ICG_Account_Role_Detail__c();
		ard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Cargo_Handling_Facility');
		ard.IATA_ISO_Country__c = country.Id;
		ard.Nearest_Airport__c = airport.Id;
		ard.Account_Role__c = ar.Id;
		ard.Available_Languages__c = 'ESP;GER';
		ard.Summary_Detail_Check_JSON__c = '{"capabilitiesMap":{"ground_service_equipment":{"summary":false,"detail":true},"screening_equipment":{"summary":true,"detail":true},"security_equipment_and_measures":{"summary":true,"detail":true},"weight_volume_and_dimension_equipment":{"summary":true,"detail":true},"safety_personal_and_protective_equipment":{"summary":true,"detail":true},"scanners":{"summary":true,"detail":true},"active_uld_equipment":{"summary":true,"detail":true},"delivery_pickup_infrastructure":{"summary":true,"detail":true},"cold_room_standard_temperature_ranges":{"summary":true,"detail":true},"cold_room_freezers_custom_temperature_ranges":{"summary":true,"detail":true},"temperature_controlled_handling_areas":{"summary":true,"detail":true},"pre_cooling":{"summary":true,"detail":true},"other_temperature_control_equipment_infrastructure":{"summary":true,"detail":true},"live_animals_capacities":{"summary":true,"detail":true},"build_up_break_down_areas":{"summary":true,"detail":true},"temporary_storage_and_working_areas":{"summary":true,"detail":true},"uld_storage":{"summary":true,"detail":true},"veterinary_phytosanitary_and_pest_control":{"summary":true,"detail":true}}}';
		insert ard;

		Account_Role_Detail_Capability__c ardCap = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCap;

		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
        capvalcert.Expiration_Date__c = Date.today().addDays(1);
        capvalcert.ICG_Account_Role_Detail__c = ard.Id;
		insert capvalcert;

		ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ard.Id, ardCap.Id);
		assignment.ICG_Capability_Assignment_Group__c = capvalcert.Id;
		insert assignment;
	}

	@isTest
	public static void getMapCategoriesByAccountRoleDetailRecordTypeTest() {
		Test.startTest();
		Map<String, List<String>> response = cw_FacilityCapabilitiesController.getMapCategoriesByAccountRoleDetailRecordType();
		Test.stopTest();
		system.assertEquals(response.containsKey('airline'), true, 'No metadata found for airline RecordType');
	}
	@isTest
	public static void getMapRecordTypesBySectionTest() {
		Test.startTest();
		List<Map<String, Object>> response = cw_FacilityCapabilitiesController.getMapRecordTypesBySection();
		Boolean found = false;
		for (Map<String, Object> mapa : response) {
			for (String clave : mapa.keySet()) {
				if (mapa.get(clave) == 'Facility Equipment and Infrastructure') {
					found = true;
					break;
				}
			}
		}
		Test.stopTest();
		system.assertEquals(true, found, 'Facility Equipment and Infrastructure section not found');
	}
	@isTest
	public static void getMapCategoriesByRecordTypeTest() {
		Test.startTest();
		Map<String, List<String>> response = cw_FacilityCapabilitiesController.getMapCategoriesByRecordType();
		Test.stopTest();
		system.assertEquals(true, response.containsKey('active_uld_equipment'), 'No metadata found for active_uld_equipment RecordType');
	}
	@isTest
	public static void getMapFieldsByRecordTypeAndCategoryTest() {
		Test.startTest();
		Map<String, List<String>> response = cw_FacilityCapabilitiesController.getMapFieldsByRecordTypeAndCategory();
		Test.stopTest();
		system.assertEquals(true, response.containsKey('active_uld_equipment#active_uld_equipment_1'), 'No metadata found for active_uld_equipment RecordType and active_uld_equipment_1 category');
	}
	@isTest
	public static void getMapFieldsByGroupFieldTest() {
		Test.startTest();
		Map<String, List<String>> response = cw_FacilityCapabilitiesController.getMapFieldsByGroupField();
		Test.stopTest();
		system.assertEquals(true, response.containsKey('Aperture Size (in cm)'), 'No metadata found for Aperture Size (in cm) groupfield');
	}
	@isTest
	public static void getCapabilitiesFromAccountRoleDetailIdTest() {
		Id ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Mail_Tracking_and_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		insert cert;
		ICG_Certification__c cert2 = CW_TestDataFactory.newCertification();
		cert2.Name = 'cert2';
		insert cert2;
		ICG_Capability_Assignment_Group__c ardcert = new ICG_Capability_Assignment_Group__c();
		ardcert.ICG_Certification__c = cert.id;
		ardcert.ICG_Account_Role_Detail__c = ardid;
		ardcert.Issue_Date__c = date.today().addDays(-1);
		ardcert.Expiration_Date__c = date.today().addDays(1);
		insert ardcert;
		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;
		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
		capvalcert.Expiration_Date__c = Date.today().addDays(1);
        capvalcert.ICG_Account_Role_Detail__c = ardid;
		insert capvalcert;

		Account_Role_Detail_Capability__c capWithBadPhotos = new Account_Role_Detail_Capability__c();
		capWithBadPhotos.GSE_ULD_Compatibility_Type_AKE__c = true;
		capWithBadPhotos.ESC_Name__c = 'whatever 2';
		capWithBadPhotos.Name = 'whatever 2';
		capWithBadPhotos.Number__c = 14.5;
		capWithBadPhotos.RecordTypeId = rtColdRoomsId;
		capWithBadPhotos.Category__c = '2_To_8_C';
		capWithBadPhotos.Equipment__c = '2_To_8_C';
		capWithBadPhotos.Photos__c = '{';
		insert capWithBadPhotos;
		Test.startTest();
		Map<String, Object> response = CW_FacilityCapabilitiesController.getCapabilitiesFromAccountRoleDetailId(ardid);
		Test.stopTest();
		system.assertEquals(true, response.containsKey('superCategories'), 'No superCategories found for this Account Role Detail');
    }

	@isTest
	public static void getCapabilitiesFromAccountRoleDetailIdTest2() {
		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Mail_Tracking_and_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		insert cert;
		ICG_Certification__c cert2 = CW_TestDataFactory.newCertification();
		cert2.Name = 'cert2';
		insert cert2;
		ICG_Capability_Assignment_Group__c ardcert = new ICG_Capability_Assignment_Group__c();
		ardcert.ICG_Certification__c = cert.id;
		ardcert.ICG_Account_Role_Detail__c = ardid;
		ardcert.Issue_Date__c = date.today().addDays(-1);
		ardcert.Expiration_Date__c = date.today().addDays(1);
		insert ardcert;

		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;

		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
		capvalcert.Expiration_Date__c = Date.today().addDays(1);
        capvalcert.ICG_Account_Role_Detail__c = ardid;
		insert capvalcert;

		Account_Role_Detail_Capability__c capWithBadPhotos = new Account_Role_Detail_Capability__c();
		capWithBadPhotos.GSE_ULD_Compatibility_Type_AKE__c = true;
		capWithBadPhotos.ESC_Name__c = 'whatever 2';
		capWithBadPhotos.Name = 'whatever 2';
		capWithBadPhotos.Number__c = 14.5;
		capWithBadPhotos.RecordTypeId = rtColdRoomsId;
		capWithBadPhotos.Category__c = '2_To_8_C';
		capWithBadPhotos.Equipment__c = '2_To_8_C';
		capWithBadPhotos.Photos__c = '{';
		insert capWithBadPhotos;

		ICG_Certification_Capability_Assignment__c capability = new ICG_Certification_Capability_Assignment__c();
		capability.ICG_Certification__c = cert.id;
		capability.Category__c = 'CCTV';
        capability.Equipment__c = 'CCTV';
        insert capability;
        
        ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ardid, cap.Id);
        assignment.ICG_Capability_Assignment_Group__c = capvalcert.id;
        insert assignment;
        
		Test.startTest();
		Map<String, Object> response = CW_FacilityCapabilitiesController.getCapabilitiesFromAccountRoleDetailId(ardid);
        Test.stopTest();
	}

	@isTest
	public static void getComparisonSchemaTest() {
		ICG_Account_Role_Detail__c ard = [SELECT id, RecordType.DeveloperName FROM ICG_Account_Role_Detail__c LIMIT 1];
		Test.startTest();
		Map<String, Object> response = (Map<String, Object>) CW_FacilityCapabilitiesController.getComparisonSchema(ard.RecordType.DeveloperName);
		system.assertEquals(true, response.containsKey('superCategories'), 'No superCategories property found in Comparison schema');
		List<CW_FacilityCapabilitiesController.ComparisonSuperCategoryWrapper> superCategories = (List<CW_FacilityCapabilitiesController.ComparisonSuperCategoryWrapper>) response.get('superCategories');
		system.assertEquals(2, superCategories.size(), 'Response does not contain supercategories');

		for (CW_FacilityCapabilitiesController.ComparisonSuperCategoryWrapper superCategory : superCategories) {
			System.assert(!superCategory.sections.isEmpty(), 'Supercategory does not contain sections');
			for (CW_FacilityCapabilitiesController.ComparisonSectionWrapper section : superCategory.sections) {
				System.assert(!section.rts.isEmpty(), 'Section does not contain rts');
				for (CW_FacilityCapabilitiesController.ComparisonRtWrapper rt : section.rts) {
					System.assert(!rt.categories.isEmpty(), 'RT does not contain categories');
					for (CW_FacilityCapabilitiesController.ComparisonCategoryWrapper category : rt.categories) {
						System.assert(!category.equipments.isEmpty(), 'Category does not contain equipments');
					}
				}
			}
		}

		Test.stopTest();
	}

	@isTest
	public static void setSummaryDetailCheckJSONTest() {
		Id ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		String jsonData = '{"capabilitiesMap":{"ground_service_equipment":{"summary":false,"detail":true},"screening_equipment":{"summary":true,"detail":true},"security_equipment_and_measures":{"summary":true,"detail":true},"weight_volume_and_dimension_equipment":{"summary":true,"detail":true},"safety_personal_and_protective_equipment":{"summary":true,"detail":true},"scanners":{"summary":true,"detail":true},"active_uld_equipment":{"summary":true,"detail":true},"delivery_pickup_infrastructure":{"summary":true,"detail":true},"cold_room_standard_temperature_ranges":{"summary":true,"detail":true},"cold_room_freezers_custom_temperature_ranges":{"summary":true,"detail":true},"temperature_controlled_handling_areas":{"summary":true,"detail":true},"pre_cooling":{"summary":true,"detail":true},"other_temperature_control_equipment_infrastructure":{"summary":true,"detail":true},"live_animals_capacities":{"summary":true,"detail":true},"build_up_break_down_areas":{"summary":true,"detail":true},"temporary_storage_and_working_areas":{"summary":true,"detail":true},"uld_storage":{"summary":true,"detail":true},"veterinary_phytosanitary_and_pest_control":{"summary":true,"detail":true}}}';

		Test.startTest();
		system.assertEquals(true, CW_FacilityCapabilitiesController.setSummaryDetailCheckJSON(ardid, jsonData));
		system.assertNotEquals('', CW_FacilityCapabilitiesController.setSummaryDetailCheckJSON(null, null));
		Test.stopTest();
	}

	@isTest
	public static void createRelationshipsForNewCapabilitiesTest() {
		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Mail_Tracking_and_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		insert cert;

		ICG_Certification__c cert2 = CW_TestDataFactory.newCertification();
		cert2.Name = 'cert2';
		insert cert2;

		ICG_Capability_Assignment_Group__c ardcert = new ICG_Capability_Assignment_Group__c();
		ardcert.ICG_Certification__c = cert.id;
		ardcert.ICG_Account_Role_Detail__c = ardid;
		ardcert.Issue_Date__c = date.today().addDays(-1);
		ardcert.Expiration_Date__c = date.today().addDays(1);
		insert ardcert;

		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;

		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
		capvalcert.Expiration_Date__c = Date.today().addDays(1);
        capvalcert.ICG_Account_Role_Detail__c = ardid;
		insert capvalcert;

		Account_Role_Detail_Capability__c capWithBadPhotos = new Account_Role_Detail_Capability__c();
		capWithBadPhotos.GSE_ULD_Compatibility_Type_AKE__c = true;
		capWithBadPhotos.ESC_Name__c = 'whatever 2';
		capWithBadPhotos.Name = 'whatever 2';
		capWithBadPhotos.Number__c = 14.5;
		capWithBadPhotos.RecordTypeId = rtColdRoomsId;
		capWithBadPhotos.Category__c = '2_To_8_C';
		capWithBadPhotos.Equipment__c = '2_To_8_C';
		capWithBadPhotos.Photos__c = '{';
		insert capWithBadPhotos;

		ICG_Certification_Capability_Assignment__c capability = new ICG_Certification_Capability_Assignment__c();
		capability.ICG_Certification__c = cert.id;
		capability.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		capability.Equipment__c = 'CARDIT';
		insert capability;

		ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ardid, cap.Id);
		assignment.ICG_Capability_Assignment_Group__c = capvalcert.id;
		insert assignment;

		List<CW_FacilityCapabilitiesController.CapabilityWrapper> listCap = new List<CW_FacilityCapabilitiesController.CapabilityWrapper>();
		List<Account_Role_Detail_Capability__c> listCapWrapper = new List<Account_Role_Detail_Capability__c>();
		listCapWrapper.add(cap);
		listCapWrapper.add(capWithBadPhotos);

		for (Account_Role_Detail_Capability__c capItem : listCapWrapper) {
			CW_FacilityCapabilitiesController.CapabilityWrapper convertItem = new CW_FacilityCapabilitiesController.CapabilityWrapper();
			convertItem.rtypeId = capItem.RecordTypeId;
			convertItem.category = capItem.Category__c;
			convertItem.equipment = capItem.Equipment__c;

			convertItem.fields = new List<CW_FacilityCapabilitiesController.CapabilityFieldsWrapper>();
			CW_FacilityCapabilitiesController.CapabilityFieldsWrapper fieldDate = new CW_FacilityCapabilitiesController.CapabilityFieldsWrapper();
			CW_FacilityCapabilitiesController.CapabilityFieldsWrapper fieldDateEmpty = new CW_FacilityCapabilitiesController.CapabilityFieldsWrapper();
			CW_FacilityCapabilitiesController.CapabilityFieldsWrapper fieldDouble = new CW_FacilityCapabilitiesController.CapabilityFieldsWrapper();
			CW_FacilityCapabilitiesController.CapabilityFieldsWrapper fieldDoubleEmpty = new CW_FacilityCapabilitiesController.CapabilityFieldsWrapper();
			CW_FacilityCapabilitiesController.CapabilityFieldsWrapper fieldBoolena = new CW_FacilityCapabilitiesController.CapabilityFieldsWrapper();
			CW_FacilityCapabilitiesController.CapabilityFieldsWrapper fieldElse = new CW_FacilityCapabilitiesController.CapabilityFieldsWrapper();

			fieldDate.field = 'Expiry_Date__c';
			fieldDate.Value = string.valueOf(Date.today().addDays(1));
			fieldDateEmpty.field = 'Expiry_Date__c';
			fieldDateEmpty.Value = '';

			fieldDouble.field = 'Number__c';
			fieldDouble.Value = '14';
			fieldDoubleEmpty.field = 'Number__c';
			fieldDoubleEmpty.Value = '';

			fieldBoolena.field = 'Depreciated__c';
			fieldBoolena.Value = 'false';

			fieldElse.field = 'Name';
			fieldElse.Value = 'Name';

			convertItem.fields.add(fieldDate);
			convertItem.fields.add(fieldDateEmpty);
			convertItem.fields.add(fieldDouble);
			convertItem.fields.add(fieldDoubleEmpty);
			convertItem.fields.add(fieldBoolena);
			convertItem.fields.add(fieldElse);

			listCap.add(convertItem);
		}

		Test.startTest();
		CW_FacilityCapabilitiesController.createRelationshipsForNewCapabilities(ardid, listCap);
		CW_FacilityCapabilitiesController.createRelationshipsForNewCapabilities(ardid, null);
		Test.stopTest();
	}

	@isTest
	public static void setVisibilityPhotosTest() {
		Id ardcid = [SELECT id FROM Account_Role_Detail_Capability__c LIMIT 1].id;

        Test.startTest();
		Object returnJson = CW_FacilityCapabilitiesController.setVisibilityPhotos(ardcid, 'test');
		system.assertNotEquals(null, returnJson);
		Test.stopTest();
	}

	@isTest
	public static void getPicklistEntryMapCapTest() {
		Id ardcid = [SELECT id FROM Account_Role_Detail_Capability__c LIMIT 1].id;

        Test.startTest();
        CW_FacilityCapabilitiesController.CapabilityPhoto photo = new CW_FacilityCapabilitiesController.CapabilityPhoto(); 
		CW_FacilityCapabilitiesController.getPicklistEntryMapCapEquipment(); 
		CW_FacilityCapabilitiesController.getPicklistEntryMapCapCategory();
		Test.stopTest();
	}

	@isTest
	public static void catchesTest() {
        Test.startTest();
        CW_FacilityCapabilitiesController.CapabilityPhoto photo = new CW_FacilityCapabilitiesController.CapabilityPhoto();
        photo.visible = true;
        photo.url = 'url';
        photo.label = 'label';  

        Account_Role_Detail_Capability__c currentDetail = new Account_Role_Detail_Capability__c(); 

		CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, null, null);
		// CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, 'field', null); 
        
        List<String> fieldsToGet = new List<String>();
        fieldsToGet.add('field');
        
        CW_FacilityCapabilitiesController.convertCapabilityAssignmentToObject(null, fieldsToGet, null);

		CW_FacilityCapabilitiesController.getItemInMap(null, null, null);
		Test.stopTest();
	}
}