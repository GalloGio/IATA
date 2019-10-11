/*
* Retrieve Now_Date Count for Agent and Agency from Elastic
* Requirement:         Count of Agency Now_Date = TODAY
* Count of Agency Now_Date != TODAY
* Count of Agent Now_Date = TODAY
* Count of Agent Now_Date != TODAY
* Log the results in EBC Setup (Record Name = Default)
* Create 1 new Section on Page Layout called “Elastic Refresh – Control Values”

* Create 4 new fields placed under this new section
* -         Elastic Count Control – Agency/Today
* -         Elastic Count Control – Agency/Not Today
* -         Elastic Count Control – Agent/Today
* -         Elastic Count Control – Agent/Not Today
* Call to Elastic runs daily at 11:30AM Montreal Time.
*/

global class EBC_Batch_CheckElasticSearchSync implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable 
{    
    global Boolean xisFailed {get;set;}
    global Boolean xisOutdated {get;set;}
    global String MsgError {get;set;}
    global class Counterhits {
        public Integer total {get;set;}
        public Decimal max_score {get;set;}
        public List<String> hits {get;set;}
        public CounterHits(){
            this.total=0;
            this.max_score=0;
            this.hits=new List<String>();
        }
    }
    /*
    {
        "hits": {
            "total": 159949,
            "max_score": 0,
            "hits": []
        }
    }
    */

    global class CounterResult {
        public CounterHits hits {get;set;}
        public CounterResult(){

        }
    }
    // Batchable 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        xisFailed=false;
        xisOutdated=false;
        MsgError='';
        String query='Select Id, Last_Date_ElasticSearch_Counter__c, ElasticSearch_Agent_Counter__c, ElasticSearch_Agency_Counter__c From EBC_Setup__c Where Last_Date_ElasticSearch_Counter__c=null or Last_Date_ElasticSearch_Counter__c<TODAY Limit 1';
        List<EBC_Setup__c> dlist= new List<EBC_Setup__c>();
        dlist= Database.Query(query);
        System.Debug('query>>>'+query);
        System.Debug('dlist>>>'+dlist);
        
        return Database.getQueryLocator(query);
    }
    //Type : agent or agency
    global Integer query_elastic(String type, String matchdate){
        /*
        {
          "database": "iata",
          "document": "agency",
          "resulttype": "count",
          "request": {
            "_source": false,
            "explain": false,
            "size": 0,
            "query":{},
            "aggs": {
              "distinct_id_list": {
                "terms": {
                  "field": "Now_Date__c",
                  "size": 1000000
                }
              }
            }
          }
        }
        */
        String matchstring = '';
        if (matchdate!='') matchstring='"match": {"Now_Date__c": "'+matchdate+'"}';
        Boolean isTest = Test.isRunningTest();
        String QueryES= '{"database": "iata","document": "'+ type + '","resulttype": "count","request": {"_source": false,"explain": false,"size": 0,"query":{'+matchstring+'},"aggs": {"distinct_id_list": {"terms": {"field": "Now_Date__c","size": 1000000}}}}}';
       
        String xkey = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_API_KEY__c;
        String url = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_AWS_URL__c;
     
       
        // Instantiate a new http object
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        if (!isTest) req.setEndpoint(url);
        if (!isTest) req.setMethod('POST');
          
        if (!isTest) req.SetHeader('Content-Type', 'application/x-www-form-urlencoded');
        if (!isTest) req.SetHeader('x-api-key', xkey);
        if (!isTest) req.setbody(QueryES);
        if (!isTest) req.setTimeout(60000);
        // Send the request, and return a response
        Integer StatusCode=200;

        HttpResponse res;
        Integer counter=0;
        try { 
            if (!isTest) res = h.send(req);
            String result='"hits": {"total": 159949,"max_score": 0,"hits": []}';
            if (!isTest) result=res.getBody();
            System.Debug('Result : >>>'+result);
            Integer startjson=result.IndexOf('"hits"');
            String jsonresult='';
            if (startjson>-1){
               Integer endjson=result.IndexOf('}',startjson);
                if (endjson>startjson) jsonresult = '{'+result.Substring(startjson, endjson+1)+'}';
            }
            System.Debug('jsonresult: >>>'+jsonresult);
            if (!isTest) System.Debug('res.getStatus(): >>>'+res.getStatus());
            if (!isTest) System.Debug('res.getStatusCode(): >>>'+res.getStatusCode());
            if (!isTest) StatusCode=res.getStatusCode(); 
            if (StatusCode!=200) return 0;

            CounterResult newcounterresult = new CounterResult();
            newcounterresult = (CounterResult) System.JSON.deserialize(jsonresult, CounterResult.class);
            counter=newcounterresult.hits.total;
         }Catch(Exception e)
        {
        }
        System.Debug('counter: >>>'+counter);
        return counter;
    }
    
    global void execute(Database.BatchableContext BC, List<EBC_Setup__c> scope) 
    {
        Integer year = System.Today().Year();
        Integer month = System.Today().Month();
        Integer day = System.Today().Day();
        String mydate = String.ValueOf(year);
        mydate= mydate.trim() +'-';
        if (month<10) mydate += '0';
        mydate += String.ValueOf(month).trim()+'-';
        if (day<10) mydate += '0';
        mydate += String.ValueOf(day).trim();
        
        System.debug('scope exec>>>'+scope);
        for(EBC_Setup__c o:scope){
            //Select the Date
            Date newdate=system.Today();
            //check when was the last time the counters got updated
            //if more than or equal to 2 days the initiate email 
            //to the administrator.
            if (o.Last_Date_ElasticSearch_Counter__c==null) o.Last_Date_ElasticSearch_Counter__c= newdate;
            Date olddate=o.Last_Date_ElasticSearch_Counter__c;
            if (olddate!=null){
                if (newdate>olddate.AddDays(1)) xisOutdated=true;
            }
             //Prepare to request for Agency
            o.Last_Date_ElasticSearch_Counter__c  = newdate;
            Integer totalagency = query_elastic('agency', '');
            if (totalagency==0) return;
            o.ElasticSearch_Agency_Counter__c = query_elastic('agency', mydate);
            if (o.ElasticSearch_Agency_Counter__c==0) return;
            //issue to manage
            if (totalagency!=o.ElasticSearch_Agency_Counter__c) return;
            
            //Prepare to request for Agent
            Integer totalagent= query_elastic('agent','');
            if (totalagent==0) return;
            o.ElasticSearch_Agent_Counter__c = query_elastic('agent',mydate);
            if (o.ElasticSearch_Agent_Counter__c==0) return;
            
            //issue to manage
            if (totalagent!=o.ElasticSearch_Agent_Counter__c) return;
        }
        system.debug('****scope.size()****'+scope.size());
        if (scope.size()==0) return;
        xisFailed=true;
        Try { update scope; xisFailed=false; xisOutdated=false;}
        Catch(Exception e){MsgError = 'EBC_Batch_CheckElasticSearchSync- Execute: ' + e.getMessage() + ' : ' + e.getStackTraceString();}
    }
    
    global void execute(SchedulableContext SC)  
    {
        //reschedule();
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //are we done with failure?
        System.Debug('xisFailed finish>>>'+xisFailed);
        if (Test.isRunningTest()) { xisFailed=true; xisOutdated=true;}
        if (xisFailed)
        {
            EBC_Schdl_CheckElasticSearchSync.cancel();
            //Send email to the administrator with what to check
            //Select from the EBC_Setup__c
            String technical_email='';
            List<EBC_Setup__c> setuplist = new List<EBC_Setup__c>();
            setuplist=[Select EBC_Admin_CC_Email__c From EBC_Setup__c Limit 1];
            if (setuplist.size()==1) technical_email=setuplist[0].EBC_Admin_CC_Email__c;  
            if (Test.isRunningTest()) technical_email='debonol@iata.org';
            if (String.isBlank(technical_email))  return;
            
            String body = 'Batch EBC CheckElasticSearchSync Failed. ';
            body +='\nTo Reschdule the batch form the console: EBC_Schdl_CheckElasticSearchSync.reschedule();';
            body +='\nError Message: '+MsgError;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSubject('Batch EBC CheckElasticSearchSync Failed');
            list<string> emails = new list<string>();
            if (technical_email!=null) 
            {
                emails.add(technical_email);
                email.setToAddresses(emails); email.setPlainTextBody( body );
                // Sends the email
                if (!Test.isRunningTest()) Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            
            if (!Test.isRunningTest()) return; 
        }
        System.Debug('xisOutdated finish>>>'+xisOutdated);
        if (xisOutdated)
        {
            //Send email to the administrator with what to check
            //Select from the EBC_Setup__c
            String technical_email='';
            List<EBC_Setup__c> setuplist = new List<EBC_Setup__c>();
            setuplist=[Select EBC_Admin_CC_Email__c From EBC_Setup__c Limit 1];
            if (setuplist.size()==1) technical_email=setuplist[0].EBC_Admin_CC_Email__c;  
            if (Test.isRunningTest()) technical_email='debonol@iata.org';
            if (String.isBlank(technical_email))  return;
            
            String body = 'ElasticSearch Sync Counter Date is outdated.';
            body +='\nThe Elasticsearch sync process is no longer running properly since at least 2 days, please verify in EBC Setup and call amazon team to investigate.';
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSubject('ElasticSearch Sync Counter Date is outdated');
            list<string> emails = new list<string>();
            if (technical_email!=null) 
            {
                emails.add(technical_email);
                email.setToAddresses(emails); email.setPlainTextBody( body );
                // Sends the email
                if (!Test.isRunningTest()) Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            
            if (!Test.isRunningTest()) return; 
        }
        //must be reschduled to later time
        EBC_Schdl_CheckElasticSearchSync.reschedule(); 
        
    }
   
}