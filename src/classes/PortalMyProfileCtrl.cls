public without sharing class PortalMyProfileCtrl {

    /*
    * @description Return the Contact Details.
    * @params
    * @return Contact
    */
    @AuraEnabled
    public static ContactWrapper getContactInfo() {
        User loggedUser = CSP_Utils.getLoggedUser();

        List<Contact> con = [SELECT Id, Name, Title, DSE__DS_Company__c, Email, Membership_Function__c, FirstName, LastName, ID_Card_Holder__c, Birthdate
        FROM Contact
        WHERE Id = :loggedUser.contactId];


        ContactWrapper wrapper = new ContactWrapper();
        wrapper.contact = con[0];

        List <ID_Card__c> cardList = [SELECT Id, VER_Number__c, Valid_To_Date__c, Photo__c, Card_Status__c, Name_on_ID_Card__c FROM ID_Card__c
        WHERE Related_Contact__c = :loggedUser.contactId
        //AND Is_Active_Card__c = :true
        ORDER BY Valid_To_Date__c DESC];

        if (!cardList.isEmpty()){
            wrapper.cardNumber = (cardList[0].VER_Number__c != null) ? cardList[0].VER_Number__c : '';
            wrapper.cardDate   = (cardList[0].Valid_To_Date__c != null) ? cardList[0].Valid_To_Date__c.format() : '';
            wrapper.cardPhoto  = (cardList[0].Photo__c != null) ? cardList[0].Photo__c : '';
            wrapper.cardName   = (cardList[0].Name_on_ID_Card__c != null) ? cardList[0].Name_on_ID_Card__c : '';
            wrapper.cardStatus = (cardList[0].Card_Status__c != null) ? cardList[0].Card_Status__c : '';
        }

        List<Account_Contact_Role__c> trainingList = [SELECT Id, (SELECT UserId__c, Username__c, Shipping_Address__c, Shipping_Address__r.Country__c, Shipping_Address__r.State_Name__c, Shipping_Address__r.Postal_Code__c, Shipping_Address__r.City_Name__c, Shipping_Address__r.Street__c, Shipping_Address__r.Street2__c FROM Training_Contact_Role_Details__r) FROM Account_Contact_Role__c WHERE Contact__c = :loggedUser.contactId AND Contact_Role_Name__c = 'Trainee'];

        //we are only expecting to have a unique account contact role with contact role name equal to trainee
        if(!trainingList.isEmpty()){
            if(!trainingList[0].Training_Contact_Role_Details__r.IsEmpty()){
                Training_Contact_Role_Details__c tcrd = trainingList[0].Training_Contact_Role_Details__r[0];
                wrapper.trainingUserId = (tcrd.UserId__c != null) ? tcrd.UserId__c : '';
                wrapper.trainingUsername = (tcrd.Username__c != null) ? tcrd.Username__c : '';
                wrapper.shippingCountry = (tcrd.Shipping_Address__r.Country__c != null) ? tcrd.Shipping_Address__r.Country__c : '';
                wrapper.shippingState = (tcrd.Shipping_Address__r.State_Name__c != null) ? tcrd.Shipping_Address__r.State_Name__c : '';
                wrapper.shippingPostalCode = (tcrd.Shipping_Address__r.Postal_Code__c != null) ? tcrd.Shipping_Address__r.Postal_Code__c : '';
                wrapper.shippingCity = (tcrd.Shipping_Address__r.City_Name__c != null) ? tcrd.Shipping_Address__r.City_Name__c : '';
                wrapper.shippingStreet1 = (tcrd.Shipping_Address__r.Street__c != null) ? tcrd.Shipping_Address__r.Street__c : '';
                wrapper.shippingStreet2 = (tcrd.Shipping_Address__r.Street2__c != null) ? tcrd.Shipping_Address__r.Street2__c : '';
                wrapper.shippingAddressId = (tcrd.Shipping_Address__c != null) ? tcrd.Shipping_Address__c : '';
                
            }
        }

        return wrapper;
    }


    public class ContactWrapper{
        @AuraEnabled
        public Contact contact;

        @AuraEnabled
        public String cardNumber;

        @AuraEnabled
        public String cardDate;

        @AuraEnabled
        public String cardPhoto;

        @AuraEnabled
        public String cardName;

        @AuraEnabled
        public String cardStatus;

        @AuraEnabled
        public String trainingUsername;

        @AuraEnabled
        public String trainingUserId;

        @AuraEnabled
        public String shippingCountry;

        @AuraEnabled
        public String shippingState;

        @AuraEnabled
        public String shippingPostalCode;

        @AuraEnabled
        public String shippingCity;

        @AuraEnabled
        public String shippingStreet1;

        @AuraEnabled
        public String shippingStreet2;

        @AuraEnabled
        public String shippingAddressId;
    }
}