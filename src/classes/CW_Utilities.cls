public with sharing class CW_Utilities {
    @AuraEnabled (cacheable=true)
    public static Portal_Identity_Data__mdt getMetadataInfo(String mtdName){

        // Fetch the metadata required
        Portal_Identity_Data__mdt metadata = [SELECT Id,MasterLabel, DeveloperName, Link__c, Description__c 
                                              FROM Portal_Identity_Data__mdt WHERE DeveloperName =: mtdName LIMIT 1];

        return metadata;
    }
}