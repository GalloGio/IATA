@isTest
global class IpinfoioMockImpl implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://ipinfo.io/92.104.157.175/json?token=871e08ecd39325', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create IpInfo.io fakse response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse());
        res.setStatusCode(200);
        return res;
    }
    
    private String mockResponse() {
		String resp = '';
		resp += '{';
			resp += '"ip": "92.104.157.175",';
        	resp += '"hostname": "175.157.104.92.dynamic.wline.res.cust.swisscom.ch",';
        	resp += '"city": "Peseux",';
        	resp += '"region": "Neuchâtel",';
        	resp += '"country": "CH",';
        	resp += '"loc": "46.9870,6.8890",';
        	resp += '"postal": "2034",';
        	resp += '"org": "AS3303 Swisscom (Switzerland) Ltd"';
		resp += '}';
		return resp;
    }
    
}