public with sharing class AWW_PerformanceCtrl {
    
    @AuraEnabled
    public static List<Objective__c> getRecords(Id accountId) {
        Id rt = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account');
        return [SELECT Id, Name, Details__c, Type__c, Status__c, Deadline__c, Division__c, Unit_Type__c 
                FROM Objective__c WHERE Account__c = :accountId AND RecordTypeId = :rt ];      
    }

    @AuraEnabled
    public static void upsertRecord(Objective__c record, Id accountId) {
        record.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account');
        record.Account__c = accountId;
        upsert record;
    }

}