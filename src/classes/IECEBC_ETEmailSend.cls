public class IECEBC_ETEmailSend {
    /*class UnexpectedResponse_Exception extends Exception{
        public String ErrorMessage {get; set;} 
    }*/

    // send single email
    public static void sendSingleEmail(String TriggeredParam, String email, Map<String, String> attributes){
        sendMassEmail(TriggeredParam, new Map<String, Map<String, String>>{
            email => attributes
        });
    }
    public static void sendMassEmail(String TriggeredParam, Map<String, Map<String, String>> recipients){
        //String email, Map<String, String> attributes
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String tags ='';
        
        for(String email : recipients.keySet()) {
            tags +='<Subscribers>'
                +'<EmailAddress>'+IECEBC_ETHelper.xmlEncode(email)+'</EmailAddress>'
                +'<SubscriberKey>'+IECEBC_ETHelper.xmlEncode(email)+'</SubscriberKey>'
                ;
            
            Map<String, String> attributes = recipients.get(email);
            for(String key : attributes.keySet()) {
                tags+='<Attributes><Name>'+IECEBC_ETHelper.xmlEncode(key)+'</Name><Value>'+IECEBC_ETHelper.xmlEncode(attributes.get(key))+'</Value></Attributes>';
            }
            
            tags += '</Subscribers>';
        }
        
        string bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Options/>'
            +'<Objects xsi:type="TriggeredSend">'
            +'<TriggeredSendDefinition>'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(TriggeredParam) +'</CustomerKey>'
            +'</TriggeredSendDefinition>'
            + tags
            +'</Objects>'
            +' </CreateRequest>';
        
        System.debug(bodyContent);
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
        // Soap response 
        HTTPResponse response = null;
        String errorMessage = '', errorCode = '', displayMessage = '';
        // try and catches
        

       	try{
            // send request
     		response = http.send(req);
            // if response status 200 OK
            if (response.getStatusCode() == 200) {     
                System.debug(response.getBody());
                // if status code not OK (Error)
                if (IECEBC_ETHelper.parse(response, 'StatusCode') != 'OK') {
                    // get errorCode and errorMessage
                    errorCode = IECEBC_ETHelper.parse(response, 'ErrorCode');
                    errorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');                    
                    // Email failed validation                     
                    if (IECEBC_ETHelper.parse(response, 'ErrorCode') == '7000') {
                        displayMessage = 'Email Failed Validation: Invalid Place Holder';
                        // throw InvalidPlaceHolderException  
                        throw new IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception(errorMessage);                        
                    }else{
                        displayMessage = 'Unexpected Response';
                        throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);   	
                    }
                }
                // else
                system.debug('Emails are sent!');
            } else {
                System.debug(response);
                System.debug(response.getBody());
                displayMessage = 'Unexpected Response';
                throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);
            }
        } catch (System.CalloutException e){
            System.debug(e);
            System.debug('ERROR:' + e);
            IECEBC_ExceptionHandler.addException('System Call out Exception', e);
        } catch (IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception e){ 
            System.debug(e);
            // set error message
            e.ErrorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');
            // set attribute name from merge filed name in error
            e.AttributeNames = getErrorMergeFieldsNames(e.ErrorMessage);            
            IECEBC_ExceptionHandler.addInvalidPlaceHolderException(displayMessage, e);
        } catch (IECEBC_ExceptionHandler.UnexpectedResponse_Exception e){
            System.debug('ERROR:' + e);
            System.debug(e);
            IECEBC_ExceptionHandler.addException(displayMessage, e);
        } finally{
         	IECEBC_ExceptionHandler.saveExceptionLog();
        }
    } 
    
    // Send emails using : email template Id, List Id
    // @ todo in case of Plan B
    /*public static void sendEmailToList(String emailId, String listId){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        // create request body
        String  xmlRequestBody = IECEBC_ETHelper.requestSendEmailToList(emailId, listId);                
        // create the soap request
        IECEBC_ETHelper.setSoapRequest(req, 'Create', xmlRequestBody);
        // Soap response 
        HTTPResponse response = null;
        String errorMessage = '', errorCode = '', displayMessage = '';
        // try and catches
       	try{
            // send request
     		response = http.send(req);
            // if response status 200 OK
            if (response.getStatusCode() == 200) {             	
                // if status code not OK (Error)
                if (IECEBC_ETHelper.parse(response, 'StatusCode') != 'OK') {
                    // get errorCode and errorMessage
                    errorCode = IECEBC_ETHelper.parse(response, 'ErrorCode');
                    errorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');                    
                    // Email failed validation                     
                    if (IECEBC_ETHelper.parse(response, 'ErrorCode') == '7000') {
                        displayMessage = 'Email Failed Validation: Invalid Place Holder';
                        // throw InvalidPlaceHolderException  
                        throw new IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception(errorMessage);                        
                    }else{
                        displayMessage = 'Unexpected Response';
                        throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);   	
                    }
                }
                // else
                system.debug('Emails are sent!');
            } else {                
                displayMessage = 'Unexpected Response';
                throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);
            }
        } catch (System.CalloutException e){
            System.debug('ERROR:' + e);
            IECEBC_ExceptionHandler.addException('System Call out Exception', e);
        } catch (IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception e){
            // set error message
            e.ErrorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');
            // set attribute name from merge filed name in error
            e.AttributeNames = getErrorMergeFieldsNames(e.ErrorMessage);            
            IECEBC_ExceptionHandler.addInvalidPlaceHolderException(displayMessage, e);
        } catch (IECEBC_ExceptionHandler.UnexpectedResponse_Exception e){
            System.debug('ERROR:' + e);
            IECEBC_ExceptionHandler.addException(displayMessage, e);
        } finally{
         	IECEBC_ExceptionHandler.saveExceptionLog();
        }
    }*/
    
    // retrieve merge field Name in error from the soap response 
    public static List<String> getErrorMergeFieldsNames(String statusMessage){          
        statusMessage = statusMessage.replaceAll('[\n\r]', '');
        //system.debug('statusMessage 1 = ' + statusMessage);
        List<String> mergeFieldNames = new List<String>();
        statusMessage = statusMessage.substringAfter('%%');
		//system.debug('statusMessage 2 = ' + statusMessage);        
        Integer len = statusMessage.length()/2;        
        statusMessage = statusMessage.substring(0, len);
        //system.debug('statusMessage 3 = ' + statusMessage);
        String s2 = '';
        do{
            s2 = statusMessage.substringBefore('%%');            
            //system.debug('s2 = ' + s2);            
            mergeFieldNames.add(s2 + ', ');			
            statusMessage = statusMessage.substringAfter('%%%%');                      
        }while(statusMessage.length() > 1);
        //system.debug('mergeFieldNames = ' + mergeFieldNames.size());
        return mergeFieldNames;
    }
	
    // send emails using triggered send definition 
    public static void sendEmails(String contactType, String TriggeredParam, String campaignName, String objectTSD_ID){
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String tags ='';
        system.debug(' contact type '+ contactType);
        if (contactType == 'Agent'){
            List<ID_Card__c> subscribers = IECEBC_ETAgentAgencyRetrieve.GetAgents();
            for(ID_Card__c a : subscribers)
            { 
                String sEmail= a.email__c; 
                tags +='<Subscribers>'
                    +'<EmailAddress>'+ IECEBC_ETHelper.xmlEncode(sEmail) +'</EmailAddress>'
                    +'<SubscriberKey>'+ IECEBC_ETHelper.xmlEncode(sEmail) +'</SubscriberKey>'
                    +'</Subscribers>';
                system.debug('Agent Email'+ sEmail);
            }
        }
        else {
            List<GDP_Products_Account_View__c> subscribers = IECEBC_ETAgentAgencyRetrieve.GetAgencies();
            for(GDP_Products_Account_View__c a : subscribers)
            { 
                String sEmail= a.Email_Address__c; 
                tags +='<Subscribers>'
                    +'<EmailAddress>'+ IECEBC_ETHelper.xmlEncode(sEmail) +'</EmailAddress>'
                    +'<SubscriberKey>'+ IECEBC_ETHelper.xmlEncode(sEmail) +'</SubscriberKey>'
                    +'</Subscribers>';
                system.debug('Agent Email'+ sEmail);
            }       
        }
        
        string bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            +'<Options/>'
            +'<Objects xsi:type="TriggeredSend">'
            +'<TriggeredSendDefinition>'
            +'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(TriggeredParam) +'</CustomerKey>'
            +'</TriggeredSendDefinition>'
            + tags
            +'</Objects>'
            +' </CreateRequest>';
        
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
        
        HTTPResponse response = http.send(req);
        
        if (response.getStatusCode() == 200) { 

            system.debug('Triggered Send ObjectId: '+ objectTSD_ID);
            
            system.debug('Emails are sent!');
        }       
    }    
}