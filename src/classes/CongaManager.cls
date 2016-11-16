public with sharing class CongaManager {

    public class CongaMergeException extends Exception{}

    public static final String CONGA7_URL = 'https://www.appextremes.com/apps/Conga/PM.aspx'; //old version
	public static final String CONGA8_URL = 'https://composer.congamerge.com/composer8/index.html'; // version 8
	public static final String SOAP_URL_290 = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/29.0/' + UserInfo.getOrganizationId();

    public static void sendMail(String sessionId, Id caseId, Id contactId, Id congaTemplate, Id emailTemplateId) {
        // create Conga merge URL
        PageReference pageref = new PageReference(CONGA7_URL);
        pageref.getParameters().put('sessionId', sessionId);
        pageref.getParameters().put('serverUrl', SOAP_URL_290);
        pageref.getParameters().put('id', caseId);
        pageref.getParameters().put('TemplateId', congaTemplate);
        pageref.getParameters().put('DefaultPDF', '1');
        //pageref.getParameters().put('OFN', 'file name');

        // send email
        pageref.getParameters().put('ds7', '12');
        pageref.getParameters().put('EmailTemplateId', emailTemplateId);
        pageref.getParameters().put('EmailToId', contactId);
        pageref.getParameters().put('EmailRelatedToId', caseId);

        makeCall(pageref.getURL());
    }

    public static void attachFile(String sessionId, Id caseId, Id congaTemplate) {
        PageReference pageref = new PageReference(CONGA7_URL);
        pageref.getParameters().put('sessionId', sessionId);
        pageref.getParameters().put('serverUrl', SOAP_URL_290);
        pageref.getParameters().put('id', caseId);
        pageref.getParameters().put('TemplateId', congaTemplate);
        pageref.getParameters().put('DefaultPDF', '1');
        //pageref.getParameters().put('OFN', 'file name');

        // create attachment
        pageref.getParameters().put('ds7', '1');
        pageref.getParameters().put('sc0', '1');
        pageref.getParameters().put('sc1', 'Attachments');

        makeCall(pageref.getURL());
    }

    public static String sendEmailURL(String sessionId, Id caseId, Id contactId, Id congaTemplate, Id emailTemplateId, String OrgWideDefaultsId) {
        PageReference pageref = new PageReference(CONGA8_URL);
        pageref.getParameters().put('sessionId', sessionId);
        pageref.getParameters().put('serverUrl', SOAP_URL_290);
        pageref.getParameters().put('id', caseId);
        pageref.getParameters().put('TemplateId', congaTemplate);
        pageref.getParameters().put('DefaultPDF', '1');
        //pageref.getParameters().put('OFN', 'file name');

        // send email
        pageref.getParameters().put('ds7', '2'); //returns automatically to send mail SF page
        pageref.getParameters().put('EmailTemplateId', emailTemplateId);
        pageref.getParameters().put('EmailFromID', OrgWideDefaultsId);
        pageref.getParameters().put('EmailToId', contactId);
        pageref.getParameters().put('EmailRelatedToId', caseId);
        return pageref.getURL();
    }


    public static String goToSendEmailConga(String sessionId, Id caseId, Id contactId, String OrgWideDefaultsId) {
        PageReference pageref = new PageReference(CONGA8_URL);
        pageref.getParameters().put('sessionId', sessionId);
        pageref.getParameters().put('serverUrl', SOAP_URL_290);
        pageref.getParameters().put('id', caseId);
        pageref.getParameters().put('DefaultPDF', '1');

        // send email
        pageref.getParameters().put('ds7', '0'); //not automated, shows conga window
        pageref.getParameters().put('EmailFromID', OrgWideDefaultsId);
        pageref.getParameters().put('EmailToId', contactId);
        pageref.getParameters().put('EmailRelatedToId', caseId);
        return pageref.getURL();
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
            System.HttpResponse result = new Http().send(req);
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