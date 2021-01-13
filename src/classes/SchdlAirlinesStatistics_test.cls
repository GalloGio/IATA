/**
 * This class contains unit tests for the Schedule Job SchdlAirlinesStatistics
 */
@isTest
public class SchdlAirlinesStatistics_test
{
	private static void InitializeTestData()
	{
		IATA_ISO_Country__c isoCountry = IECTestUtil.CreateSampleIATAISOCountry();
		try
		{
			insert isoCountry;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in creating an ISO country.'+e.getMessage());
		}
		Account sampleTestAccount = IECTestUtil.createSampleAccount('IATA_Airline');
		try
		{
			insert sampleTestAccount;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in inserting a test Account.'+e.getMessage());
		}

		GDP_Address__c sampleAccountAddress = IECTestUtil.CreateSampleGDPAddress(sampleTestAccount);
		sampleAccountAddress.IATA_ISO_Country__c = isoCountry.Id;
		try
		{
			insert sampleAccountAddress;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in inserting Account Address.'+e.getMessage());
		}

		List<GDP_Reference_Table__c> sampleTestAccountReferenceTable = new List<GDP_Reference_Table__c>();
		GDP_Reference_Table__c sampleTestAccountReferenceTable1 = IECTestUtil.createSampleGDPReferenceTableEntry('M','ReferenceTable1');
		sampleTestAccountReferenceTable.add(sampleTestAccountReferenceTable1);
		GDP_Reference_Table__c sampleTestAccountReferenceTable2 = IECTestUtil.createSampleGDPReferenceTableEntry('6','ReferenceTable2');
		sampleTestAccountReferenceTable.add(sampleTestAccountReferenceTable2);
		GDP_Reference_Table__c sampleTestAccountReferenceTable3 = IECTestUtil.createSampleGDPReferenceTableEntry('AO','ReferenceTable3');
		sampleTestAccountReferenceTable3.Table__c = 'LOCTYP';
		sampleTestAccountReferenceTable.add(sampleTestAccountReferenceTable3);
		GDP_Reference_Table__c sampleTestAccountReferenceTable4 = IECTestUtil.createSampleGDPReferenceTableEntry('AO','ReferenceTable4');
		sampleTestAccountReferenceTable4.Table__c = 'LOCTYP';
		sampleTestAccountReferenceTable.add(sampleTestAccountReferenceTable4);
		try
		{
			insert sampleTestAccountReferenceTable;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in inserting Account Reference Tables.'+e.getMessage());
		}

		GDP_Airlines_Statistic__c newAirlineStatistic = new GDP_Airlines_Statistic__c();
		newAirlineStatistic.Key__c = 'ASLTEST';
		newAirlineStatistic.Last_Update__c = system.now().addDays(-1);
		newAirlineStatistic.AO__c = 0;
		try
		{
			insert newAirlineStatistic;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in inserting a sample GDP Airline Statistic.'+e.getMessage());
		}
		Accreditation__c testaccreditationRecords = IECTestUtil.CreateSampleAccreditation(sampleTestAccount);
		testaccreditationRecords.Status__c = sampleTestAccountReferenceTable2.Id;
		testaccreditationRecords.Class__c = sampleTestAccountReferenceTable1.Id;
		try
		{
			insert testaccreditationRecords;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in inserting a test accrediation.'+e.getMessage());
		}
		List<GDP_Products_Account_View__c> accountRecords = new List<GDP_Products_Account_View__c>();
		GDP_Products_Account_View__c sampleTestProductAccount = IECTestUtil.createSampleGDPAccount('TestGDPAccount',
																								   '12345678',
																								   sampleTestAccountReferenceTable1,
																								   sampleTestAccountReferenceTable2,
																								   sampleTestAccountReferenceTable3);
		sampleTestProductAccount.Related_GDP_Address__c = sampleAccountAddress.Id;
		sampleTestProductAccount.Related_Accreditation_Class__c = testaccreditationRecords.Id;
		accountRecords.add(sampleTestProductAccount);
		GDP_Products_Account_View__c sampleTestProductAccountB = IECTestUtil.createSampleGDPAccount('TestGDPAcc',
																								   '1235485',
																								   sampleTestAccountReferenceTable1,
																								   sampleTestAccountReferenceTable2,
																								   sampleTestAccountReferenceTable4);
		sampleTestProductAccountB.Related_GDP_Address__c = sampleAccountAddress.Id;
		sampleTestProductAccountB.Related_Accreditation_Class__c = testaccreditationRecords.Id;
		accountRecords.add(sampleTestProductAccountB);
		try
		{
			insert accountRecords;
		}
		catch(Exception e)
		{
			//force failing assertion
			system.assertEquals(true,false,'There is an issue in inserting a test GDP Products Account.'+e.getMessage());
		}
	}
	public static TestMethod void TestSchedule()
	{
		InitializeTestData();
		// just give some date... it is not considered for the execution of the schedular
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		test.startTest();
		String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new SchdlAirlinesStatistics());
		test.stopTest();
	}
	public static TestMethod void TestBatch()
	{
		InitializeTestData();
		List<GDP_Airlines_Statistic__c> resultBeforeBatch = [Select Id,AA__c,AC__c,AO__c,Last_Update__c
															 from GDP_Airlines_Statistic__c];
		test.startTest();
		BtchAirlinesStatistics btchProc = new BtchAirlinesStatistics();
		Database.executeBatch(btchProc, 100);
		test.stopTest();
		List<GDP_Airlines_Statistic__c> resultAfterBatch = [Select Id,AA__c,AC__c,AO__c,Last_Update__c
															from GDP_Airlines_Statistic__c];
		system.assertNotEquals(resultBeforeBatch, resultAfterBatch,'the two selects should not be the same');
		system.assertEquals(resultAfterBatch.size(),1,'only once Code is being used in the test data => AO');
		GDP_Airlines_Statistic__c resultRecord = resultAfterBatch[0];
		system.assertEquals(resultRecord.AO__c,2,'There are 2 Product Accounts using the same Key and Code. Key = ASLTEST and Code used is AO');
	}
}
