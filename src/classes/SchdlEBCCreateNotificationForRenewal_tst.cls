/**
 * Test class for SchdlEBCCreateNotificationForRenewal
 *
 * This is part of the eBroadcast feature
 * 
 * History: 
 *  - 20160901-sl: initial version, using IECEBC_TestUtility
 *
 */
@isTest
private class SchdlEBCCreateNotificationForRenewal_tst {
	
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
		string jobName = 'SchdlEBCCreateNotificationForRenewal TEST ' + nextScheduleTime.format('hh:mm');
		system.schedule(jobName, cronvalue , new SchdlEBCCreateNotificationForRenewal());
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: SchdlEBCCreateNotificationOnStatus');
	} // test01_BasicTestOnScheduleJob
	
	
	// ========================================================================
	// basic test: calling batch job, no data provided
	@isTest (SeeAllData=false)
	static void test02_BasicTestOnBatchJob() {
		Test.startTest();
		
		BtchEBCCreateNotificationForRenewal.callBatchEBCCreateNotification();
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: BtchEBCCreateAccountNotificationOnStatus');
	} // test02_BasicTestOnBatchJob
	
	
	// ========================================================================
	// basic test: batch job, without no provided
	@isTest (SeeAllData=false)
	static void test03_BasicTestOnBatchStaticGetter() {
		Test.startTest();
		
		String targetDate = BtchEBCCreateNotificationForRenewal.subscriptionRenewalTargetDateString;
		String productRatePlanIdSetString = BtchEBCCreateNotificationForRenewal.availableEbcRatePlanIdSetString;
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: BtchEBCCreateNotificationForRenewal');
	} // test03_BasicTestOnBatchStaticGetter
	
	// ========================================================================
	// basic test: calling batch job, with single test data provided
	@isTest (SeeAllData=false)	
	static void test04_BasicTestOnBatchJobWithTestData() {

		//Generate SAP Settings
		TestDataGenerator.generateSAPSettings();

		IECEBC_TestUtility.createEbcSetupAndRelatedData();
		IECEBC_TestUtility.createTestUser();
		Date dSubscriptionEndDate = Date.today().addDays(Integer.valueOf(IECEBC_TestUtility.EBC_RENEWAL_WINDOW));
		IECEBC_TestUtility.createEbcSubscription( IECEBC_TestUtility.lEbcProductRatePlanMember[0], IECEBC_TestUtility.oEbcProductMember, dSubscriptionEndDate);
		
		Test.startTest();
		
		BtchEBCCreateNotificationForRenewal.callBatchEBCCreateNotification();
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: test04_BasicTestOnBatchJobWithTestData');
	} // test04_BasicTestOnBatchJobWithTestData
	
	
} // end of SchdlEBCCreateNotificationForRenewal_tst