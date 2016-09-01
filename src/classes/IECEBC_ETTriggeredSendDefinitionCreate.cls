public class IECEBC_ETTriggeredSendDefinitionCreate {
    class UnexpectedResponse_Exception extends Exception{}
    
    Public static void createTriggeredSendDefinition(String mailingId, String templateId, String customerKey, String objectId) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        string bodyContent =
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Options/>'
            +'<Objects xsi:type="TriggeredSendDefinition">'
            +'<CustomerKey>'+ mailingId +'</CustomerKey>'
            +'<Name>'+ mailingId +'</Name>'
            +'<SendClassification>'
            +'<ObjectID>'+objectId+'</ObjectID>'
            +'<SenderProfile>'
            +'<ObjectID xsi:nil="true"/>'
            +'<CustomerKey>'+customerKey+'</CustomerKey>'
            +'</SenderProfile>'
            +'</SendClassification>'
            +'<Email>'
            +'<ID>'+ templateId +'</ID>'
            +'<ObjectID xsi:nil="true"/>'
            +'</Email>'
            +'<IsMultipart>true</IsMultipart>'
            +'<AutoAddSubscribers>false</AutoAddSubscribers>'
            +'</Objects>'
            +' </CreateRequest>';
        
        req.setTimeout(60000);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
          
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            system.debug('Create Triggered Send Email: ' + res.getBody());
            //system.debug('Triggered Send ObjectId: '+ objectTSD_ID);
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                throw new UnexpectedResponse_Exception('Unexpected Response');
            }
        } else {
            System.debug(res);
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }        
    }    
    
    public static String accountName = 'Agent16h55Aug24';
    public static String triggeredParam = accountName + '_Test';
    
    Public static void createTriggeredSendDefinition(String templateId, String contactType, String campaignName)
    {
        
        system.debug('Account Name ' + triggeredParam);
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        string bodyContent =
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Options/>'
            +'<Objects xsi:type="TriggeredSendDefinition">'
            +'<CustomerKey>'+ triggeredParam +'</CustomerKey>'
            +'<Name>'+ triggeredParam +'</Name>'
            +'<SendClassification>'
            +'<ObjectID>82684d06-ff62-e611-8844-0025b3d7f36a</ObjectID>'
            +'<SenderProfile>'
            +'<ObjectID xsi:nil="true"/>'
            +'<CustomerKey>10691121</CustomerKey>'
            +'</SenderProfile>'
            +'</SendClassification>'
            +'<Email>'
            +'<ID>'+ templateId +'</ID>'
            +'<ObjectID xsi:nil="true"/>'
            +'</Email>'
            +'<IsMultipart>true</IsMultipart>'
            +'<AutoAddSubscribers>false</AutoAddSubscribers>'
            +'</Objects>'
            +' </CreateRequest>';
        
        req.setTimeout(60000);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
          
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            system.debug('Create Triggered Send Email: ' + res.getBody());
            String objectTSD_ID = '';
            objectTSD_ID = IECEBC_ETHelper.parse(res, 'ObjectID'); 
            //system.debug('Triggered Send ObjectId: '+ objectTSD_ID);
            IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition( triggeredParam , contactType, campaignName, objectTSD_ID);  
            
        }        
    }    
}