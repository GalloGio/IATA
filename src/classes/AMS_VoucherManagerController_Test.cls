/**
           File: AMS_VoucherManagerController_Test.cls
        Subject: Test Class for AMS_VoucherManagerController class.
        History: amtosantos, 2017-04-17, Initial Release.


*/
@isTest
private class AMS_VoucherManagerController_Test {
	@isTest
	static void testCase01() {
		Boolean aBoolean;
		String aString;
		List<IATA_ISO_Country__c> aCountryList;
		Id aId;
		AMS_Voucher_Region__c aVoucherRegion;
		List<String> aStringList;
		AMS_Voucher_Process_Run__c aVoucherProcessRun;
		Set<String> aStringSet;
		List<SelectOption> aSelectOptionList;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name = 'X-Country',
			ISO_Code__c = 'X1'
		);

		Test.startTest();

		insert country;

		AMS_VoucherManagerController controller = new AMS_VoucherManagerController();

		aBoolean = controller.batchStatusBool;
		aBoolean = controller.pollerBool;
		aString = controller.batchAverageStatus;
		aString = controller.emailNotification;
		aCountryList = controller.countries;
		aId = controller.batchCountryAverageId;
		aBoolean = controller.canExecuteBatch;
		aBoolean = controller.countriesUploaded;
		aString = controller.region;
		aString = controller.year;
		aVoucherRegion = controller.regionObject;
		aStringList = controller.countriesLst;
		aString = controller.reportURL;
		aString = controller.reportPage;
		aVoucherProcessRun = controller.process;
		aStringSet = controller.notes;
		aStringList = controller.noteList;

		controller.countriesLst = new List<String> { country.Id };

		controller.runCountryAverageBatch();
		controller.checkBatchStatus();

		aSelectOptionList = controller.getcountryobj();
		aSelectOptionList = controller.getregionobj();
		aSelectOptionList = controller.getyearobj();

		aBoolean = controller.getcanExecuteBatch();

		controller.countriesLst = new List<String> { 'Select Country'};

		aBoolean = controller.getcanExecuteBatch();		
		
		Test.stopTest();
	}
}
