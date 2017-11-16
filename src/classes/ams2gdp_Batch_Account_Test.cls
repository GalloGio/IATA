@isTest
private class ams2gdp_Batch_Account_Test 
{
	public static Integer nb = 10; // Number of record the batch will process

	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<GDP_Reference_Table__c> tables = ams2gdp_TestDataGenerator.generateReferenceTables('LOCCAT',nb, true);
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(nb,true);
		for(Integer x=0; x < accounts.size(); x++)
		{
			Account acc = accounts[x];
			GDP_Reference_Table__c ref = tables[x];
			acc.Location_Category__c = ref.Code__c;
		} 

		update accounts; 
	}
  
	@isTest static void schedulerTest()
	{
		AMS_2_GDP_Settings__c settings = AMS_2_GDP_Settings__c.getOrgDefaults();
			settings.Activate_Sync__c = true;
			settings.Schedule_Period__c = 24;
			//settings.Notification_Email__c = 'hello@world.com'; 
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

		Test.startTest();
			// Schedule the test job
			String CRON_EXP = '0 0 0 15 3 ? 2022';
      		String jobId = System.schedule('ScheduleApexClassTest'+Datetime.now(),CRON_EXP, new ams2gdp_Scheduler());			
		Test.stopTest();
	}


	@isTest static void positiveTest1AccountBatch() 
	{
		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Account());
		Test.stopTest();

		Set<String> accountIds = new Set<String>(); 
		for(Account acc : [SELECT Id FROM Account])
		{
			accountIds.add(acc.Id);
		}

		// Validate new records of GDP Product Account View are created 
		System.assertEquals(10, [SELECT count() FROM GDP_Products_Account_View__c WHERE AMS_GDP_Key__c IN : accountIds]);
	}

	@isTest static void positiveTest1Account2Batch() 
	{
		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Account2());
		Test.stopTest();

		Set<String> accountIds = new Set<String>(); 
		for(Account acc : [SELECT Id FROM Account])
		{
			accountIds.add(acc.Id+'GDP');
		}

		// Validate new records of GSA Territory are created 
		//System.assertEquals(10, [SELECT count() FROM Account_Category__c WHERE AMS_GDP_Key__c IN : accountIds]);
	}

	@isTest static void positiveTest2AccountBatch() 
	{
		List<Account> accounts = [SELECT Id FROM Account]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 1: GDP Products - Account View', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = accounts[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Account(true, true, false));
		Test.stopTest();
	}

	@isTest static void positiveTest2Account2Batch() 
	{
		List<Account> accounts = [SELECT Id FROM Account]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 4: GDS & Account Category', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = accounts[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Account2(false, false));
		Test.stopTest();
	}

	@isTest static void negativeTestAccountBatch() 
	{
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

		Test.startTest(); 
			ams2gdp_Batch_Account batch = new ams2gdp_Batch_Account(true,false, false);
				batch.throwException = true; 
 			Database.executeBatch(batch);
		Test.stopTest();
	}

	@isTest static void negativeTestAccount2Batch() 
	{
		Account new_account = ams2gdp_TestDataGenerator.generateAccounts(1,false)[0];
		new_account.Website = ams2gdp_TestDataGenerator.generateRandomString(101);
		insert new_account; 

		Test.startTest(); 
			ams2gdp_Batch_Account2 batch = new ams2gdp_Batch_Account2(false, false);
				batch.throwException = true; 
 			Database.executeBatch(batch);
		Test.stopTest();
	}

	@isTest static void positiveTestAccount2Batch3() {
        TestData.ForReplicatePhone testData = new TestData.ForReplicatePhone();
		
        System.runAs(testData.user) {
			
			AMS_2_GDP_Settings__c setting = new AMS_2_GDP_Settings__c();
			setting.Location_Classes__c = 'D';
			insert setting;
			Test.startTest(); 
				ams2gdp_Batch_Account2 batch = new ams2gdp_Batch_Account2(false, true);
					batch.throwException = true; 
				Database.executeBatch(batch);
			Test.stopTest();
			// system.assert(batch.query, '5');
		}
	}
}