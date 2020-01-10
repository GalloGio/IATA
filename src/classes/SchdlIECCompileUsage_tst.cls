/**
 * This class contains unit tests for the Schedule Job SchdlIECCompileUsage for compiling live usage into daily usage
 */
@isTest
private class SchdlIECCompileUsage_tst {

	private static void setupData() {

		// 5 success for Agency
		IEC_Usage_Tracker_Live__c oLiveUsage1 = IECTestUtil.createSampleLiveUsageCounter(null, 5, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agency);
		insert oLiveUsage1;

		// 2 fail for Agent
		IEC_Usage_Tracker_Live__c oLiveUsage2 = IECTestUtil.createSampleLiveUsageCounter(null, 2, IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agent);
		insert oLiveUsage2;
	}

	static testMethod void testCompileUsageSchdl() {
		Test.startTest();
		// Set up scheduled job
		datetime nextScheduleTime = system.now().addMinutes(1);
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' * * * ?' ;
		string jobName = 'SchdlIECCompileUsage ' + nextScheduleTime.format('hh:mm');
		system.schedule(jobName, cronvalue , new SchdlIECCompileUsage());
		Test.stopTest();
	}

	static testMethod void testNoLiveUsageToCompile() {

		setupData();

		Test.startTest();
		// Set up batch job
		BtchIECCompileUsage btchProc = new BtchIECCompileUsage();

		// test #1 - run the batch with a target date of 3 days ago (should not compile anything)
		btchProc.dtTargetEndDate = Date.today().addDays(-3);
		List<IEC_Usage_Tracker_Live__c> lstLiveUsageBefore = IECUsageCompiler.getListOfLiveUsageToCompileDaily(btchProc.dtTargetEndDate);
		Integer iNbrLiveUsageBefore = (lstLiveUsageBefore == null ? 0 : lstLiveUsageBefore.size());
		Database.executeBatch(btchProc, 50);

		Test.stopTest();

		List<IEC_Usage_Tracker_Live__c> lstLiveUsageAfter = IECUsageCompiler.getListOfLiveUsageToCompileDaily(btchProc.dtTargetEndDate);
		Integer iNbrLiveUsageAfter = (lstLiveUsageAfter == null ? 0 : lstLiveUsageAfter.size());

		system.assertEquals(iNbrLiveUsageBefore, iNbrLiveUsageAfter, 'No live usage should be compiled');
	}

	static testMethod void testLiveUsageToCompile() {

		setupData();

		Test.startTest();
		// Set up batch job
		BtchIECCompileUsage btchProc = new BtchIECCompileUsage();

		// test #1 - run the batch with a target date of tomorrow (should compile)
		btchProc.dtTargetEndDate = Date.today().addDays(1);
		Database.executeBatch(btchProc, 50);

		Test.stopTest();

		List<IEC_Usage_Tracker_Live__c> lstLiveUsageAfter = IECUsageCompiler.getListOfLiveUsageToCompileDaily(btchProc.dtTargetEndDate);

		system.assert(lstLiveUsageAfter == null || lstLiveUsageAfter.size() == 0, 'All the live usage should be compiled');
	}
}
