@isTest
public class CW_CapabilitiesManagerControllerTest {
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
		assignment.ICG_Capability_Assignment_Group__c = capvalcert.id;
		insert assignment;
	}

	@isTest
	public static void getCapabilitiesFromAccountRoleDetailIdTest() {
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
        
        Map<String, Object> response = CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId(ardid, String.valueOf(ardcert.id),false);
		system.assertEquals(true, response.containsKey('superCategories'), 'No superCategories found for this Account Role Detail');
        
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
		CW_CapabilitiesManagerController.CapabilityPhoto item = new CW_CapabilitiesManagerController.CapabilityPhoto();
		item.visible = true;
		item.url = conDoc;
		item.label = 'label';
		listPhoto.add(item);

        Test.startTest();
        
		CW_CapabilitiesManagerController.getPublicLinkToFiles(listPhoto);
        
        Test.stopTest();
	}

	@isTest
	public static void createRelationshipsForNewCapabilities() {
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

		Map<String, Object> response = CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId(ardid, String.valueOf(ardcert.id),false);

		List<CW_CapabilitiesManagerController.CapabilityWrapper> listCap = new List<CW_CapabilitiesManagerController.CapabilityWrapper>();
		List<Account_Role_Detail_Capability__c> listCapWrapper = new List<Account_Role_Detail_Capability__c>();
		listCapWrapper.add(cap);
		listCapWrapper.add(capWithBadPhotos);

		for (Account_Role_Detail_Capability__c capItem : listCapWrapper) {
			CW_CapabilitiesManagerController.CapabilityWrapper convertItem = new CW_CapabilitiesManagerController.CapabilityWrapper();
			convertItem.rtypeId = capItem.RecordTypeId;
			convertItem.category = capItem.Category__c;
			convertItem.equipment_value = capItem.Equipment__c;

			convertItem.fields = new List<CW_CapabilitiesManagerController.CapabilityFieldsWrapper>();
			CW_CapabilitiesManagerController.CapabilityFieldsWrapper fieldDate = new CW_CapabilitiesManagerController.CapabilityFieldsWrapper();
			CW_CapabilitiesManagerController.CapabilityFieldsWrapper fieldDateEmpty = new CW_CapabilitiesManagerController.CapabilityFieldsWrapper();
			CW_CapabilitiesManagerController.CapabilityFieldsWrapper fieldDouble = new CW_CapabilitiesManagerController.CapabilityFieldsWrapper();
			CW_CapabilitiesManagerController.CapabilityFieldsWrapper fieldDoubleEmpty = new CW_CapabilitiesManagerController.CapabilityFieldsWrapper();
			CW_CapabilitiesManagerController.CapabilityFieldsWrapper fieldBoolena = new CW_CapabilitiesManagerController.CapabilityFieldsWrapper();
			CW_CapabilitiesManagerController.CapabilityFieldsWrapper fieldElse = new CW_CapabilitiesManagerController.CapabilityFieldsWrapper();

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
        
		CW_CapabilitiesManagerController.createRelationshipsForNewCapabilities(ardid, ardcert.id, listCap);
        
        Test.stopTest();
	}
}