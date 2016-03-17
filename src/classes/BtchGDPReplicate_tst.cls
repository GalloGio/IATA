/**
 * Description: This class contains unit tests for the (GDP Replication) batches
 * Author: Samy Saied
 * Version: 1.0
 * History: 
 **/
@isTest
private class BtchGDPReplicate_tst {
	static void Init() {
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		
		insert new IEC_GDP_Replication__c(Schedule_Active__c = true, Schedule_Period__c = 24, System_Admin_Email__c = 'saieds@iata.org');

		// Live Data
		Account oAccount1 = IECTestUtil.CreateSampleAccount();
		oAccount1.AIMS_ID__c = IECUtil.NewGuid().substring(0, 10);
		oAccount1.RecordTypeId = IECUtil.GetRecordTypeId('Account', 'IATA_Agency');
		oAccount1.IATACode__c = '12345678';
		insert oAccount1;
		
		Account oAccount2 = IECTestUtil.CreateSampleAccount();
		oAccount2.WebStar_ID__c = IECUtil.NewGuid().substring(0, 10);
		oAccount2.RecordTypeId = IECUtil.GetRecordTypeId('Account', 'IATA_Agency');
		oAccount2.IATACode__c = '87654321';
		insert oAccount2;

		Account oAccount3 = IECTestUtil.CreateSampleAccount();
		oAccount3.AIMS_ID__c = IECUtil.NewGuid().substring(0, 10);
		oAccount3.RecordTypeId = IECUtil.GetRecordTypeId('Account', 'IATA_Agency');
		oAccount3.IATACode__c = '45698723';
		oAccount3.ParentId = oAccount1.Id;
		insert oAccount3;
		
		Account oAccount4 = IECTestUtil.CreateSampleAccount();
		oAccount4.WebStar_ID__c = IECUtil.NewGuid().substring(0, 10);
		oAccount4.RecordTypeId = IECUtil.GetRecordTypeId('Account', 'IATA_Agency');
		oAccount4.IATACode__c = '32178945';
		oAccount4.ParentId = oAccount2.Id;
		insert oAccount4;
		
		Account_Category__c oAccount_Category1 = IECTestUtil.CreateSampleAccountCategory(oAccount1);
		oAccount_Category1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oAccount_Category1.WebStar_ID__c = null;
		insert oAccount_Category1;

		Account_Category__c oAccount_Category2 = IECTestUtil.CreateSampleAccountCategory(oAccount2);
		oAccount_Category2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oAccount_Category2.AIMS_ID__c = null;
		insert oAccount_Category2;

		Accreditation__c oAccreditation1 = IECTestUtil.CreateSampleAccreditation(oAccount1);
		oAccreditation1.AIMS_ID__c = oAccount1.AIMS_ID__c + 'ACC1';
		oAccreditation1.WebStar_ID__c = null;
		insert oAccreditation1;

		Accreditation__c oAccreditation2 = IECTestUtil.CreateSampleAccreditation(oAccount2);
		oAccreditation2.WebStar_ID__c = oAccount2.WebStar_ID__c + 'ACC1';
		oAccreditation2.AIMS_ID__c = null;
		insert oAccreditation2;

		Adjacent_Airport__c oAdjacent_Airport1 = IECTestUtil.CreateSampleAdjacentAirport(oAccount1);
		oAdjacent_Airport1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oAdjacent_Airport1.WebStar_ID__c = null;
		insert oAdjacent_Airport1;

		Adjacent_Airport__c oAdjacent_Airport2 = IECTestUtil.CreateSampleAdjacentAirport(oAccount2);
		oAdjacent_Airport2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oAdjacent_Airport2.AIMS_ID__c = null;
		insert oAdjacent_Airport2;

		Agency_Owner__c oAgency_Owner1 = IECTestUtil.CreateSampleAgencyOwner(oAccount1);
		oAgency_Owner1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oAgency_Owner1.WebStar_ID__c = null;
		insert oAgency_Owner1;

		Agency_Owner__c oAgency_Owner2 = IECTestUtil.CreateSampleAgencyOwner(oAccount2);
		oAgency_Owner2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oAgency_Owner2.AIMS_ID__c = null;
		insert oAgency_Owner2;

		Assoc_Affiliation_Membership__c oAssoc_Affiliation_Membership1 = IECTestUtil.CreateSampleAssocAffiliationMembership(oAccount1);
		oAssoc_Affiliation_Membership1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oAssoc_Affiliation_Membership1.WebStar_ID__c = null;
		insert oAssoc_Affiliation_Membership1;

		Assoc_Affiliation_Membership__c oAssoc_Affiliation_Membership2 = IECTestUtil.CreateSampleAssocAffiliationMembership(oAccount2);
		oAssoc_Affiliation_Membership2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oAssoc_Affiliation_Membership2.AIMS_ID__c = null;
		insert oAssoc_Affiliation_Membership2;

		GDP_Address__c oGDP_Address1 = IECTestUtil.CreateSampleGDPAddress(oAccount1);
		oGDP_Address1.AIMS_ID__c = oAccount1.AIMS_ID__c + 'LOC';
		oGDP_Address1.WebStar_ID__c = null;
		insert oGDP_Address1;

		GDP_Address__c oGDP_Address2 = IECTestUtil.CreateSampleGDPAddress(oAccount2);
		oGDP_Address2.WebStar_ID__c = oAccount2.WebStar_ID__c + 'LOC';
		oGDP_Address2.AIMS_ID__c = null;
		insert oGDP_Address2;

		GDP_Agency_Profile_Specialization__c oGDP_Agency_Profile_Specialization1 = IECTestUtil.CreateSampleGDPAgencyProfileSpecialization(oAccount1);
		oGDP_Agency_Profile_Specialization1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oGDP_Agency_Profile_Specialization1.WebStar_ID__c = null;
		insert oGDP_Agency_Profile_Specialization1;

		GDP_Agency_Profile_Specialization__c oGDP_Agency_Profile_Specialization2 = IECTestUtil.CreateSampleGDPAgencyProfileSpecialization(oAccount2);
		oGDP_Agency_Profile_Specialization2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oGDP_Agency_Profile_Specialization2.AIMS_ID__c = null;
		insert oGDP_Agency_Profile_Specialization2;

		GDP_Phone__c oGDP_Phone1 = IECTestUtil.CreateSampleGDPPhone(oAccount1);
		oGDP_Phone1.AIMS_ID__c = oAccount1.AIMS_ID__c + 'P1';
		oGDP_Phone1.WebStar_ID__c = null;
		insert oGDP_Phone1;

		GDP_Phone__c oGDP_Phone2 = IECTestUtil.CreateSampleGDPPhone(oAccount2);
		oGDP_Phone2.WebStar_ID__c = oAccount2.WebStar_ID__c + 'P1';
		oGDP_Phone2.AIMS_ID__c = null;
		insert oGDP_Phone2;

		GDS__c oGDS1 = IECTestUtil.CreateSampleGDS(oAccount1);
		oGDS1.AIMS_ID__c = oAccount1.AIMS_ID__c + '1';
		oGDS1.WebStar_ID__c = null;
		insert oGDS1;

		GDS__c oGDS2 = IECTestUtil.CreateSampleGDS(oAccount2);
		oGDS2.WebStar_ID__c = oAccount2.WebStar_ID__c + '1';
		oGDS2.AIMS_ID__c = null;
		insert oGDS2;
		
		
		// GDP Data
		GDP_Products_Account_View__c oGDPAccount1 = IECTestUtil.createSampleGDPAccount('Account 1', '12345678');
		oGDPAccount1.AIMS_ID__c = oAccount1.AIMS_ID__c + 'GDP';
		oGDPAccount1.WebStar_ID__c = null;
		oGDPAccount1.RecordTypeId = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		insert oGDPAccount1;
		
		GDP_Products_Account_View__c oGDPAccount2 = IECTestUtil.createSampleGDPAccount('Account 1', '87654321');
		oGDPAccount2.WebStar_ID__c = oAccount2.WebStar_ID__c + 'GDP';
		oGDPAccount2.AIMS_ID__c = null;
		oGDPAccount2.RecordTypeId = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		insert oGDPAccount2;

		GDP_Products_Account_View__c oGDPAccount3 = IECTestUtil.createSampleGDPAccount('Account 1', '45698723');
		oGDPAccount3.AIMS_ID__c = oAccount3.AIMS_ID__c + 'GDP';
		oGDPAccount3.WebStar_ID__c = null;
		oGDPAccount3.RecordTypeId = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		oGDPAccount3.Parent_Account_AIMS_ID__c = oAccount1.AIMS_ID__c;
		insert oGDPAccount3;
		
		GDP_Products_Account_View__c oGDPAccount4 = IECTestUtil.createSampleGDPAccount('Account 1', '32178945');
		oGDPAccount4.WebStar_ID__c = oAccount4.WebStar_ID__c + 'GDP';
		oGDPAccount4.AIMS_ID__c = null;
		oGDPAccount4.RecordTypeId = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		oGDPAccount4.Parent_Account_WebStar_ID__c = oAccount2.WebStar_ID__c;
		insert oGDPAccount4;

		Accreditation__c oAccreditation1_GDP = IECTestUtil.CreateSampleAccreditation(oAccount1, oGDPAccount1, 'GDP');
		oAccreditation1_GDP.AIMS_ID__c = oAccount1.AIMS_ID__c + 'ACC1GDP';
		oAccreditation1_GDP.WebStar_ID__c = null;
		insert oAccreditation1_GDP;

		Accreditation__c oAccreditation2_GDP = IECTestUtil.CreateSampleAccreditation(oAccount2, oGDPAccount2, 'GDP');
		oAccreditation2_GDP.WebStar_ID__c = oAccount2.WebStar_ID__c + 'ACC1GDP';
		oAccreditation2_GDP.AIMS_ID__c = null;
		insert oAccreditation2_GDP;

		GDP_Address__c oGDP_Address1_GDP = IECTestUtil.CreateSampleGDPAddress(oAccount1, oGDPAccount1, 'GDP');
		oGDP_Address1_GDP.AIMS_ID__c = oAccount1.AIMS_ID__c + 'LOCGDP';
		oGDP_Address1_GDP.WebStar_ID__c = null;
		insert oGDP_Address1_GDP;

		GDP_Address__c oGDP_Address2_GDP = IECTestUtil.CreateSampleGDPAddress(oAccount2, oGDPAccount2, 'GDP');
		oGDP_Address2_GDP.WebStar_ID__c = oAccount2.WebStar_ID__c + 'LOCGDP';
		oGDP_Address2_GDP.AIMS_ID__c = null;
		insert oGDP_Address2_GDP;

		GDP_Phone__c oGDP_Phone1_GDP = IECTestUtil.CreateSampleGDPPhone(oAccount1, oGDPAccount1, 'GDP');
		oGDP_Phone1_GDP.AIMS_ID__c = oAccount1.AIMS_ID__c + 'P1GDP';
		oGDP_Phone1_GDP.WebStar_ID__c = null;
		insert oGDP_Phone1_GDP;

		GDP_Phone__c oGDP_Phone2_GDP = IECTestUtil.CreateSampleGDPPhone(oAccount2, oGDPAccount2, 'GDP');
		oGDP_Phone2_GDP.WebStar_ID__c = oAccount2.WebStar_ID__c + 'P1GDP';
		oGDP_Phone2_GDP.AIMS_ID__c = null;
		insert oGDP_Phone2_GDP;
    }
    
    static testMethod void TestGDPReplicateScheduleAccount() {
    	System.debug('Unit Test: Start: TestGDPReplicateScheduleAccount');

    	Init();

		Test.startTest();
		
    	//*
    	// Schedule - Account
    	//*
		// This section of code will schedule the next execution X minutes from now depending on the configured setting
		datetime nextScheduleTime = system.now().addSeconds(10);
		string month = string.valueof(nextScheduleTime.month());
		string day = string.valueof(nextScheduleTime.day());
		string hour = string.valueof(nextScheduleTime.hour());
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
		string jobName = 'SchdlIECGDPReplication ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
 		system.schedule(jobName, cronvalue , new SchdlIECGDPReplication());

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateScheduleAccount');
    }
    
    static testMethod void TestGDPReplicateAccount() {
    	System.debug('Unit Test: Start: TestGDPReplicateAccount');

    	Init();

		Test.startTest();

    	//*
    	// Account 
    	//*
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account');
		BtchGDPReplicateAccount btchProc = new BtchGDPReplicateAccount();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		btchProc.query =
			'SELECT AIMS_ID__c, Webstar_ID__c, GDP_Location_Type__c, Airline_Code__c, Name, TradeName__c'
			+ '		, Email__c, Website, TTY__c, Passenger_And_Cargo__c, Incorporation_Type__c, GDP_Opt_In__c'
			+ '		, Tax_ID_1__c, Tax_ID_2__c, BSP_CASS_Code__c, License_Number__c, Preferred_Language__c'
			+ '		, CASS_Number_Xref__c, IATACode__c, CASS_Number__c, Ticketing_Agent_Last_Name__c'
			+ '		, Ticketing_Agent_First_Name__c, Manager_Last_Name__c, Manager_First_Name__c'
			+ '		, ParentId, Parent.AIMS_ID__c, Parent.Webstar_ID__c'
			+ '	FROM Account'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND IATACode__c != null'
			+ '		AND ((Is_AIMS_Account__c = true AND AIMS_ID__c != null) OR Webstar_ID__c != null)'
			+ '		AND Account.ID IN ('
			+ '			SELECT Related_Account__c'
			+ '			FROM Accreditation__c'
			+ '			WHERE Endorsed_Accredited_By__r.Code__c IN (\'IATA\',\'IATAN\')'
			+ '				AND Class__r.Code__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\')'
			+ '				AND Related_Account__r.Id != null'
			+ '			)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Account', 'IATA_Agency') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAccount');
    }
    
        static testMethod void TestGDPReplicateAccount2() {
    	System.debug('Unit Test: Start: TestGDPReplicateAccount 2');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// Account 2 
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account Category');
		BtchGDPReplicateAccount btchProc = new BtchGDPReplicateAccount();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, Webstar_ID__c, GDP_Location_Type__c, Airline_Code__c, Name, TradeName__c'
			+ '		, Email__c, Website, TTY__c, Passenger_And_Cargo__c, Incorporation_Type__c, GDP_Opt_In__c'
			+ '		, Tax_ID_1__c, Tax_ID_2__c, BSP_CASS_Code__c, License_Number__c, Preferred_Language__c'
			+ '		, CASS_Number_Xref__c, IATACode__c, CASS_Number__c, Ticketing_Agent_Last_Name__c'
			+ '		, Ticketing_Agent_First_Name__c, Manager_Last_Name__c, Manager_First_Name__c'
			+ '		, ParentId, Parent.AIMS_ID__c, Parent.Webstar_ID__c'
			+ '	FROM Account'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Account', 'IATA_Agency') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAccount');
    }
    
    static testMethod void TestGDPReplicateAccountCategory() {
    	System.debug('Unit Test: Start: TestGDPReplicateAccountCategory');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// Account Category
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account Category');
		BtchGDPReplicateAccountCategory btchProc = new BtchGDPReplicateAccountCategory();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Account_Category__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Category_ID__c, Category_Code__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM Account_Category__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Account_Category__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAccountCategory');
    }
    
    static testMethod void TestGDPReplicateAccreditation() {
    	System.debug('Unit Test: Start: TestGDPReplicateAccreditation');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// Accreditation
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Accreditation');
		BtchGDPReplicateAccreditation btchProc = new BtchGDPReplicateAccreditation();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Accreditation__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Accreditation_ID__c, Class__c'
			+ '		, Endorsed_Accredited_By__c, Last_change_date__c, Last_re_inspection_date__c'
			+ '		, Original_approval_date__c, Status__c, Date__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM Accreditation__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Accreditation__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAccreditation');
    }
    
    static testMethod void TestGDPReplicateAdjacentAirport() {
    	System.debug('Unit Test: Start: TestGDPReplicateAdjacentAirport');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// Adjacent Airport
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Adjacent Airport');
		BtchGDPReplicateAdjacentAirports btchProc = new BtchGDPReplicateAdjacentAirports();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Adjacent_Airport__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Name, Airport_ID__c, AirportCode__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM Adjacent_Airport__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Adjacent_Airport__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAdjacentAirport');
    }
    
    static testMethod void TestGDPReplicateAgencyOwner() {
    	System.debug('Unit Test: Start: TestGDPReplicateAgencyOwner');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// Agency Owner
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Agency Owner');
		BtchGDPReplicateAgencyOwner btchProc = new BtchGDPReplicateAgencyOwner();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Agency_Owner__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Name, Owner_ID__c, Percent__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM Agency_Owner__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Agency_Owner__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAgencyOwner');
    }
    
    static testMethod void TestGDPReplicateAffiliation() {
    	System.debug('Unit Test: Start: TestGDPReplicateAffiliation');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();
    	//*
    	// Assoc Affiliation Membership
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Assoc Affiliation Membership');
		BtchGDPReplicateAffiliations btchProc = new BtchGDPReplicateAffiliations();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Assoc_Affiliation_Membership__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Assoc_Affiliation_ID__c, Assoc_Affiliation_Code__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM Assoc_Affiliation_Membership__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Assoc_Affiliation_Membership__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAffiliation');
    }
    
    static testMethod void TestGDPReplicateAddress() {
    	System.debug('Unit Test: Start: TestGDPReplicateAddress');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// GDP Address
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: GDP Address');
		BtchGDPReplicateAddress btchProc = new BtchGDPReplicateAddress();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Address__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Address_City__c, Address_Line_1__c, Address_Line_2__c'
			+ '		, Address_Line_3__c, Address_Postal_Code__c, Address_Type__c, GDP_Geo_Detail__c'
			+ '		, IATA_ISO_Country__c, IATA_ISO_State__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM GDP_Address__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDP_Address__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAddress');
    }
    
    static testMethod void TestGDPReplicateAgencyProfile() {
    	System.debug('Unit Test: Start: TestGDPReplicateAgencyProfile');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();

    	//*
    	// GDP Agency Profile and Specialization
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: GDP Agency Profile and Specialization');
		BtchGDPReplicateAgencyProfiles btchProc = new BtchGDPReplicateAgencyProfiles();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Agency_Profile_Specialization__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Main_Activity__c, Main_Destination_Specialization__c'
			+ '		, Main_Market_Specialization__c, Market_Focus_Corporate__c, Market_Focus_Leisure__c'
			+ '		, Sales_Accomodation__c, Sales_Air__c, Sales_Land__c, Sales_Sea__c, Sales_Tour__c'
			+ '		, Sales_Volume__c, Secondary_Destination_Specialization__c, Secondary_Market_Specialization__c'
			+ '		, Tertiary_Destination_Specialization__c, Tertiary_Market_Specialization__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM GDP_Agency_Profile_Specialization__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDP_Agency_Profile_Specialization__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAgencyProfile');
    }
    
    static testMethod void TestGDPReplicatePhone() {
    	System.debug('Unit Test: Start: TestGDPReplicatePhone');

    	Init();
		
		IECUtil.SetBatchReplication('GDP Replicate: Account', System.now().addHours(4));

		Test.startTest();
		
    	//*
    	// GDP Phone
    	//*
		IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: GDP Phone');
		BtchGDPReplicatePhone btchProc = new BtchGDPReplicatePhone();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Phone__c', 'GDP');
		btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
		btchProc.query =
			'SELECT AIMS_ID__c, WebStar_ID__c, Name, ISD_Code__c, Number__c, Phone_Type__c, STD_Code__c'
			+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
			+ '	FROM GDP_Phone__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDP_Phone__c', 'Live') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicatePhone');
    }
    
    static testMethod void TestGDPReplicateGDS() {
    	System.debug('Unit Test: Start: TestGDPReplicateGDS');

    	Init();
		
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
    }
    
    static testMethod void TestGDPReplicateAccountUpdate() {
    	System.debug('Unit Test: Start: TestGDPReplicateAccountUpdate');

    	Init();

		Test.startTest();

    	//*
    	// Account Update
    	//*
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account');
		BtchGDPReplicateAccountUpdate btchProc = new BtchGDPReplicateAccountUpdate();
		btchProc.dtSystemNow = btchRep.Last_Modified_Date__c;
		btchProc.query =
			'SELECT Id, AIMS_ID__c, Webstar_ID__c, Parent_Account_AIMS_ID__c, Parent_Account_WebStar_ID__c, IATA_Code__c'
			+ '	FROM GDP_Products_Account_View__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP') + '\'';
		System.debug('SSS: SOQL Query: ' + btchProc.query);
		Database.executeBatch(btchProc);

        Test.stopTest();
    	
    	System.debug('Unit Test: Finish: TestGDPReplicateAccountUpdate');
    }
    
    
    
     static testMethod void TestIECErrorLog() {
         
        IECErrorLogger logger = new IECErrorLogger();
		 
         //cover the if string > 255 chars
         String tempString = 'temptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemptemp';
        
         IECErrorLogger.logBatchError(tempString, tempString, tempString, 'tempString', 'tempString');
         IECErrorLogger.logError(null, tempString, tempString, 'tempString', 'tempString', 'tempString');
         IECErrorLogger.logInfo(null, tempString, tempString, 'tempString', 'tempString');
          
         
     }
    
    
}