/**
           File: AMS_VoucherPDFCreationBatch_Test.cls
        Subject: Test Class for AMS_VoucherPDFCreationBatch class.
        History: amtosantos, 2017-04-17, Initial Release.


*/
@isTest
private class AMS_VoucherPDFCreationBatch_Test {
	static testMethod void testBatch() {
		IATA_ISO_Country__c country;
		Account hqAccount;
		AMS_Voucher_Region__c voucherRegion;
		AMS_Voucher_Information__c voucherInformation;
		AMS_Voucher__c voucher;
		AMS_Voucher_Process_Run__c processRun;
		AMS_VoucherPDFCreationBatch batchJob;

		Test.startTest();

		country  = new IATA_ISO_Country__c(
              Name = 'Portugal',
              ISO_Code__c = 'PT',
              AIMS_Area_Name__c = 'Lisboa'
		);

		insert country;

		hqAccount = new Account(
			Name = 'Test Account',
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
			AmountLastYearSales__c = 0.00,
			Year__c = '2017',
			Vouchers_Issued_Last_Year__c = 0
		);

		insert voucherInformation;

		voucher = new AMS_Voucher__c(
			Issue_Date__c = System.today(),
			SequenceNumber__C = '0000000001',
			Voucher_Information__c = voucherInformation.Id,
			Voucher_Remark__c = 'Remark'
		);

		insert voucher;

		voucherRegion = new AMS_Voucher_Region__c(
			Name = 'Test Region',
			OwnerId = UserInfo.getUserId()
		);

		insert voucherRegion;

		processRun = new AMS_Voucher_Process_Run__c(
			Status__c = 'Started'
		);

		insert processRun;

		batchJob = new AMS_VoucherPDFCreationBatch(
			new Set<Id> { voucher.Id },
			voucherRegion,
			processRun
		);
	
		batchJob.start(null);
		batchJob.execute(null, new List<AMS_Voucher__c> { voucher });
		batchJob.finish(null);
		
		batchJob.isTestCompliant();

		Test.stopTest();
	}
}