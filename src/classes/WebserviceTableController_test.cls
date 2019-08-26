@isTest
private class WebserviceTableController_test{
	static final String ENDPOINT='endpoint.com';
	static final String METHOD='POST';
	static final String MESSAGE_BODY='{message:This is the body}';

	public class MockHttpResponse implements HttpCalloutMock {
		private Integer status;

		public MockHttpResponse(Integer st){
			this.status=st;
		}

		public HTTPResponse respond(HTTPRequest req) {
			
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(this.status);
			res.setBody(WebserviceTableController_test.MESSAGE_BODY);

			return res;
		}
	}

	static testMethod void defaultHandlerSuccess(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(200));

		Test.startTest();
		String result = WebserviceTableController.getJSON(null, ENDPOINT,METHOD, '{"request":"success"');
		Test.stopTest();
		
		System.assertEquals(result,MESSAGE_BODY);
	} 

	static testMethod void DefaultHandlerException(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(500));
		
		Test.startTest();	
		try{		
			String result=WebserviceTableController.getJSON(null, ENDPOINT,METHOD, '{"request":"exception"');
		}catch(Exception e){
			System.assertEquals('System.AuraHandledException', e.getTypeName());
			
		}
		Test.stopTest();
	} 

	
	static testMethod void DataPrivacyNotFound(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(404));

		Test.startTest();
		String result=WebserviceTableController.getJSON('WebserviceTableController.DataPrivacy', ENDPOINT,METHOD, '{"request":"not found"');
		Test.stopTest();

		System.assertEquals('[]', result, 'Result should be an empty array');
	}

	static testMethod void DataPrivacyException(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(201));
		
		Test.startTest();
		try{			
			WebserviceTableController.getJSON('WebserviceTableController.DataPrivacy', ENDPOINT, METHOD, '{"request":"exception"');
		}catch(Exception e){
			System.assertEquals('System.AuraHandledException', e.getTypeName());
		}
		
		Test.stopTest();
	} 
}