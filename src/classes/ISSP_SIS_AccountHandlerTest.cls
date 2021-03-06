@isTest
private class ISSP_SIS_AccountHandlerTest {

	@TestSetup
	private static void loadData() {
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		list<IATA_ISO_Country__c> listCountries = new list<IATA_ISO_Country__c>{
			new IATA_ISO_Country__c(Name='Spain', ISO_Code__c='SP'),
			new IATA_ISO_Country__c(Name='Jordan', ISO_Code__c='JO')
		};
		insert listCountries;

		list<ISSP_SIS_Account_Allowed_Countries__c> listAllowedCountries = new list<ISSP_SIS_Account_Allowed_Countries__c>{
			new ISSP_SIS_Account_Allowed_Countries__c(Name='SP')
		};
		insert listAllowedCountries;
		insert new ISSP_SIS_Account_Allowed_Location__c(
			Name='1',
			Location_Classes__c = 'A,B',
			Location_Types__c = 'AA,BB'
		);
		list<ISSP_SIS_Account_Allowed_Status__c> listAllowedStatus = new list<ISSP_SIS_Account_Allowed_Status__c>();
		listAllowedStatus.add(new ISSP_SIS_Account_Allowed_Status__c(Name='Approved'));
		listAllowedStatus.add(new ISSP_SIS_Account_Allowed_Status__c(Name='Cash basis/no commission'));
		listAllowedStatus.add(new ISSP_SIS_Account_Allowed_Status__c(Name='Cash basis/with commission'));
		listAllowedStatus.add(new ISSP_SIS_Account_Allowed_Status__c(Name='Changes processed'));
		insert listAllowedStatus;
	}

	static testMethod void test_afterInsert_NonSISAccount() {
		Account account = new Account(Name = 'test');
		Test.startTest();
		insert account;
		Test.stopTest();

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.isEmpty());
	}

	static testMethod void test_afterInsert_createValidSISAccount() {
		String testSISID = '123456';
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		Account account = new Account(
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Status__c = 'Changes processed',
			IATA_ISO_Country__c = country.Id,
			Name = 'test',
			Location_Class__c = 'B',
			Location_Type__c = 'BB'
		);
		ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';

		Test.startTest();
		insert account;
		Test.stopTest();

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.size()==1, '' + listLogs);
		//System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
		System.assertEquals('CreateAccount', listLogs[0].Method__c);
		System.assertEquals('SIS', listLogs[0].System__c);

		Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
		//System.assertEquals(testSISID, result.SIS_ID__c);
	}

	static testMethod void test_afterInsert_updateValidSISAccount() {
		String testSISID = '123456';
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		Account account = new Account(
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Status__c = 'Changes processed',
			IATA_ISO_Country__c = country.Id,
			Name = 'test',
			SIS_ID__c = testSISID,
			Location_Class__c = 'A',
			Location_Type__c = 'AA'
		);

		ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';

		Test.startTest();
		insert account;
		Test.stopTest();

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.size()==1, '' + listLogs);
		//System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
		System.assertEquals('UpdateAccount', listLogs[0].Method__c);
		System.assertEquals('SIS', listLogs[0].System__c);
		Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
		System.assertEquals(testSISID, result.SIS_ID__c);
	}

	static testMethod void test_beforeUpdate_createValidSISAccount() {
		String testSISID = '123456';
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		Account account = new Account(
			Name = 'test',
			Location_Class__c = 'A',
			Location_Type__c = 'AA'
		);
		insert account;

		ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';

		Test.startTest();
		account.RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY;
		account.Status__c = 'Changes processed';
		account.IATA_ISO_Country__c = country.Id;
		account.TradeName__c = 'TradeName';
		update account;
		Test.stopTest();

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.size()==1, '' + listLogs);
		//System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
		System.assertEquals('CreateAccount', listLogs[0].Method__c);
		System.assertEquals('SIS', listLogs[0].System__c);

		Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
		//System.assertEquals(testSISID, result.SIS_ID__c);
	}

	static testMethod void test_beforeUpdate_updateValidSISAccount() {
		String testSISID = '123456';
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		Account account = new Account(
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Status__c = '',
			Name = 'test',
			SIS_ID__c = testSISID,
			Location_Class__c = 'A',
			Location_Type__c = 'AA'
		);
		insert account;

		delete [SELECT Id FROM ISSP_Web_Service_Log__c];
		ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';

		Test.startTest();
		account.IATA_ISO_Country__c = country.Id;
		account.BillingCity = 'City';
		account.Status__c = 'Changes processed';
		update account;
		Test.stopTest();

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		System.assert(listLogs.size()==1, '' + listLogs);
		//System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
		System.assertEquals('UpdateAccount', listLogs[0].Method__c);
		System.assertEquals('SIS', listLogs[0].System__c);
		Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
		System.assertEquals(testSISID, result.SIS_ID__c);
	}


	static void loadCS_SISAccount() {
		list<ISSP_SIS_Account_Status__c> listCS = new list<ISSP_SIS_Account_Status__c>{
			new ISSP_SIS_Account_Status__c(
				Name='1',
				Recordtype__c='IATA_Agency',
				Status__c='Approved',
				Location_Class__c='B',
				Country_ISO_Codes__c='SP',
				SIS_Status__c='Active',
				SIS_Substatus__c='TOU'
			),
			new ISSP_SIS_Account_Status__c(
				Name='2',
				Recordtype__c='IATA_Agency',
				Status__c='Approved',
				Location_Class__c='A',
				Country_ISO_Codes__c='JO',
				SIS_Status__c='Active',
				SIS_Substatus__c='ISPA Airline'
			),
			new ISSP_SIS_Account_Status__c(
				Name='3',
				Recordtype__c='IATA_Agency',
				Status__c='Approved',
				Location_Class__c='All',
				Country_ISO_Codes__c='All',
				SIS_Status__c='Terminated',
				SIS_Substatus__c='TERMINATED'
			)
		};
		insert listCS;
	}

	static testMethod void test_beforeInsert_UpdateSISStatus() {
		loadCS_SISAccount();
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		Account account = new Account(
			Name = 'test',
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Status__c = 'Approved',
			Location_Class__c = 'B',
			Location_Type__c = 'BB',
			IATA_ISO_Country__c = country.Id
		);
		ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>123465</SISMemberID></Response>';

		Test.startTest();
		insert account;
		Test.stopTest();

		Account result = [SELECT Id, SIS_Status__c, SIS_Sub_Status__c FROM Account where Id = :account.Id];
		System.assertEquals('Active', result.SIS_Status__c);
		System.assertEquals('TOU', result.SIS_Sub_Status__c);
	}

	static testMethod void test_beforeUpdate_UpdateSISStatus() {
		loadCS_SISAccount();
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='JO'];
		Account account = new Account(
			Name = 'test',
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Status__c = 'Approved',
			Location_Class__c = 'B',
			Location_Type__c = 'BB',
			IATA_ISO_Country__c = country.Id
		);
		ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>123465</SISMemberID></Response>';

		Test.startTest();
		insert account;
		Test.stopTest();

		Account result = [SELECT Id, SIS_Status__c, SIS_Sub_Status__c FROM Account where Id = :account.Id];
		System.assertEquals('Terminated', result.SIS_Status__c);
		System.assertEquals('TERMINATED', result.SIS_Sub_Status__c);
	}

	static testMethod void test_beforeUpdate_UpdateSISStatus2() {
		loadCS_SISAccount();
		IATA_ISO_Country__c spain = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		IATA_ISO_Country__c jordan = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='JO'];

		Account account = new Account(
			Name = 'test',
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Location_Class__c = 'A',
			Location_Type__c = 'AA'
		);
		insert account;
		ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>123465</SISMemberID></Response>';

		Account result = [SELECT Id, SIS_Status__c, SIS_Sub_Status__c FROM Account where Id = :account.Id];
		System.assert(String.isBlank(result.SIS_Status__c));
		System.assert(String.isBlank(result.SIS_Sub_Status__c));

		Test.startTest();
		account.IATA_ISO_Country__c = jordan.Id;
		account.Location_Class__c = 'A';
		account.Status__c = 'Approved';
		update account;
		Test.stopTest();

		result = [SELECT Id, SIS_Status__c, SIS_Sub_Status__c FROM Account where Id = :account.Id];
		System.assertEquals('Active', result.SIS_Status__c);
		System.assertEquals('ISPA Airline', result.SIS_Sub_Status__c);
	}

	static testMethod void test_giveSISAppToAccountUsers() {
		insert new ISSP_SIS_Account_Status__c(
			Name='test',
			Recordtype__c='IATA_Agency',
			Status__c='Open',
			Country_ISO_Codes__c='All',
			SIS_Status__c='Active',
			SIS_Substatus__c='TOU'
		);
		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		insert portalApplication;
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
		Account account = new Account(
			RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
			Status__c = 'Open',
			Name = 'test'
		);
		insert account;

		Test.startTest();
		account.Sector__c = AMS_Utils.SECTOR_PASSENGER;
		account.Category__c = AMS_Utils.CATEGORY_CASSASSOCIATE;
		update account;
		Test.stopTest();
	}

}
