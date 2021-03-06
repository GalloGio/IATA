@isTest
public class IfapProcessTest {

	public static String CRON_EXP = '0 0 0 12 1 ? 2030';

	static testMethod void testSchedule(){

		Test.startTest();
		String jobId = System.schedule('IfapProcessScheduler_Test', CRON_EXP, new IfapProcessScheduler());
		Test.stopTest();

	}

	static testMethod void testExtraSchedule(){

		Test.startTest();
		IfapProcessScheduler.launchExtraSchedule();
		Test.stopTest();

	}

	static testMethod void testScheduleWithExtraExecution(){

		IfapProcessScheduler scheduleProcess = new IfapProcessScheduler();
		scheduleProcess.isExtraExecution = true;

		Test.startTest();
		String jobId = System.schedule('IfapProcessScheduler_Test', CRON_EXP, scheduleProcess);
		Test.stopTest();

	}

	static testMethod void testSendErrorMail() {

		List<String> listErrors = new list<String>();
		listErrors.add('error1');

		Test.startTest();
		IfapProcessScheduler.sendErrorEmail('title', null);
		IfapProcessScheduler.sendErrorEmail('title', listErrors);
		Test.stopTest();
	}

	public class TestException extends Exception {}

	static testMethod void testQueueableFailure(){

		TestException e = new TestException();
		IfapToolManager.PWCResponses response = new IfapToolManager.PWCResponses(e);

		Test.startTest();
		IfapProcessResultsQueueable resultQ = new IfapProcessResultsQueueable();
		resultQ.pwcress = response;
		String jobId1 = System.enqueueJob(resultQ);

		IfapProcessRejectionsQueueable rejectionQ = new IfapProcessRejectionsQueueable();
		rejectionQ.pwcress = response;
		String jobId2 = System.enqueueJob(rejectionQ);
		Test.stopTest();

	}

	static testMethod void testQueueableSuccess(){

		TestException e = new TestException();
		IfapToolManager.PWCResponses response = new IfapToolManager.PWCResponses(e);
		response.success = true;

		Test.startTest();
		IfapProcessResultsQueueable resultQ = new IfapProcessResultsQueueable();
		resultQ.pwcress = response;
		String jobId1 = System.enqueueJob(resultQ);

		IfapProcessRejectionsQueueable rejectionQ = new IfapProcessRejectionsQueueable();
		rejectionQ.pwcress = response;
		String jobId2 = System.enqueueJob(rejectionQ);
		Test.stopTest();

	}

	private static final Integer NUM_TEST_CASES = IfapProcessRejectionsQueueable.ELEMENTS_PER_BATCH;

	public static void loadTestCases( ) {
		loadTestCases('Financial Security Requested', true);
	}
	public static void loadTestCases( String status, Boolean insertQualityIssues) {
		insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c = 'AA',AIMS_Area_Name__c = 'AA', AIMS_Area_ID__c = 'A');
		insert country;
		Account account = new Account(
			Name = 'TestAccount',
			Type = 'IATA Passenger Sales Agent',
			IATACode__c = '1234567',
			BillingCountry = country.AIMS_Area_Name__c,
			Location_Type__c = 'HO');
		insert account;

		Contact contact = new Contact(FirstName = 'firstname',
			LastName = 'lastName',
			Financial_Assessment_Contact__c = true,
			accountId = account.Id
		);
		insert contact;

		ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
		list<Case> listCases = new list<Case>();
		for ( Integer i = 0; i < NUM_TEST_CASES; i++) {
			listCases.add(new Case(
				Subject = 'Test case ' + i,
				Status = status,
				RecordTypeId = IFAPcaseRecordTypeID,
				IFAP_Financial_Year__c = String.ValueOf(Date.today().year()),
				ArchivedDate__c = Date.today(),
				AccountId = account.Id,
				contactId = contact.Id
			));
		}
		insert listCases;

		if (insertQualityIssues) {
			list<IFAP_Quality_Issue__c> listQualityIssues = new list<IFAP_Quality_Issue__c>();
			for (Case c: listCases ) {
				listQualityIssues.add(
					new IFAP_Quality_Issue__c(
						Related_Case__c = c.id,
						Status__c = 'Sent to GFA',
						Assessment_using_wrong_template__c =true,
						Wrong_figure_was_extracted__c =true,
						Other_Issue_details__c = 'test details',
						The_printout_of_the_result_is_unreadable__c = true,
						Formatting_Issue_details__c = 'test details')
				);
			}
			insert listQualityIssues;
		}

		AWSKey__c key = new AWSKey__c(Name='preprod', IAS_configuration_name__c = 'aaa', IAS_Configation_name__c = 'nomaserio?');
		insert key;
	}

	static testMethod void testResultsBatch_Success() {

		loadTestCases();

		// prepare json String
		list<String> listJson = new list<String>();
		Integer errorCode = 0;
		String caseNumber;
		for ( Case c: [Select CaseNumber from Case] ) {
			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus><Error><ErrorCode>' + errorCode + '</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
				'"success":true'+
				'}';
			listJson.add(jsonCase);
			errorCode++;
			caseNumber = c.CaseNumber;
		}

		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(listJson,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"'+caseNumber+'","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+caseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';


		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();
		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		List<Financial_Assessment_Result__c> fars = [SELECT Id FROM Financial_Assessment_Result__c];
		//system.assertEquals(NUM_TEST_CASES,fars.size());
	}

	static testMethod void testResultsBatchSubmitted_Success() {

		loadTestCases('Submitted',false);
		//prepare json String
		list<String> listJson = new list<String>();
		String caseNumber;
		for ( Case c: [Select CaseNumber from Case] ) {
			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
				'"success":true'+
				'}';
			listJson.add(jsonCase);
			caseNumber = c.CaseNumber;
		}
		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(listJson,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"'+caseNumber+'","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+caseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();
		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		List<Financial_Assessment_Result__c> fars = [SELECT Id FROM Financial_Assessment_Result__c];
		//system.assertEquals(NUM_TEST_CASES,fars.size());
	}

	static testMethod void testResultsBatch_Failure() {

		loadTestCases();

		// prepare json String
		list<String> listJson = new list<String>();
		String caseNumber;
		for ( Case c: [Select CaseNumber from Case] ) {
			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
				'"success":false'+
				'}';
			listJson.add(jsonCase);
			caseNumber = c.CaseNumber;
		}

		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(listJson,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"'+caseNumber+'","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+caseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();
		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		List<Financial_Assessment_Result__c> fars = [SELECT Id FROM Financial_Assessment_Result__c];
		//system.assertEquals(NUM_TEST_CASES,fars.size());
	}

	static testMethod void testRejectionsBatch_Success() {

		loadTestCases();

		// prepare json String
		list<String> listJson = new list<String>();
		list<Case> listCase = [Select CaseNumber from Case];
		System.AssertEquals(listCase.size(),NUM_TEST_CASES);
		for ( Case c: listCase ) {
			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\"1.0\\" ?><ReassessmentRequest xmlns:xsi=\\"http://www.w3.org/2001/XMLSchema-instance\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><ReassessmentRejectionReason>Rejected.PwC has never received the BE-P-0821019#3, but only the BE-P-0821019#1 </ReassessmentRejectionReason></ReassessmentRequest>",'+
				'"success":true'+
				'}';
			listJson.add(jsonCase);
		}

		IfapToolManager.testJsonRejections = '{ "responses": [' + String.join(listJson,',')+ ']}';
		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCRejections();
		System.AssertEquals(response.success, true);
		IfapProcessRejectionsBatch batch = new IfapProcessRejectionsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		List<Financial_Assessment_Result__c> fars = [SELECT Id FROM Financial_Assessment_Result__c];
		//system.assertEquals(NUM_TEST_CASES,fars.size());
	}

	static testMethod void testRejectionsBatch_Failure() {

		loadTestCases();

		// prepare json String
		list<String> listJson = new list<String>();
		for ( Case c: [Select CaseNumber from Case] ) {
			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\"1.0\\" ?><ReassessmentRequest xmlns:xsi=\\"http://www.w3.org/2001/XMLSchema-instance\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><ReassessmentRejectionReason>Rejected.PwC has never received the BE-P-0821019#3, but only the BE-P-0821019#1 </ReassessmentRejectionReason></ReassessmentRequest>",'+
				'"success":false'+
				'}';
			listJson.add(jsonCase);
		}

		IfapToolManager.testJsonRejections = '{ "responses": [' + String.join(listJson,',')+ ']}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCRejections();
		IfapProcessRejectionsBatch batch = new IfapProcessRejectionsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		List<Financial_Assessment_Result__c> fars = [SELECT Id FROM Financial_Assessment_Result__c];
		//system.assertEquals(NUM_TEST_CASES,fars.size());
	}
	static testMethod void testResultsBatchFinancialAssessmentResult() {

		loadTestCases();

		AMS_Settlement_System__c sett_sys = new AMS_Settlement_System__c(name = 'BSP-HK', DPC_System__c = 'test_dpc');
		insert sett_sys;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c = 'HK',AIMS_Area_Name__c = 'HK', BSP_Country_free_text__c = 'HK', ANG_Enable_NewGen__c = true,AMS_Settlement_System__c = sett_sys.Id);
		insert country;

		Id caseId;
		String caseNumber;

		// prepare json String
		list<String> listJson = new list<String>();
		for ( Case c: [Select CaseNumber, AccountId from Case LIMIT 1] ) {

			caseId = c.Id;
			caseNumber = c.CaseNumber;

			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>100</FinancialCriteriaTotalScore> <Status>SUBMITTED-ASSESSMENT INPROGRESS</Status> <Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
				'"success":true'+
				'}';
			listJson.add(jsonCase);

			Account a = new Account(Id = c.AccountId);
			a.IATA_ISO_Country__c = country.Id;
			update a;
		}

		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(listJson,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"123","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>123</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();
		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		Case caseReturned = [Select Id, Financial_Assessment_Points__c from Case where Id = :caseId];

		system.assertEquals(100,caseReturned.Financial_Assessment_Points__c);
		System.assertEquals(1, batch.errors.size());
		System.assertEquals('[Result File "null" ] Case with CaseNumber 123 not found in database.', batch.errors[0]);

	}

	static testMethod void testResultsBatchFinancialAssessmentResult_Failure() {

		loadTestCases();

		AMS_Settlement_System__c sett_sys = new AMS_Settlement_System__c(name = 'BSP-HK', DPC_System__c = 'test_dpc');
		insert sett_sys;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c = 'HK',AIMS_Area_Name__c = 'HK', BSP_Country_free_text__c = 'HK', ANG_Enable_NewGen__c = true,AMS_Settlement_System__c = sett_sys.Id);
		insert country;

		Id caseId;
		String caseNumber;

		// prepare json String
		list<String> listJson = new list<String>();
		for ( Case c: [Select CaseNumber, AccountId from Case LIMIT 1] ) {

			caseId = c.Id;
			caseNumber = c.CaseNumber;
			String jsonCase =
				'{'+
				'"caseNumber": "'+c.CaseNumber+'",'+
				'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
				'"success":true'+
				'}';
			listJson.add(jsonCase);

			Account a = new Account(Id = c.AccountId);
			a.IATA_ISO_Country__c = country.Id;
			update a;
		}

		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(listJson,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"'+caseNumber+'","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+caseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();
		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		Case caseReturned = [Select Id, Financial_Assessment_Points__c from Case where Id = :caseId];

		system.assertEquals(null,caseReturned.Financial_Assessment_Points__c);
		system.assertEquals(true,batch.errors.isEmpty());

	}

	/**
	* Test method to force particular cases/exceptions
	* in order to increase overall code coverage
	*
	*/
	@isTest static void testIfapProcessResultsBatchExceptions() {

		loadTestCases();

		AMS_Settlement_System__c bsp = new AMS_Settlement_System__c(
			Name = 'BSP-HK',
			DPC_System__c = 'DPC'
		);

		insert bsp;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			ISO_Code__c = 'HK',
			AIMS_Area_Name__c = 'HK',
			BSP_Country_free_text__c = 'HK',
			ANG_Enable_NewGen__c = true,
			AMS_Settlement_System__c = bsp.Id
		);

		insert country;

		SalesforceSupportEmails__c sEmail = new SalesforceSupportEmails__c(
			Name = 'test', 
			Support_Email__c = 'test@test.com', 
			Support_User_Id__c = UserInfo.getUserId());
		insert sEmail;

		// prepare json String
		list<String> listJson = new list<String>();

		Case c = [SELECT CaseNumber, AccountId FROM Case LIMIT 1];

		String jsonCase =
			'{'+
			'"caseNumber": "'+c.CaseNumber+'",'+
			'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
			'"success":true'+
			'}';
		listJson.add(jsonCase);

		Account acct = new Account(Id = c.AccountId);
		acct.IATA_ISO_Country__c = country.Id;
		update acct;

		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(listJson,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"'+c.CaseNumber+'","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+c.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();

		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);

		//Force xml to be null to increase coverage
		response.responses[0].xml = null;
		IfapProcessResultsBatch emptyXMLBatch = new IfapProcessResultsBatch(response);
		Database.executeBatch(emptyXMLBatch);
		Test.stopTest();

		//Method call just to increase coverage
		IfapProcessResultsBatch.deleteResults(new List<String>{'file#1', 'file#2'},true);
		IfapProcessResultsBatch.deleteResults(new List<String>{'file#1', 'file#2'},false);

	}

	private static void multicountryFinancialAssessmentResults(Integer expectedPoints, String expectedFAResult){
		insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');

		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);
		insert bspPT;

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();
		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;
		insert countryPT;

		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account accountGE = new Account();
		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = agencyRecordTypeId;
		accountGE.IATACode__c = '99999999';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.Type = 'IATA Passenger Sales Agent';
		insert accountGE;

		Contact cont = new Contact(
			AccountId = accountGE.Id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = true
		);
		insert cont;

		ID ifapCaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

		Case ifap = new Case();
		ifap.AccountId = accountGE.Id;
		ifap.ContactId = cont.Id;
		ifap.Subject = 'IFAP Multicountry';
		ifap.Status = 'Financial Security Requested';
		ifap.RecordTypeId = ifapCaseRecordTypeId;
		ifap.IFAP_Financial_Year__c = String.valueOf(Date.today().year());
		ifap.ArchivedDate__c = Date.today();
		ifap.Financial_Review_Type__c = 'Multicountry Annual';
		insert ifap;

		List<String> jsonLst = new List<String>();

		ifap = [SELECT Id, CaseNumber FROM Case WHERE Id = :ifap.Id];

		String jsonCase =
				'{'+
				'"caseNumber": "'+ ifap.CaseNumber+'",'+
				'"xml": "<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>'+ifap.CaseNumber+'</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - Update Financial Security</GFAStatus> <FinancialCriteriaTotalScore>' + expectedPoints + '</FinancialCriteriaTotalScore> <Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>",' +
				'"success":true'+
				'}';

		jsonLst.add(jsonCase);

		IfapToolManager.testJsonResults = '{ "responses": [' + String.join(jsonLst,',')+ ']}';
		IfapToolManager.testJsonResultsGxA = '{ "responses": [{"success":true,"caseNumber":"123","originalFileNames":["MT-P-1099993-09991185.pdf","MT-P-1099993-09991186.pdf"],"xml":"<?xml version=\\\"1.0\\\" ?><WorkflowIntegrationDictionary xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\"><SalesforceCaseNumber>123</SalesforceCaseNumber><File><FileName>MX-P-8653021.pdf</FileName><FileType>FinancialAssessmentResult</FileType></File><GFAStatus>Unsatisfactory - New Financial Security</GFAStatus> <FinancialCriteriaTotalScore>ERR</FinancialCriteriaTotalScore><FinancialSecurity><Amount>120</Amount><Currency_x>EUR</Currency_x></FinancialSecurity><Error><ErrorCode>0</ErrorCode></Error></WorkflowIntegrationDictionary>","message":"tyu"}]}';

		//Test the batch
		Test.startTest();
		IfapToolManager.PWCResponses response = IfapToolManager.processPWCResults();
		IfapProcessResultsBatch batch = new IfapProcessResultsBatch(response);
		Database.executeBatch(batch);
		Test.stopTest();

		Case caseReturned = [Select Id, Financial_Review_Result__c, Assessment_Performed_Date__c, Financial_Assessment_Points__c from Case where Id = :ifap.Id];

		system.assertEquals(caseReturned.Financial_Assessment_Points__c, expectedPoints);
		system.assertEquals(caseReturned.Financial_Review_Result__c, expectedFAResult);
		system.assertEquals(caseReturned.Assessment_Performed_Date__c, System.today());
		system.assertEquals(1, batch.errors.size());
	}

	@isTest static void multicountryFinancialAssessmentResults70PointsTest(){
		multicountryFinancialAssessmentResults(70, AMS_Utils.FA_RESULT_SATISFACTORY_NO_ACTION);
	}

	@isTest static void multicountryFinancialAssessmentResults50PointsTest(){
		multicountryFinancialAssessmentResults(50, AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS);
	}

}
