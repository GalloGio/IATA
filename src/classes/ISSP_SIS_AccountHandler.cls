/**
    Account Trigger for SIS Integration
    Selects the accounts relevant for SIS and calls the external web services 
    to create or update accounts
**/
public with sharing class ISSP_SIS_AccountHandler {
    
    public static final ID RT_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
    public static set<ID> ALLOWED_COUNTRIES = null;
    public static Boolean BLOCK_EXECUTION = false;
    
    public static map<String,list<ISSP_SIS_Account_Status__c>> MAP_SIS_ACCOUNT_STATUS = null;
    /**
        Get the map with the custom setting 'ISSP_SIS_Account_Status__c' or creates it if not initialized
    **/
    public static map<String,list<ISSP_SIS_Account_Status__c>> getMapSISAccountStatus() {
        //initialize map only once
        if (MAP_SIS_ACCOUNT_STATUS == null) {
            MAP_SIS_ACCOUNT_STATUS = new map<String,list<ISSP_SIS_Account_Status__c>>();
            for (ISSP_SIS_Account_Status__c setting: ISSP_SIS_Account_Status__c.getAll().values()) {
                String key = RecordTypeSingleton.getInstance().getRecordTypeId('Account', setting.Recordtype__c) + ' ' + setting.Status__c;
                list<ISSP_SIS_Account_Status__c> listSettings = MAP_SIS_ACCOUNT_STATUS.get(key);
                if (listSettings==null) {
                    listSettings = new list<ISSP_SIS_Account_Status__c>();
                }
                listSettings.add(setting);
                MAP_SIS_ACCOUNT_STATUS.put(key, listSettings);
            }
        }
        return MAP_SIS_ACCOUNT_STATUS;
    }

    /**
        BEFORE INSERT
    **/
    public static void beforeInsert(list<Account> listAccount) {
        if (BLOCK_EXECUTION) return;
        updateSISStatusFields(listAccount);
    }

    /**
        AFTER INSERT
    **/
    public static void afterInsert(list<Account> listAccount) {
        if (BLOCK_EXECUTION) return;
        if (!ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED) return;
        list<Id> listInsertAccountId = new list<Id>();
        list<Id> listUpdateAccountId = new list<Id>();
        for (Account account: listAccount) {
            if (validSISAccount(account) && (account.Status__c == 'Approved' 
                || account.Status__c == 'Cash basis/no commission' 
                || account.Status__c == 'Cash basis/with commission' 
                || account.Status__c == 'Changes processed')) {
                if (String.isBlank(account.SIS_ID__c)) {
                    listInsertAccountId.add(account.Id);
                } else {
                    listUpdateAccountId.add(account.Id);
                }
            }
        }
        if (!listInsertAccountId.isEmpty()) {
            ISSP_WS_Utilities.invokeCreateAccount(listInsertAccountId);
            BLOCK_EXECUTION = true;
        }
        if (!listUpdateAccountId.isEmpty()) {
            ISSP_WS_Utilities.invokeUpdateAccount(listUpdateAccountId);
            BLOCK_EXECUTION = true;
        }
    }
    
    /**
        BEFORE UPDATE
    **/
    public static void beforeUpdate(map<Id,Account> mapNews, map<Id,Account> mapOlds) {
        if (BLOCK_EXECUTION) return;
        updateSISStatusFields(mapNews, mapOlds);
        
        if (!ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED) return;
        list<Id> listInsertAccountId = new list<Id>();
        list<Id> listUpdateAccountId = new list<Id>();
        for (Account accountNew: mapNews.values()) {
            Account accountOld = mapOlds.get(accountNew.Id);
            if ( validSISAccount(accountNew) && isAccountModified(accountNew, accountOld)) {
                if (String.isBlank(accountNew.SIS_ID__c)) {
                    listInsertAccountId.add(accountNew.Id);
                } else {
                    listUpdateAccountId.add(accountNew.Id);
                }
                if (accountnew.Status__c == 'Terminated') {
                    accountnew.SIS_Status__c = 'TERMINATED';
                }
                if (accountnew.Status__c == 'Approved') {
                    accountnew.SIS_Status__c = 'Active';
                }
            }
        }
        if (!listInsertAccountId.isEmpty()) {
            ISSP_WS_Utilities.invokeCreateAccount(listInsertAccountId);
            BLOCK_EXECUTION = true;
        }
        if (!listUpdateAccountId.isEmpty()) {
            ISSP_WS_Utilities.invokeUpdateAccount(listUpdateAccountId);
            BLOCK_EXECUTION = true;
        }
    }
    
    /**
        Returns true only if the account is valid to be updated with SIS, Must be:
            - An AGENCY
            - Not terminated
            - to be a Validated Account
            - its country must be in the Custom setting 'ISSP SIS Account Allowed Countries'
    **/
    public static Boolean validSISAccount(Account account) {
        try {
            // if is null initialize list of allowed countries using the CS
            if (ALLOWED_COUNTRIES==null) {
                ALLOWED_COUNTRIES = new map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountryByIsoCodes(ISSP_SIS_Account_Allowed_Countries__c.getAll().keyset())).keyset();
            }
            return account.RecordtypeId==RT_AGENCY &&
                (account.Quality__c.contains('YES') || account.Quality__c.contains('015w0000001yCfW')) &&
                ALLOWED_COUNTRIES.contains(account.IATA_ISO_Country__c);
            
        } catch (Exception e) {
            System.debug('ERROR in validSISAccount for account ' + account + ' ' + e.getMessage());
            return false;
        }
    }
    
    private static Boolean isAccountModified(Account accountNew, Account accountOld) {
        //special case, status is terminated
        if (accountnew.Status__c == 'Terminated') {
            if (accountOld.Status__c == 'Terminated') {
                return false; // if the status was Terminated and is not changing, ignore the update
            } else {
                return true; // if the status changing to Terminated then update it
            }
        }

        if (accountnew.Status__c == 'Approved') {
            if (accountOld.Status__c != 'Approved') {
                return true; 
            }      
        }

        if(accountnew.Status__c == 'Approved' 
                || accountnew.Status__c == 'Cash basis/no commission' 
                || accountnew.Status__c == 'Cash basis/with commission' 
                || accountnew.Status__c == 'Changes processed') {
            for (String fieldName: ISSP_WS_SIS_Callout_CreateAccount.LIST_FIELD_NAMES) {
                if (fieldName!='BillingAddress')
                if (accountNew.get(fieldName) != accountOld.get(fieldName)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
        Populate SIS status and substatus fields bases in the custom setting 'ISSP_SIS_Account_Status__c'
    **/
    //for update select only when change Recordtype, status__c or Country
    private static void updateSISStatusFields(map<Id,Account> mapNews, map<Id,Account> mapOlds) {
        list<Account> listAccount = new list<Account>();
        for (Account accountNew: mapNews.values()) {
            Account accountOld = mapOlds.get(accountNew.Id);
            if (accountNew.RecordTypeId!=accountOld.RecordtypeId ||
                accountNew.Status__c!=accountOld.Status__c ||
                accountNew.IATA_ISO_Country__c!=accountOld.IATA_ISO_Country__c
            ) {
                listAccount.add(accountNew);
            }
        }
        updateSISStatusFields(listAccount);
    }    
    
    // for insert
    private static void updateSISStatusFields(list<Account> listAccount) {
        for (Account account: listAccount) {
            // include country objetct in the account
            account.IATA_ISO_Country__r = AMS_utils.mapCountries.get(account.IATA_ISO_Country__c);
            
            if (String.isBlank(account.SIS_Status__c) || String.isBlank(account.SIS_Sub_Status__c) ) {
                ISSP_SIS_Account_Status__c setting = findCustomSettingSISStatus(account);
                if (setting!=null) {
                    account.SIS_Status__c = setting.SIS_Status__c;
                    account.SIS_Sub_Status__c = setting.SIS_Substatus__c;
                }
            }
        }
    }
    
    /**
        Search in the map setting the one that matches the recordtype, status and country
    **/
    private static ISSP_SIS_Account_Status__c findCustomSettingSISStatus(Account account) {
        //find  custom setting
        map<String,list<ISSP_SIS_Account_Status__c>> mapSettings = getMapSISAccountStatus();
        // get list of possible Setting for a specific recordtype and status
        String key = account.RecordtypeId + ' ' + account.Status__c;
        list<ISSP_SIS_Account_Status__c> listSettings = mapSettings.get(key);
        if (listSettings==null) return null;
        ISSP_SIS_Account_Status__c allCountriesSettings = null;
        // if a list of possible settings is found select the one that includes the account country
        for (ISSP_SIS_Account_Status__c setting: listSettings) {
            if (setting.Country_ISO_Codes__c.equalsIgnoreCase('All')) {
                allCountriesSettings = setting;
            } else {
                if (setting.Country_ISO_Codes__c.contains(account.IATA_ISO_Country__r.ISO_Code__c)) {
                    return setting;
                }
            }
        }
        // if no country is found use the setting with the keyword 'All'
        return allCountriesSettings;
    }
}
