public class IECEBC_ETHelper {
    // escape XML
    public static String xmlEncode(String input) {
        String str = (String.isBlank(input) ? '' : input.escapeXml()); // escaped and protected from any kind of injection.
        return str;
    }
    
    // create xml request header
    public static String createXMLHeader(){
        
        // authentication
        IECEBC_ETInit.Credentials cr = IECEBC_ETInit.setCredentials();        
        return
            '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"  xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
            + '<soap:Header>'
            + '<wsa:Action>Create</wsa:Action>'
            + '<wsa:MessageID>urn:uuid:0caa9e7d-bd29-4dab-b268-668343be00bd</wsa:MessageID>'
            + '<wsa:ReplyTo>'
            + '<wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address>'
            + '</wsa:ReplyTo>'
            + '<wsa:To>'
            + IECEBC_ETInit.ProductionEndpoint
        	+ '</wsa:To>'
            + '<wsse:Security soap:mustUnderstand="1">'
            + '<wsse:UsernameToken wsu:Id="SecurityToken-8ab9d52b-cf40-465b-9464-1a7c7f000460">'
            + '<wsse:Username>'            
            +
                cr.Username
            +
            + '</wsse:Username>'
            + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'
            +
                cr.Password
            +
            + '</wsse:Password>'
            + '</wsse:UsernameToken>'
            + '</wsse:Security>'
            + '</soap:Header>'
            + '<soap:Body>';               
    }
    
    // create xml request footer
    public static String createXMLFooter(){
        return '</soap:Body>'
            +'</soap:Envelope>';
    }
    
    // create xml request body
    public static String createXMLBody(String bodyContent){
        return CreateXMLHeader() + bodyContent + CreateXMLFooter();
    }
    /*
    // create xml for TSD create request
    public static String createRequestTSD(String triggeredParam, String templateId){
        return '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
                        +'<Options/>'
                        +'<Objects xsi:type="TriggeredSendDefinition">'
                        +'<CustomerKey>'
                        + xmlEncode(triggeredParam)
                        +'</CustomerKey>'
                        +'<Name>'
                        + xmlEncode(triggeredParam)
                        +'</Name>'
                        +'<SendClassification>'
                        +'<ObjectID>82684d06-ff62-e611-8844-0025b3d7f36a</ObjectID>'
                        +'<SenderProfile>'
                        +'<ObjectID xsi:nil="true"/>'
                        +'<CustomerKey>Default Commercial</CustomerKey>'
                        +'</SenderProfile>'
                        +'</SendClassification>'
                        +'<Email>'
                        +'<ID>'
                        + xmlEncode(templateId)
                        +'</ID>'
                        +'<ObjectID xsi:nil="true"/>'
                        +'</Email>'
                        +'<IsMultipart>true</IsMultipart>'
                        +'<AutoAddSubscribers>false</AutoAddSubscribers>'
                        +'</Objects>'
                        +' </CreateRequest>';
    }*/
    
    // create xml for Email Template retrieve request
    public static String retrieveRequestEmailTemplate(String emailTemplateName){
        
        return '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>Email</ObjectType>'
            + '<Properties>ID</Properties>'
            + '<Properties>CreatedDate</Properties>'
            + '<Properties>Name</Properties>'
            + '<Properties>Folder</Properties>'
            + '<Properties>CategoryID</Properties>'
            + '<Properties>HTMLBody</Properties>'
            + '<Properties>TextBody</Properties>'
            + '<Properties>Subject</Properties>'
            + '<Properties>IsActive</Properties>'
            + '<Properties>IsHTMLPaste</Properties>'
            + '<Properties>Status</Properties>'
            + '<Properties>EmailType</Properties>'
            + '<Properties>CharacterSet</Properties>'
            + '<Properties>HasDynamicSubjectLine</Properties>'
            + '<Properties>ContentCheckStatus</Properties>'
            + '<Properties>Client.PartnerClientKey</Properties>'
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Property>Name</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(emailTemplateName)            
            + '</Value>'
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for Subscribers retrieve request
    public static String retrieveRequestSubscribers(String status){
        return '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>Subscriber</ObjectType>'
            + '<Properties>CreatedDate</Properties>'
            + '<Properties>Client.ID</Properties>'
            + '<Properties>EmailAddress</Properties>'
            + '<Properties>SubscriberKey</Properties>'
            + '<Properties>Status</Properties>'
            + '<Properties>UnsubscribedDate</Properties>'
            + '<Properties>EmailTypePreference</Properties>'
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Property>Status</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(status)
            + '</Value>'
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for Portfolio objects retrieve request    
    public static String retrieveRequestPortfolioObjects(String categoryId){
        return             
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>Portfolio</ObjectType>'
            + '<Properties>CustomerKey</Properties>'
            + '<Properties>Client.ID</Properties>'
            + '<Properties>CategoryID</Properties>'
            + '<Properties>FileName</Properties>'
            + '<Properties>DisplayName</Properties>'
            + '<Properties>Description</Properties>'
            + '<Properties>TypeDescription</Properties>'
            + '<Properties>IsUploaded</Properties>'
            + '<Properties>IsActive</Properties>'
            + '<Properties>FileSizeKB</Properties>'
            + '<Properties>ThumbSizeKB</Properties>'
            + '<Properties>FileWidthPX</Properties>'
            + '<Properties>FileHeightPX</Properties>'
            + '<Properties>FileURL</Properties>'
            + '<Properties>ThumbURL</Properties>'
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Property>CategoryID</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(categoryId)
            + '</Value>'
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for Portfolio retrieve request    
    public static String retrieveRequestPortfolio(String categoryId, String fileName){
        return             
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>Portfolio</ObjectType>'
            + '<Properties>CustomerKey</Properties>'
            + '<Properties>Client.ID</Properties>'
            + '<Properties>CategoryID</Properties>'
            + '<Properties>FileName</Properties>'
            + '<Properties>DisplayName</Properties>'
            + '<Properties>Description</Properties>'
            + '<Properties>TypeDescription</Properties>'
            + '<Properties>IsUploaded</Properties>'
            + '<Properties>IsActive</Properties>'
            + '<Properties>FileSizeKB</Properties>'
            + '<Properties>ThumbSizeKB</Properties>'
            + '<Properties>FileWidthPX</Properties>'
            + '<Properties>FileHeightPX</Properties>'
            + '<Properties>FileURL</Properties>'
            + '<Properties>ThumbURL</Properties>'
            + '<Filter xsi:type="par:ComplexFilterPart" xmlns:par="http://exacttarget.com/wsdl/partnerAPI">'
            + '<LeftOperand xsi:type="par:SimpleFilterPart">'
            + '<Property>CategoryID</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(categoryId)
            + '</Value>'
            + '</LeftOperand>'
            + '<LogicalOperator>AND</LogicalOperator>'
            + '<RightOperand xsi:type="par:SimpleFilterPart">'
            + '<Property>FileName</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(fileName)
            + '</Value>'
            + '</RightOperand>'            
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for Image retrieve request    
    public static String retrieveRequestImage(String fileName){
        return             
            '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>Portfolio</ObjectType>'
            + '<Properties>CustomerKey</Properties>'
            + '<Properties>Client.ID</Properties>'
            + '<Properties>CategoryID</Properties>'
            + '<Properties>FileName</Properties>'
            + '<Properties>DisplayName</Properties>'
            + '<Properties>Description</Properties>'
            + '<Properties>TypeDescription</Properties>'
            + '<Properties>IsUploaded</Properties>'
            + '<Properties>IsActive</Properties>'
            + '<Properties>FileSizeKB</Properties>'
            + '<Properties>ThumbSizeKB</Properties>'
            + '<Properties>FileWidthPX</Properties>'
            + '<Properties>FileHeightPX</Properties>'
            + '<Properties>FileURL</Properties>'
            + '<Properties>ThumbURL</Properties>'
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Property>FileName</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(fileName)
            + '</Value>'            
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for Portfolio objects retrieve request    
    public static String createRequestPortfolio(String restWS, String fileName, String attachmentId){
        return  ''
            + '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Options/>'            
            + '<ns1:Objects xsi:type="ns1:Portfolio" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<ns1:PartnerKey xsi:nil="true"/>'
            + '<ns1:ModifiedDate xsi:nil="true"/>'
            + '<ns1:ObjectID xsi:nil="true"/>'
            + '<ns1:CustomerKey/>'
            + '<ns1:Source>'
            + '<ns1:PartnerKey xsi:nil="true"/>'
            + '<ns1:ModifiedDate xsi:nil="true"/>'
            + '<ns1:ObjectID xsi:nil="true"/>'
            + '<ns1:URN>'  
            + IECEBC_ETInit.IECRestAPI
            + xmlEncode(restWS) + '/' 
            + xmlEncode(attachmentId)
            + '</ns1:URN>'
            + '</ns1:Source>'
            + '<ns1:FileName>'             
            + xmlEncode(fileName)         
            + '</ns1:FileName>'
            + '</ns1:Objects>' 
            + '</CreateRequest>'
            ;  
    }
    
    // create xml for TS Summary retrieve request
    public static String retrieveRequestTriggeredSendSummary(String triggeredSendExternalKey){
        return '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>TriggeredSendSummary</ObjectType>'
            + '<Properties>Sent</Properties>'
            + '<Properties>Queued</Properties>'
            + '<Properties>NotSentDueToOptOut</Properties>'
            + '<Properties>NotSentDueToUndeliverable</Properties>'
            + '<Properties>Bounces</Properties>'
            + '<Properties>Opens</Properties>'
            + '<Properties>Clicks</Properties>'
            + '<Properties>UniqueOpens</Properties>'
            + '<Properties>UniqueClicks</Properties>'
            + '<Properties>OptOuts</Properties>'
            + '<Properties>SurveyResponses</Properties>'
            + '<Properties>Conversions</Properties>'
            + '<Properties>UniqueConversions</Properties>'
            + '<Properties>InProcess</Properties>'
            + '<Properties>NotSentDueToError</Properties>'
            + '<Properties>FTAFEmailsSent</Properties>'
            + '<Properties>FTAFOptIns</Properties>'
            + '<Properties>FTAFRequests</Properties>'            
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Property>CustomerKey</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(triggeredSendExternalKey)
            + '</Value>'
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for TS retrieve request
    public static String retrieveRequestTriggeredSend(String triggeredSendName){
        return '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<RetrieveRequest>'
            + '<ObjectType>TriggeredSendDefinition</ObjectType>'
            + '<Properties>CustomerKey</Properties>'
            + '<Properties>Name</Properties>'
            + '<Properties>TriggeredSendStatus</Properties>'
            + '<Properties>ObjectID</Properties>'
            + '<Filter xsi:type="ns1:SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Property>Name</Property>'
            + '<SimpleOperator>equals</SimpleOperator>'
            + '<Value>'
            + xmlEncode(triggeredSendName)
            + '</Value>'
            + '</Filter>'
            + '</RetrieveRequest>'
            + '</RetrieveRequestMsg>';
    }
    
    // create xml for Soap request header
    public static void setSoapRequestHeader(HttpRequest req, String soapAction){        
        // set header        
        req.setEndpoint(IECEBC_ETInit.ProductionEndpoint);
        req.setMethod('POST');
        req.setHeader('SOAPAction', soapAction);
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
    } 
    
    // create xml for Soap request
    public static void setSoapRequest(HttpRequest req, String soapAction, String bodyContent){        
        // set header        
        req.setEndpoint(IECEBC_ETInit.ProductionEndpoint);
        req.setMethod('POST');
        req.setHeader('SOAPAction', soapAction);
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setBody(CreateXMLBody(bodyContent));
    }
     
    // parse xml response to get nodename value - text
    public static String parse(HttpResponse res, String nodeName) {
        Dom.Document doc = new Dom.Document();
        doc.load(res.getBody());         
        try {              
            DOM.XMLNode root = doc.getRootElement();
            return walkThrough(root, nodeName);
        } catch (System.XMLException e) {  // invalid XML
            return e.getMessage();
        }
    }
    
    // parse xml response to get nodename values - text
    public static List<String> parseList(HttpResponse res, String nodeName) {
        List<String> ls = new List<String>();
        Dom.Document doc = new Dom.Document();
        doc.load(res.getBody());  
        try {              
            DOM.XMLNode root = doc.getRootElement();
            return walkThroughList(root, nodeName, ls);
        } catch (System.XMLException e) {  // invalid XML
            ls.add(e.getMessage());
            return ls;
        }
    }
    
    
    // Parse the XML list to get a node value
    public static List<Map<String, String>> parseListMap(HttpResponse res, List<String> elts) { 
            
        List<Map<String, String>> MyListMap = new List<Map<String, String>>();
        DOM.Document doc = new DOM.Document();      
          try {
            doc.load(res.getBody());    
            DOM.XMLNode root = doc.getRootElement();
                return   walkThrough(root, elts, MyListMap);
            
          } catch (System.XMLException e) {  // invalid XML
              System.debug(e.getMessage());
           
          }
                return null;
    }
    
    
    // walk through the xml file and get the Map of value for the node retrieve in a specific list. This Map is return as a List
    public static List<Map<String, String>> walkThrough(DOM.XMLNode node, List<String> elts, List<Map<String, String>> myListMap) {
        
     String result = '\n';
     List<String> myResult = new List<String>();
     Map<String, String> MyResult1 = new  Map<String, String>();
        
     if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
         
         result += 'Element: ' + node.getName();
         
         if (node.getText().trim() != '') {
             result += ', text=' + node.getText().trim();
         }
         
         for (Dom.XMLNode child: node.getChildElements()) {
             
             walkThrough(child, elts, myListMap);
             
                 for(String n: elts){
                    if(child.getName() == n){
                        
                       myResult1.put(n, child.getText()); //Add new item element in the Map 
                     
                    }
             	}  
        }
             if(myResult1.size() > 0){
                 MyListMap.add(myResult1); // add a Map in the List of Nap
                 
                 //system.debug('le size du map est : '+ MyListMap.size()); 
                //system.debug('le resultat final est : '+ MyListMap);     
              }   
          
        return MyListMap;
      }
            
      return null;  //should never reach here 
    }

    


   /*
    
    // class to retrieve Bounce Event subscribers
    public class SubscriberProperties {
        public String SubscriberKey {get; set;}
        public String SMTPReason {get; set;}
        public String EventDate {get; set;}       
    }
    
    // parse xml response to get Object (properties == nodenames) values
    public static Map<String, SubscriberProperties> parseMap(HttpResponse res, SubscriberProperties sp) {
        Map<String, SubscriberProperties> mapSP = new Map<String, SubscriberProperties>();
        Dom.Document doc = new Dom.Document();
        doc.load(res.getBody());  
        try {              
            DOM.XMLNode root = doc.getRootElement();
            return walkThroughMap(root, mapSP);
        } catch (System.XMLException e) {  // invalid XML
            System.debug(e.getMessage());
            return null;
        }
    }
    
    // walk through the xml file and get the list of values of a node    
    public static Map<String, SubscriberProperties> walkThroughMap(DOM.XMLNode node, Map<String, SubscriberProperties> mapSP) {                
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            SubscriberProperties sp = new SubscriberProperties();
            String mapKey = '';
            
            List<dom.Xmlnode> nodesList = node.getChildren();
            
            for (dom.Xmlnode i : nodesList)
            {
                if (node.getName() == 'SubscriberKey') {                
                    sp.SubscriberKey = node.getText().trim();
                    mapKey = sp.SubscriberKey;                
                }
                if (node.getName() == 'SMTPReason') {
                    sp.SMTPReason = node.getText().trim();
                } 
                if (node.getName() == 'EventDate') {
                    sp.EventDate = node.getText().trim();
                }                 
            }
                            
            // put into Map
            mapSP.put(mapKey, sp);
            // continue searching
            for (Dom.XMLNode child: node.getChildElements()) {
                
               // for(String key : mapSP.keySet()){
                
                mapSP = walkThroughMap(child, mapSP);
                
                 //   if(child.getName() == mapSP.get(key)){
                       //system.debug('le resultat de map est ' + mapSP.get(key)); 
                        // mapSP.put(mapKey, sp);
                        
                  //  }
               // }
            }
            return mapSP;
        }
        return null;  //should never reach here 
    }  
    
    */
    
    // parse xml response to get map<nodename, value> of TS Summary
    public static void parseMapTriggeredSendSummary(HttpResponse res, Map<String, String> tssMap) {
        // map for errors log
        Map<String, String> errorsMap = new Map<String, String>();
        for(String s : tssMap.keySet()){
            errorsMap.put(s, '');
        }
        // document
        Dom.Document doc = new Dom.Document();        
        doc.load(res.getBody());
        // for all map key values
        for(String nodeName : tssMap.keySet()){
            try {              
                DOM.XMLNode root = doc.getRootElement();                
                tssMap.put(nodeName, walkThrough(root, nodeName));                
                                
            } catch (System.XMLException e) {  // invalid XML
                errorsMap.put(nodeName, e.getMessage());                
            }
        }       
    }
            
    // walk through the xml file and get the list of values of a node
    public static List<String> walkThroughList(DOM.XMLNode node, String nodeName, List<String> ls) {                
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            
            if (node.getName() == nodeName) {
                ls.add(node.getText().trim());
            }           
            for (Dom.XMLNode child: node.getChildElements()) {
                ls = walkThroughList(child, nodeName, ls);
            }
            return ls;
        }
        return null;  //should never reach here 
    }   
    
    // walk through the xml file and get the value of a node
    public static String walkThrough(DOM.XMLNode node, String nodeName) {
        String result = '';     
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            
            if (node.getName() == nodeName) {
                result = node.getText().trim();                
                if(result != '')  return result;   // node found retrieve value                   
            }           
            for (Dom.XMLNode child: node.getChildElements()) {
                result = walkThrough(child, nodeName);
                if (result != '')  break;      // node found exit           
            }
            return result;
        }
        return 'Node not found';  //should never reach here 
    }
    
    
    
    // convert ET dateTime to GMT Time zone
    
    public static DateTime ConvertETDate (String dateT){
        
        DateTime myDate = DateTime.Parse(dateT.substring(5,7)+'/'+dateT.substring(8,10)+'/'+dateT.substring(0,4)+' '+dateT.substring(11,16)+' AM');
        
        
        return myDate;
        
    }
    
    
}