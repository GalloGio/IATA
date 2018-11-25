/**  
  * Description: This class to post the amazon task
  * Uri: https://so18vh0x0f.execute-api.us-east-1.amazonaws.com/prod/startcampaign
  * Method: POST
  * Return schema 200: { "email_counter": integer}
  * Return schema 400: { "type": String, "reason": String}
  * Return schema 500: { "message": String}
  * Author: Abdellah Bellahssan
  * Version: 1.0
  * History: 
  */

public class AWS_Manage_Task
{
    public Class ErrorCls
    {
         public String type {get;set;}
         public String reason {get;set;}
         public ErrorCls(){
             type='';
             reason='';
         }
         
    }
    public Class AccessCls
    {
         public String message {get;set;}
         public AccessCls(){
             message='';
         }
    }
    public ErrorCls errorResult {get;set;}
    public AccessCls AFResult {get;set;}
    public Integer StatusCode {get;set;}
    /*
     * INPUT
     *  istest: used for test covrage
     *  ReferencedId: Salesforce Id used by the Amazon Batch to the different salesforce class
     *  BatchName: Amazon Batch Name
     */    
    public String execute(boolean istest, String ReferenceId, String BatchName)
    {
        System.Debug('x-api-key : >>>'+IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_API_KEY__c);
        String key = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_API_KEY__c;
        String url = IEC_Settings__c.getOrgDefaults().BATCH_AWS_URL__c;
  
        errorResult = new ErrorCls();
        AFResult = new AccessCls();
        
        //those are temporarely adopted for the tests should be removed
        key = 'Cr3LomuthNnR8bQH5kn5b3p4eEwlZiRb2BmBq200';
        url ='https://so18vh0x0f.execute-api.us-east-1.amazonaws.com/prod/startcampaign';
        // Instantiate a new http object
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        if (!istest) req.setEndpoint(url);
        req.setMethod('POST');
        req.SetHeader('Content-Type', 'application/json');
        req.SetHeader('x-api-key',key);
        req.setBody('{"ReferenceId":"'+ReferenceId+'", "BatchName":"'+BatchName+'"}');
        req.setTimeout(60000);
        // Send the request, and return a response
        string response = '{"job": "123123123123", "message":""}';
        StatusCode=200;
        HttpResponse res;
        if (!istest) res = h.send(req);
        String result='';
        if (!istest) result=res.getBody();
        if (istest) result=Response;
        System.Debug('Result : >>>'+result);
        if (!istest) System.Debug('res.getStatus(): >>>'+res.getStatus());
        if (!istest) System.Debug('res.getStatusCode(): >>>'+res.getStatusCode());
        if (!istest) StatusCode=res.getStatusCode();
        
        //BAD Request
        if (StatusCode==400) {errorResult = (ErrorCls)JSON.deserialize(result, ErrorCls.class); return  '';}
        
        //Access Forbidden
        if (StatusCode==500) {AFResult = (AccessCls)JSON.deserialize(result, AccessCls.class); return  '';}

        //OK
        res=null;
        return '';
        
    }

}