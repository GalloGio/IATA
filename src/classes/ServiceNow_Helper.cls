public without sharing class ServiceNow_Helper {
    //ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
    public static void sendRequestToSNOW(string caused_by, string u_issue_identified_by, string u_operation_name, string u_application
                                 , string business_service, string short_description, string description, string subcategory, string caller_id
                                 , string opened_by, string u_business_service, string assignment_group
                                 , string impact, string urgency, string severity, string category){
        
        SNOWBody theBody = new SNOWBody();
        
            theBody.caused_by = caused_by;
            theBody.u_issue_identified_by = u_issue_identified_by;
            theBody.u_operation_name = u_operation_name;
            theBody.u_application = u_application;
            theBody.business_service = business_service;
            theBody.short_description = short_description;
            theBody.description = description;
            theBody.impact = impact;
            theBody.urgency = urgency;
            theBody.severity = severity;
            theBody.category = category;
            theBody.subcategory = subcategory;
            theBody.caller_id = caller_id;
            theBody.opened_by = opened_by;
            theBody.u_business_service = u_business_service;
            theBody.assignment_group = assignment_group;

        if(trigger.isExecuting && !(system.isFuture() || system.isBatch())) sendRequestToSNOW_Future(JSON.serialize(theBody));
        else if(system.isFuture() || system.isBatch()) sendRequestToSNOW_Immediate(JSON.serialize(theBody));
        else sendRequestToSNOW_Future(JSON.serialize(theBody));
    }
    
    
    @future(callout=true)
    private static void sendRequestToSNOW_Future(string theBody){   sendRequest(theBody); }
    
    
    private static void sendRequestToSNOW_Immediate(string theBody){    sendRequest(theBody); }
        
    
    private static void sendRequest(string theBody){
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setEndpoint('callout:ServiceNow_Login/api/now/table/incident');
        
        req.setBody(theBody);

        
        Http http = new Http();
        HTTPResponse res;

        try{
            res = http.send(req);
            system.debug('DTULLO  --> SNOW Response: ' + res);
            system.debug('DTULLO  --> SNOW Response body: ' + res.getBody());
        }catch(CalloutException e){
            system.debug('DTULLO  --> SNOW exception: ' + e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage()));
            ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
            //log.Agency_Applied_Change_code__c = changeCodeId;
            log.Web_Service__c = req.getEndpoint(); //'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
            try{ 
	          log.Input_Description__c = 'body:' + res.getBody(); 
	        }catch(exception e1){}
            log.Method__c = 'POST';
            log.Web_Service__c = String.valueOf(req);
            log.Error_Code__c = 'Exception sending request';
            log.Error_Message__c = e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage());
            log.Success__c = false;
            insert log;

            return;
        }

        ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();

        //log.Agency_Applied_Change_code__c = changeCodeId;
		log.Web_Service__c = req.getEndpoint(); //'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
        log.Input_Description__c= 'body:'+res.getBody();
        log.Method__c = 'POST';
        //log.Web_Service__c = String.valueOf(req);

        try{ 
          log.Response__c = res.getBody(); 
        }catch(exception e){}

		log.Error_Code__c = String.valueOf(res.getStatusCode());
		log.Error_Message__c = res.getStatus();

        if((res.getStatusCode() > ANG_IEP_CalloutHelper.STATUSOKLOWER && res.getStatusCode() < ANG_IEP_CalloutHelper.STATUSOKHIGHER )) log.Success__c = true;
        else log.Success__c = false;
        
        insert log;
    }
    
    
    public class SNOWBody{
        public string caused_by {get; set;}     //SFDC
        public string u_issue_identified_by {get; set;} //INT_008
        public string u_operation_name {get; set;}  //Agency MasterData
        public string u_application {get; set;} //featurespace-system-service
        public string business_service {get; set;}  //RME
        public string short_description {get; set;} //excception or description
        public string description {get; set;}   //full description
        public string impact  {get; set;} //2
        public string urgency  {get; set;} //2
        public string severity  {get; set;} //2
        public string category  {get; set;} //failure
        public string subcategory {get; set;}   //connectivity  or Software
        public string caller_id {get; set;} //Max Mule
        public string opened_by {get; set;} //Max Mule
        public string u_business_service {get; set;}    //Infrastructure Services
        public string assignment_group {get; set;}  //Mulesoft Support

    }
    
    public class SNOWResponse{
        
    }
}