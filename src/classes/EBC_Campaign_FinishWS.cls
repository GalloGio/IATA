/*
 *  Author: Abdellah Bellahssan
 *  Date: 28-09-2018
 *  Web service to start the campaign send program
 */
@RestResource(urlMapping='/EBC/Campaign/Finish')
global class EBC_Campaign_FinishWS {

  @HttpPost 
  global static void PostEBC_Campaign_FinishWS() {
      String NO_DATA='No Campaign available.';
      SourceData Source = new SourceData();
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response;

      if (req.requestBody==null) return;
      String jsonreq=req.requestBody.toString();
      Source = (SourceData) System.JSON.deserialize(jsonreq, SourceData.class);
   
      Integer BATCH_SIZE = 1;
    
      String query;
      Boolean isTest =false;
      
      //emails to be used to send to the client and the controller
      String admin_email='';
      String client_email='';
      String sObj='';
      String listfields='';
      String es_query ='';
    
      String firstId='';
      String LastId='';
      String[] ListIds;
 
      Id campaignId;
      String mailingId = 'FINAL_' + campaignId + '_'+IECEBC_Utility.generateRandomString(11);
              
      String templateExternalId;
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
            processlist[0].Process_Status__c='End';
            try{
                processlist[0].Process_Request__c=jsonreq;
            }Catch(Exception e){
                processlist[0].Process_Request__c='Request too long';
            }
            
        }
        Source.Task=processlist[0].Task_Status__c;

        EBC_Campaign__c campaign=campaignlist[0];
        system.debug('start ... ');
        
        String senderProfileCustomerKey = campaign.Id + '_'+IECEBC_Utility.generateRandomString(11);
        
        String gaCode;
        String gaName;
        if (campaign.Is_Google_Analytics_Tracker_Active__c) {gaCode = campaign.Google_Analytics_Tracking_Code__c; gaName = campaign.Name;}
        
        System.debug('gaCode ' + gaCode);
        System.debug('gaName ' +gaName);
        System.debug('templateExternalId ' + templateExternalId);
        System.debug('senderProfileCustomerKey ' + senderProfileCustomerKey);
        System.debug('mailingId ' + mailingId);
        System.debug('c ' + campaign);
        
       
        Integer TotalIds=0;

        //Begin to select emails
        boolean email_recover = false;
        boolean email_delete = false;
     
        if (campaign.Status__c=='EMAIL RECOVER') email_recover=true;
        if (campaign.Status__c=='EMAIL DELETE') email_delete=true;
        campaign.Status__c = 'STARTED';
        if (email_recover) campaign.Status__c = 'DRAFT';
        campaign.Send_Datetime__c = Datetime.now();

        campaignId = campaign.Id;

        Source.elastic_query='';
        Source.Ids='' ;
  
        //final process is under try and catch
        try {
              if (Source.isError) throw new IsErrorException('Force Error Exception.');
              update processlist;

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
    public String Ids {set;get;}
    public String campaignId {set;get;}
    public String elastic_query {set;get;}
    public Boolean isFinished {set;get;}
    public Boolean isDeleted {set;get;}
    public Boolean isAgencyCode {set;get;}
    public Integer Group_Email {set;get;}
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