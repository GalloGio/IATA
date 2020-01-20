@IsTest
public with sharing class GADM_DataSubmissionPeriodScheduler_TEST {

	@IsTest
	private static void scheduleTest() {

		Test.startTest();

		GADM_DataSubmissionPeriodScheduler scheduler = new GADM_DataSubmissionPeriodScheduler();
		scheduler.execute(null);

		Test.stopTest();


	}

}
