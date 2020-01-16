@IsTest
public with sharing class PowerBICalloutMockProvider implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {

        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-type', 'application/json');
        if(req.getEndpoint().contains('/oauth2/token')){
            String body = '{"access_token":"testTokenString","refresh_token":"refreshTokenString","expires_on":1561019267}';
            res.setBody(body);
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/myorg/datasets/')){
            String body = '{"id": "datasetid", "name": "datasetname", "isRefreshable": "true", "isEffectiveIdentityRequired": "true", "isEffectiveIdentityRolesRequired" : "true"}';
            res.setBody(body);
            res.setStatusCode(200);
        } else if(req.getEndpoint().contains('/myorg/reports/')){
            String body = '{"id": "reportid", "name": "reportname", "weburl" : "www.weburl.org", "embedUrl" : "embed/url", "datasetId" : "someDatasetId"}';
            res.setBody(body);
            res.setStatusCode(200);
        } else if(req.getEndpoint().contains('GenerateToken')) {
            String body = '{"token": "someToken", "tokenId" : "someTokenId", "expiration" : "1561019567"}';
            res.setBody(body);
            res.setStatusCode(200);
        }

        return res;
    }

    public class PowerBIexpierdTokenMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if (req.getEndpoint().contains('/oauth2/token')) {
                Long expireTime = (System.currentTimeMillis()/1000) + 3600;
                String body = '{"access_token":"testTokenString","refresh_token":"refreshTokenString","expires_on":'+ expireTime + '}';
                res.setBody(body);
                res.setStatusCode(200);
            }

            return res;
        }
    }


    public class PowerBItokenErrorMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if (req.getEndpoint().contains('/oauth2/token')) {
                Long expireTime = (System.currentTimeMillis()/1000) + 3600;
                String body = '{"error": "user_password_expired","access_token":"testTokenString","refresh_token":"refreshTokenString","expires_on":'+ expireTime + '}';
                res.setBody(body);
                res.setStatusCode(400);
            }

            return res;
        }
    }


    public class PowerBIServicePrincipalAccessErrorMock implements HttpCalloutMock {


        public HttpResponse respond(HttpRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if (req.getEndpoint().contains('/oauth2/token')) {
                String body = '{"error": "No HTTP resource was found that matches the request URI."}';
                res.setBody(body);
                res.setStatusCode(400);
            }

            return res;
        }
    }

    public class PowerBIServicePrincipalEmbedTokenErrorMock implements HttpCalloutMock {


        public HttpResponse respond(HttpRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            if (req.getEndpoint().contains('GenerateToken')) {
                Datetime expires = Datetime.now().addMinutes(60);
                String body = '{"error": {"code":"404", "message":"No HTTP resource was found that matches the request URI."}}';
                res.setBody(body);
                res.setStatusCode(400);
            }

            return res;
        }
    }
}

