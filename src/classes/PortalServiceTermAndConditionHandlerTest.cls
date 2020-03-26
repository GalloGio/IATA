@isTest
private class PortalServiceTermAndConditionHandlerTest {

    static testMethod void testInsert() {
        Portal_Applications__c pa = new Portal_Applications__c(
            Name = 'Login T&C Checker'
        );
        insert pa;

        Term_and_Condition__c tc = new Term_and_Condition__c(
            Name = 'GCS Private Policy',
            Is_Latest__c = true,
            Effective_Start_Date__c = Date.today(),
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'Bypass_Trigger_Behavior')
        );
        insert tc;

        Service_Term_and_Condition__c stc = new Service_Term_and_Condition__c(
            Portal_Service__c = pa.Id,
            Term_Condition__c = tc.Id
        );
        insert stc;    
    }

    static testMethod void testUpdate() {
        Portal_Applications__c pa = new Portal_Applications__c(
            Name = 'Login T&C Checker'
        );
        insert pa;

        Term_and_Condition__c tc = new Term_and_Condition__c(
            Name = 'GCS Private Policy',
            Is_Latest__c = true,
            Effective_Start_Date__c = Date.today(),
            Version_Number__c = 1,
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'Bypass_Trigger_Behavior')
        );
        insert tc;

        Service_Term_and_Condition__c stc = new Service_Term_and_Condition__c(
            Portal_Service__c = pa.Id,
            Term_Condition__c = tc.Id
        );
        insert stc;    

        Term_and_Condition__c tc2 = new Term_and_Condition__c(
            Name = 'GCS Private Policy',
            Is_Latest__c = true,
            Effective_Start_Date__c = Date.today(),
            Version_Number__c = 2,
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'Bypass_Trigger_Behavior')
        );
        insert tc2;


    }

}