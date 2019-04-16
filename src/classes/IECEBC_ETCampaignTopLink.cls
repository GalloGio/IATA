public class IECEBC_ETCampaignTopLink {
    class UnexpectedResponse_Exception extends Exception{}
    
    // Retrieve the Click Event properties from Exacttarget 
    
    public static List<EBC_Click_Event__c> RetrieveClickEventProperties(DateTime lastFetch){
        List<EBC_Click_Event__c> myList = new List<EBC_Click_Event__c>();
        
      
        String type = 'Click';
        String LastDate = lastFetch.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        List<String> subscribersEmailList = new List<String>();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
         string bodyContent =
            
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<RetrieveRequest>'
             
            +'<ObjectType>ClickEvent</ObjectType>'
        
            +'<Properties>BatchID</Properties>'
            +'<Properties>CreatedDate</Properties>'
            +'<Properties>EventDate</Properties>'
            +'<Properties>EventType</Properties>'
            +'<Properties>ID</Properties>'
            +'<Properties>ModifiedDate</Properties>'
            +'<Properties>SendID</Properties>'
            +'<Properties>SubscriberKey</Properties>'
            +'<Properties>TriggeredSendDefinitionObjectID</Properties>'
            +'<Properties>URL</Properties>'
            +'<Properties>URLID</Properties>'
            
            +'<Filter xmlns="http://exacttarget.com/wsdl/partnerAPI" xsi:type="ComplexFilterPart">'
            +'<LeftOperand xsi:type="SimpleFilterPart">'
            +'<Property>EventDate</Property>'
            +'<SimpleOperator>greaterThan</SimpleOperator>'
            +'<DateValue>'+ LastDate +'</DateValue>'
            +'</LeftOperand>'
            +'<LogicalOperator>AND</LogicalOperator>'
            +'<RightOperand xsi:type="SimpleFilterPart">'
            +'<Property>EventType</Property>'
            +'<SimpleOperator>equals</SimpleOperator>'
            +'<Value>'+  Type  +'</Value>'	
            +'</RightOperand>'  
            +'</Filter>'
            
            +'</RetrieveRequest>'
            +'</RetrieveRequestMsg>';
        
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        System.debug(bodyContent);
        IECEBC_ETHelper.SetSoapRequest(req, 'Retrieve', bodyContent);
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        if (res.getStatusCode() == 200) { 
            
            List<String> elements = new List<String>{'SubscriberKey', 'URL', 'URLID', 'EventDate'};
                List<Map<String, String>> TopLinkClicksMap = new List<Map<String, String>>();
            
            TopLinkClicksMap = IECEBC_ETHelper.parseListMap(res, elements);
                      
            Pattern subKeyPattern = Pattern.compile('^(' + EBC_Campaign__c.sobjecttype.getDescribe().getKeyPrefix() + '[a-zA-Z0-9]{15})_(.*)');
            

            for(Map<String, String> ListMap : TopLinkClicksMap) { 
                String eventDateTime = ListMap.get('EventDate');
                Datetime eventDate = (Datetime)JSON.deserialize('"' + eventDateTime + '"', Datetime.class);
                if (eventDate <= lastFetch) continue;
               
                String subscriberk = ListMap.get('SubscriberKey');
                Matcher subKeyMatcher = subKeyPattern.matcher(subscriberk);
                
                if (!subKeyMatcher.matches()) {
                    System.debug('Ignoring the subscriber key ' + subscriberk + ' because it does not match the supported syntax.');
                    continue; // Subscriber Key does not match the supported syntax.
                }
                
                String URL = ListMap.get('URL');
                if (URL.toLowerCase().startsWith(IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c.toLowerCase() + '/iecebc_optout')) {
                    URL = 'Unsubscribe';
                }
                String campaign = subKeyMatcher.group(1);
                
                EBC_Click_Event__c EventClickLink = new EBC_Click_Event__c();
                
                EventClickLink.Name = 'EventClickLink_'+ campaign;
                EventClickLink.EBC_Campaign__c = campaign;
                EventClickLink.Event_Date__c = eventDate;
                EventClickLink.Event_Date_Timestamp__c = eventDate.getTime();
                EventClickLink.Subscriber_Key__c = subscriberk;
                EventClickLink.URL__c = URL;
                EventClickLink.External_Id__c = ListMap.get('URLID');

                myList.add(EventClickLink); 
                
            }
            upsert myList;
           
        }else{
            System.debug(res);
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }    
        
        return myList;
    }
    

}