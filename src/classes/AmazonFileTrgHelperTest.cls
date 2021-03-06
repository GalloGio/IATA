@isTest
private class AmazonFileTrgHelperTest {
	@TestSetup
	static void makeData(){
		TestDataFactory_AWSKeys.createAllEntries();
	}

	static Case initializeCase() {

		String sSapNumberRequiredJSON = AmazonFileTrgHelper.sapNumberRequiredJSON;
		String sExpiryDateRequiredJSON = AmazonFileTrgHelper.expiryDateRequiredJSON;
		String sExpiredRequiredJSON = AmazonFileTrgHelper.expiredRequiredJSON;

		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.Sector__c = AMS_Utils.SECTOR_INFRASTRUCTURE;
		account.Category__c = AMS_Utils.CATEGORY_AIRPORT_AUTHORITY;
		account.IATACode__c = '12345678';
		insert account;

		AMS_OSCAR__c oscar1 = new AMS_OSCAR__c();
		AMS_OSCAR_TestDataFactory.createOSCARtestData();

		oscar1 = [Select Id from AMS_OSCAR__c Limit 1];

		oscar1.Process__c = AMS_Utils.CERTIFICATION;
		oscar1.Status__c = 'Accepted_Future Date';
		Update oscar1;

		Case caseObj = new Case();
		caseObj.ArchivedDate__c = null;
		caseObj.AccountId = account.Id;
		caseObj.OSCAR__c = oscar1.Id;
		insert caseObj;
		return caseObj;
	}


	@isTest static void test_method_one() {
		// Implement test code

		Test.startTest();

		Case case1 =  initializeCase();

		AmazonFile__C AmzFile = new AmazonFile__C(name ='file',Full_Name_Unique__c = 'test name', case__c = case1.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
		insert AmzFile;

		Test.stopTest();

		AmazonFile__C AmzFile2 = new AmazonFile__C(name ='file2',Full_Name_Unique__c = 'test name2', case__c = case1.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
		insert AmzFile2;

		delete AmzFile;
		delete AmzFile2;


		list<AmazonFile__C> amzFiledelete = [SELECT Id FROM AmazonFile__C WHERE isDeleted =: true and id =: AmzFile.id All ROWS];

		system.assert(amzFiledelete.size() == 1);



		SingleRequestMockAmazonRest fakeAccountResp = new SingleRequestMockAmazonRest(200,
														 'Complete',
														 '[{"Name": "sForceTest1"}]',
														 null);

		SingleRequestMockAmazonRest fakeContactsResp = new SingleRequestMockAmazonRest(200,
												  'Complete',
												  '[{"LastName": "Test Last Name"}]',
												   null);

		Map<String, HttpCalloutMock> endpoint2TestResp =
								   new Map<String,HttpCalloutMock>();
		endpoint2TestResp.put('asdasd'+ '/'
							+ string.valueof(case1.id).substring(0,3)+
							'/' +string.valueof(case1.id)+ '/' + AmzFile.name

								,fakeAccountResp);
		endpoint2TestResp.put('asdasd'+ '/'
							+ string.valueof(case1.id).substring(0,3)+
							'/' +string.valueof(case1.id)+ '/' + AmzFile.name
							,fakeContactsResp);

		HttpCalloutMock multiCalloutMock =
								   new AmazonFileTrgHelperMultiMockUp(endpoint2TestResp);

		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		undelete AmzFile;

		list<AmazonFile__C> amzFileUndelete = [SELECT Id FROM AmazonFile__C WHERE isDeleted =: true and id =: AmzFile.id All ROWS];

		system.assert(amzFileUndelete == null || amzFileUndelete.size() == 0);


	}

	@isTest static void test_InsertWithAction() {
		Account account = new Account(
									Name = 'testAccount',
									Sector__c = AMS_Utils.SECTOR_AIRLINE,
									Category__c = AMS_Utils.CATEGORY_TRAVEL_AGENT
									);
		insert account;

		Test.startTest();
		AmazonFile__c file = new AmazonFile__c(
			RecordTypeId=AmazonFileTrgHelper.RT_CERTIFICATE_ID,
			Full_Name_Unique__c = 'test',
			Action__c='Create Case',
			Account__c = account.Id
		);
		insert file;
		Test.stopTest();
	}

	@isTest static void test_UpdateWithAction_Reminder30() {
		Account account = new Account(
									Name = 'testAccount',
									Sector__c = AMS_Utils.SECTOR_AIRLINE,
									Category__c = AMS_Utils.CATEGORY_TRAVEL_AGENT
									);
		insert account;

		Case cse = new Case(
			AccountId = account.Id
		);
		insert cse;

		AmazonFile__c file = new AmazonFile__c(
			RecordTypeId=AmazonFileTrgHelper.RT_CERTIFICATE_ID,
			Full_Name_Unique__c = 'test',
			Account__c = account.Id,
			Case__c = cse.Id
		);
		insert file;

		Test.startTest();
		file.Action__c = 'Reminder 30 days';
		update file;
		Test.stopTest();
	}

	@isTest static void test_UpdateWithAction_ReminderOnExpiry() {
		Account account = new Account(
									Name = 'testAccount',
									Sector__c = AMS_Utils.SECTOR_AIRLINE,
									Category__c = AMS_Utils.CATEGORY_TRAVEL_AGENT
									);
		insert account;

		Case cse = new Case(
			AccountId = account.Id
		);
		insert cse;

		AmazonFile__c file = new AmazonFile__c(
			RecordTypeId=AmazonFileTrgHelper.RT_CERTIFICATE_ID,
			Full_Name_Unique__c = 'test',
			Account__c = account.Id,
			Case__c = cse.Id
		);
		insert file;

		Test.startTest();
		file.Action__c = 'Reminder on Expiry';
		update file;
		Test.stopTest();
	}

	@isTest static void testAutomaticReports() {

		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		portalApplication.Name = 'TIP Reports';
		portalApplication.Functional_Role__c = 'TIP Reports';
		insert portalApplication;

		ISSP_External_Reports_Config__c conf = new ISSP_External_Reports_Config__c(
			name = 'bla',
			Portal_Service_ID__c = portalApplication.Id,
			Report_ID__c = 'TIP_AUTO_REPORTS'
		);

		insert conf;

		Account acc = new Account(name = 'some airline', Sector__c = AMS_Utils.SECTOR_AIRLINE, Category__c = AMS_Utils.CATEGORY_TRAVEL_AGENT,
			IATACode__c = '123', recordtypeid = AMS_Utils.RECTYPE_AIRLINE);

		insert acc;

		Contact contact = new Contact(
			FirstName = 'test',
			LastName = 'test',
			AccountId = acc.Id,
			User_Portal_Status__c = ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM,
			email = 'testiata@yopmail.com'
			);
		insert contact;


		Portal_Application_Right__c appReq = new Portal_Application_Right__c();
		appReq.Portal_Application__c = portalApplication.Id;
		appReq.Right__c = 'Access Granted';
		appReq.Contact__c = contact.Id;

		insert appReq;

		Remote_Invocation__c ri = new Remote_Invocation__c (
			Integration_Transaction_ID__c = 'ABC1',
			Internal_ID__c = '123',
			Request_Type__c = TIP_Utils.REQUEST_TYPE_TIP_AUTO_REPORTS,
			Source__c = 'IFG',
			Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_INITIALIZING
		);

		insert ri;

		Remote_Invocation_Artefact__c ria1 = new Remote_Invocation_Artefact__c (
			Name__c = 'someDocument1.pdf',
			Format__c = 'pdf',
			Remote_Invocation__c = ri.Id
		);

		Remote_Invocation_Artefact__c ria2 = new Remote_Invocation_Artefact__c (
			Name__c = 'someDocument2.pdf',
			Format__c = 'pdf',
			Remote_Invocation__c = ri.Id
		);

		List<Remote_Invocation_Artefact__c> lria = new List<Remote_Invocation_Artefact__c>();
		lria.add(ria1);
		lria.add(ria2);

		insert lria;

		ri.Status__c = TIP_Utils.REMOTE_INVOCATION_STATUS_IN_PROGRESS;

		update ri;

		lria = [Select Id, Name, Format__c, Object_ID_Created__c, Remote_Invocation__c, Status__c From Remote_Invocation_Artefact__c Where Remote_Invocation__r.Integration_Transaction_ID__c Like 'ABC%'];

		List<AmazonFile__c> files = new List<AmazonFile__c>();
		Integer aux = 0;

		for(Remote_Invocation_Artefact__c ria : lria) {
			AmazonFile__c newFile = new AmazonFile__c(
				sObject_Id__c = ria.Object_ID_Created__c,
				Full_Name_Unique__c = '' + aux,
				Name = ria.Name
			);
			files.add(newFile);
			aux++;
		}

		insert files;

		files = [Select Id, isPublic__c From AmazonFile__c];

		for(AmazonFile__c file : files) {
			file.isPublic__c = true;
		}

		update files;
	}

	@isTest static void test_Case_Id_Populated_From_SObjectId() {
		Case case1 =  initializeCase();

		Test.startTest();
		AmazonFile__C AmzFile = new AmazonFile__C(name ='file',Full_Name_Unique__c = 'test name', sObject_Id__c = case1.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
		insert AmzFile;
		system.assert(([select case__c from AmazonFile__c where id=:AmzFile.Id].case__c) == case1.Id);
		Test.stopTest();
	}
}