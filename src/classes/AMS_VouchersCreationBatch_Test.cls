/**
           File: AMS_VouchersCreationBatch_Test.cls
        Subject: Test Class for AMS_VouchersCreationBatch class.
        History: amtosantos, 2017-04-18, Initial Release.


*/
@isTest
private class AMS_VouchersCreationBatch_Test {
	static testMethod void testBatch() {
		IATA_ISO_Country__c country;
		Account hqAccount;
		AMS_Voucher_Region__c voucherRegion;
		AMS_Voucher_Information__c voucherInformation;
		AMS_Voucher__c voucher;
		AMS_Voucher_Process_Run__c processRun;
		AMS_VouchersCreationBatch batchJob;
		Map<IATA_ISO_Country__c,Decimal> metricsMap = new Map<IATA_ISO_Country__c,Decimal>();
		String year = '2017';

		Test.startTest();

		country  = new IATA_ISO_Country__c(
              Name = 'Portugal',
              ISO_Code__c = 'PT',
              AIMS_Area_Name__c = 'Lisboa',
			  AMS_Max_Vouchers_Per_Year__c = 1000,
			  AMS_Vouchers_Benchmark__c = 100.0,
			  Region__c = 'Test Region'
		);

		insert country;

		//metricsMap.put(country, 0.0);

		hqAccount = new Account(
			Name = 'Test Account',
			Accreditation_date__c = System.today()-400,
			BillingCity = 'Lisboa',
			Sector__c = 'Travel Agent',
			Location_Type__c = 'HO',
			Location_Class__c = 'C',
			Status__c = 'Approved',
			Company_Type__c = 'A',
			IATACode__c = '100',
			IATA_ISO_Country__c = country.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')
		);

		insert hqAccount;

		voucherInformation = new AMS_Voucher_Information__c(
			Account__c = hqAccount.Id,
			Amount_Currency__c = 'EUR',
			Exchange_Rate__c = 1.00,
			AmountLastYearSales__c = 1000.00,
			Year__c = year,
			Vouchers_Issued_Last_Year__c = 0
		);

		insert voucherInformation;

		voucher = new AMS_Voucher__c(
			Issue_Date__c = System.today(),
			SequenceNumber__C = '0000000001',
			Voucher_Information__c = voucherInformation.Id,
			Voucher_Remark__c = 'Remark'
		);

		//insert voucher;

		voucherRegion = new AMS_Voucher_Region__c(
			Name = 'Test Region',
			OwnerId = UserInfo.getUserId()
		);

		insert voucherRegion;

		processRun = new AMS_Voucher_Process_Run__c(
			Status__c = 'Started'
		);

		insert processRun;

		AMS_Voucher_Information__c vInfo = [SELECT Id, Number_Of_Vouchers__c, AmountLastYearSales__c, Exchange_Rate__c, Account__c, Account__r.IATA_ISO_Country__c, Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__r.Name, Account__r.IATA_ISO_Country__r.AMS_Max_Vouchers_Per_Year__c, Account__r.IATA_ISO_Country__r.AMS_Vouchers_Benchmark__c  FROM AMS_Voucher_Information__c WHERE Id = :voucherInformation.Id LIMIT 1];

		metricsMap.put(vInfo.Account__r.IATA_ISO_Country__r, 1.0);

		batchJob = new AMS_VouchersCreationBatch(
			metricsMap,
			processRun,
			year
		);

		batchJob.vouchersPerCountry = new Map<String,Integer>();
	
		batchJob.start(null);
		batchJob.execute(null, new List<AMS_Voucher_Information__c> { vInfo });

		batchJob.insertVouchers(new List<AMS_Voucher__c> { voucher });

		batchJob.finish(null);

		Test.stopTest();
	}
}