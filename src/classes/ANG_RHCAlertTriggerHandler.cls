public class ANG_RHCAlertTriggerHandler{

    public List<ANG_Risk_Alert__c> triggerNew = (List<ANG_Risk_Alert__c>) Trigger.new;
    public List<ANG_Risk_Alert__c> triggerOld = (List<ANG_Risk_Alert__c>) Trigger.old;

    public Map<Id, ANG_Risk_Alert__c> newMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.newMap;
    public Map<Id, ANG_Risk_Alert__c> oldMap = (Map<Id,ANG_Risk_Alert__c>) Trigger.oldMap;  

    public static final String DEFAULT_CODE = 'WW';

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
            Map<Id, Account> accounts = new Map<Id, Account>();
            Map<Id, Id> countries = new Map<Id, Id>();
            for(ANG_Risk_Alert__c a : triggerNew) accounts.put(a.ANG_Account__c, null);

            Map<String, AMS_Country_Specific_Attribute__c> configs = new Map<String, AMS_Country_Specific_Attribute__c>();
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
                                                FROM AMS_Country_Specific_Attributes__r
                                                WHERE RecordTypeId = :ANG_RHCHelper.RECTYPE_RHCATTRIBUTE)
                                            , (SELECT 
                                                Id
                                                , Name
                                                , Short_Name__c
                                                , IATACode__c
                                                , ANG_IsNewGenAgency__c
                                                , Region_formula__c
                                                , BillingCountry
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

        for(ANG_Risk_Alert__c a : triggerNew){
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
            ServiceNow_Helper.sendRequestToSNOW('Salesforce', 'ANG_RHCAlertTriggerHandler', 'sendAlertNotification', 'SFDC', 'SFDC',  e.getMessage(), 'false', 'System', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
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

       for(ANG_Risk_Alert__c ralert : [Select Id, ANG_Direction__c, ANG_Account__c,ANG_Threshold_Level__c  from ANG_Risk_Alert__c where ANG_Account__c in: accountIds and Id not in:triggerNew Order by CreatedDate ASC])
            accountAlerts.put(ralert.ANG_Account__c, ralert);
        
        for(ANG_Risk_Alert__c ralert:triggerNew){

            if(!(ralert.recordTypeId == ANG_RHCHelper.RECTYPE_RISKALERT_RHC && (ralert.ANG_Threshold_Level__c == '100%' && ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_UP) || (( ralert.ANG_Threshold_Level__c == '100%' || ralert.ANG_Threshold_Level__c == '75%' || ralert.ANG_Threshold_Level__c == '50%') && ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN )))
                continue;

                if(ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_UP){
                    toDeactivateAccounts.add(ralert.ANG_Account__c);
                }
                
                if(ralert.ANG_Direction__c == ANG_RHCHelper.RISK_ALERT_DIRECTION_DOWN){
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
}
