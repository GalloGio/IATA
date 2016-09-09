public class IECEBC_ETTriggeredSendDefinitionStart {
    class UnexpectedResponse_Exception extends Exception{}
    
    public static void updateTriggeredSendDefinition(String TriggeredParam) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        system.debug('le triggered Name est '+ TriggeredParam);
        string bodyContent =
            '<UpdateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Objects xsi:type="TriggeredSendDefinition">'
            +'<ObjectID xsi:nil="true"/>'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(TriggeredParam) +'</CustomerKey>'
            +'<TriggeredSendStatus>Active</TriggeredSendStatus>'
            +'</Objects>'
            +'</UpdateRequest>';
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Update', bodyContent);
        
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) { 
            system.debug('Start Triggered Send Email: ' + res.getBody());
            system.debug('Triggered Send Definition activated ' );
            
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                throw new UnexpectedResponse_Exception('Unexpected Response');
            }
        }else{
            System.debug(res);
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }       

    }
    
    public static void updateTriggeredSendDefinition( String TriggeredParam, String contactType, String campaignName, String objectTSD_ID)  {        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        system.debug('le triggered Name est '+ TriggeredParam);
        string bodyContent =
            '<UpdateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Objects xsi:type="TriggeredSendDefinition">'
            +'<ObjectID xsi:nil="true"/>'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(TriggeredParam) +'</CustomerKey>'
            +'<TriggeredSendStatus>Active</TriggeredSendStatus>'
            +'</Objects>'
            +'</UpdateRequest>';
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Update', bodyContent);
        
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) { 
            system.debug('Start Triggered Send Email: ' + res.getBody());
            IECEBC_ETEmailSend.sendEmails(contactType, TriggeredParam, campaignName,objectTSD_ID);
            system.debug('Triggered Send Definition activated ' );
        }else{
            system.debug('This is a bad request, can not activate Triggered send!');
        }      
    }
}