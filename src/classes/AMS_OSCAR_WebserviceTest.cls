@isTest
public class AMS_OSCAR_WebserviceTest {

	private static AMS_OSCAR__c oscar;
	private static AMS_OSCAR__c oscar2;
	private static AMS_OSCAR__c oscar3;
	private static AMS_OSCAR__c oscar4;
	private static AMS_OSCAR__c oscar5;
	private static AMS_OSCAR__c oscar6;
	private static Account a1;
	private static Account a2;
	private static Account a3;
	private static Account a4;
	private static Account a5;
	private static Case oscarCase;
	
	private static void setup(){
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'US', ISO_Code__c = 'US');
		insert ctry;
		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c(Name = 'Portugal', ISO_Code__c = 'PT', AIMS_Area_ID__c = '1');
		insert ctry2;

		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
		insert account;
		
		oscar = new AMS_OSCAR__c(Account__c=account.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
		insert oscar;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		a1 = new Account(RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		a1.BillingCountry = 'Portugal';
		a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Name='Test1 Agency',Short_Name__c='Test1 Agency',BillingCountry='Brazil');
		a2.BillingCountry = 'Portugal';
		a2.Type = 'IATA Passenger Sales Agent';
		a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Location_Type__c='HO',Name='Test1 Agency',Short_Name__c='Test1 Agency',Type='IATA Cargo Agent',BillingCountry='Brazil');
		a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = agencyRT, Name = 'Test Account', BillingCountry = 'Portugal', Type = 'IATA Passenger Sales Agent', IATACode__c = '1234563');
		a5 = new Account(IATA_ISO_Country__c = ctry2.id, RecordTypeId = agencyRT, Name = 'Test Account', BillingCountry = 'Portugal', Type = 'IATA Passenger Sales Agent', IATACode__c = '1234564', BillingCity = 'Lisboa');


		insert new List<Account>{a1, a2, a3, a4, a5};

		oscar2 = new AMS_OSCAR__c(Account__c = a1.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
		oscar3 = new AMS_OSCAR__c(Account__c = a2.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
		oscar4 = new AMS_OSCAR__c(Account__c = a3.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
		oscar5 = new AMS_OSCAR__c(Account__c = a4.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
		oscar6 = new AMS_OSCAR__c(Account__c = a5.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');

		insert new List<AMS_OSCAR__c>{oscar2, oscar3, oscar4, oscar5, oscar6};

		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		insert aacc;

		Contact co1 = new Contact(AccountId = a4.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
		Contact co2 = new Contact(AccountId = a5.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
		insert new List<Contact>{co1, co2};

		oscarCase = new Case(Oscar__c = oscar6.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
		oscarCase.AccountId = a5.Id;
		oscarCase.ContactId = co2.Id;
		oscarCase.reason1__c = 'Accreditation Type';
		insert oscarCase;
		update new AMS_OSCAR__c(Id = oscar6.Id, Oscar_Communication_Case_Id__c = oscarCase.Id);
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
									+ 'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
		TestDataFactory_AWSKeys.createAllEntries();
	}


	static testMethod void test_updateFormFields() {

		setup();

		List<String> fieldApiName = new List<String>{'Status__c', 'Billing_Document_Number__c', 'Invoice_number__c', 'Bank_Guarantee_amount__c', 'Send_agreement__c'};
		List<String> fieldValue = new List<String>{'Open', '12345', '', '50,2', 'true'};

		Test.startTest();

		String resultFormFields = AMS_OSCAR_Webservice.updateFormFields(fieldApiName, fieldValue, oscar.Id);

		Test.stopTest();
	}

	static testMethod void test_createIFAP() {

		setup();

		Test.startTest();

		String resultIFAPFromOSCAR = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar.Id);
		String resultIFAPFromOSCAR2 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar2.Id);
		String resultIFAPFromOSCAR3 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar3.Id);
		String resultIFAPFromOSCAR4 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar4.Id);
		String resultIFAPFromOSCAR5 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar5.Id);
		String resultIFAPFromOSCAR6 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar6.Id);

		System.assert(resultIFAPFromOSCAR6 != null && ! resultIFAPFromOSCAR6.contains('ERROR'));

		Test.stopTest();
	}

	static testMethod void test_createAML() {

		setup();

		Test.startTest();

		String resultcreateAMLCase = AMS_OSCAR_Webservice.createAMLCase(oscar.Id);
		String resultcreateAMLCase4 = AMS_OSCAR_Webservice.createAMLCase(oscar6.Id);
		String resultcreateAMLCasenoUpdate = AMS_OSCAR_Webservice.createAMLCaseWithNoOscarUpdate([select Name, STEP17__c, Account__c, Account__r.Name, Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__r.Name from AMS_OSCAR__c where Id =: oscar6.Id]);
		String reason = AMS_Oscar_Webservice.fetchAMLCaseReason(AMS_Utils.AGENCYCHANGES);
		reason = AMS_Oscar_Webservice.fetchAMLCaseReason(AMS_Utils.IEPBANKACCOUNTSETUP);
		Test.stopTest();
	}

	static testMethod void test_copyDataToAccount() {

		setup();

		Test.startTest();

		String resultcopyDataToAccount = AMS_OSCAR_Webservice.copyDataToAccount(oscar.Id);

		Test.stopTest();
	}

	static testMethod void test_createNEWChangeCode() {

		setup();

		Test.startTest();

		insert new AMS_ChangeCodes__c(Name = 'NEW-AMS', Change_Code__c = 'UGR', Integration_RecId__c = 'C');

		String resultcreateChangeCodeNEW = AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);
		System.assertEquals('OK', resultcreateChangeCodeNEW);

		Test.stopTest();
	}

	static testMethod void test_createSidraLite1() {

		setup();

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar.Id, '6', true);
		AMS_OSCAR_Webservice.updateSIDRALite(oscar.Id, '6');
		Test.stopTest();
	}

	static testMethod void test_createSidraLite2() {

		setup();

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '1', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '6', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '9', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '11', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '12', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '13', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '14', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '26', true);
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, 'RPM', true);
		AMS_OSCAR_Webservice.updateSIDRALite(oscar6.Id, '6');
		Test.stopTest();
	}

	static testMethod void test_createSidraLite3() {

		setup();
		oscar6.Step6__c='Failed';
		//oscar6.Reason_for_unsuccessful_application__c = 'Incomplete Documentation';
		update oscar6;

		oscarCase.Reason1__c = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS1).get(0);
		update oscarCase;

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '6', true);
		AMS_OSCAR_Webservice.updateSIDRALite(oscar6.Id, '6');
		Test.stopTest();
	}

	static testMethod void test_createSidraLite4() {

		setup();
		oscar6.STEP12__c = 'Passed';
		oscar6.Validation_Status__c = 'Passed';
		oscar6.RPM_Approval__c='Authorize Disapproval';
		oscar6.Bank_Guarantee_Requested__c = Date.today();
		update oscar6;

		oscarCase.Reason1__c = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS1).get(0);
		update oscarCase;

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, 'RPM', true);
		AMS_OSCAR_Webservice.updateSIDRALite(oscar6.Id, 'RPM');
		Test.stopTest();
	}

	static testMethod void test_createSidraLite5() {

		setup();

		oscarCase.Reason1__c = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS1).get(0);
		update oscarCase;

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, 'DGR', true);
		oscar6.Step6__c='Failed';
		//oscar6.Reason_for_unsuccessful_application__c = 'Incomplete Documentation';
		update oscar6;
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, 'DGR', true);
		AMS_OSCAR_Webservice.updateSIDRALite(oscar6.Id, 'DGR');
		Test.stopTest();
	}

	static testMethod void test_createSidraLite6() {

		setup();
		oscar6.Step6__c='Failed';
		//oscar6.Reason_for_unsuccessful_application__c = 'Incomplete Documentation';
		update oscar6;

		oscarCase.Reason1__c = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS2).get(0);
		update oscarCase;

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '6', true);
		try {
			oscarCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
			update oscarCase;
			AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '6', true);
			System.assert(false, 'Exception expected');
		} catch (WSSidraLite.ShowConfirmationException e) {
			System.assert(true);
		}
		AMS_OSCAR_Webservice.updateSIDRALite(oscar6.Id, '6');
		Test.stopTest();
	}

	static testMethod void test_createSidraLite7() {

		setup();
		oscar6.Step44__c='Passed';
		//oscar6.Reason_for_unsuccessful_application__c = 'Incomplete Documentation';
		update oscar6;

		Test.startTest();
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '44', true);
		oscar6.Process__c = AMS_Utils.NGANNUALREVAL;
		oscar6.Step44__c='Failed';
		update oscar6;
		AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id, '44', true);
		Test.stopTest();
	}

	static testMethod void test_createCommissionerCase() {

		setup();

		Test.startTest();

		String resultcreateCommissionerCaseERROR = AMS_OSCAR_Webservice.createCommissionerCase(oscar.Id);
		String resultcreateCommissionerCaseSUCCESS = AMS_OSCAR_Webservice.createCommissionerCase(oscar6.Id);

		Test.stopTest();
	}

	static testMethod void test_createFSRelease() {

		setup();

		Test.startTest();

		String resultFSReleaseERROR = AMS_OSCAR_Webservice.createFSReleaseCase(oscar.Id);
		System.assert(resultFSReleaseERROR.contains('Could not find a the Oscar Communication case related to this OSCAR.'));

		String resultFSReleaseSUCCESS = AMS_OSCAR_Webservice.createFSReleaseCase(oscar6.Id);
		System.assert(Id.valueOf(resultFSReleaseSUCCESS).getSObjectType() == Case.SObjectType, 'FS Release: did not create case');

		Test.stopTest();
	}

	static testMethod void test_generateCertificates() {

		setup();

		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c(Account__c = oscar.Account__c, Change_Code__c = 'TST', Sent_to_external_system__c = false, Active__c = true);
		insert cc;

		Test.startTest();

		String resultgenerateCertificates = AMS_OSCAR_Webservice.generateCertificates(oscar6.Id, oscar.Account__c);
		System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCAR_WebserviceTest - test_generateCertificates] resultgenerateCertificates - ' + resultgenerateCertificates);

		System.assert(resultgenerateCertificates != null && ! resultgenerateCertificates.contains('ERROR'));

		Test.stopTest();
	}

	static testMethod void test_riskEventCreation() {

		setup();

		Test.startTest();

		String resultcreateSIDRALiteERROR = AMS_OSCAR_Webservice.createRiskEvent(oscar.Id);

		Test.stopTest();

		oscar = [SELECT Risk_event_creation_date__c, STEP36__c FROM AMS_OSCAR__c WHERE Id =: oscar.Id];

		system.assertEquals(oscar.Risk_event_creation_date__c, System.today());
		system.assertEquals(oscar.STEP36__c, AMS_Utils.PASSED);
	}

	static testMethod void test_createIfapPortalServiceRight() {

		setup();

		Portal_Applications__c easyPay1 = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		easyPay1.Name = 'Test';
		easyPay1.Functional_Role__c = 'IATA EasyPay (EDENRED)';
		easyPay1.Application_URL__c = '/ISSP_IFAPCases';
		insert easyPay1;
		
		Test.startTest();
		String result_createIfapPortalServiceRight = AMS_OSCAR_Webservice.createIfapPortalServiceRight(oscar5.Id);
		System.assertEquals('OK', result_createIfapPortalServiceRight);
		Test.stopTest();
	}

	@isTest
	public static void test_mcToStSplitBatchCreation() {

		setup();
		
		Test.startTest();
		String result = AMS_OSCAR_Webservice.executeMcToStSplitBatch(oscar6.Id);
		Test.stopTest();

		System.assertEquals('', result);
	}

}