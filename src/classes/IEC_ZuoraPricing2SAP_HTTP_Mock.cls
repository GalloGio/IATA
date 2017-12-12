@isTest
global class IEC_ZuoraPricing2SAP_HTTP_Mock implements HttpCalloutMock {
    //****************************************************************************************************
    //  Mock callout to use in class "IEC_ZuoraPricing2SAP_Svc_Test"
    //****************************************************************************************************


    global HTTPResponse respond(HTTPRequest httpReq)
    {
        HTTPResponse httpResp = new HttpResponse();
        IEC_ZuoraPricing2SAP_Svc svc = new IEC_ZuoraPricing2SAP_Svc();
        if (httpReq.getBody().containsIgnoreCase('<Action>' + svc.sapOperation.get(IEC_ZuoraPricing2SAP_Svc.sapOT.DEL) + '</Action>'))
        {
            httpResp.setStatus('failure');
            httpResp.setStatusCode(500);
        }
        else
        {
            httpResp.setStatus('success');
            httpResp.setStatusCode(200);
        }
        httpResp.setBody(httpReq.getBody());
        return httpResp;
    }
}