/*
 *  Author: Abdellah Bellahssan
 *  Date: 28-09-2018
 *  Web service to start the campaign send program
 */
@RestResource(urlMapping='/EBC/Campaign/CreateEmails')
global class EBC_Campaign_CreateEmailsWS {

  @HttpPost 
  global static void PostEBC_Campaign_CreateEmailsWS() {
      String NO_DATA='No Campaign available.';
      boolean IS_AGENT_QUERY=false;
      SourceData Source = new SourceData();
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response;

      if (req.requestBody==null) return;
      String jsonreq=req.requestBody.toString();
      Source = (SourceData) System.JSON.deserialize(jsonreq, SourceData.class);
   
      Integer BATCH_SIZE = 1;
      //elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
      //
      Boolean isTest=Test.isRunningTest();
    
      List<EBC_Campaign__c> campaignlist = new List<EBC_Campaign__c>();
      Integer numberOfRecipients = 0;
      campaignlist = [Select Id, 
                         Status__c,
                         EBC_Master_Filter__c,
                         Audience__c,
                         EBC_Design__r.External_Id__c,                                      
                         Name, 
                         Subject__c,
                         EBC_Design__c, 
                         Billing_Account__c, 
                         Billing_Account__r.Name, 
                         From_Name__c,
                         Is_Google_Analytics_Tracker_Active__c, 
                         Google_Analytics_Tracking_Code__c, 
                         Send_Datetime__c 
                      From EBC_Campaign__c 
                      Where Id = :Source.campaignId];

        if (campaignlist.size()==0) {Source.MyException(NO_DATA,null); return;}  
      
        //Process Status Update
        List<AWS_Task__c> processlist = new List<AWS_Task__c>();
        processlist = [Select Id
                          ,Task_Status__c
                          ,Process_Status__c
                          ,Process_Request__c
                          ,Process_Response__c
                        From AWS_Task__c
                        Where Task_Campaign__c=:Source.campaignId
                        Order by CreatedDate Desc
                        Limit 1];
        if (processlist.size()>0){
            processlist[0].Process_Status__c='Email Creation';
            try{
                processlist[0].Process_Request__c=jsonreq;
            }Catch(Exception e){
                processlist[0].Process_Request__c='Request too long';
            }
        }
        Source.isFinished=false;
        List<EBC_Campaign_Emails__c> emails_deleted= new List<EBC_Campaign_Emails__c>();
        List<EBC_Campaign_Emails__c> emails= new List<EBC_Campaign_Emails__c>();
        Set<Id> clientidset = new Set<Id>();
        String idlink='GDP_Products_Account_View__c';
          
        if (processlist[0].Task_Status__c.equals('COLLECT EMAILS')) {
            
            Source.Task=processlist[0].Task_Status__c;
            EBC_Campaign__c campaign=campaignlist[0];
           
            if (campaign.Audience__c == 'Agent') IS_AGENT_QUERY=true;
            List<SObject> new_scope = new List<SObject>();
           
           
            String new_query ='';
            String new_subquery ='';
            Integer TotalIds=0;
            /*
            //run the query against elastic search database
            EBC_Campaign_Counter req_elastic = new EBC_Campaign_Counter();
          
            String elastic_query = Source.elastic_query;
            String new_es_query = elastic_query.replace('[x]',Source.Ids).replace('sections', 'extract');
            TotalIds = req_elastic.execute(new_es_query,'list',Test.isRunningTest());
          
            String listids = String.join(req_elastic.listResult.Ids, '\',\'');
            if (false){
                Source.Ids=listids;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(json.serialize(Source));
                RestContext.response.statuscode = 200;
                return;
            }
            */
            String listids = Source.Ids;
    
           
            new_query= 'Select Id From EBC_Campaign_Emails__c Where EBC_Campaign__c=\''+Source.campaignId+'\' and Email_Sent__c=false and (Group_Email__c='+String.ValueOf(Source.Group_Email)+' Or Group_Email__c=null)';
            if (isTest) new_query += ' Limit 1';
            System.debug('new_query >>>'+new_query);
            emails_deleted=Database.Query(new_query);
      
            String OrderByEmail='Email_Address__c';
            String sObj='GDP_Products_Account_View__c';
            String SearchField='Id';
          
            if (IS_AGENT_QUERY)  { sObj='ID_CARD__c'; OrderByEmail='Email__c'; idlink='ID_Card__c';}
          
            if (Source.isAgencyCode) SearchField='Agency_Code__c';
            new_query= 'Select Id,'+OrderByEmail+' From '+ sObj +' Where '+SearchField+' in (\''+listids+'\')  Order by '+OrderByEmail;
            if (listids.equals('')) new_query= 'Select Id,'+OrderByEmail+' From '+ sObj +' Limit 0';
            
            System.debug('new_query >>>'+new_query);
            new_scope=Database.Query(new_query);
            System.debug('new_scope >>>'+new_scope);
            for(sObject i : new_scope) {
              
                String email_address = (String) i.get(OrderByEmail);
                if (email_address==null) continue;
                email_address = email_address.trim();
                if (email_address.equals('')) continue;
                String[] new_emails = email_address.split('@');
                email_address = new_emails[0]+'@akatia.com';
                EBC_Campaign_Emails__c new_email = new EBC_Campaign_Emails__c();
                new_email.EBC_Campaign__c=Source.campaignId;
                new_email.Email__c=email_address;
                new_email.ID_Card__c=null;
                new_email.GDP_Products_Account_View__c=null;
                new_email.Group_Email__c=Source.Group_Email;
                new_email.Email_Sent__c=false;
                new_email.SFDC_Id__c=String.ValueOf(i.Id);
                   
                if (IS_AGENT_QUERY) new_email.ID_Card__c=i.Id;
                if (!IS_AGENT_QUERY) new_email.GDP_Products_Account_View__c=i.Id;  
                
                clientidset.add(i.Id);
                emails.add(new_email);
                System.debug('current_SFDC_Id >>>'+new_email.SFDC_Id__c);
            }
       		Source.Ids=listids;
      }
      //final process is under try and catch
      try {
          if (Source.isError) throw new IsErrorException('Force Error Exception.');
          update processlist;
          Source.isDeleted=true;
          if (emails_deleted.size()>0) {delete emails_deleted; Database.emptyRecycleBin(emails_deleted);}
          if (emails.size()>0) insert emails;
          
          List<EBC_Campaign_Emails__c> new_subscope = new List<EBC_Campaign_Emails__c>();
         
          String new_subquery ='Select Id From EBC_Campaign_Emails__c Where Group_email__c<'+String.ValueOf(Source.Group_Email)+' and EBC_Campaign__c=\''+Source.campaignId+'\' and '+idLink+'=:clientidset';
          if (clientidset.size()>0) new_subscope=Database.Query(new_subquery);
          if (new_subscope.size()>0) {delete new_subscope; Database.emptyRecycleBin(new_subscope);}
          
         
          String new_query= 'Select Id From EBC_Campaign_Emails__c Where EBC_Campaign__c=\''+Source.campaignId+'\' and Group_Email__c>'+String.ValueOf(Source.Group_Email)+' Limit 5000';
          System.debug('new_query >>>'+new_query);
          List<EBC_Campaign_Emails__c> emails_other= new List<EBC_Campaign_Emails__c>();
          emails_other=Database.Query(new_query);
   
          if (emails_other.size()>0) { Source.isDeleted =emails_other.size()<5000 ? false:true; delete emails_other;}
          

          RestContext.response.addHeader('Content-Type', 'application/json');
          RestContext.response.responseBody = Blob.valueOf(json.serialize(Source));
          RestContext.response.statuscode = 200;
       }
      Catch(Exception e)
      {
          Source.MyException(e.getMessage(),processlist);
      }
 
  }
  public class IsErrorException extends Exception {}
 
  global class SourceData
  {
    public Integer Group_Email {set;get;}
    public String Ids {set;get;}
    public String campaignId {set;get;}
    public Boolean isFinished {set;get;}
    public Boolean isDeleted {set;get;}
    public String elastic_query {set;get;}
    public Boolean isAgencyCode {set;get;}
    public String Task {set;get;}
    public Boolean isError  {set;get;}
    public SourceData(){
    }
    public String ComposeMessage(Database.Error error){
       String errormessage ='';
       if (error!=null) errormessage = error.getStatusCode() + ': ' + error.getMessage();
       if (error!=null) errormessage +=' fields that affected this error: ' + error.getFields();
       return errormessage;
    }
    public void MyException(string message, List<AWS_Task__c> processlist )  {
        if (processlist!=null && processlist.size()>0) {
            processlist[0].Process_Response__c=message;
            update processlist;
        }
        ErrorClass newerror = new ErrorClass();
        newerror.errorCode='Bad Request';
        newerror.message = message;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(json.serialize(newerror));
        RestContext.response.statuscode =400;
    }
  }
  global Class ErrorClass
   {
    public String errorCode {get;set;}
    public String message {get;set;}
  }   
}