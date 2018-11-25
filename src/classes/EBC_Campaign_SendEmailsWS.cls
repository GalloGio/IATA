/*
 *  Author: Abdellah Bellahssan
 *  Date: 28-09-2018
 *  Web service to start the campaign send program
 */
@RestResource(urlMapping='/EBC/Campaign/SendEmails')
global with sharing class EBC_Campaign_SendEmailsWS {

  @HttpPost 
  global static void PostEBC_Campaign_SendEmailsWS() {
      String NO_DATA='No Campaign available.';
      SourceData Source = new SourceData();
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response;

      if (req.requestBody==null) return;
      String jsonreq=req.requestBody.toString();
      Source = (SourceData) System.JSON.deserialize(jsonreq, SourceData.class);
    
      Integer BATCH_SIZE = 1;
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
        EBC_Campaign__c campaign=campaignlist[0];
        
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
            processlist[0].Process_Status__c='Email Blast';
            try{
                processlist[0].Process_Request__c=jsonreq;
            }Catch(Exception e){
                processlist[0].Process_Request__c='Request too long';
            }
        }
        Source.isFinished=false;
        List<EBC_Campaign_Emails__c> new_scope = new List<EBC_Campaign_Emails__c>();
        Map<String, Map<String, String>> params = new Map<String, Map<String, String>>();
        String mailingId = 'FINAL_' + Source.campaignId + '_'+IECEBC_Utility.generateRandomString(11);
        Boolean isAuthorized=false;
        if (processlist[0].Task_Status__c.equals('SEND EMAILS')) isAuthorized=true;
        if (processlist[0].Task_Status__c.equals('SEND TEST EMAILS')) isAuthorized=true;
        if (isAuthorized) {
            
            Source.Task=processlist[0].Task_Status__c;
            boolean isTest = Test.isRunningTest();
          
            List<String> columns;
            columns = new List<String>{
                'Id',
                'SFDC_Id__c',
                'Add_recipient__c',
                'Email_Sent__c',
                'Agent_Email__c',
                'FirstName__c',
                'LastName__c',
                'Agency_Name__c',
                'Agency_Email__c',
                'EBC_Agency_Name__c',
                'State_Province__c',
                'Country_Name__c',
                'Accreditation_Class__c',
                'Location_Type_Name__c'
            };
                
            Boolean IS_AGENT_QUERY=false;
            if (campaign.Audience__c == 'Agent') IS_AGENT_QUERY=true;
            String listfields = String.join(columns, ', ');
            String new_query ='';
            new_query= 'Select '+ listfields +' From EBC_Campaign_Emails__c Where EBC_Campaign__c=\''+Source.campaignId+'\' and Email_Sent__c=false and Group_Email__c='+String.ValueOf(Source.Group_Email);
            if (isTest) new_query += ' Limit 1';
            System.debug('new_query >>>'+new_query);
            new_scope=Database.Query(new_query);
         
            for(EBC_Campaign_Emails__c i : new_scope) {
                i.Email_Sent__c=true;
                String Agency_Name = i.EBC_Agency_Name__c;
                String FirstName=i.FirstName__c;
                String LastName=i.LastName__c;
                String State_Province=i.State_Province__c;
                String Country_Name=i.Country_Name__c;
                String Accreditation_Class = i.Accreditation_Class__c;
                String Location_Type_Name =i.Location_Type_Name__c;
                String Email_Address = i.Agency_Email__c;
                String Id_Enc = IECUtil.EncryptEncodeParameter(campaign.Billing_Account__c);
                String Name_Enc = IECUtil.EncryptEncodeParameter(campaign.Billing_Account__r.Name);
    
                
                if (IS_AGENT_QUERY) { Agency_Name = i.Agency_Name__c;  Email_Address=i.Agent_Email__c;}
    
                   
                if (Source.Group_Email==0){
                    //CLIENT OR ADMINSITRATOR
                    Agency_Name ='Agency Inc.';  
                    FirstName = 'Doe';
                    LastName = 'John';
                    State_Province = 'Sample State';
                    Country_Name = 'Sample Country';
                    Accreditation_Class = 'Sample Class';
                    Location_Type_Name = 'Sample Type';
                }
                params.put(Source.campaignId+ '_' + Email_Address, new Map<String, String>{
                            'SFID' => i.SFDC_Id__c,
                            'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(Source.campaignId),
                            'CAMPAIGN_ID' => Source.campaignId,
                            'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(Email_Address),
                            'EMAIL' => Email_Address,
                            'BILLINGACCOUNT_ID_ENC' => Id_Enc,
                            'BILLINGACCOUNT_NAME_ENC' => Name_Enc,
                            'AGENCY_NAME' => Agency_Name,
                            'AGENT_FIRSTNAME' => FirstName,
                            'AGENT_LASTNAME' => LastName,
                            'AGENCY_STATE' => State_Province,
                            'AGENCY_COUNTRY' => Country_Name,
                            'AGENCY_ACCREDITATIONCLASS' => Accreditation_Class,
                            'AGENCY_LOCATIONTYPE' => Location_Type_Name
                }); 
            }
      }
      //final process is under try and catch
      try {
          if (Source.isError) throw new IsErrorException('Force Error Exception.');
          update processlist;
          if (new_scope.size()>0) update new_scope;
          System.debug(params);
          System.debug('IECEBC_ETEmailSend.sendMassEmail');
          if (params.size() > 0) {
              numberOfRecipients += params.size();
              
              IECEBC_ETEmailSend.sendMassEmail(mailingId, params);
              System.debug(IECEBC_ETEmailSend.failureDetails);
              Map<String,String> failures = new Map<String,String>();
              
              if (IECEBC_ETEmailSend.failureDetails!=null) failures=IECEBC_ETEmailSend.failureDetails;
              if (Test.isRunningTest()) failures= new Map<String,String>{'lde@iata.org'=>'SPAM','Testin@iata.org'=>'Error Code: 24 SPAM Testing '};
         
              if (failures.size()>0) {
                  List<EBC_Email_Exclusion__c> excls = new List< EBC_Email_Exclusion__c>();
                  for(String failureKey : failures.keySet()) {
                      EBC_Email_Exclusion__c excl = new EBC_Email_Exclusion__c();
                      excl.Email__c = failureKey;
                      excl.Type__c  = 'OTHER';
                      excl.Event_Date__c = Datetime.now();
                      excl.Other_Reason__c = failures.get(failureKey);
                      if (excl.Type__c == 'OTHER' && excl.Other_Reason__c.indexOf('Error Code: 24 ') == 0) {
                          excl.Type__c = 'LISTDETECTIVE';
                          excl.Other_Reason__c = null;
                      }
                      excl.Source_Campaign__c = Source.campaignId;
                      excls.add(excl);
                  }
                  System.debug(excls); 
                  if (excls.size() > 0) insert excls;
                  System.debug(excls);
              }
          }

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