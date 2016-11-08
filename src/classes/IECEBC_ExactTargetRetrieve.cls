public class IECEBC_ExactTargetRetrieve {

    // get Email Template Id from ExactTarget
    Public static String getEmailTemplateId(String emailTemplateName) {
        // http instances and variables
        Http http = new Http();
        HttpRequest req = new HttpRequest();        
        String emailTemplateId = '';                
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestEmailTemplate(emailTemplateName)
            + IECEBC_ETHelper.createXMLFooter()              
        );                
        req.setTimeout(IECEBC_ETInit.TimeOut);        
        
        // get response
        HTTPResponse response = http.send(req);        
        if (response.getStatusCode() == 200) { 
            emailTemplateId = IECEBC_ETHelper.parse(response, 'ID');
        }
        // return ID
        return emailTemplateId;
    }
    
    // get list of subscribers email list from ExactTarget
    Public static List<String> getSubscribers() {
        // http instances and variables
        List<String> subscribersEmailList = new List<String>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();        
                    
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestSubscribers('Active')
            + IECEBC_ETHelper.createXMLFooter()              
        );                
        req.setTimeout(IECEBC_ETInit.TimeOut);        
        
        // get response
        HTTPResponse response = http.send(req);        
        if (response.getStatusCode() == 200) { 
            subscribersEmailList = IECEBC_ETHelper.parseList(response, 'EmailAddress');
        }
        // return ID
        return subscribersEmailList;
    }
    
    // get list of portfolio objects from ExactTarget
    Public static List<String> getPortfolioObjects() {
        // http instances and variables
        List<String> portfolioObjectsList = new List<String>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();        
                    
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body 
        // CategoryId =  2723632
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestPortfolioObjects('2723632') // category id of the portfolio folder
            + IECEBC_ETHelper.createXMLFooter()              
        );                
        req.setTimeout(IECEBC_ETInit.TimeOut);        
        
        // get response
        HTTPResponse response = http.send(req);        
        if (response.getStatusCode() == 200) { 
            portfolioObjectsList = IECEBC_ETHelper.parseList(response, 'FileName');
        }
        // return ID
        return portfolioObjectsList;
    }
    
    // get TriggeredSend ExternalKey from a triggeredSend Name
    Public static String getTriggeredSendExternalKey(String triggeredSendName) {
        // http instances and variables  
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        String triggeredSendExternalKey = '';
                    
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body        
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestTriggeredSend(triggeredSendName)
            + IECEBC_ETHelper.createXMLFooter()              
        );                
        req.setTimeout(IECEBC_ETInit.TimeOut);                
        // get response
        HTTPResponse response = http.send(req);        
        if (response.getStatusCode() == 200) {           
            triggeredSendExternalKey = IECEBC_ETHelper.parse(response, 'CustomerKey');            
        }
        // return ID
        return triggeredSendExternalKey;
    }
    
    // get Map<kpi, value> of Triggered Send Summary from ExactTarget
    Public static Map<String, String> getTriggeredSendSummary(String triggeredSendExternalKey) {
        // http instances and variables        
        Map<String, String> triggeredSendSummaryMetrics = new Map<String, String>
        						{
                                    'Sent' => '0',
                                    'Opens'  => '0', 
                                    'Clicks'  => '0',
                                    'Bounces'  => '0',
                                    'OptOuts'  => '0',                                     
                                    'UniqueOpens'  => '0', 
                                    'UniqueClicks'  => '0',       
                                    'NotSentDueToOptOut' => '0', 
                                    'NotSentDueToUndeliverable'  => '0', 
                                    'NotSentDueToError'  => '0',                                    
                                    'FTAFEmailsSent'  => '0',
                                    'FTAFOptIns'  => '0',
                                    'FTAFRequests'  => '0',
                                    'SurveyResponses'  => '0', 
                                    'Conversions'  => '0',
                                    'UniqueConversions'  => '0',      
                                    'InProcess'  => '0', 
                                    'Queued'  => '0'
                                };
                                    
        Http http = new Http();
        HttpRequest req = new HttpRequest();        
                    
        // header
        IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
        // body        
        req.setBody(
            IECEBC_ETHelper.createXMLHeader()            
            + IECEBC_ETHelper.retrieveRequestTriggeredSendSummary(triggeredSendExternalKey)
            + IECEBC_ETHelper.createXMLFooter()              
        );                
        req.setTimeout(IECEBC_ETInit.TimeOut);                
        // get response
        HTTPResponse response = http.send(req);        
        if (response.getStatusCode() == 200) {           
            IECEBC_ETHelper.parseMaptriggeredSendSummary(response, triggeredSendSummaryMetrics);            
        }
        // return ID
        return triggeredSendSummaryMetrics;
    }
    
    // get SentEvent DateTime from ExactTarget to schedule Cron Jobs
    Public static String getSentEventDateTime(String objectTSD_ID){
        String sendDateTime = '';
        String bodyContent = ''
            + '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>' 
            + '<ObjectType>SentEvent</ObjectType>' 
            + '<Properties>EventDate</Properties>' 
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">' 
            + '<Property>TriggeredSendDefinitionObjectID</Property>' 
            + '<SimpleOperator>equals</SimpleOperator>' 
            + '<Value>' 
            + IECEBC_ETHelper.xmlEncode(objectTSD_ID) 
            + '</Value>' 
            + '</Filter>' 
            + ' </RetrieveRequest>' 
            + '</RetrieveRequestMsg>'
            ;
       
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        IECEBC_ETHelper.setSoapRequest(req, 'Retrieve', bodyContent);
        req.setTimeout(IECEBC_ETInit.TimeOut); 
        
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) { 
            sendDateTime = IECEBC_ETHelper.parse(res, 'EventDate');
            if(sendDateTime == 'Node not found'){
                sendDateTime = '';
            }                        
        }        
        return sendDateTime;
    }
    
}