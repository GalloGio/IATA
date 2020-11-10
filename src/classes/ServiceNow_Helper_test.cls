@isTest
public class ServiceNow_Helper_test {

	@testSetup
	public static void createSettings(){

		//mulesoft
		ISSP_Int_Error__c settingMS  = new ISSP_Int_Error__c(
			Name = 'JSD1',
			Business_Service__c = 'Mulesoft',
			Caused_By__c = 'Mulesoft',
			Impact__c = '2',
			Short_Description__c = ''
		);

		//RME
		ISSP_Int_Error__c settingRME  = new ISSP_Int_Error__c(
			Name = 'JSD3',
			Business_Service__c = 'RME',
			Caused_By__c = 'Mulesoft',
			Impact__c = '2',
			Short_Description__c = ''
		);

		//SFDC
		ISSP_Int_Error__c settingSFDC  = new ISSP_Int_Error__c(
			Name = 'JSD10',
			Business_Service__c = 'SFDC',
			Caused_By__c = 'Salesforce',
			Impact__c = '2',
			Short_Description__c = 'Downgrade of Risk Status - SAAM creation failed'
		);

		List<ISSP_Int_Error__c> settings = new List<ISSP_Int_Error__c>{settingMS,settingRME,settingSFDC};
		insert settings;
	}

	@isTest
	public static void responsePassed(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPassed());
		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c(Error_Code__c = 'Iata Code Mismatch');
		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.testWebserviceResult();
		ServiceNow_Helper.sendRequestToSNOWRME('JSD3', '12345678', log, result);
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert(logs[0].Success__c, 'Log should be true');
	}

	@isTest
	public static void responseFailed(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailed());
		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c(Error_Code__c = 'Exception sending request', Error_Message__c = 'test Error Message');
		ServiceNow_Helper.sendRequestToSNOWMulesoft('JSD1', '12345678', log);
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert((!logs[0].Success__c), 'Log should be false');
	}

	@isTest
	public static void noResponse(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNoResponse());
		try{
			CalloutException ce = new CalloutException();
			ce.setMessage('test Exception');
			throw ce;
		}catch(Exception e){
			ServiceNow_Helper.sendRequestToSNOWSFDC('JSD10', e, null);
		}
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert((!logs[0].Success__c), 'Log should be false');
	}

	public class MockHttpResponseGeneratorPassed implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			return res;
		}
	}

	public class MockHttpResponseGeneratorFailed implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(400);
			return res;
		}
	}

	public class MockHttpResponseGeneratorNoResponse implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
		   CalloutException e = (CalloutException)CalloutException.class.newInstance();
			e.setMessage('TESTING ERROR. Creating log accordingly');
			throw e;
		}
	}
}
