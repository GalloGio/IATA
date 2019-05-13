@IsTest
public class PowerBI_Embedded_Dashboard_CTRL_TEST {


    class PowerBi_Mockup implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"Bearer","scope":"Content.Create Dashboard.Read.All Data.Alter_Any Dataset.Read.All Dataset.ReadWrite.All Group.Read Group.Read.All Metadata.View_Any Report.Read.All","expires_in":"3599","ext_expires_in":"0","expires_on":"1482242395","not_before":"1482238495","resource":"https://analysis.windows.net/powerbi/api","access_token":"accessToken","refresh_token":"refreshToken","id_token":"idToken"}');
        res.setStatusCode(200);
        return res;
    }
}

    @TestSetup
    private static void setup() {

    }



}