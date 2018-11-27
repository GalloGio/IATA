global class ANG_RestServiceHelper {
    global static string Caller_GDI = 'GDI';
    global static string URIRequest_GDIOffer = 'gdi-create-offer';
    global static string URIRequest_AccountFiles = 'account-files';
    global static string URIRequest_AccountFinancialInfo = 'account-financial-info';

    //The following piece of code is to overcome a limit with switch in salesforce. It can't use string
    global enum Callers {GDI}
    global enum URIRequests {GDICREATEOFFER, ACCOUNTFILES, ACCOUNFFINANCIALINFO}

    global static map<string,Callers> mapEnumCaller = new map<string,Callers>{Caller_GDI => Callers.GDI};

    global static map<string,URIRequests> mapEnumURIRequest = new map<string,URIRequests>{URIRequest_GDIOffer => URIRequests.GDICREATEOFFER,
                                                                            URIRequest_AccountFiles => URIRequests.ACCOUNTFILES,
                                                                            URIRequest_AccountFinancialInfo => URIRequests.ACCOUNFFINANCIALINFO};

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
