@isTest
public with sharing class ISSP_LoginTestHttpCallout {
	@isTest(seeAllData=true)
	public static void testMockout() {   
        
		// Set the mock response
		Integer code = 200;
		String status = 'ok';
		String body = '{"country":"CH"}';
		Map<String, String> responseHeaders = new Map<String,String>();
		responseHeaders.put('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, new ISSP_MockHttpResponseGenerator(code, status, body, responseHeaders));

        ISSP_Login ctrl = new ISSP_Login();
        //ctrl.ipAddress = '10.10.10.10';
        ctrl.findLocationCaller();

		ISSP_Registration regCtrl = new ISSP_Registration();
		
        regCtrl.findLocation(); 

	} 
    @isTest(seeAllData=true)
    public static void testMockout2() { 
		// Set the mock response
		Integer code = 200;
		String status = 'ok';
		String body = '{"country":""}';
		Map<String, String> responseHeaders = new Map<String,String>();
		responseHeaders.put('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, new ISSP_MockHttpResponseGenerator(code, status, body, responseHeaders));
        ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP','10.10.10.10');
        ISSP_Login ctrl = new ISSP_Login();
        
        
        ctrl.findLocationCaller();

		ISSP_Registration regCtrl = new ISSP_Registration();
		regCtrl.findLocation();

	}
}