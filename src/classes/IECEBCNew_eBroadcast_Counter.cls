/**  
  * Description: This class to get the counter of unique email from elasticsearch
  * Uri: https://rb5luiyoea.execute-api.eu-west-1.amazonaws.com/prod/TestElasticSearchQuery 
  * Method: POST
  * Return schema 200: { "email_counter": integer}
  * Return schema 400: { "type": String, "reason": String}
  * Return schema 500: { "message": String}
  * Author: Abdellah Bellahssan
  * Version: 1.0
  * History: 
  */

public class IECEBCNew_eBroadcast_Counter
{

    public Class CounterCls
    {
         public Integer email_counter {get;set;}
         public CounterCls(){}
         
    }
    public Class ListCls
    {
         public Integer email_counter {get;set;}
         public String[] Ids {get;set;}
         public ListCls(){}
         
    }
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
    public ListCls listResult {get;set;}
    public CounterCls counterResult {get;set;}
    public ErrorCls errorResult {get;set;}
    public AccessCls AFResult {get;set;}
    public Integer StatusCode {get;set;}
    public integer execute( string elasticsearch_query,boolean istest){
        return execute(elasticsearch_query, 'counter', istest);
    }
    public integer execute( string elasticsearch_query, string resulttype, boolean istest)
    {
        System.Debug('elasticsearch_query : >>>'+elasticsearch_query);
        System.Debug('x-api-key : >>>'+IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_API_KEY__c);
        
        listResult = new ListCls();
        counterResult = new CounterCls();
        errorResult = new ErrorCls();
        AFResult = new AccessCls();

        String url = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_URL__c;
     
        // Instantiate a new http object
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        if (!istest) req.setEndpoint(url);
        req.setMethod('POST');
        req.SetHeader('Content-Type', 'application/json');
        if (!istest) req.SetHeader('x-api-key',IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_API_KEY__c);
        req.setTimeout(60000);
        if (!istest) req.setbody(elasticsearch_query);
        // Send the request, and return a response
        string response = '{"email_counter": 6}';
        if (resulttype=='list') response = '{"email_counter": 6, "Ids":["1","2"]}';
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
        if (StatusCode==400) {errorResult = (ErrorCls)JSON.deserialize(result, ErrorCls.class); return 0;}
        
        //Access Forbidden
        if (StatusCode==500) {AFResult = (AccessCls)JSON.deserialize(result, AccessCls.class); return 0;}

        //OK
        if (StatusCode==200 && resulttype=='counter') {counterResult = (CounterCls)JSON.deserialize(result, CounterCls.class); return counterResult.email_counter;}
        if (StatusCode==200 && resulttype=='list') {listResult = (ListCls)JSON.deserialize(result, ListCls.class); return listResult.email_counter;}
        res=null;
        return 0;
        
    }

}