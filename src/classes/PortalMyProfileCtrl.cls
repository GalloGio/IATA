public without sharing class PortalMyProfileCtrl {

    /* 
    * @description Return the Contact Details.
    * @params 
    * @return Contact
    */
    @AuraEnabled
    public static Contact getContactInfo() {
        User loggedUser = CSP_Utils.getLoggedUser();

        return [SELECT Id, Name, Title, DSE__DS_Company__c, Email 
                FROM Contact
                WHERE Id = :loggedUser.contactId];
    }
}