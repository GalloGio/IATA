@isTest
public class ANG_RME_Alert_Service_Test {

	private static RestRequest req;

	static {
		req = new RestRequest();
		req.httpMethod = 'PUT';
		req.requestURI = System.URL.getSalesforceBaseUrl() + '/services/apexrest/RME_ALERT_BALANCEUPDATE/';
	}

	public static void createRMEMappings(){
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Prov', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/calculatedrhc/{agencyId}/v1', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Bal', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/consumedrhc/{agencyId}/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		insert customsettings;
	}

	@testSetup 
	static void createData() {

		AMS_Settlement_System__c bspKZ = new AMS_Settlement_System__c(
			Name = 'BSP-KZ',
			CurrencyIsoCode = 'EUR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			RHC_Exceptional_Monitoring__c = true,
			Exc_RHC_Monitoring_Alert__c = '100%'
		);
		insert bspKZ;

		AMS_Settlement_System__c bspRU = new AMS_Settlement_System__c(
			Name = 'BSP-RU',
			CurrencyIsoCode = 'EUR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			RHC_Exceptional_Monitoring__c = true,
			Exc_RHC_Monitoring_Alert__c = '100%;75%;50%'
		);

		insert bspRU;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US', CurrencyIsoCode = 'USD');
		
		IATA_ISO_Country__c countryKZ = new IATA_ISO_Country__c (
			Name = 'Kazakhstan',
			ISO_Code__c = 'KZ',
			AMS_Settlement_System__c = bspKZ.Id,
			ANG_Enable_NewGen__c = false
		);

		IATA_ISO_Country__c countryRU = new IATA_ISO_Country__c (
			Name = 'Russia',
			ISO_Code__c = 'RU',
			AMS_Settlement_System__c = bspRU.Id,
			ANG_Enable_NewGen__c = false
		);

		insert new List<IATA_ISO_Country__c>{ctry, countryKZ, countryRU};

		list<AMS_Country_Specific_Attribute__c> lsAttr = new list<AMS_Country_Specific_Attribute__c>();

		lsAttr.add(new AMS_Country_Specific_Attribute__c(IATA_ISO_Country__c = countryKZ.Id,
														 ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, 
														 ANG_Percentage__c= ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100,
														 recordtypeid = ANG_RHCHelper.RECTYPE_RHCATTRIBUTE,
														 Email_Template_Internal_Stakeholders__c = 'RHC_Exceptional_Monitoring_SMAP_Notification',
														 Create_SMAP_Case__c = true,
														 ANG_Send_Email_Agent__c = false,
														 Stakeholders_email_list__c = 'tullod@iata.org'));

		lsAttr.add(new AMS_Country_Specific_Attribute__c(IATA_ISO_Country__c = countryRU.Id,
														 ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, 
														 ANG_Percentage__c= ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100,
														 recordtypeid = ANG_RHCHelper.RECTYPE_RHCATTRIBUTE,
														 Email_Template_Internal_Stakeholders__c = 'RHC_Exceptional_Monitoring_100',
														 Create_SMAP_Case__c = false,
														 ANG_Send_Email_Agent__c = false,
														 Stakeholders_email_list__c = 'tullod@iata.org'));

		lsAttr.add(new AMS_Country_Specific_Attribute__c(IATA_ISO_Country__c = countryRU.Id,
														 ANG_Direction__c = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN, 
														 ANG_Percentage__c= ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100,
														 recordtypeid = ANG_RHCHelper.RECTYPE_RHCATTRIBUTE,
														 ANG_Send_Email_Agent__c = false,
														 Email_Template_Internal_Stakeholders__c = '',
														 Create_SMAP_Case__c = false,
														 Stakeholders_email_list__c = ''));
		
		insert lsAttr;

		Account a = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = AMS_utils.RECTYPE_IATAAGENCY, IATACode__c='1234562',Location_Type__c= AMS_Utils.BR, Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT, Location_Class__c = AMS_Utils.LC_PASSENGER);
		
		Account rhcMonitoringAccount = new Account();
		rhcMonitoringAccount.Name = 'Account for exceptional monitoring';
		rhcMonitoringAccount.IATACode__c = '912345678';
		rhcMonitoringAccount.IATA_ISO_Country__c = countryKZ.Id;
		rhcMonitoringAccount.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		rhcMonitoringAccount.Location_Type__c = AMS_Utils.HO;
		rhcMonitoringAccount.Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT;
		rhcMonitoringAccount.Location_Class__c = AMS_Utils.LC_PASSENGER;

		Account RussiaRhcMonitoringAccount = new Account();
		RussiaRhcMonitoringAccount.Name = 'RUSSIA exceptional monitoring';
		RussiaRhcMonitoringAccount.IATACode__c = '88888888';
		RussiaRhcMonitoringAccount.IATA_ISO_Country__c = countryRU.Id;
		RussiaRhcMonitoringAccount.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		RussiaRhcMonitoringAccount.Location_Type__c = AMS_Utils.HO;
		RussiaRhcMonitoringAccount.Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT;
		RussiaRhcMonitoringAccount.Location_Class__c = AMS_Utils.LC_PASSENGER;


		insert new List<Account>{a, rhcMonitoringAccount, RussiaRhcMonitoringAccount};

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		List<ANG_RHC_Information__c> rhcLst = [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id];

		if(!rhcLst.isEmpty()){
			rhcLst.get(0).ANG_Forecasted_RHC_Effective_date__c = System.today();
			update rhcLst;
	   	}

		Test.startTest();
		Database.executeBatch(new ANG_RHCCopyRHCForecastBatch(null));
		Test.stopTest();

		createRMEMappings();
	}

	@isTest
	static void test_wrongJSON() {
		req.requestBody = Blob.valueOf('{"agencyCode":"somecode"}');
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		System.assertEquals(400, RestContext.response.StatusCode);
		System.assert(result.description.startsWith('Malformed request:'));
	}

	@isTest
	static void test_noAccount() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = 'nocode';

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		System.assertEquals(404, RestContext.response.StatusCode);
		System.assertEquals('No agent found with IATA Code nocode', result.description);
	}

	@isTest
	static void test_valueValidationError() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'EUR';
		message.storedRHCValue = 1000;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [SELECT Id, ANG_Threshold_Level__c, ANG_Direction__c FROM ANG_Risk_Alert__c];

		System.assert(result.description.startsWith('Conflicting informations'));
		//System.assert(result.description.contains('RHC Amount mismatch'));
		System.assert(result.description.contains('Currency mismatch'));
		System.assertEquals(409, RestContext.response.StatusCode);
	}

	@isTest
	static void test_alert_success() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.storedRHCValue = 0;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		message.thresholdLevel = ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100;
		message.direction = 'UP';

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [SELECT Id, ANG_Threshold_Level__c, ANG_Direction__c FROM ANG_Risk_Alert__c];

		System.assertEquals(202, RestContext.response.StatusCode);
		System.assertEquals(1, alerts.size());
		System.assertEquals(ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100, alerts[0].ANG_Threshold_Level__c);
		System.assertEquals('UP', alerts[0].ANG_Direction__c);
	}

	@isTest
	static void test_balance_success() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = ANG_RME_Alert_Service.BALANCE_UPDATE_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.storedRHCValue = 0;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.BALANCE_UPDATE_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_RHC_Information__c> rhcinfos = [SELECT Id, ANG_ConsumedRHC__c, ANG_ConsumedRHC_Percent__c FROM ANG_RHC_Information__c];

		System.assertEquals(202, RestContext.response.StatusCode);
		System.assertEquals(1, rhcinfos.size());
		System.assertEquals(200, rhcinfos[0].ANG_ConsumedRHC__c);
		System.assertEquals(50, rhcinfos[0].ANG_ConsumedRHC_Percent__c);
	}

	@isTest
	static void test_invaldidEvent() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = 'TestCall';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.storedRHCValue = 0;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', 'TestCall');
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		System.assertEquals(405, RestContext.response.StatusCode);
		System.assertEquals('Invalid Event Type: TestCall', result.description);
	}

	@isTest
	static void webservice_sucess() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.storedRHCValue = 200;

		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();

		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestProvisionalRHC([SELECT IATACode__c FROM Account][0].Id);

		Test.stopTest();

		System.assertEquals(message.iataCode, result.iataCode);
		System.assert(result.isSuccess);
	}

	@isTest
	static  void webservice_error() {
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(400, 'There was an error'));

		Test.startTest();

		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate([SELECT IATACode__c FROM Account][0].Id);

		Test.stopTest();

		System.assertEquals('An unexpected error ocurred while contacting the external system. An incident has been raised on Service Now.', result.description);
		System.assert(!result.isSuccess);
	}

	@isTest
	static void webservice_exception() {
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, 'Not a JSON'));

		Test.startTest();

		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate([SELECT IATACode__c FROM Account][0].Id);

		Test.stopTest();

		System.assert(!result.isSuccess);
	}

	@isTest
	static void test_RTS_alert_success() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'testRTSAlert1';
		message.eventType = ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.rtsSeverity = 'Orange';
		message.agentSales = 100.00;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [SELECT Id, ANG_Severity__c, ANG_Agent_Sales__c FROM ANG_Risk_Alert__c];

		System.assertEquals(202, RestContext.response.StatusCode);
		System.assertEquals(1, alerts.size());
		System.assertEquals('Orange', alerts[0].ANG_Severity__c);
		System.assertEquals(100.00, alerts[0].ANG_Agent_Sales__c);
	}

	@isTest
	static void test_RTS_alert_error() {

		// test Severity validation
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'testRTSAlert1';
		message.eventType = ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.rtsSeverity = 'ERROR_Severity';
		message.agentSales = 100.00;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		List<ANG_Risk_Alert__c> alerts = [SELECT Id FROM ANG_Risk_Alert__c];

		System.assertEquals(0, alerts.size());
		System.assertEquals(400, RestContext.response.StatusCode);
		System.assert(result.description.contains('Invalid rtsSeverity'));


		// test currency validation
		message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'testRTSAlert2';
		message.eventType = ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'error_Currency';
		message.rtsSeverity = 'Orange';
		message.agentSales = 100.00;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE);
		RestContext.request = req;

		result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		alerts = [SELECT Id FROM ANG_Risk_Alert__c];

		System.assertEquals(0, alerts.size());
		System.assertEquals(400, RestContext.response.StatusCode);
		System.assert(result.description.contains('Invalid storedBaseCurrency'));


		// test required fields validation
		message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'testRTSAlert3';
		message.eventType = ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE;
		message.rtsSeverity = 'Orange';

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RTS_ALERT_EVENT_TYPE);
		RestContext.request = req;

		result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		alerts = [SELECT Id FROM ANG_Risk_Alert__c];

		Test.stopTest();

		System.assertEquals(0, alerts.size());
		System.assertEquals(400, RestContext.response.StatusCode);
		System.assert(result.description.contains('Required values missing'));

	}

	@isTest
	static void testDoPost() {
		List <Account> accountList = new List <Account> ([SELECT Id FROM Account LIMIT 1]);
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = 'TestCall';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';

		message.storedRHCValue = 0;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', 'TestCall');

		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/RME_ALERT_BALANCEUPDATE';
		req.httpMethod = 'POST';

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			ANG_RME_Alert_Service.doPost(accountList[0].Id);
		Test.stopTest();
	}

	@isTest
	static void rhcAlert100UpReceptionExceptionalMonitoringTest() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '912345678';
		message.eventId = String.valueOf(System.now());
		message.eventType = ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.thresholdLevel = ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100;
		message.direction = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [
			SELECT 
				Id, ANG_Threshold_Level__c, ANG_Direction__c 
			FROM ANG_Risk_Alert__c
		];

		System.assertEquals(202, RestContext.response.StatusCode, 'The response code must be 202');
		System.assertEquals(1, alerts.size(), 'The RHC Alert must be created');
		System.assertEquals(ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100, alerts[0].ANG_Threshold_Level__c, 'The threshold of the RHC Alert must be 100%');
		System.assertEquals(ANG_RHCHelper.RISK_ALERT_DIRECTION_UP, alerts[0].ANG_Direction__c, 'The direction of the RHC Alert must be UP');
	}

	@isTest
	static void rhcAlert100UpReceptionExceptionalMonitoringInvalidTest() {

		AMS_Settlement_System__c bspKZ = [
			SELECT 
				Id, RHC_Exceptional_Monitoring__c
			FROM AMS_Settlement_System__c
			WHERE Name = 'BSP-KZ'
			LIMIT 1
		];

		bspKZ.RHC_Exceptional_Monitoring__c = false;
		update bspKZ;

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '912345678';
		message.eventId = String.valueOf(System.now());
		message.eventType = ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.thresholdLevel = ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100;
		message.direction = ANG_RHCHelper.RISK_ALERT_DIRECTION_UP;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [
			SELECT 
				Id, ANG_Threshold_Level__c, ANG_Direction__c 
			FROM ANG_Risk_Alert__c
		];

		System.assertEquals(404, RestContext.response.StatusCode, 'The response code must be 404');
		System.assertEquals('Agent 912345678 does not have RHC set', result.description, 'The description must be \'Agent 912345678 does not have RHC set\'');
		System.assertEquals(0, alerts.size(), 'The RHC Alert must NOT be created');

	}

	@isTest
	static void rhcAlert100DownReceptionExceptionalMonitoringTest() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '912345678';
		message.eventId = String.valueOf(System.now());
		message.eventType = ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE;
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.thresholdLevel = ANG_RHCHelper.RISK_ALERT_THRESHOLD_LEVEL_100;
		message.direction = ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', ANG_RME_Alert_Service.RHC_ALERT_EVENT_TYPE);
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [
			SELECT 
				Id, ANG_Threshold_Level__c, ANG_Direction__c 
			FROM ANG_Risk_Alert__c
		];

		system.debug('DTULLO --> ' + string.valueOf(RestContext.response.responseBody));

		System.assertEquals(202, RestContext.response.StatusCode, 'The response code must be 202');
		System.assertEquals(0, alerts.size(), 'The RHC Alert must NOT be created');
	}

}
