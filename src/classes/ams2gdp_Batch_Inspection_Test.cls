@isTest
private class ams2gdp_Batch_Inspection_Test 
{
	public static Integer nb = 10; // Number of record the batch will process

	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<GDP_Reference_Table__c> tables = ams2gdp_TestDataGenerator.generateReferenceTables(nb, true);
		List<AMS_Inspection__c> inspections = ams2gdp_TestDataGenerator.generateAMS_Inspections(nb,true); 

		
	}
	
	@isTest static void positiveTest1InspectionBatch()
	{
		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Inspection());
		Test.stopTest();

		Set<String> accountIds = new Set<String>();
		for(AMS_Inspection__c inspection : [SELECT Account__c FROM AMS_Inspection__c])
		{
			accountIds.add(inspection.Account__c);
		}

		// Validate new records of Accreditation__c are created 
		System.assert([SELECT count() FROM Accreditation__c WHERE Related_Account__c IN : accountIds] > 0);
	}	

	@isTest static void positiveTest2InspectionBatch() 
	{
		List<AMS_Inspection__c> inspections = [SELECT Id FROM AMS_Inspection__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 2: Accreditation', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = inspections[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_Inspection(false));
		Test.stopTest();
	}

	@isTest static void negativeTestInspectionBatch()
	{
		ams2gdp_Batch_Inspection batch = new ams2gdp_Batch_Inspection(false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		//System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}	

}