@isTest
private class WebserviceTableController_test{
	static final string ENDPOINT='endpoint.com';
	static final string METHODPATH='\\path\\method';
	static final string MESSAGE_BODY='{message:This is the body}';
	static final string EXCEPTION_MESSAGE='Invalid Endpoint!';

	public class MockHttpResponse implements HttpCalloutMock {
		private integer status;
		private boolean generateException;
		public MockHttpResponse(integer st,boolean genEx){
			this.status=st;
			this.generateException=genEx;
		}

		public HTTPResponse respond(HTTPRequest req) {
			
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(this.status);
			res.setBody(WebserviceTableController_test.MESSAGE_BODY);

			if(this.generateException){
				CalloutException e = (CalloutException)CalloutException.class.newInstance();
		        e.setMessage(WebserviceTableController_test.EXCEPTION_MESSAGE);
		        throw e;

			}
			return res;
		}
	}

	@testSetup static void setupdata(){

	}
	
	static testmethod void accessWebserviceWithSuccess(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(200,false) );
		Test.startTest();
		String result=WebserviceTableController.getJSON(ENDPOINT,METHODPATH,200);
		Test.stopTest();
		system.assertEquals(result,MESSAGE_BODY);

	} 

	
	static testmethod void accessWebserviceWithoutFail(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(201,false) );
		Test.startTest();
		String result=WebserviceTableController.getJSON(ENDPOINT,METHODPATH,200);
		Test.stopTest();
		system.assertEquals(result,null);
		
	}

	static testmethod void accessWebserviceException(){

		Test.setMock(HttpCalloutMock.class,new MockHttpResponse(201,true) );
		
		try{
			Test.startTest();			
			string result=WebserviceTableController.getJSON(ENDPOINT,METHODPATH,201);
			Test.stopTest();
		}catch(Exception e){
			system.assertEquals(e.getMessage(),EXCEPTION_MESSAGE);
			
		}
		
	} 


}