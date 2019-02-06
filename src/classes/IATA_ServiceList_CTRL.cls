global without sharing class IATA_ServiceList_CTRL {
    
    @AuraEnabled
    global static List<Portal_Application_Right__c> getUserPortalServices(){
        String contactId = null;
        String userId = UserInfo.getUserId();

        User userAux = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        System.debug('@@MAC1 - userAux - '+userAux);
        if(userAux != null && userAux.ContactId != null){ contactId = userAux.ContactId; System.debug('@@MAC2 - contactId - '+contactId);}
        
        
        if(contactId == null || contactId == ''){ System.debug('@@MAC3'); return null;}
        
        List<Portal_Application_Right__c> lstApps = [SELECT Id,Portal_Application__c,Portal_Application__r.Name,
                                                     Portal_Application__r.GDPR_PrivacyStatement__c
                                                     FROM Portal_Application_Right__c WHERE Contact__c = :contactId AND Right__c = 'Access Granted'];
        System.debug('@@MAC4 - lstApps - '+lstApps);
        return lstApps;
    }

}