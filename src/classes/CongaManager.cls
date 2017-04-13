global class CongaManager {

    public class CongaMergeException extends Exception{}

    public static final String CONGA7_URL = 'https://www.appextremes.com/apps/Conga/PM.aspx'; //old version
	public static final String CONGA8_URL = 'https://composer.congamerge.com/composer8/index.html'; // version 8
	//public static final String SOAP_URL_290 = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/29.0/' + UserInfo.getOrganizationId();
    //public static final String SOAP_URL_290 = 'https://iata--biz--c.cs87.visual.force.com/services/Soap/u/29.0/00D8E0000000N1K';

    // dummy variable to test HTTP response
    public static System.HttpResponse TEST_RESPONSE;

    /**
        Provides a session Id valid to be used with Conga
        This method executed in a regular class returns a different session id not valid for Conga
    **/
    public static string getValidSessionId() {
        return UserInfo.getSessionId();
    }

    public static void sendMail(String apiSessionId, String apiServerURL, Id caseId, Id contactId, Id congaTemplate, Id emailTemplateId) {
        // create Conga merge URL
        PageReference pageref = new PageReference(CONGA7_URL);
        pageref.getParameters().put('sessionId', apiSessionId);
        pageref.getParameters().put('serverUrl', apiServerURL);
        pageref.getParameters().put('id', String.valueof(caseId).substring(0,15));
        pageref.getParameters().put('TemplateId', congaTemplate);
        pageref.getParameters().put('DefaultPDF', '1');
        //pageref.getParameters().put('OFN', 'file name');

        // send email
        pageref.getParameters().put('ds7', '12');
        pageref.getParameters().put('EmailTemplateId', emailTemplateId);
        pageref.getParameters().put('EmailToId', contactId);
        pageref.getParameters().put('EmailRelatedToId', String.valueof(caseId).substring(0,15));

        makeCall(pageref.getURL());
    }

    public static void attachFile( String apiSessionId, String apiServerURL, Id caseId, Id congaTemplate) {
        PageReference pageref = new PageReference(CONGA7_URL);
        pageref.getParameters().put('sessionId', apiSessionId);
        pageref.getParameters().put('serverUrl', apiServerURL);
        pageref.getParameters().put('id', String.valueof(caseId).substring(0,15));
        pageref.getParameters().put('TemplateId', congaTemplate);
        pageref.getParameters().put('DefaultPDF', '1');
        //pageref.getParameters().put('OFN', 'file name');

        // create attachment
        pageref.getParameters().put('ds7', '1');
        pageref.getParameters().put('sc0', '1');
        pageref.getParameters().put('sc1', 'Attachments');

        makeCall(pageref.getURL());
    }

    public static String sendEmailURL(String apiSessionId, String apiServerURL, Id caseId, Id emailRelatedCaseId, Id contactId, Id congaTemplate, Id emailTemplateId, String OrgWideDefaultsId,list<String> listQueries) {
        //String url = CONGA8_URL;
        String url = CONGA8_URL + '?sessionId=' + apiSessionId;
        url += '&serverUrl=' + apiServerURL;
        url += '&id=' + String.valueof(caseId).substring(0,15);
        url += '&TemplateId=' + congaTemplate;
        url += '&DefaultPDF=1';
        //url +='OFN=[file name]';

        // send email
        url += '&ds7=2'; //returns automatically to send mail SF page
        if (emailTemplateId!=null) {
            url += '&EmailTemplateId=' + emailTemplateId;
        }
        url += '&EmailFromID=' + OrgWideDefaultsId;
        url += '&EmailToId=' + contactId;
        url += '&EmailRelatedToId=' + String.valueof(emailRelatedCaseId).substring(0,15);
        url += '&SC0=1';
        url += '&SC1=Attachments';

        if (listQueries!=null && !listQueries.isEmpty()) {
            url += '&QueryId=' + String.join(listQueries,',');
        }
        return url;
    }


    public static String goToSendEmailConga(String apiSessionId, String apiServerURL, Id caseId, Id emailRelatedCaseId, Id contactId, String OrgWideDefaultsId,list<String> listQueries) {
        PageReference pageref = new PageReference(CONGA8_URL);
        pageref.getParameters().put('sessionId', apiSessionId);
        pageref.getParameters().put('serverUrl', apiServerURL);
        pageref.getParameters().put('id', String.valueof(caseId).substring(0,15));
        pageref.getParameters().put('DefaultPDF', '1');

        // create attachment
        pageref.getParameters().put('ds7', '0');
        pageref.getParameters().put('EmailFromID', OrgWideDefaultsId);
        pageref.getParameters().put('EmailToId', contactId);
        pageref.getParameters().put('EmailRelatedToId', String.valueof(emailRelatedCaseId).substring(0,15));
        pageref.getParameters().put('SC0', '1');
        pageref.getParameters().put('SC1', 'Attachments');
        String url = pageref.getURL();
        if (listQueries!=null && !listQueries.isEmpty()) {
            url += '&QueryId=' + String.join(listQueries,',');
        }

        return url;
    }

    /**
        make a http call to with given url to Conga Merge server
    **/
    private static void makeCall(String url) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setTimeout(120000);
            System.HttpResponse result = Test.isRunningTest()? TEST_RESPONSE: new Http().send(req);
            System.debug('CongaMerge result: ' + result);
            if (result.getStatusCode()!=200) {
                throw new CongaMergeException(result.toString());
            }

        } catch (Exception e) {
            System.debug('**CongaMerge makeCall ' + e.getMessage());
            throw new CongaMergeException(e.getMessage());
        }
    }
}
