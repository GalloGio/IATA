@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "ip": "83.240.229.11", "hostname": "No Hostname", "city": "Areeiro", "region": "Azores", "country": "PT", "loc": "38.7333,-27.1000", "org": "AS15525 MEO - SERVICOS DE COMUNICACOES E MULTIMEDIA S.A."}');

        res.setStatusCode(200);
        return res;
    }
}