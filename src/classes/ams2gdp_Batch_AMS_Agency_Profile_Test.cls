@isTest
private class ams2gdp_Batch_AMS_Agency_Profile_Test {
	
	public static Integer nb = 10; // Number of record the batch will process
	
	@testSetup static void loadData() 
	{
		// Generate Test Data
		List<GDP_Reference_Table__c> tables = ams2gdp_TestDataGenerator.generateReferenceTableswithTableName(nb, true);
		List<AMS_Agency_Profile__c> agency_profiles = ams2gdp_TestDataGenerator.generateAMS_AgencyProfiles(nb,true); 

	}

	@isTest static void positiveTest1BatchAMSAgencyProfile() {

		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Profile());
		Test.stopTest();

		Set<String> accountIds = new Set<String>();
		for(AMS_Agency_Profile__c profiles :  [SELECT Account__c FROM AMS_Agency_Profile__c])
		{
			accountIds.add(profiles.Account__c);
		}

		// Validate new record of Assoc_Affiliation_Membership__c are created 
		System.assert([SELECT count() FROM GDP_Agency_Profile_Specialization__c WHERE Related_Account__c IN : accountIds] > 0);

	}


	@isTest static void positiveTest2BatchAMSAgencyProfile() 
	{
		List<AMS_Agency_Profile__c> agencies = [SELECT Id FROM AMS_Agency_Profile__c]; 

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 9: Agency Profile and Specialization', 
			Last_Sync_Start_Date__c=Datetime.now(), 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = agencies[0].Id
		) Batch_Name__c; 


		Test.startTest(); 
 			Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Profile(false, true));
		Test.stopTest();
	}
	
	
	@isTest static void negativeTestBatchAMSAgencyProfile() 
	{
		ams2gdp_Batch_AMS_Agency_Profile batch = new ams2gdp_Batch_AMS_Agency_Profile(false, false);
			batch.throwException = true; 

		Test.startTest(); 
 			Database.executeBatch(batch);
		Test.stopTest();

		System.assert([SELECT count() FROM AMS2GDP_Log__c] > 0);
	}

}