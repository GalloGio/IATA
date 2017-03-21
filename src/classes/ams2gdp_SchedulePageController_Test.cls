@isTest
private class ams2gdp_SchedulePageController_Test {
	
	@isTest static void test_method_one() {

		ams2gdp_SchedulerPageController schedule= new ams2gdp_SchedulerPageController();

		schedule.processNext = true;
		schedule.jobName='ams2gdp_Batch_Account';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_Account2';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_Agency_Affiliation';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_AMS_Account_Role';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_AMS_Agency_Airport';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_AMS_Agency_Profile';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_Inspection';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_Territory';
		schedule.executeJob();
		schedule.jobName='ams2gdp_Batch_Update';

		schedule.executeJob();


		// Implement test code
	}
	
		
}