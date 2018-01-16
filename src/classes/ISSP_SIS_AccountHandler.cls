/**
    Account Trigger for SIS Integration
    Selects the accounts relevant for SIS and calls the external web services 
    to create or update accounts
**/
public with sharing class ISSP_SIS_AccountHandler {
    
    public static final ID RT_AGENCY = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
    public static set<ID> ALLOWED_COUNTRIES = null;
    public static Boolean BLOCK_EXECUTION = false;

    /**
        AFTER INSERT
    **/
    public static void afterInsert(list<Account> listAccount) {
        if (BLOCK_EXECUTION) return;
        if (!ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED) return;
        list<Id> listInsertAccountId = new list<Id>();
        list<Id> listUpdateAccountId = new list<Id>();
        for (Account account: listAccount) {
            if ( validSISAccount(account) && account.Status__c != 'Terminated') {
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
                ALLOWED_COUNTRIES = new map<Id,IATA_ISO_Country__c>(
                    [SELECT Id
                    FROM IATA_ISO_Country__c
                    WHERE ISO_Code__c IN :ISSP_SIS_Account_Allowed_Countries__c.getAll().keyset()]).keyset();
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
        for (String fieldName: ISSP_WS_SIS_Callout_CreateAccount.LIST_FIELD_NAMES) {
            if (fieldName!='BillingAddress')
            if (accountNew.get(fieldName) != accountOld.get(fieldName)) {
                return true;
            }
        }
        return false;
    }
}