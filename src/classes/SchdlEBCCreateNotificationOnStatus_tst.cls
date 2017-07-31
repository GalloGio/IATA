/**
 * Test class for SchdlEBCCreateNotificationOnStatus
 *
 * This is part of the eBroadcast feature
 * 
 * History: 
 *  - 20160901-sl: initial version, with IECEBC_TestUtility for test data
 *
 */
@isTest
private class SchdlEBCCreateNotificationOnStatus_tst {
    
    // ========================================================================
    // basic test: calling scheduled job, no data provided
    @isTest (SeeAllData=false)
    static void test01_BasicTestOnScheduleJob() {
        Test.startTest();
        
        // Set up scheduled job
        datetime nextScheduleTime = system.now().addMinutes(1);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second + ' ' + minute + ' * * * ?' ;
        string jobName = 'SchdlEBCCreateNotificationOnStatus TEST ' + nextScheduleTime.format('hh:mm');
        system.schedule(jobName, cronvalue , new SchdlEBCCreateNotificationOnStatus());
        
        Test.stopTest();
        
        System.debug('Unit Test: Finish: SchdlEBCCreateNotificationOnStatus');
    } // test01_BasicTestOnScheduleJob
    
    
    // ========================================================================
    // basic test: calling batch job, no data provided
    @isTest (SeeAllData=false)
    static void test02_BasicTestOnBatchJob() {
        Test.startTest();
        BtchEBCCreateNotificationOnStatus.callBatchEBCCreateNotification();
        Test.stopTest();
        
        System.debug('Unit Test: Finish: BtchEBCCreateAccountNotificationOnStatus');
    } // test02_BasicTestOnBatchJob
    
    
    // ========================================================================
    // basic test: calling batch job, with test data
    @isTest (SeeAllData=false)  
    static void test03_BasicTestOnBatchJobWithTestData() {
        IECEBC_TestUtility.createEbcSetupAndRelatedData();
        IECEBC_TestUtility.createTestUser();
        Date dSubscriptionEndDate = Date.today().addMonths(6);
        IECEBC_TestUtility.createEbcSubscription( IECEBC_TestUtility.lEbcProductRatePlanMember[0], IECEBC_TestUtility.oEbcProductMember, dSubscriptionEndDate);
        
        createEbcCampaign();
        Test.startTest();
        vfIECEBC_ReportList cont = new vfIECEBC_ReportList();
        cont.fakeMethod();
        BtchEBCCreateNotificationOnStatus.callBatchEBCCreateNotification();
        
        Test.stopTest();
        
        System.debug('Unit Test: Finish: test03_BasicTestOnBatchJobWithTestData');
    } // test03_BasicTestOnBatchJobWithTestData
    
    
    
    // ================================================================================
    // create ebc campaign
    private static EBC_Campaign__c createEbcCampaign()
    {
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        //camp.EBC_Master_Filter__c = masterFilter.Id;
        //camp.EBC_Design__c = tpl.Id;
        camp.Scheduled_Date__c = DateTime.now().addMonths(-1);
        //camp.Activity_Type__c = 'Sent';
        camp.Status__c = 'SENT';
        insert camp;
        
        return camp;
    }

} // SchdlEBCCreateNotificationOnStatus_tst