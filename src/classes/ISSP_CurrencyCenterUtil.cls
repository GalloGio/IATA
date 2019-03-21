public without sharing class ISSP_CurrencyCenterUtil {
    
    public static PageReference checkIfUserHasAccessToService(){
        User u = [SELECT Id, ContactId From User WHERE Id =: UserInfo.getUserId()];
        if(u != null){
            List<Portal_Application_Right__c> par = [SELECT Id, Terms_Acceptance__c FROM Portal_Application_Right__c 
                                                WHERE Contact__c =: u.ContactId 
                                                AND Right__c = 'Access Granted'
                                                AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
                                                AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'];
            if(par.size()==0) {
                // No access right => return to home page
                return new PageReference('/ISSP_Homepage');
            } else {
                // has access rights, check if the T&C have been accepted
                if (par[0].Terms_Acceptance__c) {
                    // has already accepted the T&C
                    stampVisitDateTime(0);
                    return null;
                } else {
                    // hasn't accepted the T&C yet, redirect to the T&C page
                    return new PageReference('/ISSP_CurrencyCenterTermsAndConditions');
                }
            }
        }

        // if this point is reached, an error occured => return to portal home page
        return new PageReference('/ISSP_Homepage');
    }

    public static void stampVisitDateTime(Integer interval){
        User u = [SELECT Id,ContactId From User WHERE Id =: UserInfo.getUserId()];
        if(u != null){
            List<Portal_Application_Right__c> parList = [SELECT Id,ICCS_Currency_Center_Current_Visit__c,ICCS_Currency_Center_Previous_Visit__c
                                                FROM Portal_Application_Right__c 
                                                WHERE Contact__c =: u.ContactId 
                                                AND Right__c = 'Access Granted'
                                                AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
                                                AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'
                                                ORDER BY LastModifiedDate DESC
                                                LIMIT 1];
            if(parList.size()>0){
                Portal_Application_Right__c par = parList[0];
                //get diff in miliseconds
                Long diff = System.now().getTime() - (par.ICCS_Currency_Center_Current_Visit__c != null ? par.ICCS_Currency_Center_Current_Visit__c.getTime() : 0);
                //convert to hours
                diff = diff / (60 * 60 * 1000);
                if(par != null && diff >= interval){
                    par.ICCS_Currency_Center_Previous_Visit__c = par.ICCS_Currency_Center_Current_Visit__c;
                    par.ICCS_Currency_Center_Current_Visit__c = System.now();
                    system.debug('*********************************************       '+par.ICCS_Currency_Center_Previous_Visit__c);
                    system.debug('*********************************************       '+par.ICCS_Currency_Center_Current_Visit__c);
                    update par;
                }
            }
        }
    }

    public static Datetime getPreviousVisitDateTime(){
        Datetime result;

        User u = [SELECT Id,ContactId From User WHERE Id =: UserInfo.getUserId()];
        if(u != null){
            List<Portal_Application_Right__c> par = [SELECT Id,ICCS_Currency_Center_Previous_Visit__c
                                                FROM Portal_Application_Right__c 
                                                WHERE Contact__c =: u.ContactId 
                                                AND Right__c = 'Access Granted'
                                                AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
                                                AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'
                                                ORDER BY LastModifiedDate DESC
                                                LIMIT 1];
            if(par.size()>0){
                result = par[0].ICCS_Currency_Center_Previous_Visit__c;
            }
            else
                result = null;
        }
        return result;
    }

    public static String getFaq2CaseTopic(){
        String result = '';
        clsDataCategoryContainer DataCategoryContainer = new clsDataCategoryContainer();
        DataCategoryContainer.lst_DataCategories.sort();
        for(Integer index = 0; index < DataCategoryContainer.lst_DataCategories.size(); index++){
            clsDataCategory cdc = DataCategoryContainer.lst_DataCategories[index];
            if (cdc.CategoryLabel == 'Currency Center'){
                result = String.valueOf(index);
            }
        }
        return result;
    }

    public static String FaqSubtopic_AirlineChargesUpdate = 'Airline_Charges__c';
    public static String FaqSubtopic_CurrencyRepatriation = 'Currency_Repatriation_Issues__c';
    public static String FaqSubtopic_RequestSurveyUpdate = 'Request_Survey_Update__c';


    public static void sendEmailsBatch(List<Currency_Center_Survey__c> surveys, String orgWideEmail, String emailTemplate){

        Map<Id,Currency_Center_Survey__c> airlineSurveyMap = new Map<Id, Currency_Center_Survey__c>();
        for(Currency_Center_Survey__c ccs: surveys){
            airlineSurveyMap.put(ccs.Airline__c, ccs);
        }

        List<Contact> accountsContacts = [SELECT Id, Name, AccountId FROM Contact
                WHERE Status__c = 'Active' AND AccountId in:airlineSurveyMap.keySet()];
        System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch accountsContacts ' + accountsContacts);

        List<Portal_Application_Right__c> parList = [SELECT Id, Name, Contact__c FROM Portal_Application_Right__c
                WHERE Contact__c in : accountsContacts AND
                Right__c = 'Access Granted' AND
                Application_Start_URL__c = '/ISSP_CurrencyCenterHome'];
        System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch parList ' + parList);

        if(!parList.isEmpty()){
            Set<Id> contactsId = new Set<Id>();
            for(Portal_Application_Right__c par: parList){
                contactsId.add(par.Contact__c);
            }

            Map<Id,List<Contact>> airlineContactsMap = new Map<Id,List<Contact>>();
            for(Contact c: accountsContacts){
                if(contactsId.contains(c.Id)){
                    List<Contact> contacts = new List<Contact>();
                    if(airlineContactsMap.containsKey(c.AccountId)){
                        contacts = airlineContactsMap.get(c.AccountId);
                    }
                    contacts.add(c);
                    airlineContactsMap.put(c.AccountId,contacts);
                }
            }
            System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch SendEmailTo ' + contactsId);

            List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :orgWideEmail LIMIT 1];
            List<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1];
            if(!owa.isEmpty() && !et.isEmpty()){
                Messaging.Email[] mailMsgs = new Messaging.Email[]{};
                List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();

                for(String airlineId : airlineSurveyMap.keySet()){
                    Id whatId = airlineSurveyMap.get(airlineId).Id;
                    if(airlineContactsMap.containsKey(airlineId)){
                        for(Contact c : airlineContactsMap.get(airlineId)){
                            Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
                            mailMsg.setOrgWideEmailAddressId(owa[0].Id);
                            mailMsg.setTargetObjectId(c.Id);
                            mailMsg.setWhatId(whatId);
                            mailMsg.setTemplateID(et[0].Id);
                            mailMsg.setSaveAsActivity(false);
                            mailMsgs.add(mailMsg);
                        }
                    }
                    else {
                        System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch SendEmailTo: No contacts for airline ' + airlineId);
                    }
                }

                if(!mailMsgs.isEmpty()){
                    try {
                        sendEmailResults = Messaging.sendEmail(mailMsgs);
                        for(Messaging.SendEmailResult ser: sendEmailResults){
                            if(!ser.isSuccess()){
                                System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch errorMessage: ' + ser.getErrors()[0].getMessage() + ' - TargetObjectId:' + ser.getErrors()[0].getTargetObjectId());
                            }
                        }
                    }
                    catch (Exception ex){
                        System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch error: ' + ex.getMessage());
                    }
                }
            }
            else{
                if(owa.isEmpty()){
                    System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch Couldn\'t find OrgWideEmailAddress \'IATA Noreply\'');
                }
                if(et.isEmpty()){
                    System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch Couldn\'t find EmailTemplate \'Currency_Center_Annual_Survey_Initial_Notification\'');
                }
            }
        }
        else{
            System.debug('jmc - ISSP_CurrencyCenterUtil.sendEmailsBatch : No contacts with access to Currency Center service');
        }
    }

    public static String batchAirlineQuery = 'SELECT Id, name, IATACode__c,'
                                            +' IATA_ISO_Country__c, IATA_ISO_Country__r.ISO_Code__c'
                                            +' FROM account '
                                            +' WHERE '
                                            +'  recordtype.developername = \'iata_airline\' ';

    public static Id rtIdAnnualSurvey = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'AnnualSurveyRecord');
    public static Id rtIdAnnualBank = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'AnnualBankRecord');
    public static Id rtIdAnnualCountryComment = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'AnnualCountryCommentRecord');
    public static Id rtIdAnnualCountry = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'AnnualCountryRecord');
    public static Id rtIdAnnualReportType = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'AnnualReportTypeRecord');
    public static Id rtIdAnnualTypeOfOperations = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'AnnualTypeOfOperationsRecord');
    public static Id rtIdMonthlySurvey = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'MonthlySurveyRecord');
    public static Id rtIdMonthlyBank = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'MonthlyBankRecord');
    public static Id rtIdMonthlyCountry = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'MonthlyCountryRecord');
    public static Id rtIdMonthlyReportType = RecordTypeSingleton.getInstance().getRecordTypeId('Currency_Center_Survey__c', 'MonthlyReportTypeRecord');
}