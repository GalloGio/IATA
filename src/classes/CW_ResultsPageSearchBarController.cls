public with sharing class CW_ResultsPageSearchBarController {
    @AuraEnabled (cacheable = true)
    public static List<ICG_Certification__c> getCertifications(){
        return [Select id, name, Image__c from ICG_Certification__c]; //where isactive and more filters
    }
}