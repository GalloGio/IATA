@isTest
private class ams2gdp_Batch_Agency_Affiliation_Test 
{
	public static Integer nb = 10; // Number of record the batch will process

	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<GDP_Reference_Table__c> tables = ams2gdp_TestDataGenerator.generateReferenceTables(nb, true);
		List<AMS_Agency_Affiliation__c> agency_affiliations = ams2gdp_TestDataGenerator.generateAMS_Agency_Affiliations(nb,true); 
	}

	
	@isTest static void positiveTest1BatchAgencyAffiliation() 
	{
		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Agency_Affiliation());
		Test.stopTest();

		Set<String> accountIds = new Set<String>();
		for(AMS_Agency_Affiliation__c agency : [SELECT Account__c FROM AMS_Agency_Affiliation__c])
		{
			accountIds.add(agency.Id+'GDP');
		}

		// Validate new record of Assoc_Affiliation_Membership__c are created 
		System.assert([SELECT count() FROM Assoc_Affiliation_Membership__c WHERE AMS_GDP_Key__c IN : accountIds] > 0);
	}

	@isTest static void positiveTest2BatchAgencyAffiliation() 
	{
		List<AMS_Agency_Affiliation__c> agencies = [SELECT Id FROM AMS_Agency_Affiliation__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 6: Assoc Affiliation Membership', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = agencies[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Agency_Affiliation(false, true));
		Test.stopTest();
	}
	
	@isTest static void negativeTestBatchAgencyAffiliation()
	{
		ams2gdp_Batch_Agency_Affiliation batch = new ams2gdp_Batch_Agency_Affiliation(false, false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}	
}