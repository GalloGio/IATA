global class IECEBC_ETSubscriberCreateAsync {
    class UnexpectedResponse_Exception extends Exception{}
    
    public class Recipient {
        public String Key;
        public String EmailAddress;
        public Map<String, String> Attributes {
            get {
                if (Attributes == null) Attributes = new Map<String, String>();
                return Attributes;
            }
            set;
        }
    }
    
    public static void addRecipientsToList(String ListId, List<Recipient> recipients) {
        // http instances and string variables
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String tags ='';
        String tagsList ='';      
        
        tagsList +='<Lists>'
            + '<PartnerKey xsi:nil="true" />'
            +'<ID>'+ListId+'</ID>'
            +'<ObjectID xsi:nil="true" />'
            +'</Lists>';
        
        // Build subscriber object for Agent (XML tag will be used in SOAP API)
        for(Recipient r : recipients)
        { 
            tags +='<Objects xsi:type="Subscriber">'+
                tagsList 
                +   '<ObjectID xsi:nil="true"> </ObjectID>'
                +'<EmailAddress>'+IECEBC_ETHelper.xmlEncode(r.EmailAddress)+'</EmailAddress>'
                +'<SubscriberKey>'+IECEBC_ETHelper.xmlEncode(r.Key)+'</SubscriberKey>';
            if (!r.Attributes.isEmpty()) {
                for(String key : r.Attributes.keySet()) {
                    
                    tags +='<Attributes>'
                        +'<Name>'+IECEBC_ETHelper.xmlEncode(key)+'</Name>'
                        
                        +'<Value>'+IECEBC_ETHelper.xmlEncode(r.Attributes.get(key))+'</Value>'
                        +'</Attributes>';
                }
            }
            tags +='<PartnerKey xsi:nil="true"/>'
                +'</Objects>';
        }
        
        
        String bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+      
            tags +
           '</CreateRequest>';
        
        req.setTimeout(100000);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);

        system.debug('Body create subscribers: ' + req.getBody());
        
        HttpResponse res = http.send(req);
        string bodyRes = '';
        bodyRes = res.getBody();
        system.debug('Subscribers SoapResponse:' + bodyRes);
        if (res.getStatusCode() == 200) {             
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                throw new UnexpectedResponse_Exception('Unexpected Response');
            }
        } else {
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }
    }
    
    // This method is no more needed
    @Future(callout=true)
    public static void createSubscribers(String campaignName,String contactType,Id emailTempId)
    {
        // http instances and string variables
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String tags ='';
        String tagsList ='';      
        
        if (contactType == 'Agent'){
            List<ID_Card__c> subscribers = IECEBC_ETAgentAgencyRetrieve.GetAgents();
            if (subscribers.size() > 1){
                String ListName = campaignName;
                String IdList = IECEBC_ETListCreate.createList(ListName);
                tagsList +='<Lists>'
                    + '<PartnerKey xsi:nil="true" />'
                    +'<ID>'+IdList+'</ID>'
                    +'<ObjectID xsi:nil="true" />'
                    +'</Lists>';
            }
            
            // Build subscriber object for Agent (XML tag will be used in SOAP API)
            for(ID_Card__c a : subscribers)
            { 
                String sId= a.id;
                String sEmail= a.email__c; 
                tags +='<Objects xsi:type="Subscriber">'+
                    tagsList 
                    +   '<ObjectID xsi:nil="true"> </ObjectID>'
                    +'<EmailAddress>'+sEmail+'</EmailAddress>'
                    +'<SubscriberKey>'+sEmail+'</SubscriberKey>'
                    +'<Attributes>'
                    +'<Name>ExternalId</Name>'
                    +'<Value>'+sId+'</Value>'
                    +'</Attributes>'
                    +'<PartnerKey xsi:nil="true"/>'
                    +'</Objects>';
            }
        }
        else {
            List<GDP_Products_Account_View__c> subscribers = IECEBC_ETAgentAgencyRetrieve.GetAgencies();
            
            if (subscribers.size() > 1){
                String ListName = 'Agencies list for '+ campaignName;
                String IdList = IECEBC_ETListCreate.createList(ListName);
                tagsList +='<Lists>'
                    + '<PartnerKey xsi:nil="true" />'
                    +'<ID>'+IdList+'</ID>'
                    +'<ObjectID xsi:nil="true" />'
                    +'</Lists>';
            }
            //build subscriber object for Agency (XML tag will be used in SOAP API)
            for(GDP_Products_Account_View__c a : subscribers)
            { 
                String sId= a.id; 
                String sEmail= a.Email_Address__c; 
                tags +='<Objects xsi:type="Subscriber">'
                    +tagsList
                    +'<ObjectID xsi:nil="true"> </ObjectID>'
                    +'<EmailAddress>'+ sEmail +'</EmailAddress>'
                    +'<SubscriberKey>'+ sEmail +'</SubscriberKey>'
                    +'<Attributes>'
                    +'<Name>ExternalId</Name>'
                    +'<Value>'+sId+'</Value>'
                    +'</Attributes>'
                    +'<PartnerKey xsi:nil="true"/>'
                    +'</Objects>';
            }
            
        }
        
        String bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+      
            tags +
           '</CreateRequest>';
        
        req.setTimeout(100000);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);

        system.debug('Body create subscribers: ' + req.getBody());
        
        HttpResponse res = http.send(req);
        string bodyRes = '';
        bodyRes = res.getBody();
        system.debug('Subscribers SoapResponse:' + bodyRes);
        if (res.getStatusCode() == 200) { 
           IECEBC_ETTemplateCreate.createEmailTemplate(emailTempId,campaignName, contactType);
        }
    }
}