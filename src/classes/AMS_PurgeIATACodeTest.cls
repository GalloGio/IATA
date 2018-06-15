@isTest
private class AMS_PurgeIATACodeTest {
	
	@testSetup static void setup(){

		Date myDate1 = Date.newInstance(2016, 2, 17);
		Date myDate2 = Date.newInstance(2016, 2, 17);

        ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Portugal');
        insert portugal;


		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account 1';
		account1.IATACode__c = '1234567';
		account1.Type = 'IATA Cargo Agent';
		account1.BillingCity = 'Lisboa';
		account1.BillingCountry = 'Portugal';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		account1.Accreditation_date__c = myDate1;
		account1.recordTypeId = rtAgency;
		account1.IATA_ISO_Country__c = portugal.Id;
		account1.Location_Class__c = 'C';
		account1.Purge_Flag__c = false;

		insert account1;

		// create test account1
		Account account2 = new Account();
		account2.Name = 'Test account 2';
		account2.IATACode__c = '12345689111';
		account2.Type = 'IATA Cargo Agent';
		account2.BillingCity = 'Lisboa';
		account2.BillingCountry = 'Portugal';
		account2.BillingStreet = 'some street 2';
		account2.Location_Type__c = 'HO';
		account2.Accreditation_date__c = myDate2;
		account2.recordTypeId = rtAgency;
		account2.IATA_ISO_Country__c = portugal.Id;
		account2.Location_Class__c = 'C';
		account2.Purge_Flag__c = false;

		insert account2;

		GDP_Products_Account_View__c gdp = new GDP_Products_Account_View__c(IATA_Code__c = '1234567');
		GDP_Products_Account_View__c gdp2 = new GDP_Products_Account_View__c(IATA_Code__c = '12345689111');

		insert gdp;
		insert gdp2;

	}

	@isTest static void runProcessForIatacodePurge() {
		
		Test.startTest();

		List<Account> accts = [SELECT Id, Name, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c from Account];

		String newIATACodePurged = AMS_PurgeAccountBatch.transformIATACodeintoPurged(accts.get(0).IATACode__c);

		Set<Id> accountsToPurge = new Set<Id>{accts.get(0).Id, accts.get(1).Id};

		AMS_PurgeAccountBatch pab = new AMS_PurgeAccountBatch(accountsToPurge);

    	Id aMS_PurgeAccountBatchId = Database.executeBatch(pab,200);

		Test.stopTest();

		accts = [SELECT Id, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c, NAme from Account];

		System.assertEquals(newIATACodePurged,accts.get(0).IATACode__c );
		
		List<GDP_Products_Account_View__c> gdps = [select Id, IATA_Code__c from GDP_Products_Account_View__c];

		System.assertEquals(newIATACodePurged, gdps.get(0).IATA_Code__c);
	}

	
	@isTest static void runProcessForIatacodePurgeErrorTesting2() {
		
		Test.startTest();

		List<Account> accts = [SELECT Id, Name, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c from Account];

		Account acctError1 = accts.get(0);
		Account acctError2 = accts.get(1);

		acctError1.IATACode__c = acctError1.IATACode__c + '123456';
		acctError2.IATACode__c = acctError2.IATACode__c + '123457';

		update new List<Account>{acctError1,acctError2};

		List<GDP_Products_Account_View__c> gdps = [select Id, IATA_Code__c from GDP_Products_Account_View__c];

		GDP_Products_Account_View__c gdpError1 = gdps.get(0);
		GDP_Products_Account_View__c gdpError2 = gdps.get(1);

		gdpError1.IATA_Code__c = acctError1.IATACode__c;
		gdpError2.IATA_Code__c = acctError2.IATACode__c;

		update new List<GDP_Products_Account_View__c>{gdpError1,gdpError2};

		Set<String> accountsIATACODEToPurge = new Set<String>{acctError1.IATACode__c, acctError2.IATACode__c};

		AMS_PurgeGDPIATACodeBatch pab = new AMS_PurgeGDPIATACodeBatch(accountsIATACODEToPurge);

    	Id aMS_PurgeGDPBatchId = Database.executeBatch(pab,200);

		Test.stopTest();

	}

	@isTest static void runProcessForIatacodePurgeErrorTesting() {
		
		Test.startTest();

		List<Account> accts = [SELECT Id, Name, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c from Account];

		Account acctError1 = accts.get(0);
		Account acctError2 = accts.get(1);

		acctError1.IATACode__c = acctError1.IATACode__c + '123456';
		acctError2.IATACode__c = acctError2.IATACode__c + '123457';

		update new List<Account>{acctError1,acctError2};

		Set<Id> accountsToPurge = new Set<Id>{accts.get(0).Id, accts.get(1).Id};

		AMS_PurgeAccountBatch pab = new AMS_PurgeAccountBatch(accountsToPurge);

    	Id aMS_PurgeAccountBatchId = Database.executeBatch(pab,200);

		Test.stopTest();

	}

	@isTest static void aMS_PurgeIATACodeControllerTest() {
		Id purgeId;
		AMS_SOQL_Query_Export__c exportRecord = new AMS_SOQL_Query_Export__c(
			Name = 'Full Purge IATA Code',
			Order_Direction__c = 'Ascending'
		);


		PageReference pageRef = Page.AMS_PurgeIATACodePage;

        Test.setCurrentPageReference(pageRef);

        AMS_PurgeIATACodeController controller = new AMS_PurgeIATACodeController();

        Test.startTest();
        
        //AMS_VoucherManagerPage page = new AMS_VoucherManagerPage(sc);

		purgeId = controller.fullPurgeId;
		purgeId = controller.litePurgeId;
        
        controller.checkBatchStatus();

        controller.contentFile = Blob.valueOf('Id,IATACode__c,C_Code__c,A_Code__c,N_Code__c,Site,Name,Location_Type__c,Location_Class__c,Expiry_Date__c,Accreditation_date__c,Not to Purge SFDC,Not to Purge External\n0013E0000000000001,00000000012,,,,,Account A Portugal,HO,C,,Wed Jan 01 00:00:00 GMT 2014,,');

        controller.fetchSOQLObjects();

        controller.ReadFile();

        controller.runPurgeProcess();

        controller.checkBatchStatus();

        controller.contentFile = Blob.valueOf('Id,IATACode__c,C_Code__c,A_Code__c,N_Code__c,Site,Name,Location_Type__c,Location_Class__c,Expiry_Date__c,Accreditation_date__c,Not to Purge SFDC,Not to Purge External\n0013E0000000000001,00000000012,,,,,Account A Portugal,HO,C,,Wed Jan 01 00:00:00 GMT 2014,Wed Jan 01,xxx,xxx,yyy');

        controller.fetchSOQLObjects();

        controller.ReadFile();

        controller.runPurgeProcess();


        List<String> notesTest = controller.noteListFullPurge;
		List<String> notesTest2 = controller.noteListLitePurge;
		List<String> notesTest3 = controller.noteListUpload;

		insert exportRecord;

		controller.fetchSOQLObjects();

		exportRecord.Name = 'Lite Purge IATA Code';

		update exportRecord;
	
		controller.fetchSOQLObjects();

        Test.stopTest();

	}

	@isTest static void AMSSOQ_ControllerTest() {

		

		PageReference pageRef = Page.AMS_SOQL_ExportPage;

		AMS_SOQL_Query_Export__c export1 = new AMS_SOQL_Query_Export__c();
		export1.Name = 'Full Purge IATA Code';
		export1.Fields__c='Id,IATACode__c,C_Code__c,A_Code__c,N_Code__c,Site,Name,Location_Type__c,Location_Class__c,Expiry_Date__c,Accreditation_date__c';
		export1.Limit__c='10000';
		export1.Object_name__c = 'Account';
		export1.Order_by__c='IATACode__c';
		export1.Order_Direction__c = 'Ascending';
		export1.Where_condition__c = '(Status__c = \'Terminated\' and Expiry_Date__c < LAST_N_YEARS:10 and Accreditation_date__c != null and IATACode__c != null and Purge_Flag__c = false) or Name != \'\'';


		AMS_SOQL_Query_Export__c export2 = new AMS_SOQL_Query_Export__c();
		export2.Name = 'Lite Purge IATA Code';
		export2.Fields__c='Id,IATACode__c,C_Code__c,A_Code__c,N_Code__c,Site,Name,Location_Type__c,Location_Class__c,Expiry_Date__c,Accreditation_date__c';
		export2.Limit__c='10000';
		export2.Object_name__c = 'Account';
		export2.Order_by__c='IATACode__c';
		export2.Order_Direction__c = 'Ascending';
		export2.Where_condition__c = 'Purge_Flag__c = false and Status__c = \'Not accreditated\' and IATACode__c != null and Id in (select account__c from Agency_Applied_Change_code__c where Change_Code__c = \'DIS\' and active__c = true and Effective_Date__c < LAST_N_MONTHS:6 )';


		insert new List<AMS_SOQL_Query_Export__c>{export1,export2};

        ApexPages.currentPage().getParameters().put('fullPurgeId', export1.Id);
		ApexPages.currentPage().getParameters().put('litePurgeId', export2.Id);

		Test.setCurrentPageReference(pageRef);

		Test.startTest();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(export1);

		AMS_SOQL_Export exportSOQL = new AMS_SOQL_Export(sc);

        Test.stopTest();

	}

	
}