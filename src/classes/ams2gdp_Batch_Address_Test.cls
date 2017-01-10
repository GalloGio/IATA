@isTest
private class ams2gdp_Batch_Address_Test 
{
	public static Integer nb = 10; // Number of record the batch will process

	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<AMS_Address__c> addresses = ams2gdp_TestDataGenerator.generateAMS_Addresses(nb, true);
	}


	@isTest static void positiveTest1BatchAddress() 
	{
		Test.startTest();
 			Database.executeBatch(new ams2gdp_Batch_Address());
		Test.stopTest();

		Set<String> addressIds = new Set<String>(); 
		Set<String> phoneKeys = new Set<String>();
		for(AMS_Address__c adr : [SELECT Id FROM AMS_Address__c])
		{
			addressIds.add(adr.Id+'GDP');
			phoneKeys.add(adr.Id+'-P1GDP');
			phoneKeys.add(adr.Id+'-P2GDP');

		}

		//-- Validate GDP Address & Phones are created
		System.assertEquals(nb, [SELECT count() FROM GDP_Address__c WHERE AMS_GDP_Key__c IN : addressIds]);
		System.assertEquals(nb*2, [SELECT count() FROM GDP_Phone__c WHERE AMS_GDP_Key__c IN : phoneKeys]); // Phone 1, Phone2 and Fax
	}

	@isTest static void positiveTest2BatchAddress() 
	{
		List<AMS_Address__c> addresses = [SELECT Id FROM AMS_Address__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Address', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = addresses[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Address(false));
		Test.stopTest();
	}

	@isTest static void negativeTestBatchAddress()
	{
		ams2gdp_Batch_Address batch = new ams2gdp_Batch_Address(false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}	
}