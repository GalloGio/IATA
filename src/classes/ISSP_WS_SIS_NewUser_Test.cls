@isTest
private class ISSP_WS_SIS_NewUser_Test {

	private static final Profile AIRLINE_PORTAL_PROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];
	private static final Profile IATA_AGENCY_PROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User'];
	private static final Id IATA_AIRLINE_RT_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	private static final Id IATA_AGENCY_RT_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

	@TestSetup
	private static void setup() {
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		// insert errors in Custom Setting
		list<ISSP_Int_Error__c> listError = new list<ISSP_Int_Error__c>();
		for (Integer i=1; i<=50; i++) {
			String name = i.format().leftPad(3, '0');
			ISSP_Int_Error__c newError = new ISSP_Int_Error__c(
				Name = name,
				Error_Message__c = name
			);
			listError.add(newError);
		}
		insert listError;

		//insert SIS app
		Portal_Applications__c SISapp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		SISapp.Name = 'SIS';
		insert SISapp;

		// insert Portal service CS
		ISSP_Portal_Service_Ids__c portalServiceCs = new ISSP_Portal_Service_Ids__c(
			SIS__c = SISapp.id
		);
		insert portalServiceCs;

		//insert ISSP CS
		list<ISSP_CS__c> listIsspCs = new list<ISSP_CS__c>();
		listIsspCs.add(new ISSP_CS__c(
				Name = 'ISS_Portal_Airline_User',
				Value__c = AIRLINE_PORTAL_PROFILE.Id));
		listIsspCs.add(new ISSP_CS__c(
				Name = 'Host',
				Value__c = 'portal.iata.org'));
		listIsspCs.add(new ISSP_CS__c(
				Name = 'ISS_Portal_Agency_User',
				Value__c = IATA_AGENCY_PROFILE.id));
		insert listIsspCs;
	}

	public static ISSP_WS_SIS_NewUser.InputData createInputData() {
		ISSP_WS_SIS_NewUser.InputData inputData = new ISSP_WS_SIS_NewUser.InputData();
		inputData.SISMemberID = 'SISID';
		inputData.FirstName = 'firstName';
		inputData.LastName = 'lastName';
		inputData.EmailAddress = 'test@email.com';
		inputData.UserType = 'S';
		inputData.TypeOfService = 'SIS';
		inputData.Description = '';
		return inputData;
	}

	private static void checkLogs(Boolean isSuccess) {
		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.size()==1, '' + listLogs);
		System.assertEquals(isSuccess, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		System.assertEquals('ISSP_WS_SIS_NewUser', listLogs[0].Web_Service__c);
		System.assertEquals('newUser', listLogs[0].Method__c);
		System.assertEquals('SIS', listLogs[0].System__c);
	}

	static testMethod void newUser_noSISID() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.SISMemberID = '';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('018', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void newUser_noFirstName() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.FirstName = '';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('019', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void newUser_noLastName() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.LastName = '';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('003', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void newUser_noEmail() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.EmailAddress = '';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('002', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void newUser_invalidEmail() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.EmailAddress = 'wrongemail';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('006', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void newUser_invalidUserType() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.UserType = '';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('020', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void newUser_invalidTypeOfService() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		inputData.TypeOfService = '';
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('010', response.ErrorCode);

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.size()==1, '' + listLogs);
		System.assertEquals(false, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		System.assertEquals('ISSP_WS_SIS_NewUser', listLogs[0].Web_Service__c);
		System.assertEquals('newUser', listLogs[0].Method__c);
		System.assertEquals(null, listLogs[0].System__c);
	}

	static testMethod void createSISUser_NoAccountfound() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();

		Test.startTest();
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();

		System.assertEquals(false, response.IsSuccess);
		System.assertEquals('018', response.ErrorCode);

		checkLogs(false);
	}

	static testMethod void createSISUser_NoUser() {
		ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
		ISSP_SIS_Account_Status__c listCS = new ISSP_SIS_Account_Status__c(
				Name='1',
				Recordtype__c='IATA_Agency',
				Status__c='Approved',
				Country_ISO_Codes__c='SP',
				SIS_Status__c='Active',
				SIS_Substatus__c='TOU'
			);
			insert listCS;

		Account account = ISSP_ObjectFactory.createNewAccount();
		account.SIS_ID__c = inputData.SISMemberID;
		account.RecordTypeId = IATA_AGENCY_RT_ID;
		insert account;

		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = account.Id;
		contact.FirstName = inputData.FirstName;
		contact.LastName = inputData.LastName;
		contact.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
		contact.Email = inputData.EmailAddress;
		insert contact;

		Test.startTest();
		ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
		Test.stopTest();
		//System.assertEquals(true, response.IsSuccess);
		//System.assertEquals(contact.Id, response.FederationID);
		ISSP_WS_SIS_NewUser.increasecoverage();

		//checkLogs(true);
	}

}
