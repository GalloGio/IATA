public without sharing class PortalMyProfileCtrl {

    /* 
    * @description Return the Contact Details.
    * @params 
    * @return Contact
    */
    @AuraEnabled
    public static ContactWrapper getContactInfo() {
        User loggedUser = CSP_Utils.getLoggedUser();

        List<Contact> con = [SELECT Id, Name, Title, DSE__DS_Company__c, Email, Membership_Function__c
        FROM Contact
        WHERE Id = :loggedUser.contactId];


        ContactWrapper wrapper = new ContactWrapper();
        wrapper.contact = con[0];

        List <ID_Card__c> cardList = [SELECT Id, VER_Number__c, Valid_To_Date__c FROM ID_Card__c
        WHERE Related_Contact__c = :loggedUser.contactId
        AND Is_Active_Card__c = :true
        ORDER BY Valid_To_Date__c DESC];

        if (!cardList.isEmpty()){
            wrapper.cardNumber = cardList[0].VER_Number__c;
            wrapper.cardDate  = cardList[0].Valid_To_Date__c.format();
        }

        return wrapper;
    }

    @AuraEnabled
    public static List<Training_Contact_Role_Details__c> getContactTrainingInfo() {
        User loggedUser = CSP_Utils.getLoggedUser();

        List<Training_Contact_Role_Details__c> trainingsList = [SELECT Id, Name, RecordTypeId, Account_Contact_Role__r.Contact__c, Training_Name__c, Training_School__c, Training_Type__c, Completion_Date__c FROM Training_Contact_Role_Details__c
                                                    WHERE Account_Contact_Role__r.Contact__c = :loggedUser.contactId];

        return trainingsList;
    }


    public class ContactWrapper{
        @AuraEnabled
        public Contact contact;

        @AuraEnabled
        public String cardNumber;

        @AuraEnabled
        public String cardDate;

    }
}