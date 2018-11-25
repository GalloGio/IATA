/*
 *  Author: Abdellah Bellahssan
 *  Date: 28-09-2018
 *  Web service to start the campaign send program
 */
@RestResource(urlMapping='/EBC/Campaign/Initialize')
global with sharing class EBC_Campaign_InitializeWS {

  @HttpPost 
  global static void PostEBC_Campaign_InitializeWS() {
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
            processlist[0].Process_Status__c='Initialization';
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
        List<String> columns=new List<String>();
        if (campaign.Audience__c == 'Agent') columns = new List<String>{'Id','Email__c','FirstName__c','LastName__c','Agency_Name__c'};
        if (campaign.Audience__c != 'Agent')
            columns = new List<String>{
                'Id',
                'Email_Address__c',
                'EBC_Agency_Name__c',
                'State_Province__c',
                'Country_Name__c',
                'Accreditation_Class__c',
                'Location_Type_Name__c'
            };
           
        listfields = String.join(columns, ', ');
        //elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
    
        campaignId = campaign.Id;
        templateExternalId = campaign.EBC_Design__r.External_Id__c;
            
        //find the controller email recipient only if the client wants to be notified
        List<EBC_Preference__c> client_email_list = new List<EBC_Preference__c>();
        client_email_list = [Select PrimaryContact_Email__c,
                               Notify_On_Send__c 
                          From EBC_Preference__c 
                          Where Billing_Account__c=:campaign.Billing_Account__c];
        if (client_email_list.size()>0) { client_email= (client_email_list[0].Notify_On_Send__c ? client_email_list[0].PrimaryContact_Email__c:'');}
        
        //find the client email recipient
        List<EBC_Setup__c> admin_email_list = new List<EBC_Setup__c>();           
        admin_email_list = [Select EBC_Admin_CC_Email__c From EBC_Setup__c Limit 1];
        if (admin_email_list.size()>0) admin_email=admin_email_list[0].EBC_Admin_CC_Email__c;
      
        List<EBC_Campaign_Emails__c> emails= new List<EBC_Campaign_Emails__c>();
    
        //Run the Query against the elastic search first then create the Query with first and last Id
        //Call out to ealstic search
        EBC_Master_Filter__c masterFilter = [Select Id,
                                               Name,
                                               Audience__c,
                                               Geo_Condition__c,
                                               Refinement_Condition__c,
                                               Billing_Account__c,
                                               IATA_Codes__c,
                                               (
                                                   Select Id,
                                                   Field_Name__c,
                                                   Field_Operator__c,
                                                   Field_Value__c,
                                                   EBC_Application_Filter__r.Filter_Field__c,
                                                   EBC_Application_Filter__r.Search_Level__c,
                                                   EBC_Application_Filter__r.Filter_RelatedList__c,
                                                   EBC_Application_Filter__r.Filter_RelatedList_Field__c
                                                   From EBC_Customer_Filters__r
                                               )
                                               FROM EBC_Master_Filter__c
                                               Where Id=:campaign.EBC_Master_Filter__c
                                               Limit 1];    
          //Build the query by requesting to extract section every salesforce ids
          //the result is going to look like this
          /*{
            "email_counter": 130301,
            "request_counter": 652,
            "ids": [
            "a406E0000004NUlQAM",
            "a406E0000004cSvQAI",....
            ]
            }
            */
          es_query = EBC_Campaign_Elastic.ES_getSOQLFromMasterFilter(masterFilter, 'sections', '[x]', '1000');
          System.debug('es_query:'+es_query);
          if (Source.elastic_query!='') es_query=Source.elastic_query;
          //String new_query =es_query.replace('[x]','');
          
          /*
          //run the query against elastic search database
          EBC_Campaign_Counter req_elastic = new EBC_Campaign_Counter();
          //return the number of salesforce ids
          if (Source.elastic_query!='') new_query=Source.elastic_query;
          TotalIds = req_elastic.execute(new_query,'list', Test.isRunningTest());
          TotalIds = req_elastic.listResult.Ids.Size();
          */

          List<EBC_Campaign_Emails__c> delete_emails= new List<EBC_Campaign_Emails__c>();
          delete_emails = [Select Id 
                    From EBC_Campaign_Emails__c 
                    Where EBC_Campaign__c=:campaign.Id
                    and Add_recipient__c=true
                    and Group_Email__c=0
                   ];

          //client email
          EBC_Campaign_Emails__c new_client_email = new EBC_Campaign_Emails__c();
          new_client_email.EBC_Campaign__c=campaign.Id;
          new_client_email.Group_Email__c=0;
          new_client_email.Add_recipient__c=true;
          new_client_email.Email__c=client_email;
          new_client_email.SFDC_Id__c='CLIENT';
          new_client_email.GDP_Products_Account_View__c=null;
          new_client_email.ID_Card__c=null;
          if (client_email!=null && client_email!='') emails.add(new_client_email);

          //client email
          EBC_Campaign_Emails__c new_admin_email = new EBC_Campaign_Emails__c();
          new_admin_email.EBC_Campaign__c=campaign.Id;
          new_admin_email.Group_Email__c=0;
          new_admin_email.Add_recipient__c=true;
          new_admin_email.Email__c=admin_email;
          new_admin_email.SFDC_Id__c='ADMINISTRATOR';
          new_admin_email.GDP_Products_Account_View__c=null;
          new_admin_email.ID_Card__c=null;
          if (admin_email!=null && admin_email!='') emails.add(new_admin_email);
          //extract first and last ids from the returned array
          //create the different section by adding 
          //delete first old query list of sections where email is equal to ebc-batch-delimitor@ebroadcast.iata.org
          /*
          emails = [Select Id 
                    From EBC_Campaign_Emails__c 
                    Where EBC_Campaign__c=:campaign.Id
                    and Email__c='ebc-batch-delimitor@ebroadcast.iata.org'
                   ];
          
          System.Debug('req.listResult.Ids>>>'+req_elastic.listResult.Ids);
          System.Debug('TotalIds>>>'+TotalIds);
          //collect all the salesforce ids to perform callout on 
          //the different range of ids.
          boolean isGDP = campaign.Audience__c != 'Agent'? true:false;
          
          if (isTest){
              List<GDP_Products_Account_View__c> gdp_list =  new List<GDP_Products_Account_View__c>();
              gdp_list = [Select Id From GDP_Products_Account_View__c Where Email_Address__c!=null Limit 1];
              if (isGDP) req_elastic.listResult.Ids[0]=gdp_list[0].Id;
              List<ID_Card__c> card_list =  new List<ID_Card__c>();
              card_list = [Select Id From ID_Card__c Where Email__c!=null Limit 1];
              if (!isGDP) req_elastic.listResult.Ids[0]=card_list[0].Id;
          }
          for(integer i=0; i<TotalIds; i++){
              
              EBC_Campaign_Emails__c new_email = new EBC_Campaign_Emails__c();
              new_email.EBC_Campaign__c=campaign.Id;
              new_email.Add_recipient__c= (i==0? true:false);
              new_email.Email__c='ebc-batch-delimitor@ebroadcast.iata.org';
              new_email.SFDC_Id__c=String.ValueOf(i);
              if (isGDP) new_email.GDP_Products_Account_View__c=req_elastic.listResult.Ids[i];
              if (!isGDP) new_email.ID_Card__c=req_elastic.listResult.Ids[i];
              emails.add(new_email);
              if (isTest) break;
          }*/
          
      Source.elastic_query=es_query;
      Source.Ids=''; //String.join(req_elastic.listResult.Ids, ',') ;
  
      //final process is under try and catch
      try {
          if (Source.isError) throw new IsErrorException('Force Error Exception.');
          update processlist;
          if (delete_emails.size()>0) delete delete_emails;
          if (emails.size()>0) insert emails;

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