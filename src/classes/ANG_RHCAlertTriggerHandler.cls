public class ANG_RHCAlertTriggerHandler{

    public List<ANG_Risk_Alert__c> triggerNew = (List<ANG_Risk_Alert__c>) Trigger.new;
    public List<ANG_Risk_Alert__c> triggerOld = (List<ANG_Risk_Alert__c>) Trigger.old;

    public Map<Id, ANG_Risk_Alert__c> newMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.newMap;
    public Map<Id, ANG_Risk_Alert__c> oldMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.oldMap;  

    public Map<Id, Account> accounts;
    public Map<String, AMS_Country_Specific_Attribute__c> configs;

    public static final String DEFAULT_CODE = 'WW';

    private map<id,account> raAccMap{get;private set;}

    public final Double UPPERFLUCTUATION = 1;
    public final Double LOWERFLUCTUATION = 2;


    // ************************************************************
    // ****************** distribution methods ********************
    // ************************************************************

    public void onBeforeInsert(){
    }
    public void onAfterInsert() {
        sendAlertNotification();
        analyzeThresholdAndDirection();
        handleRedAlerts();

    }

    public void onBeforeUpdate(){
    }
    public void onAfterUpdate() {
    }

    public void onBeforeDelete(){}
    public void onAfterDelete(){}

    // ************************************************************
    // ********************* action methods ***********************
    // ************************************************************

    public void sendAlertNotification(){
        try{
            System.debug(loggingLevel.Debug, '____ [cls ANG_RHCAlertTriggerHandler - sendAlertNotification] Method Started');

            //fecth AMS Country Specifc Attributes for the accounts/countries involved
            accounts = new Map<Id, Account>();
            Map<Id, Id> countries = new Map<Id, Id>();
            for(ANG_Risk_Alert__c a : triggerNew) accounts.put(a.ANG_Account__c, null);

            configs = new Map<String, AMS_Country_Specific_Attribute__c>();

            Set<Id> newGenAccounts = new Set<Id>();
            Set<Id> legacyAccounts = new Set<Id>();
            for(IATA_ISO_Country__c c : [SELECT
                                            Id
                                            , ANG_Enable_NewGen__c
                                            , ISO_Code__c
                                            , (SELECT 
                                                ANG_Direction__c
                                                , ANG_Percentage__c
                                                , ANG_EmailTemplate_Legacy__c
                                                , ANG_EmailTemplate_NG__c
                                                , ANG_PortalNotificationTemplate__c
                                                , ANG_Create_Process_Case__c
                                                , ANG_Block_Cut_Cash_Form_of_Payment__c
                                                FROM AMS_Country_Specific_Attributes__r
                                                WHERE RecordTypeId = :ANG_RHCHelper.RECTYPE_RHCATTRIBUTE)
                                            , (SELECT 
                                                Id
                                                , Name
                                                , Guaranteed_amount__c
                                                , IATA_ISO_Country__r.Name
                                                , Short_Name__c
                                                , IATACode__c
                                                , ANG_IsNewGenAgency__c
                                                , Region_formula__c
                                                , BillingCountry
                                                , IATA_ISO_Country__c
                                                FROM Accounts_ISO_Country__r
                                                WHERE Id IN :accounts.keySet())
                                        FROM IATA_ISO_Country__c]){
                for(Account a : c.Accounts_ISO_Country__r){
                    accounts.put(a.Id, a);
                    countries.put(a.Id, c.Id);
                    if(c.ANG_Enable_NewGen__c) newGenAccounts.add(a.Id);
                    else legacyAccounts.add(a.Id);
                }
                for(AMS_Country_Specific_Attribute__c att : c.AMS_Country_Specific_Attributes__r) configs.put((c.ISO_Code__c == DEFAULT_CODE ? c.ISO_Code__c : c.Id) + att.ANG_Direction__c + att.ANG_Percentage__c, att);
            }

            if(configs.isEmpty()) return; //no configurations set, no need to check further

        //check if any of the risk alerts match the Country Specific Attributes and gather information to query other objects
        Map<ANG_Risk_Alert__c, AMS_Country_Specific_Attribute__c> alertsToNotify = new Map<ANG_Risk_Alert__c, AMS_Country_Specific_Attribute__c>();
        Set<String> emailTemplateNames = new Set<String>();
        Set<String> notificationTemplates = new Set<String>();
        map<id,ANG_Risk_Alert__c> riskAlertMap = new map<id,ANG_Risk_Alert__c>();
        List<ANG_Risk_Alert__c> orangeRiskAlerts = new List<ANG_Risk_Alert__c>();
        raAccMap = new map<id,account>();
        for(ANG_Risk_Alert__c a : triggerNew){
            
            //NEWGEN-5198
            if(a.ANG_Severity__c == 'Orange'){
                orangeRiskAlerts.add(a);
                raAccMap.put(a.id,accounts.get(a.ANG_Account__c));
            }

            String key = countries.get(a.ANG_Account__c) + a.ANG_Direction__c + a.ANG_Threshold_Level__c;
            if(!configs.containsKey(key)) key = DEFAULT_CODE + a.ANG_Direction__c + a.ANG_Threshold_Level__c;
            
            if(configs.containsKey(key)){
                AMS_Country_Specific_Attribute__c config = configs.get(key);

                alertsToNotify.put(a, config);
            riskAlertMap.put(a.ANG_Account__c,a);

                if(String.isNotEmpty(config.ANG_EmailTemplate_Legacy__c)) emailTemplateNames.add(config.ANG_EmailTemplate_Legacy__c);
                if(String.isNotEmpty(config.ANG_EmailTemplate_NG__c)) emailTemplateNames.add(config.ANG_EmailTemplate_NG__c);
            }
        }

        if(!orangeRiskAlerts.isEmpty())sendNotificationToSeniors(orangeRiskAlerts,'RTS_Notification_Manager_orange');

        //prevent breaking already existing logic
        raAccMap.clear();

            if(alertsToNotify.isEmpty()) return; //no match, no need to go further

            //Fetch email templates and RHC Information 
            
            Map<String, Id> emailTemplates = new Map<String, Id>();
            if(!emailTemplateNames.isEmpty()){
                for(EmailTemplate e : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames AND isActive = true]){
                    emailTemplates.put(e.DeveloperName, e.Id);
                }
            }

            Map<Id, ANG_RHC_Information__c> rhcInfo = new Map<Id, ANG_RHC_Information__c>();
            for(ANG_RHC_Information__c r : [SELECT 
                                            Id
                                            , CurrencyIsoCode
                                            , ANG_AccountId__c
                                            , ANG_RHC_Amount__c
                                            , ANG_ConsumedRHC__c
                                            , ANG_ConsumedRHC_Percent__c
                                            FROM ANG_RHC_Information__c
                                            WHERE ANG_AccountId__c in :accounts.keySet()]){
                rhcInfo.put(r.ANG_AccountId__c, r);
            }

        List<Portal_Applications__c> rhcServices = [SELECT Id FROM Portal_Applications__c WHERE Name =:ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE];
        Map<String, Set<Id>> rhcContacts = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(newGenAccounts, new Map<Id, Portal_Applications__c>(rhcServices).keySet()); //this sets use the 15 char id

            Map<Id, Set<Id>> portalAdmins = new Map<Id, Set<Id>>();
            for(Contact c : [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM AND (Account.Top_Parent__c IN :legacyAccounts OR AccountId IN :legacyAccounts)]){

                Id accId;
                if(legacyAccounts.contains(c.AccountId)) accId = c.AccountId;
                else if (legacyAccounts.contains(c.Account.Top_Parent__c)) accId = c.Account.Top_Parent__c;
                else continue;

                if(portalAdmins.containsKey(accId)) portalAdmins.get(accId).add(c.Id);
                else portalAdmins.put(accId, new Set<Id>{c.Id});
            }

            Map<Id, Id> contactAccounts = new Map<Id, Id>();
            List<ANG_RHCHelper.Email> mailList = new List<ANG_RHCHelper.Email>();
            List<Case> processCases = new List<Case>();
            List<String> notificationTargets = new List<String>();
            Set<Id> notifiedAlerts = new Set<Id>();
            for(ANG_Risk_Alert__c a : alertsToNotify.keySet()){
                AMS_Country_Specific_Attribute__c config = alertsToNotify.get(a);

                if(portalAdmins.containsKey(a.ANG_Account__c) && !String.isEmpty(config.ANG_EmailTemplate_Legacy__c)){
                    for(Id contact : portalAdmins.get(a.ANG_Account__c)){
                        notifiedAlerts.add(a.Id);
                        mailList.add(new ANG_RHCHelper.Email(contact, rhcInfo.get(a.ANG_Account__c).Id, emailTemplates.get(config.ANG_EmailTemplate_Legacy__c)));
                    }
                }

                String accountId = String.valueOf(a.ANG_Account__c).substring(0,15);
                if(rhcContacts.containsKey(accountId) && (!String.isEmpty(config.ANG_EmailTemplate_NG__c) || !String.isEmpty(config.ANG_PortalNotificationTemplate__c))){
                    for(Id contact : rhcContacts.get(accountId)){
                        contactAccounts.put(contact, a.ANG_Account__c);

                        if(!String.isEmpty(config.ANG_EmailTemplate_NG__c)){
                            notifiedAlerts.add(a.Id);
                            mailList.add(new ANG_RHCHelper.Email(contact, rhcInfo.get(a.ANG_Account__c).Id, emailTemplates.get(config.ANG_EmailTemplate_NG__c)));
                        }
                        if(!String.isEmpty(config.ANG_PortalNotificationTemplate__c)) notificationTargets.add(contact + ':' + config.ANG_PortalNotificationTemplate__c);
                    }
                }

            String processRecorType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;

                if(config.ANG_Create_Process_Case__c){
                    Account acc = accounts.get(a.ANG_Account__c);

                    Case c = new Case();
                    c.RecordTypeId = processRecorType;
                    c.AccountId = acc.Id;
                    c.ContactId = rhcContacts.containsKey(accountId) ? new List<Id>(rhcContacts.get(accountId))[0] : null;
                    c.Subject = (String.isEmpty(acc.Short_Name__c) ? acc.Name.left(20) : acc.Short_Name__c.left(20)) + ' - ' + acc.IATACode__c + ' - RHC 75';
                    c.Region__c = acc.Region_formula__c;
                    c.BSPCountry__c = acc.BillingCountry;
                    c.Origin = ANG_Risk_Helper.CASE_ORIGIN_INTERNAL_CASE;
                    c.CaseArea__c = ANG_Risk_Helper.CASE_AREA_CUSTOMER_SERVICE; 
                    c.Reason1__c = ANG_Risk_Helper.CASE_REASON_RHC_75;
                    c.Visible_on_ISS_Portal__c = false;

                    //make sure that the default assignment rule is used
                    c.setOptions(dmlOpts);

                    processCases.add(c);
                }
            }

        //NewGenApp Start
        System.Debug('NewGenApp Start');
        Map <Id, Account> accountMap = NewGen_Account_Statement_Helper.getAllHierarchies(accounts.keySet());
        Map <Id, Set <String>> usersPerAccount = NewGen_Account_Statement_Helper.getUsersPerAccount(accountMap.keySet(), NewGen_Account_Statement_Helper.SERVICE_RHC);

        for (Id accountId : accounts.keySet()) {
        NewGen_Account_Statement_Helper.sendPushNotification(usersPerAccount.get(accountId), Label.NewGenApp_RHC_RiskAlert_Notification, 
                new List <String> { riskAlertMap.get(accountId).ANG_Threshold_Level__c, riskAlertMap.get(accountId).ANG_Direction__c }, NewGen_Account_Statement_Helper.NAVIGATE_TO_RHC_HOME);
        }
        System.Debug('NewGenApp End');
        //NewGenApp End  

        if(!processCases.isEmpty()) insert processCases;
        if(!mailList.isEmpty()) System.enqueueJob(new ANG_RHCHelper.RiskAlertMailService(mailList, notifiedAlerts));

            if(!notificationTargets.isEmpty()){
                List<Notification__c> notifications = new List<Notification__c>();
                for(Notification__c nt : ISSP_CreateNotification.createnotification(notificationTargets, false)){
                    ANG_RHC_Information__c rhc = rhcInfo.get(contactAccounts.get(nt.Contact__c));

                    nt.Message__c = nt.Message__c
                                    .replace('#RHC_CURRENCY#', rhc.CurrencyIsoCode)
                                    .replace('#RHC_AMOUNT_USED#', (rhc.ANG_ConsumedRHC__c == null ? 0 : rhc.ANG_ConsumedRHC__c).format())
                                    .replace('#RHC_AMOUNT_TOTAL#', (rhc.ANG_RHC_Amount__c == null ? 0 : rhc.ANG_RHC_Amount__c).format())
                                    .replace('#RHC_PERCENTAGE#', (rhc.ANG_ConsumedRHC_Percent__c == null ? 0 : rhc.ANG_ConsumedRHC_Percent__c).format());

                    notifications.add(nt);
                }
                if(!notifications.isEmpty()) insert notifications;
            }
        }catch(Exception e){
            //ServiceNow_Helper.sendRequestToSNOW('Salesforce', 'ANG_RHCAlertTriggerHandler', 'sendAlertNotification', 'SFDC', 'SFDC',  e.getMessage(), 'false', 'System', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
            ServiceNow_Helper.sendRequestToSNOWSFDC('SNOW14',e);
        }
    }


    private void analyzeThresholdAndDirection(){

        Set<Id> toActivateAccounts = new Set<Id>();
        Set<Id> toDeactivateAccounts = new Set<Id>(); 
        List<Agency_Authorization__c> toUpdate = new List<Agency_Authorization__c>();

        Set<Id> accountIds = new Set<Id>();
    
        for(ANG_Risk_Alert__c ralert:triggerNew){
            accountIds.add(ralert.ANG_Account__c);
        }

        Map<Id,ANG_Risk_Alert__c> accountAlerts = new Map<Id,ANG_Risk_Alert__c>();

       for(ANG_Risk_Alert__c ralert : [Select Id, ANG_Direction__c, ANG_Account__c,ANG_Threshold_Level__c from ANG_Risk_Alert__c where RecordTypeId =:ANG_RHCHelper.RECTYPE_RISKALERT_RHC AND ANG_Account__c in: accountIds and Id not in:triggerNew Order by CreatedDate ASC])
            accountAlerts.put(ralert.ANG_Account__c, ralert);   

        for(ANG_Risk_Alert__c ralert:triggerNew){

            if(!(ralert.recordTypeId == ANG_RHCHelper.RECTYPE_RISKALERT_RHC && (ralert.ANG_Threshold_Level__c == '100%' && ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_UP) || (( ralert.ANG_Threshold_Level__c == '100%' || ralert.ANG_Threshold_Level__c == '75%' || ralert.ANG_Threshold_Level__c == '50%') && ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN )))
                continue;

                if(ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_UP){
                    String key = accounts.get(ralert.ANG_Account__c).IATA_ISO_Country__c + ANG_RHCHelper.RISK_ALERT_DIRECTION_UP + ralert.ANG_Threshold_Level__c;
                
                    if(configs.containsKey(key) && configs.get(key).ANG_Block_Cut_Cash_Form_of_Payment__c && ralert.ANG_Threshold_Level__c == '100%') continue;
                    toDeactivateAccounts.add(ralert.ANG_Account__c);
                } else if(ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN){
                    if(accountAlerts.get(ralert.ANG_Account__c) != null && accountAlerts.get(ralert.ANG_Account__c).ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_UP && accountAlerts.get(ralert.ANG_Account__c).ANG_Threshold_Level__c == '100%')
                        toActivateAccounts.add(ralert.ANG_Account__c);  
                }
            
        }

        if(!toDeactivateAccounts.isEmpty()){
            
            Map<Id, List<AMS_Agencies_relationhip__c>> toDeactivateAccountsMap = AMS_HierarchyHelper.getAccountsHierarchies(toDeactivateAccounts);
                        
            if(isEmptySetOfLists(toDeactivateAccountsMap.values())){        
                toUpdate.addAll(performFOPaction(toDeactivateAccounts,UPPERFLUCTUATION));
            }else{
                toDeactivateAccounts = ANG_AgencyChangesHelper.extractAllAccounts(toDeactivateAccountsMap);
                toUpdate.addAll(performFOPaction(toDeactivateAccounts,UPPERFLUCTUATION));
            }
        }
        
        if(!toActivateAccounts.isEmpty()){
            
            Map<Id, List<AMS_Agencies_relationhip__c>> toActivateAccountsMap = AMS_HierarchyHelper.getAccountsHierarchies(toActivateAccounts);
                        
            if(isEmptySetOfLists(toActivateAccountsMap.values())){ // does not have a hierarchy
                toUpdate.addAll(performFOPaction(toActivateAccounts,LOWERFLUCTUATION));
            }else{
                toActivateAccounts = ANG_AgencyChangesHelper.extractAllAccounts(toActivateAccountsMap);
                toUpdate.addAll(performFOPaction(toActivateAccounts,LOWERFLUCTUATION));
            }



        }

        if(!toUpdate.isEmpty())
            update toUpdate;

        Map<Id,String> accountsToCreateFOP = new Map<Id,String> ();

        for(Agency_Authorization__c aa: toUpdate){

            accountsToCreateFOP.put(aa.Account__c,aa.Status__c);
        }

        if(!accountsToCreateFOP.isEmpty())
            createChangeCodeForFOP(accountsToCreateFOP);


    }

    private List<Agency_Authorization__c> performFOPaction(Set<Id> accounts, Decimal action){

        System.debug('Performing FOP actions on accounts ' + accounts + ' with action ' + action);

        List<Agency_Authorization__c> toReturn = new List<Agency_Authorization__c>();

        String statusFOP = action == UPPERFLUCTUATION ? 'Non-Active' : 'Active';

        Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');

        List<Agency_Authorization__c> aaLst = [Select Id, ANG_FormOfPayment_ID__c, Status__c, Account__r.Is_PCI_compliant__c from Agency_Authorization__c where Account__c in :accounts and ANG_FormOfPayment_ID__c = 'CA' and recordTypeId = :formOfPaymentRT and Account__r.recordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY];

        for(Agency_Authorization__c aa: aaLst){
            
            if(aa.Status__c != statusFOP){ 
                
                if(action == LOWERFLUCTUATION){
                    aa.Status__c = statusFOP;
                }

                if(action == UPPERFLUCTUATION){
                    aa.Status__c = statusFOP;
                }
                
                toReturn.add(aa);
                
            }

        }
        
        return toReturn;

    }


    public void createChangeCodeForFOP(Map<Id,String> accountsAndStatus) {

        AMS_ChangeCodes__c changeCodeConfigPCA = AMS_ChangeCodes__c.getInstance('PCA');
        AMS_ChangeCodes__c changeCodeConfigPCR = AMS_ChangeCodes__c.getInstance('PCR');

        Set<Id> accountIds = accountsAndStatus.keySet();

        List<Agency_Applied_Change_code__c> activeChangeCodes =
            new List<Agency_Applied_Change_code__c>([SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c FROM Agency_Applied_Change_code__c WHERE Account__c IN :accountIds AND Active__c = true]);

        //map accountId -> active change code
        Map<Id, Agency_Applied_Change_code__c> accountsChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

        for (Id accId : accountIds) {
            for (Agency_Applied_Change_code__c changeCode : activeChangeCodes)
                if (changeCode.Account__c == accId)
                    accountsChangeCode.put(accId, changeCode);
        }

        List<Account> accountToCreateCC = [Select Id, Status__c, CNS_Agency__c from Account where Id in :accountIds];

        List<AMS_OSCAR_JSON.ChangeCode> listOfCCToInsert = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<AMS_OSCAR__c> oscarsToAdd = new List<AMS_OSCAR__c>();

        For(Account acctToAddCC: accountToCreateCC){

            oscarsToAdd.add(null);

            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

            AMS_ChangeCodes__c toUse = accountsAndStatus.get(acctToAddCC.Id) == 'Active' ? changeCodeConfigPCR : changeCodeConfigPCA;

            changeCode.name = toUse.Change_Code__c;
            changeCode.reasonCode = toUse.Reason_Code__c;

            if(accountsAndStatus.get(acctToAddCC.Id) == 'Active')
                changeCode.memoText ='Agent has complied to Agency Rules. Cash payment methods are reinstated.';
            else
                changeCode.memoText = 'Agent is restricted from using Cash form of payment method as all amounts Owing are higher than the Remittance Holding Capacity.';

            changeCode.reasonDesc  = toUse.Reason_Code_Description__c;


            if(changeCode.reasonCode == null && accountsChangeCode.get(acctToAddCC.Id) != null){
                changeCode.reasonCode = accountsChangeCode.get(acctToAddCC.Id).Reason_Code__c;
            }

            if(changeCode.reasonDesc == null && accountsChangeCode.get(acctToAddCC.Id) != null){
                changeCode.reasonDesc = accountsChangeCode.get(acctToAddCC.Id).Reason_Description__c;
            }

            changeCode.status  = toUse.Account_status_change__c;

            listOfCCToInsert.add(changeCode);
        }

        if(!listOfCCToInsert.isEmpty())
            AMS_ChangeCodesHelper.createAAChangeCodes(listOfCCToInsert, oscarsToAdd, accountToCreateCC, true);

    }


    private boolean isEmptySetOfLists(List<List<AMS_Agencies_relationhip__c>> setOfLists){

        if(setOfLists.isEmpty())
            return true;

        for(List<AMS_Agencies_relationhip__c> lst: setOfLists){
            if(!lst.isEmpty())
                return false;
        }

        return true;
    }

    public void handleRedAlerts(){
        List<ANG_Risk_Alert__c> redAlerts = new List<ANG_Risk_Alert__c>();
        List<RiskAlertParentCaseWrapper> wrapperList = new List<RiskAlertParentCaseWrapper>();
               

        set<id> accIdSet= new set<id>();
        for(ANG_Risk_Alert__c ra :triggerNew ){
            if(ra.recordtypeId==RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_RTS'))accIdSet.add(ra.ANG_Account__c);
        }

        if(accIdSet.isEmpty())return;

        Map<String,AMS_Country_Specific_Attribute__c> rtsConfigMap= new Map<String,AMS_Country_Specific_Attribute__c>();//iso_countr_isoCode__c =>AMS_Country_Specific_Attribute__c
        for(AMS_Country_Specific_Attribute__c csa: [
            SELECT IATA_ISO_Country__r.ISO_Code__c,ANG_Send_Email_Agent__c,ANG_Create_Sidra_Lite__c,ANG_Remove_Ticketing_Authority__c 
            FROM AMS_Country_Specific_Attribute__c 
            WHERE recordtypeId=: RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c','RTS_Risk_Alert_Notification') ]){
            rtsConfigMap.put(csa.IATA_ISO_Country__r.ISO_Code__c,csa);
        }

        if(rtsConfigMap.isEmpty())return;

        //NEEDED QUERY BECAUSE WE WEREN'T GETTING ALL FIELDS NEEDED FROM TRIGGER
        raAccMap= new map<id,account>();
        Map<Id,List<Contact>> contactsPerAccount = new Map<Id,List<Contact>>();

        for(Account acc :[
            SELECT id,Name, IATACode__c, Location_Class__c, ANG_IsNewGenAgency__c, Top_Parent__c, CurrencyIsoCode, Guaranteed_amount__c, IATA_ISO_Country__r.BSP__c,IATA_ISO_Country__r.BSP_Country_free_text__c,Remittance_frequency__c,IATA_ISO_Country__c,IATA_ISO_Country__r.Name,
                    IATA_ISO_Country__r.ISO_Code__c, Region_formula__c, IATA_ISO_Country__r.AMS_Settlement_System__c, IATA_ISO_Country__r.AMS_Settlement_System__r.Name,
        
        (SELECT ID,Name,ANG_Account__c,CurrencyIsoCode,ANG_Sidra_Lite__c,ANG_Agent_Sales__c,ANG_Is_Case_Created__c,ANG_Direction__c,ANG_email_sent__c,ANG_EventId__c,ANG_RHC_Information__c,ANG_RME_Last_Update__c,ANG_Severity__c,ANG_Threshold_Level__c
        FROM Risk_Alerts__r 
        WHERE ID IN :triggerNew
        AND ANG_Severity__c = 'Red'
        AND recordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_RTS') 
        AND ANG_Account__c IN :accIdSet
        ),
        (SELECT Id, User_Portal_Status__c, AccountId, Account.Top_Parent__c, Financial_Assessment_Contact__c
        FROM contacts
        WHERE Status__c = 'Active'
        )
        FROM ACCOUNT
        WHERE ID IN :accIdSet OR Top_Parent__c IN :accIdSet]){
            for(ANG_Risk_Alert__c ra: acc.Risk_Alerts__r){
                redAlerts.add(ra);  
                raAccMap.put(ra.id,acc);    
            }

            contactsPerAccount.put(acc.id,acc.contacts);
        }
       

        if(!redAlerts.isEmpty()){
            // NEWGEN-2005
            sendNotificationToSeniors(redAlerts,'RTS_Notification_Manager');
            // END - NEWGEN-2005

            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;


            Case smapParentCase;
            List<Case> sidraLiteCases;
            List<Case> smapParentCases = new List<Case>();
            Map<String,case> mapCaseRiskAlert = new Map<String,case>();
            Set<Id> accountsIds = new Set<Id>();
            Map<Id,Operational_Calendar__c> mapAccountOpCalendar = fetchCalendar(redAlerts);


            for(ANG_Risk_Alert__c ra: redAlerts){
                string configKey=rtsConfigMap.containsKey(raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c)?raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c:DEFAULT_CODE ;//checks if key exists in map, if not uses default key
                if(rtsConfigMap.get(configKey).ANG_Create_Sidra_Lite__c){
                    smapParentCase = new Case(
                        Region__c = raAccMap.get(ra.id).Region_formula__c,
                        Subject = 'Real Time Sales RED Alert - ' +   raAccMap.get(ra.id).IATA_ISO_Country__r.ISO_Code__c + ' - ' + raAccMap.get(ra.id).IATACode__c ,
                        AccountId = ra.ANG_Account__c,
                        Status = 'Accepted',
                        BSP_CASS__c = 'BSP',
                        Origin = 'Risk Monitoring Engine',
                        BSPCountry__c = raAccMap.get(ra.id).IATA_ISO_Country__r.Name,
                        Decision__c = 'Prejudiced Collection of Funds',
                        RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','sMAP_sales_Monitoring_Alert_Process'),
                        Suspension_Date__c = Date.today()
                    );
                    // smap date fields population
                    if( (!raAccMap.get(ra.id).ANG_IsNewGenAgency__c && (raAccMap.get(ra.id).location_class__c  == 'P' || raAccMap.get(ra.id).location_class__c  == 'D')) && !mapAccountOpCalendar.containsKey(ra.ANG_Account__c)){
                        System.debug('## This Account doesn\'t require SMAP case to have Next_Remittance_Date__c, Start_Date_of_Sales_Period__c and End_Date_of_Sales_Period__c date fields to be populated.');
                    }else if(mapAccountOpCalendar.containsKey(ra.ANG_Account__c)){
                        smapParentCase.Next_Remittance_Date__c = mapAccountOpCalendar.get(ra.ANG_Account__c).Remittance_Day__c;
                        smapParentCase.Start_Date_of_Sales_Period__c = mapAccountOpCalendar.get(ra.ANG_Account__c).First_Day__c;
                        smapParentCase.End_Date_of_Sales_Period__c = mapAccountOpCalendar.get(ra.ANG_Account__c).Last_Day__c;
                    }else {
                        ServiceNow_Helper.SNOWBody theBody = new ServiceNow_Helper.SNOWBody();
                        theBody.description = 'A RTS Red Alert was received for agency with IATA code: '+raAccMap.get(ra.id).IATACode__c +
                            ' but the SMAP and SIDRA Lite Cases failed to be created. Please check if active Operational_Calendar__c records exist for '+
                            raAccMap.get(ra.id).IATA_ISO_Country__r.AMS_Settlement_System__r.Name+' and Remittance frequency: '+
                            raAccMap.get(ra.id).Remittance_frequency__c;

                        ServiceNow_Helper.sendRequestToSNOW(theBody, 'SNOW18');               
                        System.debug('## Creating Red Alert Only - No case is created');
                        // We are not creating any case - just the alert
                        continue;                      
                    }

                    smapParentCase.setOptions(dmlOpts);
                    wrapperList.add(new RiskAlertParentCaseWrapper(ra.Id, smapParentCase));

                    //we'll get the portal approved admin or if none the ifap contact 
                    //if has parent, use parent contacts. else, use theirs
                    Id accId = (raAccMap.get(ra.id).Top_Parent__c != null && contactsPerAccount.containsKey(raAccMap.get(ra.id).Top_Parent__c)? raAccMap.get(ra.id).Top_Parent__c: ra.ANG_Account__c);

                    for(Contact con :contactsPerAccount.get(accId)){                        
                        if(con.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM){
                            smapParentCase.ContactId = con.Id;
                            break;
                        }else if(con.Financial_Assessment_Contact__c){
                            smapParentCase.ContactId = con.Id;                          
                        }
                    }
                    
                    //fallback to have one contact for the sidra lite case
                    if(smapParentCase.ContactId == null){
                        smapParentCase.ContactId = contactsPerAccount.get(accId)[0].Id;
                    }

                    smapParentCases.add(smapParentCase);
                    accountsIds.add(ra.ANG_Account__c);
                }
            }


            if(!smapParentCases.isEmpty()){
                //insert smapParentCases --> all or none = false;
                //need to store result to later interate the correct ones and then atribute the sidra case to the Alert  
                List<Database.SaveResult> resultInsSMAPcases;
                
                try{
                    resultInsSMAPcases = Database.insert(smapParentCases, false);
                }catch(Exception e){
                    // Should not happen but just in case it does we make sure risk alert creation is not rolled back
                    System.debug('## Case not created: '+e);
                }

                for(Case parentCase :smapParentCases){
                    mapCaseRiskAlert.put(parentCase.Id,parentCase);            
                }

                //Create SIDRA CASE NOW
                Case sidraLiteCase;
                Map<Id,Case> mapSMAPtoSIDRA = new Map<Id,Case>(); 
                sidraLiteCases = new List<Case>();

                //map to get account's IsoCode- used to control RTS actions
                map<id,string>  accIsoCode = new map<id,string>();

                for(Case parentCase :[Select Id, IATAcode__c,AccountId, Account.Name,Account.IATACode__c, Account.Site,Account.IATA_ISO_Country__r.ISO_Code__c, Region__c, BSPCountry__c, ParentId, OwnerId FROM Case WHERE Id IN: smapParentCases]){
                    
                    accIsoCode.put(parentCase.AccountId,parentCase.Account.IATA_ISO_Country__r.ISO_Code__c);

                    //NEWGEN-1933 fill fields on sidra case
                    sidraLiteCase = WSSidraLite.createCase(parentCase.id);
                    sidraLiteCase.Subject = 'RTS Alert' + ' - ' + parentCase.Account.IATACode__c + ' - ' + parentCase.Account.Name;
                    sidraLiteCase.Case_Remarks__c = '';
                    sidraLiteCase.Description = '';                    
                    sidraLiteCase.Region__c = parentCase.Region__c; 
                    sidraLiteCase.BSPCountry__c = parentCase.BSPCountry__c;
                    sidraLiteCase.BSP_CASS__c = 'BSP';
                    sidraLiteCase.Status = 'Open'; 
                    sidraLiteCase.Origin = 'Risk Monitoring Engine'; 
                    sidraLiteCase.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds'; 
                    sidraLiteCase.Priority = 'High'; 
                    sidraLiteCase.Reason_for_Default__c = 'Under Review';
                    sidraLiteCase.CS_Rep_Acc_DEF__c = userInfo.getUserId();
                    sidraLiteCase.OwnerId = parentCase.OwnerId;
                    //sidraLiteCase.Shut_Down_TKT_System_GDS_and_BSPlink__c = Datetime.now(); //already done on callout
                    sidraLiteCase.ContactId = smapParentCase.ContactId;
                    
                    //END -NEWGEN-1933
                    sidraLiteCases.add(sidraLiteCase);
                    mapSMAPtoSIDRA.put(parentCase.id,sidraLiteCase);
                }


                if (!sidraLiteCases.isEmpty()) {
                    insert sidraLiteCases;
                    List<ANG_Risk_Alert__c> riskAlertsToUpdate = new List<ANG_Risk_Alert__c>();
                    // Iterate through each returned result
                    for (Database.SaveResult sr : resultInsSMAPcases) {
                        if (sr.isSuccess()) {
                            for (RiskAlertParentCaseWrapper w: wrapperList) {
                                if (w.smap.Id == sr.getId()) {
                                    //because trigger is running on after inset we need a new instace and DML operation to update 
                                    riskAlertsToUpdate.add(new ANG_Risk_Alert__c(id = w.riskAlertId, 
                                        ANG_Sidra_Lite__c = mapSMAPtoSIDRA.get(sr.getId()).Id));
                                    break;
                                }
                            }
                        }
                    }

                    if(!riskAlertsToUpdate.isEmpty())
                        update riskAlertsToUpdate;  

                    //Newgen-2179 - Generate Change code (Requires a update)
                    AMS_OscarCase_RiskMgmt.EndRun();
                                       
                    list<Case> sidrasToGenerateChangeCode = new list<Case>();
                    for(Case sidraToUpdate : sidraLiteCases){
                        sidraToUpdate.Update_AIMS_DEF__c = Date.today();
                        sidraToUpdate.DEF_Approval_Rejection__c = 'Approved';
                        sidraToUpdate.SIDRA_Lite_Default_Date__c = Date.today();
                        sidraToUpdate.Reason_for_Default__c = 'Under Review';
                        sidraToUpdate.Update_AIMS_DEF__c = Datetime.now();
                        sidraToUpdate.CS_Rep_Acc_DEF__c = userInfo.getUserId();
                        sidrasToGenerateChangeCode.add(sidraToUpdate);
                    }
                    update sidrasToGenerateChangeCode;  
                    //Newgen-2179 - END

                    List<Id> caseIds = new List<Id>();
                    List<Id> accountIds = new List<Id>();
                    for (Case sLiteCase : sidraLiteCases) {
                        string configKey=rtsConfigMap.containsKey(accIsoCode.get(sLiteCase.AccountId))?accIsoCode.get(sLiteCase.AccountId):DEFAULT_CODE ;
                        if(rtsConfigMap.get(configKey).ANG_Remove_Ticketing_Authority__c){
                            caseIds.add(sLiteCase.Id);
                            accountIds.add(sLiteCase.AccountId);
                        }
                    }
                    
                    AMS_CaseTriggerHandler.SelectAgencyOnSidraCase(sidraLiteCases);
                    bspLinkCallout(caseIds, accountIds);
                }
            }
        }
    }

    private Map<Id,operational_Calendar__c> fetchCalendar(List<ANG_Risk_Alert__c> ras){

        Set<String> issOperations = new Set<String>();
        Set<String> rfs = new Set<String>();
        Map<Id,operational_Calendar__c> ocMap = new Map<Id,operational_Calendar__c>();
        for(ANG_Risk_Alert__c ra : ras){
            issOperations.add(raAccMap.get(ra.id).IATA_ISO_Country__r.AMS_Settlement_System__c);
            rfs.add(raAccMap.get(ra.id).Remittance_frequency__c);
        }

        List<Operational_Calendar__c> ops = [SELECT id,ISS_Operation__r.Name,Frequency_Code__c,First_Day__c, Last_Day__c, Remittance_Day__c   
            FROM Operational_Calendar__c 
            WHERE Frequency_Code__c IN :rfs
                AND First_Day__c <= :Date.today() 
                AND Last_Day__c >= :Date.today() 
                AND ISS_Operation__c IN :issOperations
            ];
        for(ANG_Risk_Alert__c ra : ras){
            for(Operational_Calendar__c op: ops){            
                
                if(op.ISS_Operation__c == raAccMap.get(ra.id).IATA_ISO_Country__r.AMS_Settlement_System__c &&
                    op.Frequency_Code__c == raAccMap.get(ra.id).Remittance_frequency__c){

                    ocMap.put(ra.ANG_Account__c,op);
                    break;
                }
            }
        }
        return ocMap;       
    }

    // NEWGEN-2005
    private void sendNotificationToSeniors(List<ANG_Risk_Alert__c> riskAlerts, String emailTemplate) {
        List<RTS_Senior_Manager__c> sManagers = RTS_Senior_Manager__c.getAll().values();

        if(sManagers.isEmpty()){
            System.debug('Warning: No RTS Senior Managemrs found');
            return;
        }

        if(String.isEmpty(emailTemplate)){System.debug('Warning: No email Template defined');return;}

        List<EmailTemplate> eTemplates = [SELECT Id, Subject,Body FROM EmailTemplate WHERE DeveloperName = :emailTemplate];
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];

        if (eTemplates.isEmpty() || orgWideEmail.isEmpty()) {
            System.debug('Warning: No email template or org wide email found');
            return;
        }

        List<String> toAddresses = new List<String>();
        for (RTS_Senior_Manager__c sManager: sManagers) {
            if (sManager.Active__c && String.isNotBlank(sManager.Email__c))
                toAddresses.add(sManager.Email__c);
        }

        if(toAddresses.isEmpty()){
             System.debug('Warning: No active RTS Senior Managers or valid manager\'s email found');
             return; 
        }

        EmailTemplate template = eTemplates.get(0);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(template.Subject); 
        mail.setOrgWideEmailAddressId(orgWideEmail.get(0).Id);
        for (ANG_Risk_Alert__c riskAlert: riskAlerts) {
            String tBody = template.Body;
            String agentSales = (riskAlert.ANG_Agent_Sales__c == null ? '' : String.valueOf(riskAlert.ANG_Agent_Sales__c));
            String iataCode = (raAccMap.get(riskAlert.id).IATACode__c == null ? '' : raAccMap.get(riskAlert.id).IATACode__c);
            String gAmount = (raAccMap.get(riskAlert.id).Guaranteed_amount__c == null ? '' : String.valueOf(raAccMap.get(riskAlert.id).Guaranteed_amount__c.setScale(2)));
            tBody = tBody.replace('{{agentName}}', raAccMap.get(riskAlert.id).Name);
            tBody = tBody.replace('{{iataCode}}', iataCode);
            tBody = tBody.replace('{{iataCountry}}', raAccMap.get(riskAlert.id).IATA_ISO_Country__r.Name);
            tBody = tBody.replace('{{agentSales}}', agentSales);
            tBody = tBody.replace('{{currencyIsoCode}}', (agentSales == '' ? '' : riskAlert.CurrencyIsoCode));
            tbody = tBody.replace('{{fsAmount}}', gAmount);
            
            mail.setPlainTextBody(tBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    // END - NEWGEN-2005
        

    //Remove Ticketing Authority (Deactivate in BSPLink) - NEWGEN-1925

    @Future(callout=true)
    public static void bspLinkCallout(List<Id> sidraLiteCaseIds, List<Id> accountIds) {
        List<ISSP_Web_Service_Log__c> logs = new List<ISSP_Web_Service_Log__c>();
        ISSP_Web_Service_Log__c log;
        Boolean hasError = false;
        Boolean hasSuccess = false;
        String errorMessage = '';
        String successMessage = '';
        Integer size = sidraLiteCaseIds.size();
        List<AMS_BSPLinkIntegration.Response> responses;

        
        map<id,account> accIsoCode= new map<id,account>([Select id, IATA_ISO_Country__c from account where id in:accountIds ]);//map to get account's IsoCode- used to control RTS actions


        map<string,AMS_Country_Specific_Attribute__c> rtsConfigMap= new map<string,AMS_Country_Specific_Attribute__c>();//iso_countr_isoCode__c =>AMS_Country_Specific_Attribute__c
        for(AMS_Country_Specific_Attribute__c csa:  [
            SELECT IATA_ISO_Country__r.ISO_Code__c,ANG_Send_Email_Agent__c,ANG_Create_Sidra_Lite__c,ANG_Remove_Ticketing_Authority__c 
            FROM AMS_Country_Specific_Attribute__c 
            WHERE recordtypeId=: RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c','RTS_Risk_Alert_Notification') ]){
            rtsConfigMap.put(csa.IATA_ISO_Country__c,csa);
        }
        
        //NEWGEN-2006
        Map<Id,Notification__c> notifications = new Map<Id,Notification__c>();
        List<Contact> agents = [
            SELECT Id, Name, AccountId, Account.Top_Parent__c FROM Contact WHERE AccountId in (
                SELECT id FROM Account WHERE Top_Parent__c in :accountIds OR Id in :accountIds
            ) AND User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM];
        Map<Id, List<Contact>> mapAccContacts = new Map<Id, List<Contact>>();

        for (Contact c: agents) {
            Id heId =  c.Account.Top_Parent__c != null ? c.Account.Top_Parent__c : c.AccountId;
            if (!mapAccContacts.containsKey(heId))
                mapAccContacts.put(heId, new List<Contact>());
            mapAccContacts.get(heId).add(c);
        }
        //END - NEWGEN-2006

        for (Integer i = 0; i < size; i++) {
            log = new ISSP_Web_Service_Log__c();
            log.Case__c = sidraLiteCaseIds[i];
            log.System__c = 'bsplink';
            errorMessage = 'Following locations were not deactivated in BSPLink:\n';
            successMessage = 'Following locations were deactivated successfully in BSPLink:\n';
            responses = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('UrgentDeactivation', (new List<Id>{accountIds[i]}) ,'FromSidra', sidraLiteCaseIds[i]);
            for (AMS_BSPLinkIntegration.Response r: responses) {
                if (r.result == 'Ok') {
                    successMessage = successMessage + '\n ' + r.IATACode;
                    //NEWGEN-2006
                    if (!mapAccContacts.get(accountIds[i]).isEmpty()) {
                        for (Contact c: mapAccContacts.get(accountIds[i])) {
                            string configKey=rtsConfigMap.containsKey(accIsoCode.get(accountIds[i]).IATA_ISO_Country__c)?accIsoCode.get(accountIds[i]).IATA_ISO_Country__c:DEFAULT_CODE ;
                            if(!notifications.containsKey(c.Id) && rtsConfigMap.get(configKey).ANG_Send_Email_Agent__c){
                                notifications.put(c.Id, new Notification__c(
                                    Contact__c = c.Id,
                                    Subject__c = Label.RTS_TAR_Notification_Title,
                                    Message__c = '<div style="text-align: justify">' + Label.RTS_TAR_Notification_Message.replace('{{name}}', c.Name) + Label.RTS_TAR_Notification_MessageB + '</div>',
                                    Alert_Contact_By_Email__c = true
                                ));
                            }
                        }
                    }
                    //END - NEWGEN-2006
                    hasSuccess = true;
                } else if (r.result == 'Error') {
                    hasError = true;
                    if (r.IATACode == '-') {
                        errorMessage = errorMessage + '\n' + r.description;
                    } else {
                        errorMessage = errorMessage + '\n ' + r.IATACode + ': ' + r.description;
                    }
                }
            }
            if (!hasError) {
                log.Error_Message__c = successMessage;
                log.Success__c = true; 
            }
            if (!hasSuccess) {
                log.Error_Message__c = errorMessage;
            }
            if (hasError && hasSuccess) {
                log.Error_Message__c = successMessage + '\n\n' + errorMessage;
            }
            logs.add(log);
        }// end for loop
        if (!notifications.values().isEmpty()) {
            insert notifications.values();
        }
        insert logs;
    }

    private class RiskAlertParentCaseWrapper {
        public Id riskAlertId;
        public Case smap;
        public RiskAlertParentCaseWrapper(Id riskAlertId, Case smap) {
            this.riskAlertId = riskAlertId;
            this.smap = smap;
        }
    }


}
