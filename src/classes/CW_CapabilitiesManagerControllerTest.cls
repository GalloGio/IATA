@isTest
public class CW_CapabilitiesManagerControllerTest {
	@TestSetup
	private static void setup() {
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
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
		capvalcert.ICG_Certification__c = cert.id;
		capvalcert.RecordTypeId = RT_CERTIFICATION;
		insert capvalcert;
		
		ICG_Capability_Assignment_Group__c capvalcertRV = new ICG_Capability_Assignment_Group__c();
		capvalcertRV.Issue_Date__c = Date.today().addDays(-1);
		capvalcertRV.Expiration_Date__c = Date.today().addDays(1);
		capvalcertRV.ICG_Account_Role_Detail__c = ard.Id;
		capvalcertRV.RecordTypeId = RT_REMOTE_VALIDATION;
		insert capvalcertRV;

		ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ard.Id, ardCap.Id);
		assignment.ICG_Capability_Assignment_Group__c = capvalcert.id;
		insert assignment;
	}

	@isTest
	public static void getCapabilitiesFromAccountRoleDetailIdTest() {
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c WHERE Name = 'Generic Cargo Handling' LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'System_For_Mail_Tracking_And_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		Account_Role_Detail_Capability__c cap = new Account_Role_Detail_Capability__c();
		cap.GSE_ULD_Compatibility_Type_AKE__c = true;
		cap.ESC_Name__c = 'whatever';
		cap.Name = 'whatever';
		cap.Number__c = 10.5;
		cap.RecordTypeId = rtId;
		cap.Category__c = 'System_For_Mail_Tracking_And_Reporting';
		cap.Equipment__c = 'CARDIT';
		insert cap;

		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c WHERE Name ='cert'];
		
		ICG_Capability_Assignment_Group__c ardcert = [SELECT id,ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_CERTIFICATION];

		ICG_Capability_Assignment_Group__c capvalcert = [SELECT id FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =: RT_REMOTE_VALIDATION];

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
		
		Map<String, Object> responseByCerti = CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId(ardid, ardcert.ICG_Certification__c, ardcert.id, null);
		system.assertEquals(true, responseByCerti.containsKey(CW_CapabilitiesUtilities.SUPERCATEGORIES), 'No superCategories found for this Account Role Detail');
		
		Map<String, Object> responseAllCapab = CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId(ardid, null, null, null);
		system.assertEquals(true, responseAllCapab.containsKey(CW_CapabilitiesUtilities.SUPERCATEGORIES), 'No superCategories found for this Account Role Detail');
		
		Test.stopTest();
	}

	@isTest
	public static void getPublicLinkToFiles() {
		ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
		conVer.PathOnClient = 'item.pdf'; // The files name, extension is very important here which will help the file in preview.
		conVer.Title = 'title file'; // Display name of the files
		conVer.VersionData = EncodingUtil.base64Decode('TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCAuLi4='); // converting your binary string to Blog
		insert conVer;
		// First get the content document Id from ContentVersion
		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;

		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;

		//Create ContentDocumentLink
		ContentDocumentLink cDe = new ContentDocumentLink();
		cDe.ContentDocumentId = conDoc;
		cDe.LinkedEntityId = ardid; // you can use objectId,GroupId etc
		cDe.ShareType = 'I';
		cDe.Visibility = 'AllUsers';
		insert cDe;

		List<Object> listPhoto = new List<Object>();
		CW_FacilityCapabilitiesController.CapabilityPhoto item = new CW_FacilityCapabilitiesController.CapabilityPhoto();
		item.visible = true;
		item.url = conDoc;
		item.Id = conDoc;
		item.label = 'label';
		item.internalExtension = 'pdf';
		listPhoto.add(item);

		Test.startTest();
		
		String response = CW_CapabilitiesManagerController.getPublicLinkToFiles(listPhoto);
		CW_Utilities.ResponseBody resp = (CW_Utilities.ResponseBody) System.JSON.deserialize(response, CW_Utilities.ResponseBody.class);
		system.assertEquals(true, resp.success, 'getPublicLinkToFiles error');
		
		Test.stopTest();
	}

	@isTest
	public static void createRelationshipsForNewCapabilities() {
		String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		String ardid = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Id rtId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'System_For_Mail_Tracking_And_Reporting' LIMIT 1].id;
		Id rtColdRoomsId = [SELECT id FROM RecordType WHERE SObjectType = 'Account_Role_Detail_Capability__c' AND developername = 'Cold_Room_Standard_Temperature_Ranges' LIMIT 1].id;

		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c WHERE Name ='cert'];
		
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

		ICG_Account_Role_Detail__c ard = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1];

		ardCert.id = null;
		ardCert.ICG_Account_Role_Detail__c = ard.id;
		ardCert.ICG_Certification__c = cert.id;
		ardCert.Certification_Id__c = 'testABC12345';
		ardCert.Issue_Date__c = Date.valueOf('2019-12-12');
		ardCert.Expiration_Date__c = Date.valueOf('2020-12-12');
		string jsonCertificationToAdd = JSON.serialize(ardCert);

		Test.startTest();
		
		CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId(ardid, String.valueOf(ardcert.id), capvalcert.id, null);
		
		String response = CW_CapabilitiesManagerController.createRelationshipsForNewCapabilities(ardid, cert.id, listCap, jsonCertificationToAdd);
		CW_Utilities.ResponseBody resp = (CW_Utilities.ResponseBody) System.JSON.deserialize(response, CW_Utilities.ResponseBody.class);
		system.assertEquals(true, resp.success, 'createRelationshipsForNewCapabilities');

		String responseUpdate = CW_CapabilitiesManagerController.updateCapabilitiesEdited(ardid,cert.Id,listCap);
		CW_Utilities.ResponseBody respUpdate = (CW_Utilities.ResponseBody) System.JSON.deserialize(response, CW_Utilities.ResponseBody.class);
		system.assertEquals(true, respUpdate.success, 'updateCapabilitiesEditedTest');
		
		String responseEditAllCapab = CW_CapabilitiesManagerController.editAllCapabilitiesFromStation(ardid,listCap,new List<Object>{assignment});
		CW_Utilities.ResponseBody respEditAllCapab = (CW_Utilities.ResponseBody) System.JSON.deserialize(response, CW_Utilities.ResponseBody.class);
		system.assertEquals(true, respEditAllCapab.success, 'updateCapabilitiesEditedAllCapabTest');
		
		Test.stopTest();
	}

	@isTest
	public static void updateCapabilitiesEditedCatchTest() {

		Test.startTest();
		
		String response = CW_CapabilitiesManagerController.updateCapabilitiesEdited(null,null,null);
		CW_Utilities.ResponseBody resp = (CW_Utilities.ResponseBody) System.JSON.deserialize(response, CW_Utilities.ResponseBody.class);
		system.assertEquals(false, resp.success, 'updateCapabilitiesEditedCatchTest error');
		
		
		Test.stopTest();
	}

	@isTest
	public static void editAllCapabilitiesFromStationCatchTest() {

		Test.startTest();
		
		String response = CW_CapabilitiesManagerController.editAllCapabilitiesFromStation(null,null,null);
		CW_Utilities.ResponseBody resp = (CW_Utilities.ResponseBody) System.JSON.deserialize(response, CW_Utilities.ResponseBody.class);
		system.assertEquals(false, resp.success, 'editAllCapabilitiesFromStationCatchTest error');
		
		
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
	
}