@isTest
private class GDS_DataExportSchedulerTest {

    private static void loadData() {
        ContentWorkspace library = [SELECT Id, Name FROM ContentWorkspace LIMIT 1];
        String libraryName = library.Name;
        insert new ISSP_CS__c(Name = GDS_DataExportScheduler.LIBRARY_CS_NAME,Value__c = libraryName);
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'France',
            ISO_Code__c = 'FR'
        );
        insert country;
        Account account = new Account(
            Name = 'Test Account',
            IATA_ISO_Country__c = country.Id,
            Location_Class__c = 'P',
            Zuora__Active__c = 'True');
        insert account;
        
        list<Agency_Applied_Change_code__c> listChangeCodes = new list<Agency_Applied_Change_code__c>();
        for (Integer i=0; i<100; i++) {
            listChangeCodes.add(
                new Agency_Applied_Change_code__c(
                    Account__c = account.Id,
                    Change_Code__c = 'TER')
            );
        }
        insert listChangeCodes;
    }

    static testMethod void test_Batch() {
        loadData();

        Test.startTest();
        GDS_DataExportScheduler job = new GDS_DataExportScheduler();
        String sch = '0 0 13 * * ?';
        System.schedule('GDS Data Export Test', sch, job);
        Test.stopTest();
        
        // TODO uncomment this line and fix the library creation in loadData() when the SF fix the bug
        //System.assert([SELECT ContentDocumentId FROM ContentVersion].size() == 1);
    }
}