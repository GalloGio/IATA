@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
//      res.setBody('{"foo":"bar"}');
        //res.setBody('{ "ip": "101.23.4.123", "hostname": "No Hostname", "city": "Hebei", "region": "Hebei", "country": "CN", "loc": "39.8897,115.2750", "org": "AS4837 CNCGROUP China169 Backbone"}');
        res.setBody('{ "ip": "83.240.229.11", "hostname": "No Hostname", "city": "Areeiro", "region": "Azores", "country": "PT", "loc": "38.7333,-27.1000", "org": "AS15525 MEO - SERVICOS DE COMUNICACOES E MULTIMEDIA S.A."}');

        res.setStatusCode(200);
        return res;
    }
}