@isTest
private class CaseValidationDueDiligenceForAPTest {

    public static final Id RT_ICCS_ASP_ID = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('IDFS_Airline_Participation_Process').getRecordTypeId();

    static testMethod void testController() {
        insert new Case_Reason_Service__c(Name = 'SIS Client', Service__c = 'SIS Client', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'SIS Client',
            Type = 'TOU'
        );
        insert cse;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        Test.startTest();
        CaseValidationDueDiligenceForAP controller = new CaseValidationDueDiligenceForAP(stdController);
        controller.updateCase();
        Test.stopTest();
    }

}