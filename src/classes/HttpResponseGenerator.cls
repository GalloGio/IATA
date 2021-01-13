@isTest
public class HttpResponseGenerator implements HttpCalloutMock {

    // potentially set by the caller / user
    public String nextBody;
    public Integer nextStatusCode;

    // returned / set by respond(), to be used in assertions
    public HttpRequest lastRequest;
    public HttpRequest firstRequest;

    private static Integer DEFAULT_STATUS = 200;

    public HttpResponseGenerator() {
        this(DEFAULT_STATUS);
    }

    public HttpResponseGenerator(Integer statusCode) {
        this(statusCode, '');
    }

    public HttpResponseGenerator(String body) {
        this(DEFAULT_STATUS, body);
    }

    public HttpResponseGenerator(Integer statusCode, String body) {
        this.nextBody = body;
        this.nextStatusCode = statusCode;
    }

    public HttpResponse respond(HttpRequest req) {
        if (this.firstRequest == null) this.firstRequest = req;
        this.lastRequest = req;
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.nextStatusCode);
        res.setBody(this.nextBody);
        
        return res;
    }
}