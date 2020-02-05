/****************************************************************************************************************
@ Last modified by: Bhargavi Rayavarapu
@ Last modified date : 2016 - 03 -22
@ Description : This is the test class for the scheduled batch that creates a snapshot of all the Accounts
that can be searched for through GAD search engine
*****************************************************************************************************************/
@isTest
public class Test_SchdlGDPProdAccountSnapshotCleanup
{
	private static void initializeRelatedRecords()
	{
		//  initilize GDP_Reference_Table__c
		List<GDP_Reference_Table__c> gdpReferenceTable = new List<GDP_Reference_Table__c>();
		for(Integer i = 0 ; i< 5; i++)
		{
			GDP_Reference_Table__c testgdpReferenceTable = IECTestUtil.createSampleGDPReferenceTableEntry(''+(i+1),'Test Name - '+i);
			gdpReferenceTable.add(testgdpReferenceTable);
		}
		try
		{
			insert gdpReferenceTable;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'initialization of GDP Reference Table failed with an exception '+testexception.getMessage());
		}

		// initialize the GDPProductAccountRecords for which we will create snapshots
		List<GDP_Products_Account_View__c> gdpAccountRecords = new List<GDP_Products_Account_View__c>();
		for(Integer i = 1 ; i<=5; i++)
		{
			GDP_Products_Account_View__c testAccount = IECTestUtil.createSampleGDPAccount('GDPAccount'+i,'ABC'+i);
			gdpAccountRecords.add(testAccount);
		}
		try
		{
			insert gdpAccountRecords;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'initialization of GDP Account Records failed with an exception '+testexception.getMessage());
		}

		// initialize the Accreditation__c table
		List<Accreditation__c> accreditationRecords = new List<Accreditation__c>();
		for(Integer i = 0 ; i<5; i++)
		{
			Accreditation__c testaccreditationRecords = IECTestUtil.CreateSampleGDPAccreditation(gdpAccountRecords[i],gdpReferenceTable[i],gdpReferenceTable[i]);
			accreditationRecords.add(testAccreditationRecords);
		}
		try
		{
			insert accreditationRecords;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'initialization of accrediation Records failed with an exception '+testexception.getMessage());
		}

		//update the GDPProductAccount records with the Accrediation so that we can get the Agency Status Code
		for(Integer i = 0 ; i<5; i++)
		{
			GDP_Products_Account_View__c testAccount = gdpAccountRecords[i];
			testAccount.Related_Accreditation_Class__c = accreditationRecords[i].Id;
		}
		try
		{
			update gdpAccountRecords;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'update operation of GDP Account Records failed with an exception '+gdpAccountRecords);
		}
	}
	/*******************************************************************************
	 * Description : This testmethod covers the test case for inserting any new Product Accounts that
	 * are subscribed and can be displayed in the search results.
	 * *******************************************************************************/
	public static TestMethod void testInsertRecords()
	{
		// create Or initialize the test data
		initializeRelatedRecords();
		// check if the snapshort table has any records present
		List<GDP_Products_Account_Snapshot__c> existingSnapshotRecords = [Select Id,Account_View__c
																		  from GDP_Products_Account_Snapshot__c];
		system.assertEquals(existingSnapshotRecords.size(), 0, 'There should not be any records present in this table '+existingSnapshotRecords.size());
		Test.startTest();
			database.executebatch(new SchdlGDPProductsAccountSnapshotCleanup());
		Test.stopTest();

		// Check if any records have been inserted into the table now
		existingSnapshotRecords = [Select Id,Account_View__c
								   from GDP_Products_Account_Snapshot__c];
		system.assertEquals(existingSnapshotRecords.size(), 2, 'There should be 2 records present in this table '+existingSnapshotRecords.size());
	}
	/*******************************************************************************
	 * Description : This testmethod covers the test case for updating an existing snapshot of Product Accounts that
	 * are subscribed and can be displayed in the search results.
	 * *******************************************************************************/
	public static TestMethod void testUpdateRecords()
	{
		// create Or initialize the test data
		initializeRelatedRecords();

		List<GDP_Products_Account_Snapshot__c> existingSnapshotRecords = new List<GDP_Products_Account_Snapshot__c>();
		// initialize few snapshot records and then modify the GDPProductAccountRecords so that the batch updates the created Snapshot records accordingly.
		List<GDP_Products_Account_View__c> gdpAccountRecords = [Select Id,IATA_Code__c,Agency_Status_Code__c
																from GDP_Products_Account_View__c];
		for(GDP_Products_Account_View__c parseGdpAccountRecords : gdpAccountRecords)
		{
			if(parseGdpAccountRecords.Agency_Status_Code__c >= 4)
			{
				GDP_Products_Account_Snapshot__c newRecord = new GDP_Products_Account_Snapshot__c();
				newRecord.IATA_Code__c = parseGdpAccountRecords.IATA_Code__c;
				newRecord.Account_View__c = parseGdpAccountRecords.Id;
				existingSnapshotRecords.add(newRecord);
			}

			parseGdpAccountRecords.IATA_Code__c = parseGdpAccountRecords.IATA_Code__c+'ABC';
		}
		try
		{
			insert existingSnapshotRecords;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'insert operation of GDP Account Record Snapshots have failed with an exception '+testexception.getMessage());
		}
		try
		{
			update gdpAccountRecords;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'update operation of GDP Account Records failed with an exception '+testexception.getMessage());
		}

		Test.startTest();
	  	database.executebatch(new SchdlGDPProductsAccountSnapshotCleanup());
		Test.stopTest();

		List<GDP_Products_Account_Snapshot__c> updatedSnapshotRecords = [Select Id,IATA_Code__c,Account_View__r.IATA_Code__c
																		  from GDP_Products_Account_Snapshot__c];
		for(GDP_Products_Account_Snapshot__c parserUpdatedSnapshotRecords : updatedSnapshotRecords)
		{
			system.assertEquals(parserUpdatedSnapshotRecords.IATA_Code__c, parserUpdatedSnapshotRecords.Account_View__r.IATA_Code__c, 'update operation of GDP Account Records Snapshot has failed');
		}
	}
	/*******************************************************************************
	 * Description : This testmethod covers the test case for deleting any existing snapshot of Product Accounts that
	 * are no longer subscribed and should not be displayed in the search results.
	 * *******************************************************************************/
	public static TestMethod void testDeleteRecords()
	{
		// create Or initialize the test data
		initializeRelatedRecords();

		List<GDP_Products_Account_Snapshot__c> existingSnapshotRecords = new List<GDP_Products_Account_Snapshot__c>();
		// initialize few snapshot records and then modify the GDPProductAccountRecords so that the batch updates the created Snapshot records accordingly.
		List<GDP_Products_Account_View__c> gdpAccountRecords = [Select Id,IATA_Code__c,Agency_Status_Code__c
																from GDP_Products_Account_View__c];
		for(GDP_Products_Account_View__c parseGdpAccountRecords : gdpAccountRecords)
		{
			if(parseGdpAccountRecords.Agency_Status_Code__c >= 4)
			{
				GDP_Products_Account_Snapshot__c newRecord = new GDP_Products_Account_Snapshot__c();
				newRecord.IATA_Code__c = parseGdpAccountRecords.IATA_Code__c;
				newRecord.Account_View__c = parseGdpAccountRecords.Id;
				existingSnapshotRecords.add(newRecord);
			}
		}
		try
		{
			insert existingSnapshotRecords;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'insert operation of GDP Account Record Snapshots have failed with an exception '+testexception.getMessage());
		}
		List<GDP_Reference_Table__c> gdpReferenceTable = [Select Id,Code__c
														  from GDP_Reference_Table__c];
		for(GDP_Reference_Table__c parserGdpReferenceTable : gdpReferenceTable)
		{
			parserGdpReferenceTable.Code__c = '2';
		}
		try
		{
			update gdpReferenceTable;
		}
		catch(Exception testexception)
		{
			system.assertEquals(true, false, 'update operation of GDP Account Records failed with an exception '+testexception.getMessage());
		}

		Test.startTest();
	  	database.executebatch(new SchdlGDPProductsAccountSnapshotCleanup());
		Test.stopTest();

		List<GDP_Products_Account_Snapshot__c> updatedSnapshotRecords = [Select Id,IATA_Code__c,Account_View__r.IATA_Code__c
																		  from GDP_Products_Account_Snapshot__c];
		system.assertEquals(updatedSnapshotRecords.size(), 0, 'There should not be any records present in this table '+updatedSnapshotRecords.size());
	}
	/*******************************************************************************
	 * Description : This testmethod covers the test case for scheduling the batch.
	 * *******************************************************************************/
	public static TestMethod void testBatchScheduler()
	{
		// create Or initialize the test data
		initializeRelatedRecords();
		Test.startTest();
			SchdlGDPProductsAccountSnapshotCleanup.schedule(null);
		Test.stopTest();
	}
}
