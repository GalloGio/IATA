@isTest
private class ams2gdp_Batch_AMS_AgencyAirport_Test 
{

	public static Integer nb = 10; // Number of record the batch will process
	
	@testSetup static void loadData() 
	{
		// Generate Test Data
	    List<GDP_Reference_Table__c> tables = ams2gdp_TestDataGenerator.generateReferenceTables(nb, true);
		List<AMS_Agency_Airport__c> agency_airports = ams2gdp_TestDataGenerator.generateAMS_AgencyAirports(nb,true); 
	}
	
	@isTest static void positiveTest1BatchAMSAgencyAirport() 
	{

		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Airport());
		Test.stopTest();

		Set<String> accountIds = new Set<String>();
		for(AMS_Agency_Airport__c agency :  [SELECT Account__c FROM AMS_Agency_Airport__c])
		{
			accountIds.add(agency.Id+'GDP');
		}

		System.assert([SELECT count() FROM Adjacent_Airport__c WHERE AMS_GDP_Key__c IN : accountIds] > 0);
	}
	

	@isTest static void positiveTest2BatchAMSAgencyAirport() 
	{
		List<AMS_Agency_Airport__c> agencies = [SELECT Id FROM AMS_Agency_Airport__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 8: Adjacent Airport', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = agencies[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Airport(false, true));
		Test.stopTest();
	}

	@isTest static void negativeTestBatchAMSAgencyAirport()
	{
		ams2gdp_Batch_AMS_Agency_Airport batch = new ams2gdp_Batch_AMS_Agency_Airport(false, false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}			
}