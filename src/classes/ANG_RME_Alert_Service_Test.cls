@isTest
public class ANG_RME_Alert_Service_Test {

	private static RestRequest req;

	static{
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

	@testSetup static void createData() {
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US', CurrencyIsoCode = 'USD');
		insert ctry;

		Account a = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = AMS_utils.RECTYPE_IATAAGENCY, IATACode__c='1234562',Location_Type__c= AMS_Utils.BR, Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT, Location_Class__c = AMS_Utils.LC_PASSENGER);
		insert a;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		createRMEMappings();
	}
	
	static testMethod void test_wrongJSON() {
		req.requestBody = Blob.valueOf('{"agencyCode":"somecode"}');
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		System.assertEquals(400, RestContext.response.StatusCode);
		System.assert(result.description.startsWith('Malformed request:'));
	}
	
	static testMethod void test_noAccount() {
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
	
	static testMethod void test_valueValidationError() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = 'RHCAlert';
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
	
	static testMethod void test_alert_success() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = 'RHCAlert';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.storedRHCValue = 0;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		message.thresholdLevel = '100%';
		message.direction = 'UP';

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', 'RHCAlert');
		RestContext.request = req;

		Test.startTest();

		ANG_RME_Alert_Service.RequestResult result = ANG_RME_Alert_Service.doPut().get('apiStatus');

		Test.stopTest();

		List<ANG_Risk_Alert__c> alerts = [SELECT Id, ANG_Threshold_Level__c, ANG_Direction__c FROM ANG_Risk_Alert__c];

		System.assertEquals(202, RestContext.response.StatusCode);
		System.assertEquals(1, alerts.size());
		System.assertEquals('100%', alerts[0].ANG_Threshold_Level__c);
		System.assertEquals('UP', alerts[0].ANG_Direction__c);
	}
	
	static testMethod void test_balance_success() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventId = 'AlertRequest';
		message.eventType = 'BalanceUpdate';
		message.schemaVersion = 2;
		message.eventTime = System.now();

		message.storedBaseCurrency = 'USD';
		message.storedRHCValue = 0;
		message.consumedRHCAmount = 200;
		message.consumedRHCPercentage = 0.5;

		req.requestBody = Blob.valueOf(JSON.serialize(message));
		req.params.put('eventType', 'BalanceUpdate');
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
	
	static testMethod void test_invaldidEvent() {
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
	
	static testMethod void webservice_sucess() {
		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();
		message.iataCode = '1234562';
		message.eventTime = System.now();
		message.storedRHCValue = 200;

		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		Test.startTest();

		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestProvisionalRHC([SELECT IATACode__c FROM Account][0].Id, false);

		Test.stopTest();

		System.assertEquals(message.iataCode, result.iataCode);
		System.assert(result.isSuccess);
	}
	
	static testMethod void webservice_error() {
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(400, 'There was an error'));

		Test.startTest();

		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate([SELECT IATACode__c FROM Account][0].Id);

		Test.stopTest();
        
		System.assertEquals('An unexpected error ocurred while contacting the external system. An incident has been raised on Service Now.', result.description);
		System.assert(!result.isSuccess);
	}
	
	static testMethod void webservice_exception() {
		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, 'Not a JSON'));

		Test.startTest();

		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate([SELECT IATACode__c FROM Account][0].Id);

		Test.stopTest();

		System.assert(!result.isSuccess);
	}
	static testMethod void testDoPost() {
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
}
