global class ANG_RestServiceHelper {
    global static string Caller_GDI = 'GDI';
    global static string URIRequest_GDIOffer = 'gdi-create-offer';
    global static string URIRequest_AccountFiles = 'account-files';
    global static string URIRequest_AccountFinancialInfo = 'account-financial-info';
    global static string URIRequest_CaseDetails = 'payment-status';

    /* Generates the response */
    global static void GenerateResponse(string sBody, integer iStatusCode){
        RestResponse res = RestContext.response;
        res.statusCode = iStatusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(sBody);
    }


    /* ERROR Payload - Common to all request */
    global class ErrorPayload{
        global string sError;
        global string sMessage;
        
        global ErrorPayload(string sError, string sMessage){
            this.sError = sError;
            this.sMessage = sMessage;
        }
    }
}
