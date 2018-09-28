@isTest
public class ServiceNow_Helper_test {
	
	@isTest
	public static void responsePassed(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPassed());
        ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert(logs[0].Success__c, 'Log should be true');
	} 
    
    @isTest
	public static void responseFailed(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailed());
        ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert((!logs[0].Success__c), 'Log should be false');
	}

	@isTest
	public static void noResponse(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNoResponse());
        ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
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