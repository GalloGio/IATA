@isTest
private class ams2gdp_Batch_AMS_Account_Role_Test
{
	
	public static Integer nb = 10; // Number of record the batch will process
	
	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<GDP_Reference_Table__c> tables = ams2gdp_TestDataGenerator.generateReferenceTables(nb, true);
		List<AMS_Account_Role__c> account_roles = ams2gdp_TestDataGenerator.generateAMS_AccountRoles(nb,true); 
	}


	@isTest static void positiveTest1BatchAMSAccountRole()
	{
	
		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_AMS_Account_Role());
		Test.stopTest();

		Set<String> accountIds = new Set<String>();
		for(AMS_Account_Role__c accountRole : [SELECT Account__c FROM AMS_Account_Role__c])
		{
			accountIds.add(accountRole.Id+'GDP');
		}

		System.assert([SELECT count() FROM Agency_Owner__c WHERE AMS_GDP_Key__c IN : accountIds] > 0);
		
	}
	
	@isTest static void positiveTest2BatchAMSAccountRole() 
	{
		List<AMS_Account_Role__c> roles = [SELECT Id FROM AMS_Account_Role__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 7: Agency Owner', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = roles[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_AMS_Account_Role(false, true));
		Test.stopTest();
	}

	@isTest static void negativeTestBatchAMSAccountRole()
	{
		ams2gdp_Batch_AMS_Account_Role batch = new ams2gdp_Batch_AMS_Account_Role(false, false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}	
}