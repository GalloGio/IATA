@isTest
private class ams2gdp_Batch_Territory_Test {
	
	public static Integer nb = 10; // Number of record the batch will process

	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<AMS_Territory__c> territories = ams2gdp_TestDataGenerator.generateAMS_territories(nb, true);
	}


	@isTest static void positiveTest1BatchTerritory() 
	{
		Test.startTest();
 			Database.executeBatch(new ams2gdp_Batch_Territory());
		Test.stopTest();

		Set<String> territoryKeys = new Set<String>(); 
		Set<String> phoneKeys = new Set<String>();
		for(AMS_Territory__c ter : [SELECT Id FROM AMS_Territory__c])
		{
			territoryKeys.add(ter.Id+'GDP');

		}

		
	}

	@isTest static void positiveTest2BatchTerritory() 
	{
		List<AMS_Territory__c> territories = [SELECT Id FROM AMS_Territory__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 3: GSA Territory', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = territories[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Territory(false, true));
		Test.stopTest();
	}

	@isTest static void negativeTestBatchTerritory()
	{
		ams2gdp_Batch_Territory batch = new ams2gdp_Batch_Territory(false, false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		//System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}	
	
	
}