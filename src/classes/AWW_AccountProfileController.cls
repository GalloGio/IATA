public with sharing class AWW_AccountProfileController {

    @AuraEnabled
    public static Account getAccount(Id accountId){
        Account acc = [SELECT Id, RecordTypeId, RecordType.Name, Name, Quality__c,
                            IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c,
                            Sector__c, Category__c, Account_Type__c, Logo_File_ID__c,
                            Company_Logo__c, Legal_Name__c, AccountNumber, Region_formula__c,
                            AM_Account_Manager__c, AM_Account_Manager__r.Name, AM_Account_Manager__r.PPD_Tittle__c,
                            AM_Account_Manager__r.PPD_Office__c, AM_Account_Manager__r.Email, AM_Account_Manager__r.Phone,
                            AM_Account_Manager__r.MobilePhone, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                            BillingCountry, Sub_Region__c, Website
                       FROM Account
                       WHERE Id = :accountId];
                       
        return acc;
    }
        
    @AuraEnabled
    public static List<AccountWrapper> getHeadOffices(Id accountId) {
        List<Account> accounts =  [SELECT Name, IATACode__c, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.Name, Top_Parent__c
                                   FROM Account 
                                   WHERE World_Wide_Account__c = :accountId ORDER BY Name];

        List<AccountWrapper> res = new List<AccountWrapper>();
        for(Account acc : accounts) {
            res.add(new AccountWrapper(acc));
        }

        return res;
    }

    @AuraEnabled
    public static List<AccountWrapper> searchAccounts(String key, Id accountId, String typeOperation){
        List<AccountWrapper> res = new List<AccountWrapper>();
        Set<String> locationTypes = new Set<String> {'GE', 'HE', 'HO', 'AO'};
        String queryStr = 'SELECT Name, IATACode__c, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.Name, Top_Parent__c ';
        queryStr += 'FROM Account ';

        if(typeOperation == 'add') {
            queryStr += 'WHERE World_Wide_Account__c <> :accountId AND Top_Parent__c = null AND ';
        } else {
            queryStr += 'WHERE World_Wide_Account__c = :accountId AND ';
        }

        queryStr += '(Name LIKE \'%' + key +'%\' OR IATACode__c LIKE \'%' + key +'%\')';
        queryStr += ' AND Location_Type__c IN :locationTypes';

        List<Account> accs = (List<Account>) Database.query(queryStr);
        for(Account acc : accs) {
            res.add(new AccountWrapper(acc));
        }

        return res;
    }

    @AuraEnabled
    public static Response applyChangesToHierarchy(Id parentId, List<Id> childIds, String operationType){
        List<Account> accounts = new List<Account>();
        Id valueToApply = operationType == 'add' ? parentId : null;
        for(Id accountId : childIds) {
            accounts.add(new Account(Id= accountId, World_Wide_Account__c= valueToApply));
        }

        try {
            update accounts;
            return new Response(true, 'Success');
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    @AuraEnabled 
    public static List<KeyContact> getKeyContacts(Id accountId) {
        List<Contact> keyContacts = searchKeyContacts(accountId);

        List<KeyContact> keyContactsWrapper = new List<KeyContact>();
        for(Contact con : keyContacts) {
            keyContactsWrapper.add(new KeyContact(con));
        }
        return keyContactsWrapper;
    }

    public static List<Contact> searchKeyContacts(Id accountId) {
        List<Account> topParents = [SELECT Id FROM Account WHERE World_Wide_Account__c = :accountId];
        List<Contact> keyContacts = [SELECT Id, AccountId, Account.Top_Parent__c, Name, Title, Email,
                                        Phone, Function__c, Airline_Contact_Type__c, MobilePhone,
                                        Account.Name, Account.Site, CEO_CFO__c, Invoicing_Contact__c,
                                        BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c,
                                        Authorized_Signatory__c
                                     FROM Contact
                                     WHERE Account_Management_Key_Contact__c = true AND 
                                        (AccountId IN :topParents OR Account.Top_Parent__c IN :topParents) 
                                     ORDER BY Name, Key_Contacts_Order__c];
        
        return keyContacts;
    }

    @AuraEnabled
    public static Id getReportId(){
        return [SELECT Id FROM Report WHERE DeveloperName = 'AGM_Key_Contacts_DO_NOT_EDIT' LIMIT 1].Id;
    }

    public class AccountWrapper {
        @AuraEnabled public Id topParentId {get;set;}
        @AuraEnabled public Id accountId {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String accountLink {get;set;}
        @AuraEnabled public String locationType {get;set;}
        @AuraEnabled public String iataCode {get;set;}
        @AuraEnabled public String country {get;set;}

        public AccountWrapper(Account acc) {
            this.topParentId = acc.Top_Parent__c;
            this.accountId = acc.Id;
            this.accountName = acc.Name;
            this.accountLink = '/' + acc.Id;
            this.locationType = acc.Location_Type__c;
            this.iataCode = acc.IATACode__c;
            this.country = acc.IATA_ISO_Country__c == null ? '' : acc.IATA_ISO_Country__r.Name;
        }
    }

    public class Response {
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}

        public Response(Boolean isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

    public class KeyContact {
        @AuraEnabled public Id contactId {get;set;}
        @AuraEnabled public String contactLink {get;set;}
        @AuraEnabled public String contactName {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String accountLink {get;set;}
        @AuraEnabled public String accountSite {get;set;}
        @AuraEnabled public String contactType {get;set;}
        @AuraEnabled public String primaryFor {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String phone {get;set;}
        @AuraEnabled public String mobile {get;set;}
        @AuraEnabled public String email {get;set;}

        public KeyContact(Contact con) {
            this.contactId = con.Id;
            this.contactLink = '/' + con.Id;
            this.contactName = con.Name;
            this.accountName = con.Account.Name;
            this.accountLink = '/' + con.AccountId;
            this.accountSite = con.Account.Site;
            this.contactType = con.Airline_Contact_Type__c;
            this.primaryFor = String.isBlank(con.Function__c) ? '' : con.Function__c.replace(';', '; ');
            this.title = con.Title;
            this.phone = con.Phone;
            this.mobile = con.MobilePhone;
            this.email = con.Email;
        }
    }
}