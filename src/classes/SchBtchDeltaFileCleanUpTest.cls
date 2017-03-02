/**
 * This test class tests 
 *   - SchBtchDeltaFileCleanUp
 *   - BtchDeltaFileCleanUp
 *
 *  Change log:
 *   -  20160420-sl: initial version
 *
 *
 */
 
@isTest
private class SchBtchDeltaFileCleanUpTest {
    // ensure that we have old enough GDP_Delta records, going back to certain number of months below
    static private final Integer DELTA_MODIFIED_MONTHS_OLD = 3; 
    
    static testMethod void testSchBtchDeltaFileCleanUp() {
        createTestData();
        
        // Set up scheduled job definition
        datetime nextScheduleTime = system.now().addMinutes(1);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second + ' ' + minute + ' * * * ?' ;
        string jobName = 'SchBtchDeltaFileCleanup TEST ' + nextScheduleTime.format('hh:mm');
        
        Test.startTest();
        SchBtchDeltaFileCleanup.schedule();
        Test.stopTest();
    } // testSchBtchDeltaFileCleanUp
    
    
    // create some test records
    // GDP_Delta__c and GDP_Products_Account_View
    static void createTestData()
    {
        // rely on GSS_REST_Test to create GDP_Delta__c and GDP_Products_Account_View
        GSS_REST_Test.SetupTestData();
        // 
        List<GDP_Delta__c> lstGdpDelta = [select Id, DeltaLastModifiedDate__c 
                                          from GDP_Delta__c
                                          order by DeltaLastModifiedDate__c
                                         limit 5];
        for (GDP_Delta__c gdpDelta : lstGdpDelta) 
        {
            gdpDelta.DeltaLastModifiedDate__c = Date.today().addMonths(-DELTA_MODIFIED_MONTHS_OLD);
        }
        update lstGdpDelta;
    }
}