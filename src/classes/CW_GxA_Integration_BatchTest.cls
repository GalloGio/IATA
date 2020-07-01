@IsTest
public with sharing class CW_GxA_Integration_BatchTest {
	private static final Boolean TRACEIT = true;
	private static final string PREFIX = 'CW_GxA_Handler:: ';
	
	@TestSetup
	static void setup(){
		CW_GxA_Amazon_S3__c cfgAwsGxA = new CW_GxA_Amazon_S3__c();
		cfgAwsGxA.Base_Path__c = 'SmartFacilityRemoteValidations/';
		cfgAwsGxA.Named_Credential__c = 'CW_AWS_S3_REMOTE_VALIDATIONS';
		cfgAwsGxA.Index_File__c = 'Result.json';
		cfgAwsGxA.Bucket__c = 'pwc-dev-0f0a94bcb834b69f';

		insert cfgAwsGxA;

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

		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		ard.Name = 'Generic Cargo Handling';
		insert ard;
		ICG_Account_Role_Detail__c ard2 = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard2;
		handleTrace(PREFIX + 'ICG_Account_Role_Detail__c insert');

		ICG_Certification__c sfocCert = CW_TestDataFactory.newCertification();
		sfocCert.Name = 'SF Operational Capacity';
		insert sfocCert;
		ICG_Certification__c ceivCert = CW_TestDataFactory.newCertification();
		ceivCert.Certification_Type__c = 'Certifications of Excellency';
		insert ceivCert;
		handleTrace(PREFIX + 'ICG_Certification__c insert');
	   
		ICG_Capability_Assignment_Group__c ardCert = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard.id, sfocCert.id);
		insert ardCert;
		ICG_Capability_Assignment_Group__c ardCert2 = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard2.id, ceivCert.id);
		insert ardCert2;
		handleTrace(PREFIX + 'ICG_Capability_Assignment_Group__c insert');

		Contact con1 = new Contact(FirstName = 'Test', LastName='Test', Email = 'Test@Test.com',AccountId = acc.id);
		insert con1;
		
		Order oOrder = TestDataGenerator.generateOrder(1, con1.AccountId, con1.Id, con1.Id, false)[0];
		oOrder.Type = 'Cart';
		oOrder.Remote_Validation_Status__c='Preparing Document';
		insert oOrder;

		OrderItem oit = TestDataGenerator.generateOrderItem(oOrder.Id, 1, false)[0];
		oit.Station__c = ard.id;
		oit.IEC_Is_Paid__c = true;
		insert oit;
		
		Product2 pr = [Select id, name from product2 limit 1];
		pr.name = 'Smart Facility Remote Validation';
		pr.Smart_Facility_Remote_Validation__c = true;
		pr.SAP_Material_Number__c = '12345';
		update pr;
	}   

	@IsTest
	public static void testBatch(){
		Test.startTest();
   
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		Id ardId = [SELECT Id FROM ICG_Account_Role_Detail__c Limit 1].Id;
		List<Order> currentOrder = [SELECT Id, (SELECT Id FROM Orderitems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order];
	   
		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate": "2020-05-20T11:07:43.013Z","SalesforceCaseNumber": "09991143","Files": [{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/TA UI Screens_9ea59f93-656f-48c7-a31b-b905013c2002.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Lufthansa SF16_291c5153-4adc-48a6-a348-b119b19a307e.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/1000770-09991143-50.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/2020-04-02_152038_e2a63e09-4c75-4efa-9935-c070412fe727.png"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Lufthansa SF16_74dfd987-5e05-4aa0-b7d6-68c96d129897.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/2020-04-02_152022_3b45dc1e-5b7f-4a75-a08b-3be359dbb867.jpg"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/2020-04-02_152022_729f11a2-99f1-40e2-9a8d-48218c21748e.jpg"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Lufthansa SF18_b5596511-ec07-48fb-91bc-5f94c285cba3.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/Cold Rooms 2 to 25_41.pdf"},{"File": "https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/8013N0000011AT6QAM/SF_Ecllipse14_1000770_1000770-09991143-50_IATA_Cargo_v13_General_Information22_05_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup.RecordTypeId = remoteValidationRtId;

		assigmentGroup.Order_Product__c = currentOrder[0].OrderItems[0].Id;
		insert assigmentGroup;
		
		List<ICG_Capability_Assignment_Group__c> cag = [SELECT Id, Order_Product__r.Station__c FROM ICG_Capability_Assignment_Group__c]; 
		List<Id> enterParameter = new List<Id>();

		
		for(ICG_Capability_Assignment_Group__c item : cag) {
			enterParameter.add(item.Id);
		}

		Test.setMock(HttpCalloutMock.class, new CW_GxA_MockHttpResponseGenerator());
		CW_GxA_Integration_Batch batchNotif = new CW_GxA_Integration_Batch(enterParameter);
		Id batchId = Database.executeBatch(batchNotif);

		List<ICG_Capability_Assignment_Group__c> listcag = [SELECT Id, Order_Product__r.Station__c, GxA_Error_Message__c, GxA_Error_StackTrace__c, GxA_Result_Json__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId = :remoteValidationRtId AND Id IN :enterParameter];
		System.assertEquals(listcag[0].GxA_Error_Message__c, '');

		Test.stopTest();

		System.abortJob(batchId);
	}

	@IsTest
	public static void testBatchNoStation(){
		Test.startTest();
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		Id ardId = [SELECT Id FROM ICG_Account_Role_Detail__c Limit 1].Id;
		List<Order> currentOrder = [SELECT Id, (SELECT Id FROM Orderitems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order];
	   
		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate":"2020-03-12T14:45:10.000Z","SalesforceCaseNumber":"00885000",' + '"Files":[{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture_10009914-00885000-25.JPG"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Facility Equipment and Infrastructure17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft 2_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft Word Document_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Temperature Control 17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture 1_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.xlsx"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Working Areas & Temporary Storage17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture3_10009914-00885000-25.JPEG"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/unnamed_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Veterinary, Phytosanitary and Pest Control17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New dc1_10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Electronic System Capacities17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Live Animals Capacities17_03_2020.json"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_General Information17_03_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup.RecordTypeId = remoteValidationRtId;
		insert assigmentGroup;

		List<ICG_Capability_Assignment_Group__c> cag = [SELECT Id FROM ICG_Capability_Assignment_Group__c]; 
		List<Id> enterParameter = new List<Id>();
		
		for(ICG_Capability_Assignment_Group__c item : cag) {
			enterParameter.add(item.Id);
		}

		Test.setMock(HttpCalloutMock.class, new CW_GxA_MockHttpResponseGenerator());
		CW_GxA_Integration_Batch batchNotif = new CW_GxA_Integration_Batch(enterParameter);
		Id batchId = Database.executeBatch(batchNotif);

		List<ICG_Capability_Assignment_Group__c> listcag = [SELECT Id, Order_Product__r.Station__c, GxA_Error_Message__c, GxA_Error_StackTrace__c, GxA_Result_Json__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId = :remoteValidationRtId AND Id IN :enterParameter];
		System.assertNotEquals(listcag[0].GxA_Error_Message__c, '');
		
		Test.stopTest();

		System.abortJob(batchId);
	}

	@IsTest
	public static void testErrorCallout(){
		Test.startTest();
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		Id ardId = [SELECT Id FROM ICG_Account_Role_Detail__c Limit 1].Id;
		List<Order> currentOrder = [SELECT Id, (SELECT Id FROM Orderitems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order];
	   
		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate":"2020-03-12T14:45:10.000Z","SalesforceCaseNumber":"00885000",' + '"Files":[{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture_10009914-00885000-25.JPG"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Facility Equipment and Infrastructure17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft 2_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft Word Document_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Temperature Control 17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture 1_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.xlsx"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Working Areas & Temporary Storage17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture3_10009914-00885000-25.JPEG"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/unnamed_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Veterinary, Phytosanitary and Pest Control17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New dc1_10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Electronic System Capacities17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Live Animals Capacities17_03_2020.json"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_General Information17_03_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup.RecordTypeId = remoteValidationRtId;
		assigmentGroup.Order_Product__c = currentOrder[0].OrderItems[0].Id;
		insert assigmentGroup;

		List<ICG_Capability_Assignment_Group__c> cag = [SELECT Id FROM ICG_Capability_Assignment_Group__c]; 
		List<Id> enterParameter = new List<Id>();
		
		for(ICG_Capability_Assignment_Group__c item : cag) {
			enterParameter.add(item.Id);
		}

		CW_GxA_Integration_Batch batchNotif = new CW_GxA_Integration_Batch(enterParameter);
		Id batchId = Database.executeBatch(batchNotif);

		List<ICG_Capability_Assignment_Group__c> listcag = [SELECT Id, Order_Product__r.Station__c, GxA_Error_Message__c, GxA_Error_StackTrace__c, GxA_Result_Json__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId = :remoteValidationRtId AND Id IN :enterParameter];
		System.assertNotEquals(listcag[0].GxA_Error_Message__c, '');
		
		Test.stopTest();

		System.abortJob(batchId);
	}

	@IsTest
	public static void testErrorStatusCallout(){
		Test.startTest();
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		Id ardId = [SELECT Id FROM ICG_Account_Role_Detail__c Limit 1].Id;
		List<Order> currentOrder = [SELECT Id, (SELECT Id FROM Orderitems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order];
	   
		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate":"2020-03-12T14:45:10.000Z","SalesforceCaseNumber":"00885000",' + '"Files":[{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture_10009914-00885000-25.JPG"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Facility Equipment and Infrastructure17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft 2_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft Word Document_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Temperature Control 17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture 1_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.xlsx"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Working Areas & Temporary Storage17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture3_10009914-00885000-25.JPEG"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/unnamed_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Veterinary, Phytosanitary and Pest Control17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New dc1_10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Electronic System Capacities17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Live Animals Capacities17_03_2020.json"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_General Information17_03_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup.RecordTypeId = remoteValidationRtId;
		assigmentGroup.Order_Product__c = currentOrder[0].OrderItems[0].Id;
		insert assigmentGroup;

		List<ICG_Capability_Assignment_Group__c> cag = [SELECT Id FROM ICG_Capability_Assignment_Group__c]; 
		List<Id> enterParameter = new List<Id>();
		
		for(ICG_Capability_Assignment_Group__c item : cag) {
			enterParameter.add(item.Id);
		}

		Test.setMock(HttpCalloutMock.class, new CW_GxA_MockHttpResponseGenerator(''));
		CW_GxA_Integration_Batch batchNotif = new CW_GxA_Integration_Batch(enterParameter);
		Id batchId = Database.executeBatch(batchNotif);

		List<ICG_Capability_Assignment_Group__c> listcag = [SELECT Id, Order_Product__r.Station__c, GxA_Error_Message__c, GxA_Error_StackTrace__c, GxA_Result_Json__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId = :remoteValidationRtId AND Id IN :enterParameter];
		System.assertNotEquals(listcag[0].GxA_Error_Message__c, '');

		Test.stopTest();

		System.abortJob(batchId);
	}
	
	public static void testMutipleItems(){
		Test.startTest();
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		
		Id ardId = [SELECT Id FROM ICG_Account_Role_Detail__c Limit 1].Id;
		List<Order> currentOrder = [SELECT Id, (SELECT Id FROM Orderitems WHERE Station__c != null AND Product2.Smart_Facility_Remote_Validation__c = true) FROM Order];
	   
		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate":"2020-03-12T14:45:10.000Z","SalesforceCaseNumber":"00885000",' + '"Files":[{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture_10009914-00885000-25.JPG"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Facility Equipment and Infrastructure17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft 2_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft Word Document_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Temperature Control 17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture 1_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.xlsx"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Working Areas & Temporary Storage17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture3_10009914-00885000-25.JPEG"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/unnamed_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Veterinary, Phytosanitary and Pest Control17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New dc1_10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Electronic System Capacities17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Live Animals Capacities17_03_2020.json"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_General Information17_03_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup.RecordTypeId = remoteValidationRtId;
		assigmentGroup.Order_Product__c = currentOrder[0].OrderItems[0].Id;
		insert assigmentGroup;
		
		ICG_Capability_Assignment_Group__c assigmentGroup2 = new ICG_Capability_Assignment_Group__c();
		assigmentGroup2.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup2.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup2.GxA_Result_Json__c = '{"SubmittedDate":"2020-03-12T14:45:10.000Z","SalesforceCaseNumber":"00885000",' + '"Files":[{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture_10009914-00885000-25.JPG"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Facility Equipment and Infrastructure17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft 2_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft Word Document_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Temperature Control 17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture 1_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.xlsx"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Working Areas & Temporary Storage17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture3_10009914-00885000-25.JPEG"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/unnamed_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Veterinary, Phytosanitary and Pest Control17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New dc1_10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Electronic System Capacities17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Live Animals Capacities17_03_2020.json"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_General Information17_03_2020.json"}]}';
		assigmentGroup2.ICG_Account_Role_Detail__c = ardId;
		assigmentGroup2.RecordTypeId = remoteValidationRtId;
		assigmentGroup2.Order_Product__c = currentOrder[0].OrderItems[0].Id;
		insert assigmentGroup2;

		List<ICG_Capability_Assignment_Group__c> cag = [SELECT Id FROM ICG_Capability_Assignment_Group__c]; 
		List<Id> enterParameter = new List<Id>();
		
		for(ICG_Capability_Assignment_Group__c item : cag) {
			enterParameter.add(item.Id);
		}

		Id batchId = null;
		String errorMessage = '';
		try {
			Test.setMock(HttpCalloutMock.class, new CW_GxA_MockHttpResponseGenerator());
			CW_GxA_Integration_Batch batchNotif = new CW_GxA_Integration_Batch(enterParameter);
			batchId = Database.executeBatch(batchNotif);
				
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}

		System.assertEquals('The batch size for CW_GxA_Integration_Batch_Exception must be 1', errorMessage, 'Error multiple items test');
		
		Test.stopTest();

		System.abortJob(batchId);
	}

	@IsTest
	public static void testBatchNull(){
		Test.startTest();
		
		CW_GxA_Integration_Batch batchNotif = new CW_GxA_Integration_Batch(null);
		Id batchId = Database.executeBatch(batchNotif);
		Test.stopTest();

		System.abortJob(batchId);
	}
   
	private static void handleTrace(String traceMsg) {
		if (TRACEIT) {
			system.debug(logginglevel.FINEST, traceMsg);
		}
	}
	private static List<RecordType> getRecTypes() {
		return RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account');
	}
}