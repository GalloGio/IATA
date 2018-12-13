@isTest
global class AMP_MockHttpResponseGenerator implements HttpCalloutMock {
	 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://news.google.com/_/rss/search?cf=all&pz=1&q=test&hl=en-US&gl=US&ceid=US:en', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<rss version="2.0"><channel><item><title>test</title><link></link><pubDate>Tue, 16 Aug 2016 05:19:04 GMT</pubDate><description></description></item></channel></rss>');
        res.setStatusCode(200);
        return res;
    }
}