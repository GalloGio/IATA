global without sharing class IATA_ServiceList_CTRL {
    
    @AuraEnabled
    global static List<Portal_Application_Right__c> getUserPortalServices(){
        String contactId = null;
        String userId = UserInfo.getUserId();

        User userAux = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        if(userAux != null && userAux.ContactId != null){contactId = userAux.ContactId;}
        
        
        if(contactId == null || contactId == ''){return null;}
        
        List<Portal_Application_Right__c> lstApps = [SELECT Id,Portal_Application__c,Portal_Application__r.Name,
                                                     Portal_Application__r.GDPR_PrivacyStatement__c
                                                     FROM Portal_Application_Right__c WHERE Contact__c = :contactId AND Right__c = 'Access Granted'];
        return lstApps;
    }

}