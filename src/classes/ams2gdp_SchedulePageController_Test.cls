@isTest
private class ams2gdp_SchedulePageController_Test {
	private static Integer nb = 10;

	@isTest static void test_method_one() {

		AMS_2_GDP_Settings__c settings = AMS_2_GDP_Settings__c.getOrgDefaults();
			settings.Activate_Sync__c = true;
			settings.Schedule_Period__c = 24;
		upsert settings AMS_2_GDP_Settings__c.Id;

		Account new_account = ams2gdp_TestDataGenerator.generateAccounts(1,false)[0];
		new_account.Website = ams2gdp_TestDataGenerator.generateRandomString(101);
		insert new_account;

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 1: GDP Products - Account View', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = new_account.Id
		) Batch_Name__c; 

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