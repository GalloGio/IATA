//Tested in production

public class IECEBC_ETTriggeredSendDefinitionCreate {
    class UnexpectedResponse_Exception extends Exception{}
    
    Public static void createTriggeredSendDefinition(String mailingId, String templateId, String senderProfileCustomerKey, String objectId) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        string bodyContent =
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Options/>'
            +'<Objects xsi:type="TriggeredSendDefinition">'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(mailingId) +'</CustomerKey>'
            +'<Name>'+ IECEBC_ETHelper.xmlEncode(mailingId) +'</Name>'
            +'<SendClassification>'
            +'<ObjectID>'+ IECEBC_ETHelper.xmlEncode(objectId) +'</ObjectID>'
            +'<SenderProfile>'
            +'<ObjectID xsi:nil="true"/>'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(senderProfileCustomerKey) +'</CustomerKey>'
            +'</SenderProfile>'
            +'</SendClassification>'
            +'<IsWrapped>true</IsWrapped>'
            +'<Email>'
            +'<ID>'+ IECEBC_ETHelper.xmlEncode(templateId) +'</ID>'
            +'<ObjectID xsi:nil="true"/>'
            +'</Email>'
            +'<IsMultipart>true</IsMultipart>'
            +'<AutoAddSubscribers>false</AutoAddSubscribers>'
            +'</Objects>'
            +' </CreateRequest>';
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
          
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            system.debug('Create Triggered Send Email: ' + res.getBody());
           
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                throw new UnexpectedResponse_Exception('Unexpected Response');
            }
        } else {
            System.debug(res);
            System.debug(res.getBody());
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }        
    }    
    
    public static String accountName = 'Agent16h55Aug24';
    public static String triggeredParam = accountName + '_Test';
    
    
    Public static void createTriggeredSendDefinition(String templateId, String contactType, String campaignName) {
        
        system.debug('Account Name ' + triggeredParam);
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        string bodyContent =
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Options/>'
            +'<Objects xsi:type="TriggeredSendDefinition">'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(triggeredParam) +'</CustomerKey>'
            +'<Name>'+ IECEBC_ETHelper.xmlEncode(triggeredParam) +'</Name>'
            +'<SendClassification>'
            +'<ObjectID>82684d06-ff62-e611-8844-0025b3d7f36a</ObjectID>'
            +'<SenderProfile>'
            +'<ObjectID xsi:nil="true"/>'
            +'<CustomerKey>10691121</CustomerKey>'
            +'</SenderProfile>'
            +'</SendClassification>'
            +'<Email>'
            +'<ID>'+ IECEBC_ETHelper.xmlEncode(templateId) +'</ID>'
            +'<ObjectID xsi:nil="true"/>'
            +'</Email>'
            +'<IsMultipart>true</IsMultipart>'
            +'<AutoAddSubscribers>false</AutoAddSubscribers>'
            +'</Objects>'
            +' </CreateRequest>';
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
          
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            system.debug('Create Triggered Send Email: ' + res.getBody());
            String objectTSD_ID = '';
            objectTSD_ID = IECEBC_ETHelper.parse(res, 'ObjectID'); 
            
            IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition( triggeredParam , contactType, campaignName, objectTSD_ID);  
            
        }        
    }    
}