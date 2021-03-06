@isTest
private class AmazonFinancialTest {

	@TestSetup
	static void makeData(){
		insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');
		TestDataFactory_AWSKeys.createAllEntries();
	}

	@isTest
	private static void testArchivedCase(){
		Case caseObj = new Case();
		caseObj.ArchivedDate__c = Date.today();
		insert caseObj;

		ENZ__FTPAttachment__c attach = new ENZ__FTPAttachment__c();
		attach.Name = 'testAttachment';
		attach.Case__c = caseObj.Id;
		insert attach;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);

		Test.stopTest();

	}

	@isTest
	private static void testNotArchivedCase_ErrorAgentCode(){
		Case caseObj = new Case();
		caseObj.ArchivedDate__c = null;
		insert caseObj;

		ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);

		Test.startTest();
			AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);

		Test.stopTest();
	}

	private static Case initializeCase() {
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '12345678';
		insert account;

		Case caseObj = new Case();
		caseObj.ArchivedDate__c = null;
		caseObj.AccountId = account.Id;
		insert caseObj;
		return caseObj;
	}

	@isTest
	private static void testNotArchivedCase(){
		Case caseObj = initializeCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);

		Test.startTest();
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
		controller.RefreshAll();

		AmazonFinancialCtrl.IfapMessage message = new AmazonFinancialCtrl.IfapMessage();
		message.ISOCountryCodes = '';
		message.AgentType = '';
		message.Country = '';
		message.Documents = '';

		Test.stopTest();
	}

	@isTest
	private static void testProcessResponse_Exception(){
		Case caseObj = initializeCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
		controller.response = null;

		Test.startTest();
		Object response = controller.processResponse();
		Test.stopTest();

		System.AssertEquals(response, null);
	}

	@isTest
	private static void testProcessResponse_Error(){
		Case caseObj = initializeCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
		controller.response = new IfapToolManager.Response(
									'{"success": false ,"code":"AllFood","message":"error message","response":""}'
									);

		Test.startTest();
		Object response = controller.processResponse();
		Test.stopTest();

		System.AssertEquals(response, null);
	}

	@isTest
	private static void testProcessResponse_Success(){
		Case caseObj = initializeCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(caseObj);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stdController);
		controller.response = new IfapToolManager.Response(
									'{"success": true ,"code":"AllFood","message":"from in a bottle!","response":"my risp"}'
									);

		Test.startTest();
		Object response = controller.processResponse();
		Test.stopTest();

		System.AssertEquals(response, null);
	}

	@isTest
	private static void testRemoteFunctions(){
		Case caseObj = initializeCase();

		Test.startTest();
		Boolean response = AmazonFinancialCtrl.checkIfFileWasUploaded('key');
		System.AssertEquals(response, false);

		String strResponse = AmazonFinancialCtrl.getExpiringLinkIfap('filename');

		AmazonFinancialCtrl.UploadFile upFile1 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename', 'applciation/pdf', 10);
		System.AssertEquals(upFile1.isSuccess, false);
		System.AssertEquals(upFile1.errorMessage, System.label.IfapNotPdf);

		AmazonFinancialCtrl.UploadFile upFile2 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename$.pdf', 'applciation/pdf', 10);
		System.AssertEquals(upFile2.isSuccess, false);

		AmazonFinancialCtrl.UploadFile upFile3 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename.pdf', 'applciation/pdf', AmazonFinancialCtrl.FILE_SIZE_LIMIT_BYTES);
		System.AssertEquals(upFile3.isSuccess, false);

		AmazonFinancialCtrl.UploadFile upFile4 = AmazonFinancialCtrl.createUploadFile(caseObj.Id, 'filename.pdf', 'applciation/pdf', AmazonFinancialCtrl.FILE_SIZE_LIMIT_BYTES-1);
		System.AssertEquals(upFile4.isSuccess, false);

		AmazonFinancialCtrl.deleteFile(caseObj.Id, 'filename');

		list<string> names = new list<string>();
		names.add('name1.pdf');
		names.add('name2.xml');
		AmazonFinancialCtrl.parseTheIntegerForName(names);
		Test.stopTest();

	}


	@isTest
	private static void secondNotArchived(){
		PageReference pageRef = Page.AmazonFinancial;
		Test.setCurrentPage(pageRef);
		
		 UtilityCS__c sup = new UtilityCS__c(name = 'Emails',value__c='arandomEmail@gmail.com');
		 insert sup;

		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
		insert isoCountry;

		Account agent = New Account(name = 'The Agent',
									recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
									IATACode__c = '1234567' ,
									IATA_ISO_Country__c=isoCountry.id,
									Type = 'Passenger'      );
		insert agent;

		Case testCase1 = new Case(  CaseArea__c = 'TTBS',
									status = 'Agent Notified (Mail)',
									Financial_Review_Type__c = 'Annual',
									//Tax_Effective_Date__c = Date.valueOf('2011-08-29'),
									Origin = 'Other',
									SuppliedEmail = 'paia@iata.org',
									SuppliedPhone = '12456987456',
									Type = 'TFC update',
									Description = 'Testing...',
									Priority = '3',
									Subject = 'TTBS Test Case',
									accountId = agent.id);
		 insert testCase1;


		ENZ__FTPAttachment__c att = new ENZ__FTPAttachment__c(name = 'asd', case__c = testCase1.id);
		insert att;


		testCase1  = [select id, Status,CaseNumber,ArchivedDate__c,account.type,
							 account.IATA_ISO_Country__r.iso_code__c ,account.Country_ISO_Code__c,
							 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c
								from Case where id =: testCase1.id ];


		ApexPages.StandardController stand = new ApexPages.StandardController(testCase1);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stand);
		//system.debug('asdasd '+ controller.listFile);
	  // throw new transformationException('asdasd '+ controller.listFile);
		system.assertEquals(controller.listFile.size(),2);

		controller.refreshAll();
		//system.assertEquals(controller.docs.size(), 1);
		controller.filenameupload = 'uploadthisone';
		controller.filetypeupload = '.pdf';

		system.assertEquals(controller.canUploadAndDelete,true);
		//AmazonFinancialCtrl.UploadFile up2 = AmazonFinancialCtrl.createUploadFile(testCase1.id,'uploadthisone','.pdf');
		controller.sendFileInfo();
		AmazonFinancialCtrl.UploadFile upF = new AmazonFinancialCtrl.UploadFile(testCase1.id,'uploadthisone',testCase1.caseNumber,'.pdf');
		//throw new transformationException(''+controller.file.filenameupload);

		//system.assertEquals(up2.filenameupload,upF.filenameupload);
		system.assertEquals(controller.file.filenameupload,upF.filenameupload);

		string link = AmazonFinancialCtrl.getExpiringLinkIfap('thefile');
		system.assertEquals(link.contains('thefile'),true);
		controller.mergeFilesAndSubmitParams();

		controller.response = new IfapToolManager.Response(
									'{"success": true ,"code":"AllFood","message":"from in a bottle!","response":"my risp"}'
									);




		controller.processresponse();

		Case tC = [SELECT ID, Status from Case where id =: testCase1.id ];

		system.assertEquals(tC.Status,'Submitted');


		controller.response = new IfapToolManager.Response(
									'{"success":false,"code":"badlyDone","message":"in a bottle!","response":"my risp"}'
									);




		controller.processresponse();

		system.assertEquals(controller.hasMessage,true);

		system.assertEquals(ApexPages.getmessages()[0].getSummary().contains('in a bottle'),true);

		system.assertEquals(controller.canUploadAndDelete,false);

		controller.fileNameFromPage = 'asdasd';

		//AmazonFinancialCtrl.UploadFile upF5 =  AmazonFinancialCtrl.createUploadFile(testCase1.id,'uploadthison~e','.pdf');
		//system.assertEquals(upf5.isSuccess, false);
	}


	@isTest
	private static void firstMethodArchivedPath(){
		PageReference pageRef = Page.AmazonFinancial;
		Test.setCurrentPage(pageRef);


		 UtilityCS__c sup = new UtilityCS__c(name = 'Emails',value__c='arandomEmail@gmail.com');
		 insert sup;


		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
		insert isoCountry;

		Account agent = New Account(name = 'The Agent',
									recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
									IATACode__c = '1234567' ,
									IATA_ISO_Country__c=isoCountry.id,
									Type = 'Passenger'      );
		insert agent;

		Case testCase1 = new Case(  CaseArea__c = 'TTBS',
									ArchivedDate__c = date.today(),
									//Tax_Effective_Date__c = Date.valueOf('2011-08-29'),
									Origin = 'Other',
									SuppliedEmail = 'paia@iata.org',
									SuppliedPhone = '12456987456',
									Type = 'TFC update',
									Description = 'Testing...',
									Priority = '3',
									Subject = 'TTBS Test Case',
									accountId = agent.id);
		 insert testCase1;


		ENZ__FTPAttachment__c att = new ENZ__FTPAttachment__c(name = 'asd', case__c = testCase1.id);
		insert att;


		testCase1  = [select id,ArchivedDate__c from Case where id =: testCase1.id ];


		ApexPages.StandardController stand = new ApexPages.StandardController(testCase1);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stand);

		//  throw new transformationException('asdasd '+ controller.cse);
		system.assertEquals(controller.Archived, true);
		system.assertEquals(controller.docs.size(), 1);

	}

	@isTest static void canUploadFinancialReviewDocumentsTest(){
		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert bspSG;

		IATA_ISO_Country__c countrySG = new IATA_ISO_Country__c (
			Name = 'Singapore',
			ISO_Code__c = 'SG',
			AMS_Settlement_System__c = bspSG.Id,
			ANG_Enable_NewGen__c = true
		);

		insert countrySG;

		Account agentSG = new Account(
			Name = 'Agent SG',
			IATACode__c ='999999999',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countrySG.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			ANG_HE_RiskStatus__c = 'A',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Singapore'
		);

		insert agentSG;

		Contact contSG = new Contact(
			FirstName = 'Agent',
			LastName = 'Singapore',
			Type_of_Contact__c = 'IFAP Contact',
			AccountId = agentSG.Id,
			Email = 'agent.singapore@test.com',
			Financial_Assessment_Contact__c = true
		);

		insert contSG;

		Case caseSG = new Case(
			ContactId = contSG.Id,
			AccountId = agentSG.Id,
			Subject = 'Financial Review',
			Description = 'Financial Review - 2018',
			Status = 'Agent to be Notified',
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2018',
			Deadline_Date__c = System.today().addDays(-7)
		);

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		insert caseSG;

		PageReference pageRef = Page.AmazonFinancial;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stand = new ApexPages.StandardController(caseSG);
		AmazonFinancialCtrl controller = new AmazonFinancialCtrl(stand);

		system.assert(!controller.canUploadAndDelete);

		caseSG.Status = 'Closed_Non compliance';
		update caseSG;

		stand = new ApexPages.StandardController(caseSG);
		controller = new AmazonFinancialCtrl(stand);

		system.assert(controller.canUploadAndDelete);

	}

}
