public without sharing class OneId_NDCRelationsController {
    
    public static final Id flatRelationshipRT = Schema.SObjectType.Account_Role_Relationship__c.getRecordTypeInfosByName().get('Flat').getRecordTypeId();
    
    public class AirlineWrapper{
        @AuraEnabled
        public String AirlineName      {get;set;}
        @AuraEnabled
        public String AirlineId        {get;set;}
    }
    
    @AuraEnabled
    public static Boolean getUserInfo() {
        User usr = [SELECT Id, AccountId, Account.Sector__c, Account.Category__c, Account.RecordType.DeveloperName 
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()];
        Boolean isItAirline;
        if(usr.Account.RecordType.DeveloperName == 'IATA_Airline' || usr.Account.RecordType.DeveloperName == 'Operator') {
            isItAirline = True;
        } else {
            isItAirline = False;
        }
        return isItAirline;
    }
    
    @AuraEnabled
    public static List<AirlineWrapper> getNDCRelations() {
        
        User usr = [SELECT Id, AccountId, Account.Sector__c, Account.Category__c, Account.RecordType.DeveloperName 
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()];

        Account acc = [SELECT Id, Sector__c, Category__c 
                       FROM Account 
                       WHERE Id =: usr.AccountId];
        
        // Step 1: retrieve Account Roles record, based on Account's sector and category
        // The record should exist as this method is called if the user has access to NDC in 1Id
        Account_Roles__c accountsRoles = [SELECT Id 
                                          FROM Account_Roles__c 
                                          WHERE Sector__c =: acc.Sector__c 
                                          AND Category__c =: acc.Category__c
                                          LIMIT 1];

		// Step 2: retrieve the Account Role record linked to the Account record and the Account Roles record
		// The record should exist as this method is called if the user has access to NDC in 1Id
        Account_Role__c accountRole = [SELECT Id
                                       FROM Account_Role__c
                                       WHERE Account__c =: usr.AccountId
                                       AND Account_Roles__c =: accountsRoles.Id
                                       AND RecordType.DeveloperName = 'Default'
                                       LIMIT 1];
        
        // Step 3.1: retrieve the NDC Portal Service
        One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                          FROM One_Id_Service_Provider_Config__c 
                                                          WHERE Service_Provider_Name__c = 'NDCMM' 
                                                          AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
        
		// Step 3.2: retrieve the NDC Relationships
        List<AirlineWrapper> AirlineList = new List<AirlineWrapper>();
        
        if(usr.Account.RecordType.DeveloperName == 'IATA_Airline' || usr.Account.RecordType.DeveloperName == 'Operator') {
            for(Account_Role_Relationship__c rel : [SELECT Id, From__r.Account__r.Name, From__c, To__c 
                                                    FROM Account_Role_Relationship__c 
                                                    WHERE To__c =: accountRole.Id 
                                                    AND Portal_Service__c =: oneIdService.Portal_Service__c 
                                                    AND Relationship_Type__c = 'NDC Player' 
                                                    AND RecordTypeId =: flatRelationshipRT
                                                    AND Relationship_Status__c = 'Active']){
                AirlineWrapper al = new AirlineWrapper();
                al.AirlineId = rel.Id;
                al.AirlineName = rel.From__r.Account__r.Name;
                AirlineList.add(al);
            }
        } else {
            for(Account_Role_Relationship__c rel : [SELECT Id, To__r.Account__r.Name, From__c, To__c 
                                                    FROM Account_Role_Relationship__c 
                                                    WHERE From__c =: accountRole.Id 
                                                    AND Portal_Service__c =: oneIdService.Portal_Service__c 
                                                    AND Relationship_Type__c = 'NDC Player' 
                                                    AND RecordTypeId =: flatRelationshipRT
                                                    AND Relationship_Status__c = 'Active']){
			    AirlineWrapper al = new AirlineWrapper();
			    al.AirlineId = rel.Id;
			    al.AirlineName = rel.To__r.Account__r.Name;
			    AirlineList.add(al);
			}
        }

        return AirlineList;
        
    }
    
    @AuraEnabled
    public static void deleteRelations (String relations) {
        //Json desearization was introduced because lightning default casting was returning Salesforce INTERNAL ERROR
        List<AirlineWrapper> relationsList = (List<AirlineWrapper>) JSON.deserialize(relations, List<AirlineWrapper>.class);
        List<Account_Role_Relationship__c> relationsToDelete = new List<Account_Role_Relationship__c>();
        for(AirlineWrapper aw : relationsList) {
            relationsToDelete.add(new Account_Role_Relationship__c(Id = aw.AirlineId));
        }
        delete relationsToDelete;
    }
    
    @AuraEnabled
    public static List<AirlineWrapper> getAirlines() {
        
        User usr = [SELECT Id, AccountId, Account.Sector__c, Account.Category__c, Account.RecordType.DeveloperName 
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()];
        
        Account acc = [SELECT Id, Sector__c, Category__c 
                       FROM Account 
                       WHERE Id =: usr.AccountId];
        
        // Step 1: retrieve Account Roles record, based on Account's sector and category
        // The record should exist as this method is called if the user has access to NDC in 1Id
        Account_Roles__c accountsRoles = [SELECT Id 
                                          FROM Account_Roles__c 
                                          WHERE Sector__c =: acc.Sector__c 
                                          AND Category__c =: acc.Category__c
                                          LIMIT 1];

		// Step 2: retrieve the Account Role record linked to the Account record and the Account Roles record
        // The record should exist as this method is called if the user has access to NDC in 1Id
        Account_Role__c accountRole = [SELECT Id
                                       FROM Account_Role__c
                                       WHERE Account__c =: usr.AccountId
                                       AND Account_Roles__c =: accountsRoles.Id
                                       AND RecordType.DeveloperName = 'Default'
                                       LIMIT 1];
                
        List<AirlineWrapper> AirlineList = new List<AirlineWrapper>();
        
        Set<Id> existingRelationships = new Set<Id>();
        
        for(Account_Role_Relationship__c relationship : [SELECT To__r.Id
                                                         FROM Account_Role_Relationship__c 
                                                         WHERE From__c =: accountRole.Id
                                                         AND RecordTypeId =: flatRelationshipRT
                                                         AND Relationship_Type__c = 'NDC Player']){
			existingRelationships.add(relationship.To__r.Id);
		}
        
        for(NDC_Account_Service_Detail__c ndcAccountServiceDetail : [SELECT Account_Role_Service__r.Account_Role__r.Id, Account_Role_Service__r.Account_Role__r.Account__r.Name 
                                                                     FROM NDC_Account_Service_Detail__c
                                                                     WHERE Account_Role_Service__r.Account_Role__r.Id !=: accountRole.Id 
                                                                     AND NDC_Capable__c = TRUE
                                                                     AND (Account_Role_Service__r.Account_Role__r.Account__r.RecordType.DeveloperName = 'IATA_Airline' 
                                                                          OR Account_Role_Service__r.Account_Role__r.Account__r.RecordType.DeveloperName = 'Operator')]){
									                                   			
			// This check can't be performed in the WHERE clause because of the number of level of relationships
			if(! existingRelationships.contains(ndcAccountServiceDetail.Account_Role_Service__r.Account_Role__r.Id)){
	           AirlineWrapper al = new AirlineWrapper();
	           al.AirlineId = ndcAccountServiceDetail.Account_Role_Service__r.Account_Role__r.Id;
	           al.AirlineName = ndcAccountServiceDetail.Account_Role_Service__r.Account_Role__r.Account__r.Name;
	           AirlineList.add(al);
			}
       }
        
        return AirlineList;
    }
    
    @AuraEnabled
    public static void createRelations (String airlines) {
        
        User usr = [SELECT Id, AccountId, Account.Sector__c, Account.Category__c
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()];

        Account acc = [SELECT Id, Sector__c, Category__c 
                       FROM Account 
                       WHERE Id =: usr.AccountId];
        
        // Step 1: retrieve Account Roles record, based on Account's sector and category
        // The record should exist as this method is called if the user has access to NDC in 1Id
        Account_Roles__c accountsRoles = [SELECT Id 
                                          FROM Account_Roles__c 
                                          WHERE Sector__c =: acc.Sector__c 
                                          AND Category__c =: acc.Category__c
                                          LIMIT 1];

		// Step 2: retrieve the Account Role record linked to the Account record and the Account Roles record
		// The record should exist as this method is called if the user has access to NDC in 1Id
        Account_Role__c accountRole = [SELECT Id
                                       FROM Account_Role__c
                                       WHERE Account__c =: usr.AccountId
                                       AND Account_Roles__c =: accountsRoles.Id
                                       AND RecordType.DeveloperName = 'Default'
                                       LIMIT 1];
        
        One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                          FROM One_Id_Service_Provider_Config__c 
                                                          WHERE Service_Provider_Name__c = 'NDCMM' 
                                                          AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
        
        //Json desearization was introduced because lightning default casting was returning Salesforce INTERNAL ERROR
        List<AirlineWrapper> relationsList = (List<AirlineWrapper>) JSON.deserialize(airlines, List<AirlineWrapper>.class);
        
        List<Account_Role_Relationship__c> relationsToAdd = new List<Account_Role_Relationship__c>();
        
        
        
        for(AirlineWrapper airline : relationsList) {
            relationsToAdd.add(new Account_Role_Relationship__c(From__c = accountRole.Id, To__c = airline.AirlineId, Relationship_Type__c = 'NDC Player', Relationship_Status__c = 'Active', RecordTypeId = flatRelationshipRT, Portal_Service__c = oneIdService.Portal_Service__c));
        }
        insert relationsToAdd;
    }
    
}