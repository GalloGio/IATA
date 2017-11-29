global class SchdlIECEBCStartCampaign implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {    
    public static final Integer BATCH_SIZE = 1;
    public Set<String> previousBatchEmail {
        get {
            if (previousBatchEmail == null) previousBatchEmail = new Set<String>();
            
            return previousBatchEmail;
        }
        set;
    }
    public String query;
    public Boolean is_runnning =false;
    public Boolean is_testing_mode = false;
    public Boolean is_email_saved = false;
    public Boolean elastic_switch=false;
    public String controller_email='';
    public String client_email='';
    public String sObj='';
    public String listfields='';
    public String es_query ='';
    
    public String firstId='';
    public String LastId='';
    public String[] ListIds;
 
    public Id campaignId;
    public String mailingId {
        get {
            if (mailingId == null) {
                mailingId = 'FINAL_' + campaignId + '_'+IECEBC_Utility.generateRandomString(11);
            }
            
            return mailingId;
        }
        set;
    }
    public String templateExternalId;
    public EBC_Campaign__c c;
    public Integer numberOfRecipients = 0;

    //prepare the template and all the exactarget required elements like:
    //Sender Profile
    //Classification
    public static void prepare(EBC_Campaign__c c, String gaCode, String gaName, String templateExternalId, String senderProfileCustomerKey, String mailingId) {
        system.debug('prepere starting....');
        String body = '';
        String noreply = ''; 
        String senderExternalId = '';
        String sendClassificationId ='';
        Boolean IsTest=!Test.isRunningTest();
        body = vfIECEBC_Template.getTemplateHtml(c.EBC_Design__c, true, gaCode, gaName);
        IECEBC_ETTemplateCreate.updateEmailTemplate(templateExternalId, c.Subject__c, body, 'HTML');
        noreply = IEC_Settings__c.getInstance().EBC_Send_From_Email__c;  //'ebroadcast@iata.org';'noreply@ebroadcast.iata.org';
        senderExternalId = IECEBC_ETSenderProfileCreate.createSenderProfile(senderProfileCustomerKey, senderProfileCustomerKey, c.From_Name__c, noreply);
        sendClassificationId = IECEBC_ETSendClassificationCreate.createSendClassification(senderProfileCustomerKey, senderProfileCustomerKey, senderExternalId);
        
        IECEBC_ETTriggeredSendDefinitionCreate.createTriggeredSendDefinition(mailingId, templateExternalId, senderProfileCustomerKey, sendClassificationId);
        IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition(mailingId);
    }
    
    // Batchable 
    global Database.QueryLocator start(Database.BatchableContext BC){
        c = [Select Id, 
                 Name, 
                 Subject__c,
                 Audience__c,
                 EBC_Master_Filter__c,
                 EBC_Design__c, 
                 Billing_Account__c, 
                 Billing_Account__r.Name, 
                 From_Name__c,
                 Is_Google_Analytics_Tracker_Active__c, 
                 Google_Analytics_Tracking_Code__c, 
                 Send_Datetime__c 
              From EBC_Campaign__c 
              Where Id = :campaignId];
        system.debug('start ... ');
        
        String senderProfileCustomerKey = c.Id + '_'+IECEBC_Utility.generateRandomString(11);
        
        String gaCode;
        String gaName;
        if (c.Is_Google_Analytics_Tracker_Active__c) {
            gaCode = c.Google_Analytics_Tracking_Code__c;
            gaName = c.Name;
        }
        
        System.debug('gaCode ' + gaCode);
        System.debug('gaName ' +gaName);
        System.debug('templateExternalId ' + templateExternalId);
        System.debug('senderProfileCustomerKey ' + senderProfileCustomerKey);
        System.debug('mailingId ' + mailingId);
        System.debug('c ' + c);
        
        if (!Test.isRunningTest() && is_email_saved==false)  prepare(c, gaCode, gaName, templateExternalId, senderProfileCustomerKey, mailingId);
       
        Integer TotalIds=0;
        
        
        
        System.debug('Query:'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<String> newPreviousBatchEmail = new Set<String>();
        Set<String> currentBatchEmail = new Set<String>();
        List<EBC_Campaign_Emails__c> emails= new List<EBC_Campaign_Emails__c>();
        String token;
        String currentId='';
        Map<String, Map<String, String>> params = new Map<String, Map<String, String>>();
        
        
        IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter();
        Boolean insert_controller_client_email = false;
        //get the current id to fetch the range of sfdc ids returned by elastic search
        sObj='GDP_Products_Account_View__c';
        for(sObject i : scope) { 
            EBC_Campaign_Emails__c o= (EBC_Campaign_Emails__c)i;
            currentId= o.SFDC_Id__c;
            if (o.ID_Card__c!=null) sObj= 'ID_CARD__c';
            if (o.Add_recepient__c) insert_controller_client_email=true;
        }
        System.debug('currentId >>>'+currentId);
        Map<String, String> client_agent=new Map<String, String>{
                    'SFID' => currentId,
                    'TOKEN' => token,
                    'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(campaignId),
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(client_email),
                    'EMAIL' => client_email,
                    'BILLINGACCOUNT_ID_ENC' => IECUtil.EncryptEncodeParameter(currentId),
                    'BILLINGACCOUNT_NAME_ENC' => IECUtil.EncryptEncodeParameter('CLIENT'),
                    'AGENCY_NAME' => 'Agency Inc.',
                    'AGENT_FIRSTNAME' => 'Doe',
                    'AGENT_LASTNAME' => 'John'
                };
         
        Map<String, String> client_agency=new Map<String, String>{
                    'SFID' => currentId,
                    'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(campaignId),
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(client_email),
                    'EMAIL' => client_email,
                    'BILLINGACCOUNT_ID_ENC' => IECUtil.EncryptEncodeParameter(currentId),
                    'BILLINGACCOUNT_NAME_ENC' => IECUtil.EncryptEncodeParameter('CLIENT'),
                    'AGENCY_NAME' => 'Agency Inc.',
                    'AGENCY_STATE' => 'Sample State',
                    'AGENCY_COUNTRY' => 'Sample Country',
                    'AGENCY_ACCREDITATIONCLASS' =>'Sample Class',
                    'AGENCY_LOCATIONTYPE' => 'Sample Type'
                };
        Map<String, String> controller_agency=new Map<String, String>{
                    'SFID' => currentId,
                    'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(campaignId),
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(controller_email),
                    'EMAIL' => controller_email,
                    'BILLINGACCOUNT_ID_ENC' => IECUtil.EncryptEncodeParameter(currentId),
                    'BILLINGACCOUNT_NAME_ENC' => IECUtil.EncryptEncodeParameter('ADMINISTRATOR'),
                    'AGENCY_NAME' => 'Agency Inc.',
                    'AGENCY_STATE' => 'Sample State',
                    'AGENCY_COUNTRY' => 'Sample Country',
                    'AGENCY_ACCREDITATIONCLASS' =>'Sample Class',
                    'AGENCY_LOCATIONTYPE' => 'Sample Type'
               };
        Map<String, String> controller_agent=new Map<String, String>{
                    'SFID' => currentId,
                    'TOKEN' => token,
                    'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(campaignId),
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(controller_email),
                    'EMAIL' => controller_email,
                    'BILLINGACCOUNT_ID_ENC' => IECUtil.EncryptEncodeParameter(currentId),
                    'BILLINGACCOUNT_NAME_ENC' => IECUtil.EncryptEncodeParameter('ADMINISTRATOR'),
                    'AGENCY_NAME' => 'Agency Inc.',
                    'AGENT_FIRSTNAME' => 'Doe',
                    'AGENT_LASTNAME' => 'John'
                };
        if (insert_controller_client_email && client_email!='' && sObj=='ID_CARD__c') params.put(campaignId + '_' + client_email,client_agent); 
        if (insert_controller_client_email && client_email!='' && sObj!='ID_CARD__c') params.put(campaignId + '_' + client_email,client_agency); 
        if (insert_controller_client_email && client_email!='') currentBatchEmail.add(client_email);
        
        if (insert_controller_client_email && controller_email!='' && sObj=='ID_CARD__c') params.put(campaignId + '_' + controller_email, controller_agent); 
        if (insert_controller_client_email && controller_email!='' && sObj!='ID_CARD__c') params.put(campaignId + '_' + controller_email, controller_agency); 
        if (insert_controller_client_email && controller_email!='') currentBatchEmail.add(controller_email);
                     
        emails = [Select Id 
                   From EBC_Campaign_Emails__c 
                   Where EBC_Campaign__c=:campaignId
                     and Email__c!='noreply@iata.com'
                     and SFDC_Id__c=:currentId
                 ];
                
        delete emails;
        emails.clear();
        
        List<SObject> new_scope = new List<SObject>();
        new_scope = scope;
        String new_es_query = es_query.replace('[x]',currentId).replace('sections', 'extract');
        Integer TotalIds = req.execute(new_es_query,'list',Test.isRunningTest());
        
        boolean isTest = Test.isRunningTest();
        String listids = String.join(req.listResult.Ids, '\',\'');
        if (isTest) listids=currentId;
            
        String new_query ='';
        new_query= 'Select '+ listfields +' From '+ sObj +' Where Id in (\''+listids+'\') Order by Id Limit '+String.ValueOf(TotalIds);
        //if (is_testing_mode)  new_query= String.format('Select {0} From {1} Where Id !=null Order by Id Limit {3}', new List<string>{listfields, sObj, '\''+listids+'\'' , String.ValueOf(TotalIds)});
        System.debug('new_query >>>'+new_query);
        if (elastic_switch) new_scope=Database.Query(new_query);
        System.debug('new_scope >>>'+new_scope);
        elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
        for(sObject i : new_scope) {
            //boolean foundid=false;
            //for(integer fi=0; fi<listIds.size(); fi++){
            //    if (listIds.get(fi)==i.Id) {foundid=true; break;}
            //}
            if (i instanceof GDP_Products_Account_View__c) {
                GDP_Products_Account_View__c a = (GDP_Products_Account_View__c)i;
                newPreviousBatchEmail.add(a.Email_Address__c);
                
                if (previousBatchEmail.contains(a.Email_Address__c) || currentBatchEmail.contains(a.Email_Address__c)) continue;
                if (is_email_saved || isTest){
                    EBC_Campaign_Emails__c new_email = new EBC_Campaign_Emails__c();
                    new_email.EBC_Campaign__c=campaignId;
                    new_email.Email__c=a.Email_Address__c;
                    new_email.GDP_Products_Account_View__c=a.Id;
                    new_email.ID_Card__c=null;
                    new_email.SFDC_Id__c=currentId;
                    emails.add(new_email);
                }
                params.put(campaignId + '_' + a.Email_Address__c, new Map<String, String>{
                    'SFID' => a.Id,
                    'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(campaignId),
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(a.Email_Address__c),
                    'EMAIL' => a.Email_Address__c,
                    'BILLINGACCOUNT_ID_ENC' => IECUtil.EncryptEncodeParameter(c.Billing_Account__c),
                    'BILLINGACCOUNT_NAME_ENC' => IECUtil.EncryptEncodeParameter(c.Billing_Account__r.Name),
                    'AGENCY_NAME' => a.EBC_Agency_Name__c,
                    'AGENCY_STATE' => a.State_Province__c,
                    'AGENCY_COUNTRY' => a.Country_Name__c,
                    'AGENCY_ACCREDITATIONCLASS' => a.Accreditation_Class__c,
                    'AGENCY_LOCATIONTYPE' => a.Location_Type_Name__c
                }); 
                
                currentBatchEmail.add(a.Email_Address__c);
            } else if (i instanceof Id_Card__c) {
                Id_Card__c a = (Id_Card__c)i;
                newPreviousBatchEmail.add(a.Email__c);
                if (previousBatchEmail.contains(a.Email__c) || currentBatchEmail.contains(a.Email__c)) continue;
                if (is_email_saved || isTest){
                    EBC_Campaign_Emails__c new_email = new EBC_Campaign_Emails__c();
                    new_email.EBC_Campaign__c=campaignId;
                    new_email.Email__c=a.Email__c;
                    new_email.GDP_Products_Account_View__c=null;
                    new_email.ID_Card__c=a.Id;
                    new_email.SFDC_Id__c=currentId;
                    emails.add(new_email);
                }
                
                
                params.put(campaignId + '_' + a.Email__c, new Map<String, String>{
                    'SFID' => a.Id,
                    'TOKEN' => token,
                    'CAMPAIGN_ID_ENC' => IECUtil.EncryptEncodeParameter(campaignId),
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL_ENC' => IECUtil.EncryptEncodeParameter(a.Email__c),
                    'EMAIL' => a.Email__c,
                    'BILLINGACCOUNT_ID_ENC' => IECUtil.EncryptEncodeParameter(c.Billing_Account__c),
                    'BILLINGACCOUNT_NAME_ENC' => IECUtil.EncryptEncodeParameter(c.Billing_Account__r.Name),
                    'AGENCY_NAME' => a.Agency_Name__c,
                    'AGENT_FIRSTNAME' => a.FirstName__c,
                    'AGENT_LASTNAME' => a.LastName__c
                });
                
                currentBatchEmail.add(a.Email__c);
            }
            CurrentId=i.Id;
        }

        previousBatchEmail = newPreviousBatchEmail;
        
        System.debug(params);
        System.debug('IECEBC_ETEmailSend.sendMassEmail');
        if (params.size() > 0 && is_email_saved) insert emails;
        if (params.size() > 0 && is_email_saved==false) {
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
                    excl.Source_Campaign__c = campaignId;
                        
                    excls.add(excl);
                }
                System.debug(excls); 
                if (excls.size() > 0) insert excls;
                System.debug(excls);
            }
        }
        
        // Send the mailing to scope
    }
    
    global void finish(Database.BatchableContext BC) {
        if (is_email_saved) return;
        EBC_Campaign__c c = [Select Id, 
                                Send_Datetime__c,
                                Name,
                                Number_of_Recipients__c,
                                Billing_Account__c
                             From EBC_Campaign__c
                             Where Id = :campaignId];
        c.Status__c = 'SENT';
        c.External_Id__c = mailingId;
        update c;
        
        EBC_Activity__c a = new EBC_Activity__c();
        a.Name = 'Campaign Adjustment';
        a.Activity_Date_Time__c = Datetime.now();
        a.Activity_Type__c = 'Adjustment';
        a.EBC_Campaign__c = c.Id;
        a.Total_Count__c = (c.Number_of_Recipients__c - numberOfRecipients);
        a.Related_Billing_Account__c = c.Billing_Account__c;
        a.Reason__c = 'Negative count on send';
        if (c.Number_of_Recipients__c > numberOfRecipients) insert a;
                    
        IECEBC_ETCampaignTrackingAsync.initCampaignTrackingRecords(c); 
    }
    
    
    // Schedulable it is called once to initate the query variable 
    // First callout the Elasticsearch database to retrieve a large amount of Agency or Agent Ids
    // available during batch process
    public static void executeSingle() {
        //Status__c = 'APPROVED' Or 
        boolean isTest = Test.isRunningTest();
        List<EBC_Campaign__c> campaigns = [Select Id,
                                            Status__c,
                                            Billing_Account__c,
                                            EBC_Master_Filter__c,
                                            Audience__c,
                                            EBC_Design__r.External_Id__c
                                           From EBC_Campaign__c 
                                           Where (Status__c = 'EMAIL RECOVER' or Status__c = 'APPROVED') 
                                             AND (Scheduled_Date__c <= :Datetime.now() or Scheduled_Date__c = null)
                                          ];
        
        for(EBC_Campaign__c campaign : campaigns) {
            boolean email_recover = false;
            String query='';
            String listfields='';
            Boolean is_email_saved=false;
            Boolean elastic_switch=false;
            String es_query='';
            String templateExternalId='';
            String controller_email='';
            String client_email='';
            Id campaignId;
            if (campaign.Status__c=='EMAIL RECOVER') email_recover=true;
            campaign.Status__c = 'STARTED';
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
            is_email_saved=email_recover;
            elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
        
 
            if (!elastic_switch)  query = IECEBC_Utility.getSOQLFromMasterFilter(columns, campaign.EBC_Master_Filter__c);
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
            List<EBC_Setup__c> controller_email_list = new List<EBC_Setup__c>();           
            controller_email_list = [Select EBC_Admin_CC_Email__c From EBC_Setup__c Limit 1];
            if (controller_email_list.size()>0) controller_email=controller_email_list[0].Id;
            if (elastic_switch) {
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
                es_query = IECEBC_Utility.ES_getSOQLFromMasterFilter(masterFilter, 'sections', '[x]', '1000');
                System.debug('es_query:'+es_query);
                String new_query =es_query.replace('[x]','');
                
                //run the query against elastic search database
                IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter();
                //return the number of salesforce ids
                Integer TotalIds = req.execute(new_query,'list', Test.isRunningTest());
                TotalIds = req.listResult.Ids.Size();
                //extract first and last ids from the returned array
                //create the different section by adding 
                //delete first old query list of sections where email is equal to noreply@iata.com
                List<EBC_Campaign_Emails__c> emails= new List<EBC_Campaign_Emails__c>();
                
                emails = [Select Id 
                            From EBC_Campaign_Emails__c 
                            Where EBC_Campaign__c=:campaign.Id
                                and Email__c='noreply@iata.com'
                          ];
                
                delete emails;
                emails.clear();
                System.Debug('req.listResult.Ids>>>'+req.listResult.Ids);
                System.Debug('TotalIds>>>'+TotalIds);
                //collect all the salesforce ids to perform callout on 
                //the different range of ids.
                boolean isGDP = campaign.Audience__c != 'Agent'? true:false;
               
                if (isTest){
                    List<GDP_Products_Account_View__c> gdp_list =  new List<GDP_Products_Account_View__c>();
                    gdp_list = [Select Id From GDP_Products_Account_View__c Limit 1];
                    if (isGDP) req.listResult.Ids[0]=gdp_list[0].Id;
                    List<ID_Card__c> card_list =  new List<ID_Card__c>();
                    card_list = [Select Id From ID_Card__c Limit 1];
                    if (!isGDP) req.listResult.Ids[0]=card_list[0].Id;
                }
                for(integer i=0; i<TotalIds; i++){
                    
                    EBC_Campaign_Emails__c new_email = new EBC_Campaign_Emails__c();
                    new_email.EBC_Campaign__c=campaign.Id;
                    new_email.Add_recepient__c= (i==0? true:false);
                    new_email.Email__c='noreply@iata.com';
                    new_email.SFDC_Id__c=req.listResult.Ids[i];
                    if (isGDP) new_email.GDP_Products_Account_View__c=req.listResult.Ids[i];
                    if (!isGDP) new_email.ID_Card__c=req.listResult.Ids[i];
                    emails.add(new_email);
                    if (isTest) break;
                }
                if (emails.size()>0) insert emails;
                //listIds = req.listResult.Ids;
                //firstId=req.listResult.Ids[0];
                //LastId=req.listResult.Ids[TotalIds-1];
                //build the salesforce Query for the Query Locator
                String OrderBy ='GDP_Products_Account_View__c';
                if (campaign.Audience__c == 'Agent') OrderBy='ID_Card__c';
                query = 'Select Id, Add_recepient__c, SFDC_Id__c, ID_Card__c,GDP_Products_Account_View__c From EBC_Campaign_Emails__c Where EBC_Campaign__c=\''+campaign.Id+'\' and Email__c=\'noreply@iata.com\' Order By '+OrderBy;
            }
            //temporary
           
            SchdlIECEBCStartCampaign n = new SchdlIECEBCStartCampaign();
            n.es_query=es_query;
            n.is_email_saved=is_email_saved;
            n.listfields = listfields;
            n.controller_email=controller_email;
            n.client_email=client_email;
            n.query=query;
            n.elastic_switch=elastic_switch;
            n.campaignId = campaignId;
            n.templateExternalId = templateExternalId;
            
            Database.executeBatch(n,1);
            if (isTest) break;
            
        }
        //temporary
        if (!Test.isRunningTest() && campaigns.size()>0) update campaigns;
    }
    global void execute(SchedulableContext SC)  {
       executeSingle();
       reschedule();
    }
    global static void cancel() {
        cancel('SchdlIECEBCStartCampaign' + (Test.isRunningTest() ? 'Test' : ''));
    }
    global static void cancel(String name) {
        List<CronTrigger> ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name like :name LIMIT 10];
        for(CronTrigger o:ct) {
            if (!Test.isRunningTest()) System.abortJob(o.Id);
        }
    }
    
    
    global static void Schedule(string sch) {
        if (String.isBlank(sch)) {
            Datetime nextSchedules = Datetime.now().addMinutes(2);
            sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';
        }
        SchdlIECEBCStartCampaign a = new SchdlIECEBCStartCampaign(); 
        try {
            System.schedule('SchdlIECEBCStartCampaign' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
        }catch(Exception e){
            
        }
        
    }
    
    global static void reschedule() {
        cancel();
        
        Datetime nextSchedules = Datetime.now().addMinutes(15);
        String sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';
        
        Schedule(sch);
    }
}