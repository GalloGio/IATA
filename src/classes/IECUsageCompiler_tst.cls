/**
 * This class contains test units for the IECUsageCompiler class
 */
@isTest
private class IECUsageCompiler_tst {

	private static Account oAccount;
	private static Contact oContact1;
	private static Contact oContact2;
	private static Contact oContact3;
	private static Contact oContact4;

	private static void setupData() {

		oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;

		oContact1 = IECTestUtil.createSampleContact(oAccount);
		oContact1.Email = 'testIECGuest1@test.iata.org';
		insert oContact1;

		oContact2 = IECTestUtil.createSampleContact(oAccount);
		oContact2.Email = 'testIECGuest2@test.iata.org';
		insert oContact2;

		oContact3 = IECTestUtil.createSampleContact(oAccount);
		oContact3.Email = 'testIECGuest3@test.iata.org';
		insert oContact3;

		oContact4 = IECTestUtil.createSampleContact(oAccount);
		oContact4.Email = 'testIECGuest4@test.iata.org';
		insert oContact4;
	}

	private static void createAnonymousData() {

		// create anonymous usage for CAC Free

		// 5 success for Agency
		IEC_Usage_Tracker_Live__c oLiveUsage1 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage1;
		IEC_Usage_Tracker_Live__c oLiveUsage2 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage2;
		IEC_Usage_Tracker_Live__c oLiveUsage3 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage3;
		IEC_Usage_Tracker_Live__c oLiveUsage4 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage4;
		IEC_Usage_Tracker_Live__c oLiveUsage5 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage5;

		// 2 fail for Agency
		IEC_Usage_Tracker_Live__c oLiveUsage6 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage6;
		IEC_Usage_Tracker_Live__c oLiveUsage7 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage7;

		// 4 success for Agent
		IEC_Usage_Tracker_Live__c oLiveUsage8 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agent);
		insert oLiveUsage8;
		IEC_Usage_Tracker_Live__c oLiveUsage9 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agent);
		insert oLiveUsage9;
		IEC_Usage_Tracker_Live__c oLiveUsage10 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agent);
		insert oLiveUsage10;
		IEC_Usage_Tracker_Live__c oLiveUsage11 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agent);
		insert oLiveUsage11;

		// 1 fail for Agent
		IEC_Usage_Tracker_Live__c oLiveUsage12 = IECTestUtil.createSampleLiveUsageCounter(null, 1, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agent);
		insert oLiveUsage12;
	}

	private static void createCustomerData() {

		// create customer usage for CAC Pro

		IEC_Usage_Tracker_Live__c oLiveUsage1 = IECTestUtil.createSampleLiveUsageCounter(oContact1, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage1;
		IEC_Usage_Tracker_Live__c oLiveUsage2 = IECTestUtil.createSampleLiveUsageCounter(oContact1, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage2;
		IEC_Usage_Tracker_Live__c oLiveUsage3 = IECTestUtil.createSampleLiveUsageCounter(oContact1, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage3;
		IEC_Usage_Tracker_Live__c oLiveUsage4 = IECTestUtil.createSampleLiveUsageCounter(oContact2, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage4;
		IEC_Usage_Tracker_Live__c oLiveUsage5 = IECTestUtil.createSampleLiveUsageCounter(oContact2, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage5;
		IEC_Usage_Tracker_Live__c oLiveUsage6 = IECTestUtil.createSampleLiveUsageCounter(oContact3, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage6;
		IEC_Usage_Tracker_Live__c oLiveUsage7 = IECTestUtil.createSampleLiveUsageCounter(oContact4, 1, IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage7;
	}

	static testMethod void testCompileAnonymousLiveUsage() {

		try {
			List<IEC_Usage_Tracker_Live__c> lstLiveUsage = null;

			// Test #1 - no usage to compile yet
			lstLiveUsage = IECUsageCompiler.getListOfLiveUsageToCompileDaily(Date.today());
			system.assert(lstLiveUsage == null || lstLiveUsage.isEmpty(), 'There should be no usage yet');

			// create the data
			setupData();
			createAnonymousData();

			// Test #2 - no usage to compile for an old date
			lstLiveUsage = IECUsageCompiler.getListOfLiveUsageToCompileDaily(Date.today().addDays(-5));
			system.assert(lstLiveUsage == null || lstLiveUsage.isEmpty(), 'There should be no usage for a past date');

			// Test #3 - 13 usage to compile
			lstLiveUsage = IECUsageCompiler.getListOfLiveUsageToCompileDaily(Date.today().addDays(1));
			system.assert(lstLiveUsage != null && lstLiveUsage.size() == 12, 'There should be 12 usage to compile');

			// Test #4 - compile live usage
			List<IEC_Compiled_Usage_Tracker__c> lstCompiledUsage = IECUsageCompiler.compileDailyUsage(lstLiveUsage);
			system.assert(lstCompiledUsage != null && lstCompiledUsage.size() == 4, 'The usage should be compiled into 4 records.');
			lstLiveUsage = IECUsageCompiler.getListOfLiveUsageToCompileDaily(Date.today().addDays(1));
			system.assert(lstLiveUsage == null || lstLiveUsage.isEmpty(), 'There should be no usage after compile');
		}
		catch(Exception ex) {
			system.assert(false, 'Exception thrown: ' + ex.getMessage() + '\r\n' + ex.getStacktraceString());
		}
	}


}
