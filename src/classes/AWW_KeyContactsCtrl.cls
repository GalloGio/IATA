public with sharing class AWW_KeyContactsCtrl {

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
                                        (AccountId IN :topParents OR Account.Top_Parent__c IN :topParents OR AccountId = :accountId) 
                                     ORDER BY Name, Key_Contacts_Order__c];
        
        return keyContacts;
    }

    @AuraEnabled
    public static Id getReportId(){
        return [SELECT Id FROM Report WHERE DeveloperName = 'AGM_Key_Contacts_DO_NOT_EDIT' LIMIT 1].Id;
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
