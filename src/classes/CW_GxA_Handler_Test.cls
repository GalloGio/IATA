@isTest
/**
 * @description		Test class for CW_GxA_Handler
 *
 * Edit Log:
 * @history			2020/04/13  |  sf-536  |  Creation.
 */
public with sharing class CW_GxA_Handler_Test {
	private static final Boolean TRACEIT = true;
	private static final string PREFIX = 'CW_GxA_Handler:: ';
	/*
	Test Setup:
	*/
	@testSetup
	public static void makeData() {
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

		ICG_Capability_Assignment_Group__c assigmentGroup = new ICG_Capability_Assignment_Group__c();
		assigmentGroup.Expiration_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.Issue_Date__c = Date.valueOf('2021-03-12');
		assigmentGroup.GxA_Result_Json__c = '{"SubmittedDate":"2020-03-12T14:45:10.000Z","SalesforceCaseNumber":"00885000",' + '"Files":[{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture_10009914-00885000-25.JPG"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Facility Equipment and Infrastructure17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft 2_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New Microsoft Word Document_10009914-00885000-25.pdf"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Temperature Control 17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture 1_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/10009914-00885000-25.xlsx"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Working Areas & Temporary Storage17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/Capture3_10009914-00885000-25.JPEG"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/unnamed_10009914-00885000-25.png"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Veterinary, Phytosanitary and Pest Control17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/New dc1_10009914-00885000-25.pdf"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Electronic System Capacities17_03_2020.json"},' + '{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_Live Animals Capacities17_03_2020.json"},{"File":"https://s3.amazonaws.com/pwc-dev-0f0a94bcb834b69f/10009914-00885000/SF Cor_10009914-00885000-25_IATA Cargo_v13_General Information17_03_2020.json"}]}';
		assigmentGroup.ICG_Account_Role_Detail__c = ard.Id;
		insert assigmentGroup;

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

	/**
	 * @description		Check URL input.
	 *
	 */
	@isTest
	public static void TEMP_convertUrlToS3ObjectKey_test() {
		Test.startTest();

		String res = CW_AmazonS3Connector.convertUrlResourceToS3ObjectKey('https://pwc-dev-0f0a94bcb834b69f.s3.eu-west-1.amazonaws.com/SmartFacilityRemoteValidations/10009914-00088811/Cargo_v13_Working_Areas_and_Temporary_Storage_13_04_2020.json', 'pwc-dev-0f0a94bcb834b69f');
		System.assertNotEquals(null, res);

		Test.stopTest();
	}
	
	@isTest
	public static void convertAnswersJsonToDataTest() {
		Test.startTest();
		
		String RT_NEW_VERSION = 'V4_19.05';

		List<ICG_GxA_Integration_Mapping__c> listImap = new List<ICG_GxA_Integration_Mapping__c>();
		ICG_GxA_Integration_Mapping__c imap = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap.GxA_Options__c = 'Yes,No';
		imap.GxA_Question_Id__c = '1';
		imap.GxA_Question_Parent_Id__c = '1';
		imap.GxA_Question_Text__c = 'Availability';
		imap.GxA_Question_Type_Id__c = '13';
		imap.GxA_Sub_Survey_Id__c = '';
		imap.GxA_Validation__c = '';
		imap.SF_Data_Extra__c = '';
		imap.SF_Equipment__c = 'Track_And_Trace_Module';
		imap.SF_Options_Mapping__c = '';
		imap.SF_Process_Question__c = 'yes';
		imap.SF_Specific_Processing__c = '';
		imap.SF_Target_Field__c = 'Is_Planned_To_Implement__c';
		imap.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap);

		ICG_GxA_Integration_Mapping__c imap1 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap1.GxA_Options__c = 'Yes,No';
		imap1.GxA_Question_Id__c = '2';
		imap1.GxA_Question_Parent_Id__c = '1';
		imap1.GxA_Question_Text__c = 'Availability';
		imap1.GxA_Question_Type_Id__c = '13';
		imap1.GxA_Sub_Survey_Id__c = '';
		imap1.GxA_Validation__c = '';
		imap1.SF_Data_Extra__c = '';
		imap1.SF_Equipment__c = 'Track_And_Trace_Module';
		imap1.SF_Options_Mapping__c = '';
		imap1.SF_Process_Question__c = 'yes';
		imap1.SF_Specific_Processing__c = '';
		imap1.SF_Target_Field__c = 'Airport_Authorization_Copy_1__c';
		imap1.SF_Target_Object__c = 'ICG_Account_Role_Detail__c';
		listImap.add(imap1);

		ICG_GxA_Integration_Mapping__c imap2 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap2.GxA_Options__c = 'Yes,No';
		imap2.GxA_Question_Id__c = '3';
		imap2.GxA_Question_Parent_Id__c = '1';
		imap2.GxA_Question_Text__c = 'Availability';
		imap2.GxA_Question_Type_Id__c = '13';
		imap2.GxA_Sub_Survey_Id__c = '';
		imap2.GxA_Validation__c = '';
		imap2.SF_Data_Extra__c = '';
		imap2.SF_Equipment__c = 'Track_And_Trace_Module';
		imap2.SF_Options_Mapping__c = '';
		imap2.SF_Process_Question__c = 'yes';
		imap2.SF_Specific_Processing__c = 'Fileupload';
		imap2.SF_Target_Field__c = 'Airport_Authorization_Copy_1__c';
		imap2.SF_Target_Object__c = 'ICG_Account_Role_Detail__c';
		listImap.add(imap2);

		ICG_GxA_Integration_Mapping__c imap3 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap3.GxA_Options__c = 'Yes,No';
		imap3.GxA_Question_Id__c = '3';
		imap3.GxA_Question_Parent_Id__c = '1';
		imap3.GxA_Question_Text__c = 'Availability';
		imap3.GxA_Question_Type_Id__c = '13';
		imap3.GxA_Sub_Survey_Id__c = '';
		imap3.GxA_Validation__c = '';
		imap3.SF_Data_Extra__c = '';
		imap3.SF_Equipment__c = 'Track_And_Trace_Module';
		imap3.SF_Options_Mapping__c = '';
		imap3.SF_Process_Question__c = 'yes';
		imap3.SF_Specific_Processing__c = 'Fileupload';
		imap3.SF_Target_Field__c = '';
		imap3.SF_Target_Object__c = 'ICG_Account_Role_Detail__c';
		listImap.add(imap3);

		ICG_GxA_Integration_Mapping__c imap4 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap4.GxA_Options__c = 'Yes (Entire room),Yes (Segregated area within room),No';
		imap4.GxA_Question_Id__c = '4';
		imap4.GxA_Question_Parent_Id__c = '1';
		imap4.GxA_Question_Text__c = 'Pharma Dedicated';
		imap4.GxA_Question_Type_Id__c = '10';
		imap4.GxA_Sub_Survey_Id__c = '';
		imap4.GxA_Validation__c = '';
		imap4.SF_Data_Extra__c = '';
		imap4.SF_Equipment__c = '2_To_8_C';
		imap4.SF_Options_Mapping__c = 'Entire_Room,Segregated_Area_Whithin_Room,No';
		imap4.SF_Process_Question__c = 'yes';
		imap4.SF_Specific_Processing__c = 'Options.Mapping';
		imap4.SF_Target_Field__c = 'CRSTR_Pharma_Dedicated__c';
		imap4.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap4);

		ICG_GxA_Integration_Mapping__c imap5 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap5.GxA_Options__c = '';
		imap5.GxA_Question_Id__c = '5';
		imap5.GxA_Question_Parent_Id__c = '1';
		imap5.GxA_Question_Text__c = 'from C';
		imap5.GxA_Question_Type_Id__c = '2';
		imap5.GxA_Sub_Survey_Id__c = '';
		imap5.GxA_Validation__c = 'number';
		imap5.SF_Data_Extra__c = '';
		imap5.SF_Equipment__c = 'Other_Temperature_Control_Equipment';
		imap5.SF_Options_Mapping__c = '';
		imap5.SF_Process_Question__c = 'yes';
		imap5.SF_Specific_Processing__c = 'Temperature.Range.From';
		imap5.SF_Target_Field__c = 'TCHA_Alarm_Range__c';
		imap5.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap5);

		ICG_GxA_Integration_Mapping__c imap6 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap6.GxA_Options__c = 'AKE,10ft ULD,20ft ULD';
		imap6.GxA_Question_Id__c = '6';
		imap6.GxA_Question_Parent_Id__c = '1';
		imap6.GxA_Question_Text__c = 'ULD Compatibility';
		imap6.GxA_Question_Type_Id__c = '21';
		imap6.GxA_Sub_Survey_Id__c = '';
		imap6.GxA_Validation__c = '';
		imap6.SF_Data_Extra__c = '';
		imap6.SF_Equipment__c = 'Dollies_Tub_Carts';
		imap6.SF_Options_Mapping__c = '';
		imap6.SF_Process_Question__c = 'yes';
		imap6.SF_Specific_Processing__c = 'UldCompatibility';
		imap6.SF_Target_Field__c = 'GSE_ULD_Compatibility_Type_AKE__c;GSE_ULD_Compatibility_Type_F10__c;GSE_ULD_Compatibility_Type_F20__c';
		imap6.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap6);

		ICG_GxA_Integration_Mapping__c imap7 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap7.GxA_Options__c = '';
		imap7.GxA_Question_Id__c = '7';
		imap7.GxA_Question_Parent_Id__c = '1';
		imap7.GxA_Question_Text__c = 'Pictures allowing for appropriate identification and validation of claimed equipment/infrastructure';
		imap7.GxA_Question_Type_Id__c = '14';
		imap7.GxA_Sub_Survey_Id__c = '';
		imap7.GxA_Validation__c = '';
		imap7.SF_Data_Extra__c = '';
		imap7.SF_Equipment__c = 'Electronic_Metal_Detection_Device_EDM';
		imap7.SF_Options_Mapping__c = '';
		imap7.SF_Process_Question__c = 'yes';
		imap7.SF_Specific_Processing__c = 'Fileupload';
		imap7.SF_Target_Field__c = 'Photos_Private__c';
		imap7.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap7);

		ICG_GxA_Integration_Mapping__c imap8 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap8.GxA_Options__c = '';
		imap8.GxA_Question_Id__c = '8';
		imap8.GxA_Question_Parent_Id__c = '1';
		imap8.GxA_Question_Text__c = 'Pictures allowing for appropriate identification and validation of claimed equipment/infrastructure';
		imap8.GxA_Question_Type_Id__c = '14';
		imap8.GxA_Sub_Survey_Id__c = '9';
		imap8.GxA_Validation__c = '';
		imap8.SF_Data_Extra__c = 'Pictures of equipment/infrastructure';
		imap8.SF_Equipment__c = 'Weight_Scales';
		imap8.SF_Options_Mapping__c = '';
		imap8.SF_Process_Question__c = 'yes';
		imap8.SF_Specific_Processing__c = 'Fileupload.Json.Url';
		imap8.SF_Target_Field__c = 'Photos__c';
		imap8.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap8);

		ICG_GxA_Integration_Mapping__c imap9 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap9.GxA_Options__c = '';
		imap9.GxA_Question_Id__c = '9';
		imap9.GxA_Question_Parent_Id__c = '1';
		imap9.GxA_Question_Text__c = 'Pictures allowing for appropriate identification and validation of claimed equipment/infrastructure';
		imap9.GxA_Question_Type_Id__c = '14';
		imap9.GxA_Sub_Survey_Id__c = '';
		imap9.GxA_Validation__c = '';
		imap9.SF_Data_Extra__c = 'Pictures of equipment/infrastructure';
		imap9.SF_Equipment__c = 'Weight_Scales';
		imap9.SF_Options_Mapping__c = '';
		imap9.SF_Process_Question__c = 'yes';
		imap9.SF_Specific_Processing__c = 'Fileupload.Json.Url';
		imap9.SF_Target_Field__c = 'Photos__c';
		imap9.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap9);

		ICG_GxA_Integration_Mapping__c imap10 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap10.GxA_Options__c = '';
		imap10.GxA_Question_Id__c = '10';
		imap10.GxA_Question_Parent_Id__c = '1';
		imap10.GxA_Question_Text__c = 'to C';
		imap10.GxA_Question_Type_Id__c = '2';
		imap10.GxA_Sub_Survey_Id__c = '';
		imap10.GxA_Validation__c = 'number';
		imap10.SF_Data_Extra__c = '';
		imap10.SF_Equipment__c = '2_To_8_C';
		imap10.SF_Options_Mapping__c = '';
		imap10.SF_Process_Question__c = 'yes';
		imap10.SF_Specific_Processing__c = 'Temperature.Range.To';
		imap10.SF_Target_Field__c = 'TCHA_Alarm_Range__c';
		imap10.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap10);

		ICG_GxA_Integration_Mapping__c imap11 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap11.GxA_Options__c = '';
		imap11.GxA_Question_Id__c = '11';
		imap11.GxA_Question_Parent_Id__c = '1';
		imap11.GxA_Question_Text__c = 'to C';
		imap11.GxA_Question_Type_Id__c = '2';
		imap11.GxA_Sub_Survey_Id__c = '';
		imap11.GxA_Validation__c = 'number';
		imap11.SF_Data_Extra__c = '';
		imap11.SF_Equipment__c = '2_To_8_C';
		imap11.SF_Options_Mapping__c = '';
		imap11.SF_Process_Question__c = 'yes';
		imap11.SF_Specific_Processing__c = 'Fileupload.Json.Visible';
		imap11.SF_Target_Field__c = 'TCHA_Alarm_Range__c';
		imap11.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap11);

		ICG_GxA_Integration_Mapping__c imap12 = new ICG_GxA_Integration_Mapping__c(Version__c= RT_NEW_VERSION,GxA_Group__c='Question',GxA_Is_Mandatory__c = true);
		imap12.GxA_Options__c = '';
		imap12.GxA_Question_Id__c = '12';
		imap12.GxA_Question_Parent_Id__c = '111';
		imap12.GxA_Question_Text__c = 'to C';
		imap12.GxA_Question_Type_Id__c = '2';
		imap12.GxA_Sub_Survey_Id__c = '';
		imap12.GxA_Validation__c = 'number';
		imap12.SF_Data_Extra__c = '';
		imap12.SF_Equipment__c = '2_To_8_C';
		imap12.SF_Options_Mapping__c = '';
		imap12.SF_Process_Question__c = 'yes';
		imap12.SF_Specific_Processing__c = 'Fileupload.Json.Visible';
		imap12.SF_Target_Field__c = 'TCHA_Alarm_Range__c';
		imap12.SF_Target_Object__c = 'Account_Role_Detail_Capability__c';
		listImap.add(imap12);

		insert listImap;

		List<String> anwsersJsonContent = new List<String>();
		String bodyMock = '{"ClientName": "SF Ecllipse14_1000770","SurveyId": "11","SurveySessionId": "2076","SurveyName": "IATA Cargo_v13_Electronic System Capacities","SurveyAnswers": [';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "1","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "2","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "3","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "4","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "5","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "6","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "7","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "8","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "9","Question": "Availability","Response": "180,181","SubSurvey": [{"QuestionTypeId": "2","QuestionID": "6321","Question": "Name","SubSurveySessionId": "180","Response": "34"},{"QuestionTypeId": "13","QuestionID": "6323","Question": "System self- or carrier owned?","SubSurveySessionId": "181","Response": "Carrier owned"}]},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "10","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "11","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "12","Question": "Availability","Response": "No","SubSurvey": []},';
		bodyMock += '{"QuestionTypeId": "13","QuestionID": "100","Question": "Availability","Response": "No","SubSurvey": []}';
		bodyMock += ']}';
		anwsersJsonContent.add(bodyMock);

		Map<String, Object> res = CW_GxA_Handler.convertAnswersJsonToData(anwsersJsonContent);
		System.assertNotEquals(0, res.size());
		Test.stopTest();
	}
	
	@isTest
	public static void getOrdersIdWithLastIntegrationFailedTest() {
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
		assigmentGroup.GxA_Integration_Status__c = 'Failed';
		insert assigmentGroup;

		List<String> anwsersJsonContent = new List<String>();
		String bodyMock = '{"ClientName": "SF Ecllipse14_1000770","SurveyId": "11","SurveySessionId": "2076","SurveyName": "IATA Cargo_v13_Electronic System Capacities","SurveyAnswers": [{"QuestionTypeId": "13","QuestionID": "5878","Question": "Availability","Response": "No","SubSurvey": []}]}';
		anwsersJsonContent.add(bodyMock);

		List<Id> res = CW_GxA_Handler.getOrdersIdWithLastIntegrationFailed(null, null);
		System.assertNotEquals(0, res.size());
		
		Test.stopTest();
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