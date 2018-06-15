@isTest
private class AMS_VoucherProcessTest {
	
	@testSetup static void setup(){

		Date myDate = Date.newInstance(2012, 2, 17);


        ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(AMS_Vouchers_Benchmark__c=600000 ,AMS_Max_Vouchers_Per_Year__c = 4, Name='Portugal', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Portugal');
        insert portugal;

        AMS_Voucher_Region__c region = new AMS_Voucher_Region__c(Name='Europe');
        insert region;

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account 1';
		account1.IATACode__c = '1234567';
		account1.Type = 'IATA Cargo Agent';
		account1.BillingCity = 'Lisboa';
		account1.BillingCountry = 'Portugal';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		account1.Accreditation_date__c = myDate;
		account1.recordTypeId = rtAgency;
		account1.IATA_ISO_Country__c = portugal.Id;
		account1.Location_Class__c = 'C'; 
		insert account1;

		// create test account1
		Account account2 = new Account();
		account2.Name = 'Test account 2';
		account2.IATACode__c = '1234568';
		account2.Type = 'IATA Cargo Agent';
		account2.BillingCity = 'Lisboa';
		account2.BillingCountry = 'Portugal';
		account2.BillingStreet = 'some street 2';
		account2.Location_Type__c = 'HO';
		account2.Accreditation_date__c = myDate;
		account2.recordTypeId = rtAgency;
		account2.IATA_ISO_Country__c = portugal.Id;
		account2.Location_Class__c = 'C';
		insert account2;

		AMS_Voucher_Information__c voucherInfo1 = new  AMS_Voucher_Information__c(Account__c = account1.Id, Amount_Currency__c = 'USD', AmountLastYearSales__c = 1000000, Exchange_Rate__c =1 , Year__c = '2016');
		AMS_Voucher_Information__c voucherInfo2 = new  AMS_Voucher_Information__c(Account__c = account2.Id, Amount_Currency__c = 'USD', AmountLastYearSales__c = 2000000, Exchange_Rate__c =1 , Year__c = '2016');
	
		insert new List<AMS_Voucher_Information__c>{voucherInfo1,voucherInfo2};

	}

	@isTest static void runProcessForVouchersAssignation() {
		
		Test.startTest();

		List<Account> accts = [SELECT Id, Accreditation_date__c, Status__c , Location_Class__c, IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c, IATA_ISO_Country__r.AMS_Vouchers_Benchmark__c from Account];

		System.debug('List of Accounts is:' + accts);

		List<AMS_Voucher_Information__c> vInfo = [SELECT Id , AmountLastYearSales__c, Year__c , Amount_Currency__c, IsAgencyEligibleForCountryAverage__c,IsAgencyEligible__c,Exchange_Rate__c from AMS_Voucher_Information__c ];

		System.assertEquals(vInfo.size(),2);

		System.debug('Voucher info list:'+vInfo);

		AMS_Voucher_Process_Run__c process = new AMS_Voucher_Process_Run__c(status__c = 'Started');

        insert process;
    
		AMS_VoucherProcessManager ams_VPM = new AMS_VoucherProcessManager(process);

		Set<Id> setCountries = new Set<Id>();

		IATA_ISO_Country__c portugal = [SELECT Id from IATA_ISO_Country__c];
		setCountries.add(portugal.Id);

        ams_VPM.setCountries(setCountries);

        Id batchCountryAverageId = ams_VPM.runVouchersProcess('2016');

		Test.stopTest();

		AMS_VouchersCalculationBatch processBatch = ams_VPM.processBatch;

		process = [SELECT id , Average_Country_Calculation_Batch__c, Country_Averages__c, Status__c, AMS_Vouchers_Creation_Batch__c, Vouchers_PDF_Creation_Batch__c from AMS_Voucher_Process_Run__c ];

		List<AMS_Voucher__c> vouchersCreated  = [SELECT Id from AMS_Voucher__c];

		System.assertEquals(6 , vouchersCreated.size());

	}

	@isTest static void testAMS_VoucherManagerController() {

		PageReference pageRef = Page.AMS_VoucherManagerPage;

        Test.setCurrentPageReference(pageRef);

        AMS_VoucherManagerController controller = new AMS_VoucherManagerController();

        Test.startTest();
        
        //AMS_VoucherManagerPage page = new AMS_VoucherManagerPage(sc);
        
        controller.runCountryAverageBatch();

        controller.getcanExecuteBatch();

        controller.getcountryobj();

        controller.getregionobj();

        Set<String> notesTest = controller.notes;

        Test.stopTest();

	}

	@isTest static void testAMS_VoucherPDFGeneratorController() {

		PageReference pageRef = Page.AMS_VoucherPDFGeneratorPage;

        Test.setCurrentPageReference(pageRef);

        ApexPages.currentPage().getParameters().put('runId', '0');
		ApexPages.currentPage().getParameters().put('runExec', '0');

        AMS_VoucherPDFGeneratorController controller = new AMS_VoucherPDFGeneratorController();

        Test.startTest();
        
        controller.getParametersFromBatch();

        List<String> idsToPrint = new List<String>();

        controller.fetchVouchersInfo();

        Test.stopTest();

	}

	
	
}