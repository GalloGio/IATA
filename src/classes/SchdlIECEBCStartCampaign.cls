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
    
    // Batchable 
    global Database.QueryLocator start(Database.BatchableContext BC){
        EBC_Campaign__c c = [Select Id, Name, Subject__c, EBC_Design__c, Billing_Account__c, From_Name__c, Is_Google_Analytics_Tracker_Active__c, Google_Analytics_Tracking_Code__c, Send_Datetime__c From EBC_Campaign__c Where Id = :campaignId];
        
        String senderProfileCustomerKey = c.Id + '_'+IECEBC_Utility.generateRandomString(11);
        
        String gaCode;
        String gaName;
        if (c.Is_Google_Analytics_Tracker_Active__c) {
            gaCode = c.Google_Analytics_Tracking_Code__c;
            gaName = c.Name;
        }
        
        System.debug(gaCode);
        System.debug(gaName);
        
        String body = vfIECEBC_Template.getTemplateHtml(c.EBC_Design__c, true, gaCode, gaName);
        IECEBC_ETTemplateCreate.updateEmailTemplate(templateExternalId, c.Subject__c, body, 'HTML');
        
        String senderExternalId = IECEBC_ETSenderProfileCreate.createSenderProfile(senderProfileCustomerKey, senderProfileCustomerKey, c.From_Name__c, 'test@cubicmedia.ca'); //@todo
        String sendClassificationId = IECEBC_ETSendClassificationCreate.createSendClassification(senderProfileCustomerKey, senderProfileCustomerKey, senderExternalId);
        
        System.debug('IECEBC_ETTriggeredSendDefinitionCreate.createTriggeredSendDefinition');
        System.debug(mailingId);
        System.debug(templateExternalId);
        IECEBC_ETTriggeredSendDefinitionCreate.createTriggeredSendDefinition(mailingId, templateExternalId, senderProfileCustomerKey, sendClassificationId);
        System.debug('IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition');
        IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition(mailingId);
        
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
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL' => a.Email_Address__c,
                    'AGENCY_NAME' => a.Trading_Name__c,
                        
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
                
                params.put(campaignId + '_' + a.Email__c, new Map<String, String>{
                    'SFID' => a.Id,
                    'CAMPAIGN_ID' => campaignId,
                    'EMAIL' => a.Email__c,
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
        	IECEBC_ETEmailSend.sendMassEmail(mailingId, params);
            System.debug(IECEBC_ETEmailSend.failureDetails);
            if (IECEBC_ETEmailSend.failureDetails != null) {
                List<EBC_Email_Exclusion__c> excls = new List< EBC_Email_Exclusion__c>();
                for(String failureKey : IECEBC_ETEmailSend.failureDetails.keySet()) {
                    EBC_Email_Exclusion__c excl = new EBC_Email_Exclusion__c();
                    excl.Email__c = failureKey;
                    excl.Type__c  = 'OTHER';
                    excl.Event_Date__c = Datetime.now();
                    excl.Other_Reason__c = IECEBC_ETEmailSend.failureDetails.get(failureKey);
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
        EBC_Campaign__c c = [Select Id, Send_Datetime__c, Name From EBC_Campaign__c Where Id = :campaignId];
        c.Status__c = 'SENT';
        c.External_Id__c = mailingId;
        update c;
        
        IECEBC_ETCampaignTrackingAsync.initCampaignTrackingRecords(c); 
    }
    
    
    // Schedulable
    public static void executeSingle() {
        List<EBC_Campaign__c> campaigns = [Select Id, EBC_Master_Filter__c, Audience__c, EBC_Design__r.External_Id__c From EBC_Campaign__c Where OwnerId = '0058E000001Lwad' AND Status__c = 'APPROVED' AND (Scheduled_Date__c <= :Datetime.now() or Scheduled_Date__c = null)];
        for(EBC_Campaign__c campaign : campaigns) {
            campaign.Status__c = 'STARTED';
            campaign.Send_Datetime__c = Datetime.now();
            List<String> columns;
            if (campaign.Audience__c == 'Agent') {
                columns = new List<String>{
                    'Id',
                    'Email__c',
                    'FirstName__c',
                    'LastName__c',
                    'Agency_Name__c'
                };
            } else {
                columns = new List<String>{
                    'Id',
                    'Email_Address__c',
                    'Trading_Name__c',
                    'State_Province__c',
                    'Country_Name__c',
                    'Accreditation_Class__c',
                    'Location_Type_Name__c'
                };
            }
            
            SchdlIECEBCStartCampaign n = new SchdlIECEBCStartCampaign();
            n.query = IECEBC_Utility.getSOQLFromMasterFilter(columns, campaign.EBC_Master_Filter__c);
            n.campaignId = campaign.Id;
            n.templateExternalId = campaign.EBC_Design__r.External_Id__c;
            Database.executeBatch(n,SchdlIECEBCStartCampaign.BATCH_SIZE);
        }
        
        update campaigns;
    }
    global void execute(SchedulableContext SC)  {
        executeSingle();
        
        reschedule();
    }
    global static void cancel() {
        cancel('SchdlIECEBCStartCampaign');
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
        System.schedule('SchdlIECEBCStartCampaign', sch, a);
    }
    
    global static void reschedule() {
        cancel();
        
        Datetime nextSchedules = Datetime.now().addMinutes(15);
        String sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';
        
        Schedule(sch);
    }
}