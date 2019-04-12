global without sharing class GDPR_RequestList_CTRL {
    
    @AuraEnabled
    global static List<Case> getUserCases(){
        String contactId = null;
        String userId = UserInfo.getUserId();

        User userAux = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        if(userAux != null && userAux.ContactId != null){contactId = userAux.ContactId;}
        
        
        if(contactId == null || contactId == ''){return null;}
        
        List<Case> lstCases = [SELECT Id,CaseNumber,Status,Data_Privacy_Rights__c,ContactId,Subject,Description 
                               FROM Case 
                               WHERE ContactId = :contactId AND DPO_Owner__c = NULL ORDER BY createddate desc];
        return lstCases;
    }
    
    @AuraEnabled
    global static List<Case> getUserCasesDPO(){
        String contactId = null;
        String userId = UserInfo.getUserId();

        User userAux = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        if(userAux != null && userAux.ContactId != null){contactId = userAux.ContactId;}
        
        
        if(contactId == null || contactId == ''){return null;}
        
        List<Case> lstCases = [SELECT Id,CaseNumber,Status,Data_Privacy_Rights__c,ContactId,Contact.Name,
                               Passenger_Name_PXNM__c,Ticket_Number_TDNR__c,Date_of_Issue_DAIS__c,Subject,Description
                               FROM Case 
                               WHERE ContactId = :contactId AND DPO_Owner__c = :contactId ORDER BY createddate desc];
        return lstCases;
    }
    
    
    
    @AuraEnabled
    global static Boolean checkIfContactIsDPO(){
        String contactId = null;
        String userId = UserInfo.getUserId();

        User userAux = [SELECT Id, ContactId,Contact.Data_Protection_Officer__c FROM User WHERE Id = :userId];
        if(userAux != null && userAux.ContactId != null){contactId = userAux.ContactId;}
        
        
        if(contactId == null || contactId == '' || userAux.contact.Data_Protection_Officer__c == null ){return null;}
        
        Boolean isDPO = userAux.contact.Data_Protection_Officer__c;
        
        return isDPO;
    }



}