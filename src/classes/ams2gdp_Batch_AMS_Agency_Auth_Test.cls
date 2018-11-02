@isTest
private class ams2gdp_Batch_AMS_Agency_Auth_Test
{
	public static Integer nb = 10; // Number of record the batch will process

	@testSetup static void loadData()
	{
		// Generate Test Data
		//List<AMS_Address__c> addresses = ams2gdp_TestDataGenerator.generateAMS_Addresses(nb, true);
		List<Agency_Authorization__c> accountslist = ams2gdp_TestDataGenerator.generateAMS_AgencyAuthorizations(nb, true);
	}


	@isTest static void positiveTest1BatchAgencyAuthorization()
	{

		Test.startTest();
 		Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Authorization());
		Test.stopTest();

		// Set<String> addressIds = new Set<String>();
		// Set<String> phoneKeys = new Set<String>();
		// //for(AMS_Address__c adr : [SELECT Id FROM AMS_Address__c])
		// for(Account accIds : [SELECT Id FROM Account])
		// {
        //
		// 	addressIds.add(accIds.Id+'LOCGDP');
		// 	addressIds.add(accIds.Id+'MAIGDP');
		// 	phoneKeys.add(accIds.Id+'-P1GDP');
		// 	phoneKeys.add(accIds.Id+'-FXGDP');
        //
		// }
        //
		// //-- Validate GDP Address & Phones are created
		// System.assert([SELECT count() FROM GDP_Address__c WHERE AMS_GDP_Key__c IN : addressIds] > 0);
		// System.assert([SELECT count() FROM GDP_Phone__c WHERE AMS_GDP_Key__c IN : phoneKeys] > 0); // Phone 1, Phone2 and Fax
	}

	@isTest static void positiveTest2BatchAgencyAuthorization()
	{
		//List<AMS_Address__c> addresses = [SELECT Id FROM AMS_Address__c];
		List<Account> accountList = [SELECT Id FROM Account];

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 10: Agency Authorization',
			Last_Sync_Start_Date__c=Datetime.now(),
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = accountList[0].Id
		) Batch_Name__c;

		Test.startTest();
 			Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Authorization(false, true));
		Test.stopTest();
	}

	@isTest static void positiveTest3BatchAgencyAuthorization()
	{
		//List<AMS_Address__c> addresses = [SELECT Id FROM AMS_Address__c];
		List<Account> accountList = [SELECT Id FROM Account];

		upsert new AMS_GDP_Batch__c(
			Batch_Name__c='Job 10: Agency Authorization',
			Last_Sync_Start_Date__c=Datetime.now(),
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = 1,
			Total_Records_Processed__c = nb,
			Failed_Records__c = accountList[0].Id
		) Batch_Name__c;

		List<String> lsIds = new List<String>();
		for(Account a: accountList) {lsIds.add((String)a.Id);}

		Test.startTest();
 			Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Authorization(false, lsIds, true));
		Test.stopTest();
	}


}