/*
 *  Author: Abdellah Bellahssan
 *  Date: 28-09-2018
 *  Web service to delete the email registered under the given campaign
 */
@RestResource(urlMapping='/EBC/Campaign/DeleteEmails')
global class EBC_Campaign_DeleteEmailsWS {

  @HttpPost 
  global static void PostEBC_Campaign_DeleteEmailsWS() {
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
            processlist[0].Process_Status__c='Email Deletion';
            try{
                processlist[0].Process_Request__c=jsonreq;
            }Catch(Exception e){
                processlist[0].Process_Request__c='Request too long';
            }
        }
        Source.isFinished=false;
        List<EBC_Campaign_Emails__c> emails_deleted= new List<EBC_Campaign_Emails__c>();
        Boolean isAuthorized=false;
        if (processlist[0].Task_Status__c.equals('SEND EMAILS')) isAuthorized=true;
        //If there is at least one email already sent
        //this a resume send email situation
        
        List<EBC_Campaign_Emails__c> emails_sent= new List<EBC_Campaign_Emails__c>();
        emails_sent = [Select Id 
                         From EBC_Campaign_Emails__c
                         Where Email_Sent__c=true
                          and Group_Email__c>0
                          Limit 1];
        
        if (processlist[0].Task_Status__c.equals('DELETE EMAILS') && emails_sent.size()==0) isAuthorized=true;
        
        if (isAuthorized) {   
            Source.Task=processlist[0].Task_Status__c;
            EBC_Campaign__c campaign=campaignlist[0];
            if (campaign.Audience__c == 'Agent') IS_AGENT_QUERY=true;
            if (isTest) Source.Ids='';
            String new_query ='';
          
            new_query= 'Select Id From EBC_Campaign_Emails__c Where EBC_Campaign__c=\''+Source.campaignId+'\'  and (Group_Email__c>='+String.ValueOf(Source.Group_Email)+' Or Group_Email__c=null)';
            if (isTest) new_query += ' Limit 1';
            if (!isTest) new_query += ' Limit 5000';
            System.debug('new_query >>>'+new_query);
            emails_deleted=Database.Query(new_query);
        }
      //final process is under try and catch
      try {
          if (Source.isError) throw new IsErrorException('Force Error Exception.');
          update processlist;
          Source.isFinished=false;
          if (emails_deleted.size()==0) Source.isFinished=true;
          if (emails_deleted.size()>0) {delete emails_deleted; Database.emptyRecycleBin(emails_deleted);}
         
          RestContext.response.addHeader('Content-Type', 'application/json');
          RestContext.response.responseBody = Blob.valueOf(json.serialize(Source));
          RestContext.response.statuscode = 200;
      }
      Catch(Exception e)
      {
          Source.MyException(e.getMessage(), processlist);
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