global class SchdlIECEBCStartCampaign implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {    
    public static final Integer BATCH_SIZE = 200;
    public Set<String> previousBatchEmail {
        get {
            if (previousBatchEmail == null) previousBatchEmail = new Set<String>();
            
            return previousBatchEmail;
        }
        set;
    }
    public String query;
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

    public static void prepare(EBC_Campaign__c c, String gaCode, String gaName, String templateExternalId, String senderProfileCustomerKey, String mailingId) {
        system.debug('prepere starting....');
        String body = vfIECEBC_Template.getTemplateHtml(c.EBC_Design__c, true, gaCode, gaName);
        IECEBC_ETTemplateCreate.updateEmailTemplate(templateExternalId, c.Subject__c, body, 'HTML');
        String noreply = IEC_Settings__c.getInstance().EBC_Send_From_Email__c;  //'ebroadcast@iata.org';'noreply@ebroadcast.iata.org';
        String senderExternalId = IECEBC_ETSenderProfileCreate.createSenderProfile(senderProfileCustomerKey, senderProfileCustomerKey, c.From_Name__c, noreply);
        String sendClassificationId = IECEBC_ETSendClassificationCreate.createSendClassification(senderProfileCustomerKey, senderProfileCustomerKey, senderExternalId);
        
        IECEBC_ETTriggeredSendDefinitionCreate.createTriggeredSendDefinition(mailingId, templateExternalId, senderProfileCustomerKey, sendClassificationId);
        IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition(mailingId);
    }
    
    // Batchable 
    global Database.QueryLocator start(Database.BatchableContext BC){
        c = [Select Id, Name, Subject__c, EBC_Design__c, Billing_Account__c, Billing_Account__r.Name, From_Name__c, Is_Google_Analytics_Tracker_Active__c, Google_Analytics_Tracking_Code__c, Send_Datetime__c From EBC_Campaign__c Where Id = :campaignId];
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
        
        if (!Test.isRunningTest())  prepare(c, gaCode, gaName, templateExternalId, senderProfileCustomerKey, mailingId);

        
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<String> newPreviousBatchEmail = new Set<String>();
        Set<String> currentBatchEmail = new Set<String>();
        
        Map<String, Map<String, String>> params = new Map<String, Map<String, String>>();
        
        
        for(sObject i : scope) {
            if (i instanceof GDP_Products_Account_View__c) {
                GDP_Products_Account_View__c a = (GDP_Products_Account_View__c)i;
                newPreviousBatchEmail.add(a.Email_Address__c);
                
                if (previousBatchEmail.contains(a.Email_Address__c) || currentBatchEmail.contains(a.Email_Address__c)) continue;
                
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
                
                String token;
                
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
        }
        
        
        previousBatchEmail = newPreviousBatchEmail;
        
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
        EBC_Campaign__c c = [Select Id, Send_Datetime__c, Name, Number_of_Recipients__c, Billing_Account__c From EBC_Campaign__c Where Id = :campaignId];
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
    
    
    // Schedulable
    public static void executeSingle() {
        List<EBC_Campaign__c> campaigns = [Select Id, EBC_Master_Filter__c, Audience__c, EBC_Design__r.External_Id__c From EBC_Campaign__c Where Status__c = 'APPROVED' AND (Scheduled_Date__c <= :Datetime.now() or Scheduled_Date__c = null)];
        for(EBC_Campaign__c campaign : campaigns) {
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
            
            
            SchdlIECEBCStartCampaign n = new SchdlIECEBCStartCampaign();
            n.query = IECEBC_Utility.getSOQLFromMasterFilter(columns, campaign.EBC_Master_Filter__c);
            n.campaignId = campaign.Id;
            n.templateExternalId = campaign.EBC_Design__r.External_Id__c;
            //if (!Test.isRunningTest()) {
                Database.executeBatch(n,SchdlIECEBCStartCampaign.BATCH_SIZE);
            //}
        }
        
        update campaigns;
    }
    global void execute(SchedulableContext SC)  {
        executeSingle();
        
        reschedule();
    }
    global static void cancel() {
        cancel('SchdlIECEBCStartCampaign' + (Test.isRunningTest() ? 'Test' : ''));
    }
    global static void cancel(String name) {
        CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
        System.abortJob(ct.Id);
    }
    
    global static void Schedule(string sch) {
        SchdlIECEBCStartCampaign a = new SchdlIECEBCStartCampaign();
        if (String.isBlank(sch)) {
            Datetime nextSchedules = Datetime.now().addMinutes(2);
            sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';
        }
        System.schedule('SchdlIECEBCStartCampaign' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
    }
    
    global static void reschedule() {
        cancel();
        
        Datetime nextSchedules = Datetime.now().addMinutes(15);
        String sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';
        
        Schedule(sch);
    }
}