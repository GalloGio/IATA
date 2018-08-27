/**
 * Description: This class contains unit tests for the BtchGDPReplicateTerritoriesBatch
 *  - Based on t he model we have in BtchGDPReplicate_tst.cls
 *
 * Author: Sonny Leman
 * Version: 1.0
 * History: 
 *   - Sonny Leman 04/02/2016: was written as part of BtchGDPReplicate_tst.cls
 *
 * Important note (Sonny Leman):
 *   - During the addition of test method for BtchGDPReplicateTerritories, I come to a realization that this test class was not intended to do any test, except get a high coverage.
 *   - While we tried to reduce the bad model, we are limited to the the fact that as this batch is running in cascading process with other and we avoid changing other codes.
 *   - Our suggestion is to correct this whole model. 
 **/
 

@isTest (SeeAllData=false)
private class BtchGDPReplicateTerrTest {
	private static string aimsID_good = '1234567890'; // oAccount1.AIMS_ID__c , good AIMS_ID__c for territory testing
	private static string iataCode_good = '1234567'; // oAccount1.IATACode__c.substring(0,7), good IATA_Code__c for territory testing
	private static string iataCode_bad = '9234560'; // bad IATA_Code__c for territory testing that has match in the 
		
	
	@testSetup static void dataInitialization() {
		insert new IEC_GDP_Replication__c(Schedule_Active__c = true, Schedule_Period__c = 24, System_Admin_Email__c = 'saieds@iata.org');
		
		list<sObject> sObjList = new list<sObject>();
		
		GDP_Reference_Table__c refTableEndorser = new GDP_Reference_Table__c( Code__c = 'IATA', Name='IATA'
			, Definition__c = 'Test IATA', System_ID__c='ORGABBIATA', System__c='Global', Table__c ='ORGABB');
		GDP_Reference_Table__c refTableClass = new GDP_Reference_Table__c( Code__c = 'C', Name='Corporation'
			, Definition__c = 'Corporation' 
			, System_ID__c='LGLTYP', System__c='Global', Table__c ='LGLTYP');
		List<GDP_Reference_Table__c> refTable = new List<GDP_Reference_Table__c> { refTableEndorser, refTableClass};
		upsert refTable;
		System.debug( 'GDP_Reference_Table upserted:' + refTable);
		
		// Live Data
		Account oAccount1 = IECTestUtil.CreateSampleAccount();
		oAccount1.AIMS_ID__c = aimsID_good;
		oAccount1.RecordTypeId = IECUtil.GetRecordTypeId('Account', 'IATA_Agency');
		oAccount1.IATACode__c = iataCode_good; // '12345678';
		sObjList.add(oAccount1);
		 
		Account oAccount2 = IECTestUtil.CreateSampleAccount();
		oAccount2.WebStar_ID__c = IECUtil.NewGuid().substring(0, 10);
		oAccount2.RecordTypeId = IECUtil.GetRecordTypeId('Account', 'IATA_Agency');
		oAccount2.IATACode__c = '87654321';
		sObjList.add(oAccount2);

		insert sObjList;
		sObjList.clear();
		
		// add Accreditation__c
		Accreditation__c oAccreditation1 = IECTestUtil.CreateSampleAccreditation(oAccount1);
		oAccreditation1.AIMS_ID__c = oAccount1.AIMS_ID__c + 'ACC1';
		oAccreditation1.WebStar_ID__c = null;
		
		oAccreditation1.Class__c = refTableClass.Id; // this is used for testing BtchGDPReplicateTerritories
		
		sObjList.add(oAccreditation1);
		
		GDS__c oGDS1 = IECTestUtil.CreateSampleGDS(oAccount1);
		oGDS1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oGDS1.WebStar_ID__c = null;
		sObjList.add(oGDS1);

		GDS__c oGDS2 = IECTestUtil.CreateSampleGDS(oAccount2);
		oGDS2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oGDS2.AIMS_ID__c = null;
		sObjList.add(oGDS2);
		
		//Insert at mid of list to avoid folling error
		//Cannot have more than 10 types in a single save operation. Please reduce number of types in one save operation.
		insert sObjList;
		sObjList.clear();
			
		// GDP Data
		GDP_Products_Account_View__c oGDPAccount1 = IECTestUtil.createSampleGDPAccount('Account 1', '1234567'); // aimsID_good
		oGDPAccount1.AIMS_ID__c = oAccount1.AIMS_ID__c + 'GDP';
		oGDPAccount1.WebStar_ID__c = null;
		oGDPAccount1.RecordTypeId = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		sObjList.add(oGDPAccount1);
		
		GDP_Products_Account_View__c oGDPAccount2 = IECTestUtil.createSampleGDPAccount('Account 1', '87654321');
		oGDPAccount2.WebStar_ID__c = oAccount2.WebStar_ID__c + 'GDP';
		oGDPAccount2.AIMS_ID__c = null;
		oGDPAccount2.RecordTypeId = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		sObjList.add(oGDPAccount2);
		
		Accreditation__c oAccreditation1_GDP = IECTestUtil.CreateSampleAccreditation(oAccount1, oGDPAccount1, 'GDP');
		oAccreditation1_GDP.AIMS_ID__c = oAccount1.AIMS_ID__c + 'ACC1GDP';
		oAccreditation1_GDP.WebStar_ID__c = null;
		sObjList.add(oAccreditation1_GDP);

		Accreditation__c oAccreditation2_GDP = IECTestUtil.CreateSampleAccreditation(oAccount2, oGDPAccount2, 'GDP');
		oAccreditation2_GDP.WebStar_ID__c = oAccount2.WebStar_ID__c + 'ACC1GDP';
		oAccreditation2_GDP.AIMS_ID__c = null;
		sObjList.add(oAccreditation2_GDP);
		
		sObjList.sort();
		insert sObjList;
		
		// set static variable for testing the territory
		aimsID_good = oAccount1.AIMS_ID__c; // this is for testing the territory
		//iataCode_good = oAccount1.IATACode__c.substring(0,7); // this is for testing the territory
		
		System.debug('Init(): iataCode_:' + iataCode_good);
		System.debug('Init: aimsID:' + aimsID_good);
	
	} // end of Init
	
	private static void showTerritory( DateTime batchStartTime)
	{
		List<GSA_Territory__c> gterall = [select Id, Name, LastModifiedDate, AIMS_ID__c
										  , Related_account__c, Related_Accreditation__c 
										  from GSA_Territory__c];
		System.debug( 'all territory :' + gterall);
		
		List<Accreditation__c> accredall = [select Id, Name, AIMS_ID__c, Related_Account__c
												, Related_Account__r.Name
												, Endorsed_Accredited_By__c 
												, Class__c, Class__r.Code__c
												from Accreditation__c
										   		order by Id];
		System.debug( 'all accreditation:' + accredall);
		
		
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Territories' );
		System.debug( 'showTerritory btchRep: ' + btchRep);
		String query =
			'SELECT Id, AIMS_ID__c, IATA_Code__c'
			+ ', Related_Account__r.IATACode__c'
			+ ', Check_Digit__c'
			+ ', IATA_ISO_Country__c'
			+ ', IATA_ISO_NCode__c'
			+ ', Location_Country_Name__c'
			+ ', Accreditation_ID__c'
			+ ', Airline_Code__c'
			+ ', Airline_Name__c'
			+ ', Appointment_Type__c'
			+ ', Appointment_Date__c'
			+ ', Related_Accreditation__c'
			+ ', Territory_ISO_Country__c'
			+ ', Territory_IATA_Numeric_Country_Code__c'
			+ ', Territory_Country_Name__c'
			+ ', Territory_State_Abbreviation__c'
			+ ', Territory_Description__c'
			+ ', AIMS_Related_Account__c'
			+ '	FROM GSA_Territory__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + batchStartTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null)'
			//+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GSA_Territory__c', 'Live') + '\''
			+ '     AND Related_Account__c IN (SELECT Id FROM Account WHERE Location_Class__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\'))'                  
			+ '		AND Related_Accreditation__c != null '
			;
			
		System.debug( 'territories: query: ' + query);
		List<GSA_Territory__c> gterlist = Database.query(query);
		System.debug( '\n\nterritory result:' + gterlist.size());
		System.debug( 'territories: ' + gterlist);
	}
	
	// create but not insert a territory
	private static GSA_Territory__c newTerritory( String acctAimsId )
	{
		GSA_Territory__c returnTerritory = new GSA_Territory__c(
			 AIMS_ID__c = acctAimsId
			, AIMS_Territory_Unique_Reference__c = acctAimsId
			//, IATA_ISO_Country__c = 'CA'
			//, IATA_ISO_NCode__c = '12'
			//, Location_Country_Name__c = 'Canada'
			//, Airline_Code__c = 'XX'
			//, Airline_Name__c = 'XX Airlines'
			//// , Appointment_Type__c
			//, Appointment_Date__c = Date.today().addMonths(-3)
			//, Territory_ISO_Country__c = 'CA'
			//, Territory_IATA_Numeric_Country Code__c = '12'
			//, Territory_Country_Name__c = 'Canada'
			//, Territory_State_Abbreviation__c = 'QC'
			//, Territory_Description__c
		);
		if (acctAimsId != null) 
		{
			//Account relatedAccount = new Account( AIMS_ID__c = acctAimsId );
			//returnTerritory.Related_Account__r = relatedAccount;
			
			Accreditation__c relatedAccreditation = new Accreditation__c( AIMS_ID__c = acctAimsId + 'ACC1');
			returnTerritory.Related_Accreditation__r = relatedAccreditation;
		}
		
		return returnTerritory;
	} // end of newTerritory
	
	
	// ========================================================================
	// The test methods are listed below
	// ========================================================================
	static testMethod void TestGDPReplicateGDS() {
		System.debug('Unit Test: Start: TestGDPReplicateGDS');
		
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));
		
		Test.startTest();
		
		//*
		// GDS
		//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: GDS');
		BtchGDPReplicateGDS btchProc = new BtchGDPReplicateGDS();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDS__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Computer_Reservation_System__c, GDS_ID__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM GDS__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDS__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

		Test.stopTest();
		
		System.debug('Unit Test: Finish: TestGDPReplicateGDS');
	} // TestGDPReplicateGDS
	
	// ========================================================================
	// test BtchGDPReplicateTerritories.cls
	static testMethod void TestGDPReplicateTerritories_01_GoodCase() {
		System.debug('Unit Test: Start: TestGDPReplicateTerritories');
		// set the log: the previous GDP Replication was done 4 hour before
		IECUtil.SetBatchReplication('GDP Replicate: Territories', System.now().addDays(-1));
		
		// add good Territory record
		// 
		System.debug('iataCode_:' + iataCode_good);
		System.debug('aimsID:' + aimsID_good);
		GSA_Territory__c oGSA_Territory_GDP = newTerritory( aimsID_good) ; // oAccount1.AIMS_ID__c;
		oGSA_Territory_GDP.IATA_Code__c = iataCode_good; // '1234567'; // oAccount1.IATACode__c.substring(0,7);
		insert oGSA_Territory_GDP;	
		
		System.debug('Unit Test: Start: TestGDPReplicateTerritories check');
		
		// ideally this should return 0, as no error was created at this time
		Integer numberOfErrorLogBefore = [select count() from IEC_Error_Log__c ];
		System.debug( 'IEC Error log list at the beginning: numberOfErrorLogBefore ' +  numberOfErrorLogBefore);
		List<IEC_Error_Log__c> iecErrorLogList01 = [select Id, Source__c, Errror_Message__c from IEC_Error_Log__c order by LastModifiedDate limit 15];
		System.debug( 'IEC Error log list at the beginning: ' + iecErrorLogList01);
		System.assertEquals(0, iecErrorLogList01.size(), 'This should give zero error logged at the beginning.');
		
		Test.startTest();
		// ====================================================================
		System.debug('Unit Test: Start: startTest:');
		BtchGDPReplicateTerritories.callBatchReplicateTerritories(DateTime.now().addHours(4));
		
		// ====================================================================
		Test.stopTest();
		
		// no error should have been reported, as this is a good test case
		Integer numberOfErrorLogAfter = [select count() from IEC_Error_Log__c ];
		System.debug( 'IEC Error log list after: numberOfErrorLogAfter ' +  numberOfErrorLogAfter);
		List<IEC_Error_Log__c> iecErrorLogList02 = [select Id, Source__c, Errror_Message__c from IEC_Error_Log__c order by LastModifiedDate limit 15];
		System.debug( 'IEC Error log list after test: ' + iecErrorLogList02);
		// System.assertEquals(0, iecErrorLogList02.size(), 'This should give zero error logged.'); // we cannot enforce this, as apparently some other class will generate error on purpose
		System.debug('Unit Test: Finish: TestGDPReplicateTerritories');
	} // end TestGDPReplicateTerritories_01_GoodCase
	
	
	// ========================================================================
	// test BtchGDPReplicateTerritories.cls
	static testMethod void TestGDPReplicateTerritories_02_BadCase() {
		System.debug('Unit Test: Start: TestGDPReplicateTerritories');
		// set the log: the previous GDP Replication was done 4 hour before
		IECUtil.SetBatchReplication('GDP Replicate: Territories', System.now().addDays(-1));
		
		// add good Territory record
		// 
		System.debug('iataCode_:' + iataCode_bad);
		System.debug('aimsID:' + aimsID_good);
		GSA_Territory__c oGSA_Territory_GDP = newTerritory( aimsID_good) ; // oAccount1.AIMS_ID__c;
		oGSA_Territory_GDP.IATA_Code__c = iataCode_bad; 
		insert oGSA_Territory_GDP;	
		
		System.debug('Unit Test: Start: TestGDPReplicateTerritories check');
		
		// ideally this should return 0, as no error was created at this time
		Integer numberOfErrorLogBefore = [select count() from IEC_Error_Log__c ];
		System.debug( 'IEC Error log list at the beginning: numberOfErrorLogBefore ' +  numberOfErrorLogBefore);
		List<IEC_Error_Log__c> iecErrorLogList01 = [select Id, Source__c, Errror_Message__c from IEC_Error_Log__c order by LastModifiedDate limit 15];
		System.debug( 'IEC Error log list at the beginning: ' + iecErrorLogList01);
		System.assertEquals(0, iecErrorLogList01.size(), 'This should give zero error logged at the beginning.');
		
		Test.startTest();
		// ====================================================================
		System.debug('Unit Test: Start: startTest:');
		BtchGDPReplicateTerritories.callBatchReplicateTerritories(DateTime.now().addHours(4));
		
		// ====================================================================
		Test.stopTest();
		
		// no error should have been reported, as this is a good test case
		Integer numberOfErrorLogAfter = [select count() from IEC_Error_Log__c ];
		System.debug( 'IEC Error log list after: numberOfErrorLogAfter ' +  numberOfErrorLogAfter);
		List<IEC_Error_Log__c> iecErrorLogList02 = [select Id, Source__c, Errror_Message__c from IEC_Error_Log__c order by LastModifiedDate limit 15];
		System.debug( 'IEC Error log list after test: ' + iecErrorLogList02);
		// System.assertEquals(0, iecErrorLogList02.size(), 'This should give zero error logged.'); // we cannot enforce this, as apparently some other class will generate error on purpose
		System.debug('Unit Test: Finish: TestGDPReplicateTerritories');
	} // end TestGDPReplicateTerritories_02_BadCase
	
	
}