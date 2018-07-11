@isTest
public class ServiceNow_Helper_test {
	
	@isTest
	public static void test(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
		Test.stopTest();
	} 

	
	public class MockHttpResponseGenerator implements HttpCalloutMock {
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"foo":"bar"}');
	        res.setStatusCode(200);
	        return res;
	    }
	}
}