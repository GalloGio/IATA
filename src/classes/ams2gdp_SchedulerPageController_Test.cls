@isTest
private class ams2gdp_SchedulerPageController_Test {
    
    @testSetup static void loadData() 
	{
		AMS_2_GDP_Settings__c settings = AMS_2_GDP_Settings__c.getOrgDefaults();
			settings.Activate_Sync__c = true;
			settings.Schedule_Period__c = 24;
			settings.Notification_Email__c = 'hello@world.com';
		upsert settings AMS_2_GDP_Settings__c.Id; 

	}

    @isTest static void test_job1() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Account';
       		ctrl.processNext = true;

   		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2,true);

   		ctrl.recordIds = accounts[0].Id + ';' + accounts[1].Id;

   		Test.startTest();
   			ctrl.executeJob();
   			ctrl.refresh();
   		Test.stopTest();
    }
    
    @isTest static void test_job2() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Account2';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job3() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Address';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job4() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Agency_Affiliation';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job5() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_AMS_Account_Role';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job6() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_AMS_Agency_Airport';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job7() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_AMS_Agency_Profile';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job8() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Inspection';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job9() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Territory';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    @isTest static void test_job10() {
       	ams2gdp_SchedulerPageController ctrl = new ams2gdp_SchedulerPageController(); 
       		ctrl.jobName = 'ams2gdp_Batch_Update';

   		Test.startTest();
   			ctrl.executeJob();
   		Test.stopTest();
    }

    
}