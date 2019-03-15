global class HigherLogicServiceMock implements HttpCalloutMock {

	global HTTPResponse respond(HTTPRequest req) {

		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"success":true,"count":1}');
		res.setStatusCode(200);
		
		return res;

	}
	
}