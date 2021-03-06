@isTest
public class CW_FacilityCapabilitiesControllerTest {
	@TestSetup
	private static void setup() {
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		String RT_NO_CERTIFICATION_REQUIRED = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'No_Certification_Required');

		Account acc = new Account(Name = 'Qatar Airways (Test)', Account_Type__c = 'Airline', Sector__c = 'Airline', Category__c = 'General Aviation', Payment_Term__c = 'Z001', Reason_for_creation__c = 'New agent');
		insert acc;

		Account_Role__c ar = CW_TestDataFactory.testAccountRole(acc.Id, 'Test Account Role');
		insert ar;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		ICG_Account_Role_Detail__c ard = new ICG_Account_Role_Detail__c();
		ard.Name = 'Generic Cargo Handling';
		ard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Cargo_Handling_Facility');
		ard.IATA_ISO_Country__c = country.Id;
		ard.Nearest_Airport__c = airport.Id;
		ard.Account_Role__c = ar.Id;
		ard.Available_Languages__c = 'ESP;GER';
		ard.Summary_Detail_Check_JSON__c = '{"capabilitiesMap":{"ground_service_equipment":{"summary":false,"detail":true},"screening_equipment":{"summary":true,"detail":true},"security_equipment_and_measures":{"summary":true,"detail":true},"weight_volume_and_dimension_equipment":{"summary":true,"detail":true},"safety_personal_and_protective_equipment":{"summary":true,"detail":true},"scanners":{"summary":true,"detail":true},"active_uld_equipment":{"summary":true,"detail":true},"delivery_pickup_infrastructure":{"summary":true,"detail":true},"cold_room_standard_temperature_ranges":{"summary":true,"detail":true},"cold_room_freezers_custom_temperature_ranges":{"summary":true,"detail":true},"temperature_controlled_handling_areas":{"summary":true,"detail":true},"pre_cooling":{"summary":true,"detail":true},"other_temperature_control_equipment_infrastructure":{"summary":true,"detail":true},"live_animals_capacities":{"summary":true,"detail":true},"build_up_break_down_areas":{"summary":true,"detail":true},"temporary_storage_and_working_areas":{"summary":true,"detail":true},"uld_storage":{"summary":true,"detail":true},"veterinary_phytosanitary_and_pest_control":{"summary":true,"detail":true}}}';
		insert ard;
		
		ICG_Account_Role_Detail__c ardAirline = new ICG_Account_Role_Detail__c();
		ardAirline.Name = 'Generic Airline';
		ardAirline.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Airline');
		ardAirline.IATA_ISO_Country__c = country.Id;
		ardAirline.Nearest_Airport__c = airport.Id;
		ardAirline.Account_Role__c = ar.Id;
		ardAirline.Available_Languages__c = 'ESP;GER';
		ardAirline.Summary_Detail_Check_JSON__c = '{"capabilitiesMap":{"ground_service_equipment":{"summary":false,"detail":true},"screening_equipment":{"summary":true,"detail":true},"security_equipment_and_measures":{"summary":true,"detail":true},"weight_volume_and_dimension_equipment":{"summary":true,"detail":true},"safety_personal_and_protective_equipment":{"summary":true,"detail":true},"scanners":{"summary":true,"detail":true},"active_uld_equipment":{"summary":true,"detail":true},"delivery_pickup_infrastructure":{"summary":true,"detail":true},"cold_room_standard_temperature_ranges":{"summary":true,"detail":true},"cold_room_freezers_custom_temperature_ranges":{"summary":true,"detail":true},"temperature_controlled_handling_areas":{"summary":true,"detail":true},"pre_cooling":{"summary":true,"detail":true},"other_temperature_control_equipment_infrastructure":{"summary":true,"detail":true},"live_animals_capacities":{"summary":true,"detail":true},"build_up_break_down_areas":{"summary":true,"detail":true},"temporary_storage_and_working_areas":{"summary":true,"detail":true},"uld_storage":{"summary":true,"detail":true},"veterinary_phytosanitary_and_pest_control":{"summary":true,"detail":true}}}';
		insert ardAirline;

		Account_Role_Detail_Capability__c ardCap = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		ardCap.Photos__c = '[{"extension":"jpg","id":"0691w000001YvlfAAC","internalExtension":"jpg","label":"ULD Dollies-0","url":"/sfc/dist/version/download/?oid=00D1w0000000Nw2&ids=0681w000001Z63k&d=%2Fa%2F1w000000D1kE%2FzZYdzMivXSgH5HIFOgHQFc6pVtYxps4iqKQNAz8Ohf8&asPdf=false","visible":true,"downloadDocument":"/sfc/dist/version/download/?oid=00D1w0000000Nw2&ids=0681w000001Z63k&d=%2Fa%2F1w000000D1kE%2FzZYdzMivXSgH5HIFOgHQFc6pVtYxps4iqKQNAz8Ohf8&asPdf=false"}]';
		insert ardCap;
		
		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		cert.Name = 'cert';
		insert cert;
		ICG_Certification__c cert2 = CW_TestDataFactory.newCertification();
		cert2.Name = 'cert2';
		insert cert2;

		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
		capvalcert.Expiration_Date__c = Date.today().addDays(1);
		capvalcert.ICG_Account_Role_Detail__c = ard.Id;
		capvalcert.RecordTypeId = RT_CERTIFICATION;
		insert capvalcert;

		ICG_Capability_Assignment_Group__c capvalcertRV = new ICG_Capability_Assignment_Group__c();
		capvalcertRV.Issue_Date__c = Date.today().addDays(-1);
		capvalcertRV.Expiration_Date__c = Date.today().addDays(1);
		capvalcertRV.ICG_Account_Role_Detail__c = ard.Id;
		capvalcertRV.RecordTypeId = RT_REMOTE_VALIDATION;
		insert capvalcertRV;
		
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
	public static void getMapFieldsByExtraDataType() {
		Test.startTest();
		Map<String, List<String>> response = cw_FacilityCapabilitiesController.getMapFieldsByExtraDataType();
		Test.stopTest();
		system.assertEquals(true, response.containsKey('active_uld_equipment#active_uld_equipment_1'), 'No metadata found for active_uld_equipment RecordType and active_uld_equipment_1 category');
	}
	@isTest
	public static void getCapabilitiesFromAccountRoleDetailIdTest() {
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');

		Id ardid = [SELECT id FROM ICG_Account_Role_Detail__c WHERE Name = 'Generic Airline' LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'System_For_Mail_Tracking_And_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c WHERE Name ='cert' AND ValidationPrograms__c = 'IATA'];
		
		ICG_Capability_Assignment_Group__c ardcert = [SELECT id,ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_CERTIFICATION];

		ICG_Capability_Assignment_Group__c capvalcert = [SELECT id FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_REMOTE_VALIDATION];
		
		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;

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
		system.assertEquals(true, response.containsKey(CW_CapabilitiesUtilities.SUPERCATEGORIES), 'No superCategories found for this Account Role Detail');
	}

	@isTest
	public static void getCapabilitiesFromAccountRoleDetailIdTest2() {
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');

		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'System_For_Mail_Tracking_And_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c WHERE Name ='cert' AND ValidationPrograms__c = 'IATA'];
		
		ICG_Capability_Assignment_Group__c ardcert = [SELECT id,ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_CERTIFICATION];

		ICG_Capability_Assignment_Group__c capvalcert = [SELECT id FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_REMOTE_VALIDATION];

		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;

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
		Boolean res = response.ContainsKey('e_getMessage');
		System.assertEquals(false, res, JSON.serialize(response));

		Test.stopTest();
	}

	@isTest
	public static void getComparisonSchemaTest() {
		ICG_Account_Role_Detail__c ard = [SELECT id, RecordType.DeveloperName FROM ICG_Account_Role_Detail__c LIMIT 1];
		Test.startTest();
		Map<String, Object> response = (Map<String, Object>) CW_FacilityCapabilitiesController.getComparisonSchema(ard.RecordType.DeveloperName);
		system.assertEquals(true, response.containsKey(CW_CapabilitiesUtilities.SUPERCATEGORIES), 'No superCategories property found in Comparison schema');
		List<CW_FacilityCapabilitiesController.ComparisonSuperCategoryWrapper> superCategories = (List<CW_FacilityCapabilitiesController.ComparisonSuperCategoryWrapper>) response.get(CW_CapabilitiesUtilities.SUPERCATEGORIES);
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
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');

		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'System_For_Mail_Tracking_And_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c WHERE Name ='cert' AND ValidationPrograms__c = 'IATA'];
		
		ICG_Capability_Assignment_Group__c ardcert = [SELECT id,ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_CERTIFICATION];

		ICG_Capability_Assignment_Group__c capvalcert = [SELECT id FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_REMOTE_VALIDATION];

		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;

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

		List<CW_Utilities.CapabilityWrapper> listCap = new List<CW_Utilities.CapabilityWrapper>();
		List<Account_Role_Detail_Capability__c> listCapWrapper = new List<Account_Role_Detail_Capability__c>();
		listCapWrapper.add(cap);
		listCapWrapper.add(capWithBadPhotos);

		for (Account_Role_Detail_Capability__c capItem : listCapWrapper) {
			CW_Utilities.CapabilityWrapper convertItem = new CW_Utilities.CapabilityWrapper();
			convertItem.rtypeId = capItem.RecordTypeId;
			convertItem.category = capItem.Category__c;
			convertItem.equipment = capItem.Equipment__c;

			convertItem.fields = new List<CW_Utilities.CapabilityFieldsWrapper>();
			CW_Utilities.CapabilityFieldsWrapper fieldDate = new CW_Utilities.CapabilityFieldsWrapper();
			CW_Utilities.CapabilityFieldsWrapper fieldDateEmpty = new CW_Utilities.CapabilityFieldsWrapper();
			CW_Utilities.CapabilityFieldsWrapper fieldDouble = new CW_Utilities.CapabilityFieldsWrapper();
			CW_Utilities.CapabilityFieldsWrapper fieldDoubleEmpty = new CW_Utilities.CapabilityFieldsWrapper();
			CW_Utilities.CapabilityFieldsWrapper fieldBoolena = new CW_Utilities.CapabilityFieldsWrapper();
			CW_Utilities.CapabilityFieldsWrapper fieldElse = new CW_Utilities.CapabilityFieldsWrapper();

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
		
		String jsonRes = CW_FacilityCapabilitiesController.createRelationshipsForNewCapabilities(ardid, listCap);
		String jsonResError = CW_FacilityCapabilitiesController.createRelationshipsForNewCapabilities(ardid, null);
		
		CW_Utilities.ResponseBody res = (CW_Utilities.ResponseBody) JSON.deserialize(jsonRes, CW_Utilities.ResponseBody.class);
		CW_Utilities.ResponseBody resError = (CW_Utilities.ResponseBody) JSON.deserialize(jsonResError, CW_Utilities.ResponseBody.class);

		system.assertEquals(res.success, true);
		system.assertEquals(resError.success, false);

		Test.stopTest();
	}

	@isTest
	public static void setVisibilityPhotosTest() {
		Id ardcid = [SELECT id FROM Account_Role_Detail_Capability__c LIMIT 1].id;

		Test.startTest();
		Object returnJson = CW_FacilityCapabilitiesController.setVisibilityPhotos(ardcid,'photos__c', 'test');
		system.assertNotEquals(null, returnJson);
		Test.stopTest();
	}

	@isTest
	public static void getPicklistEntryMapCapTest() {
		Id ardcid = [SELECT id FROM Account_Role_Detail_Capability__c LIMIT 1].id;

		Test.startTest();
		CW_FacilityCapabilitiesController.CapabilityPhoto photo = new CW_FacilityCapabilitiesController.CapabilityPhoto(); 
		
		Map<String, Schema.PicklistEntry> equipment =  CW_FacilityCapabilitiesController.getPicklistEntryMapCapEquipment(); 
		Map<String, Schema.PicklistEntry> category = CW_FacilityCapabilitiesController.getPicklistEntryMapCapCategory();
		
		system.assertNotEquals(equipment.size(), 0);
		system.assertNotEquals(category.size(), 0);

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

		List<List<Map<String, Object>>> columns = CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, null, null);
		system.assertNotEquals(columns.size(), 0);
		
		List<String> fieldsToGet = new List<String>();
		fieldsToGet.add('field');
		
		Map<String, Object> fieldNotExist = CW_FacilityCapabilitiesController.convertCapabilityAssignmentToObject(null, fieldsToGet, null);
		String fieldNotExistValue = (String)fieldNotExist.get('field');
		system.assertEquals(fieldNotExistValue, 'NOT EXIST');

		Object itemMap = CW_FacilityCapabilitiesController.getItemInMap(null, null, null);
		system.assertEquals(itemMap, null);
		
		Test.stopTest();
	}

	@isTest
	public static void AsgmtGroupWrapperCompareTest() {
		Test.startTest();
		
		CW_Utilities.AsgmtGroupWrapper asgmtGroupToAdd1 = new CW_Utilities.AsgmtGroupWrapper();
		CW_Utilities.AsgmtGroupWrapper asgmtGroupToAdd2 = new CW_Utilities.AsgmtGroupWrapper();
		
		Integer result = asgmtGroupToAdd1.compareTo(asgmtGroupToAdd2);
		system.assertEquals(result, 0);

		asgmtGroupToAdd1.order = 1;
		asgmtGroupToAdd2.order = 1;

		result = asgmtGroupToAdd1.compareTo(asgmtGroupToAdd2);
		system.assertEquals(result, 0);

		asgmtGroupToAdd1.order = 2;
		result = asgmtGroupToAdd1.compareTo(asgmtGroupToAdd2);
		system.assertEquals(result, 1);

		asgmtGroupToAdd2.order = 3;
		result = asgmtGroupToAdd1.compareTo(asgmtGroupToAdd2);
		system.assertEquals(result, -1);
		
		Test.stopTest();
	}

	@isTest
	public static void generateCapabilitiesStructureCsvTest() {
		Test.startTest();
		
		String result = CW_FacilityCapabilitiesController.generateCapabilitiesStructureCsv();
		system.assertNotEquals(null, result);
		
		Test.stopTest();
	}

	@isTest
	public static void getCapabilitiesPhotosFromStation() {
		ICG_Account_Role_Detail__c stationFound;
		for (ICG_Account_Role_Detail__c currentRow : [SELECT Id FROM ICG_Account_Role_Detail__c WHERE Name = 'Generic Cargo Handling']) {
			if (stationFound == null) {
				stationFound = currentRow;
			}
		}

		Test.startTest();
		List<CW_AccountDetailCarousel.Carousel> photos = CW_CapabilitiesUtilities.getCapabilitiesPhotosFromStation(stationFound.Id);
		System.assertEquals(false, photos.isEmpty(), 'Photos must not be empty');
		System.assertEquals(1, photos.size(), 'Photos length must be 1');
		System.assertEquals(true, photos[0].visible, 'Photos [0] must be visible');
		System.assertEquals('jpg', photos[0].fileExtension, 'Photos [0] extension must be jpg');
		Test.stopTest();
	}

	@isTest
	public static void getMapTooltipBySuperCategoryTest() {
		Test.startTest();
		
		Map<String, List<String>> result = CW_FacilityCapabilitiesController.getMapTooltipBySuperCategory();
		system.assertNotEquals(null, result);
		
		Test.stopTest();
	}
}