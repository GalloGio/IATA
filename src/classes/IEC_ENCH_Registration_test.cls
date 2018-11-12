@isTest 
private class IEC_ENCH_Registration_test {

	public static testMethod void testPOBoxValidation() {
		Test.startTest();
		IECUtil.isPostOfficeBox('PO Box 1234');
		Test.stopTest();
	}
	
	public static testMethod void testIEC_ShippingController() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		IEC_ShippingController ctrl = new IEC_ShippingController();
		List<SelectOption> opts = ctrl.availableCountries;
		Map<String, Boolean> mps = ctrl.zipCodeApplicableMap;
		ctrl.newShipToAddress = new Address_DTO();
		ctrl.newShipToAddress.countryCode = 'pt';
		ctrl.newShipToAddress.addressName = 'test';
		ctrl.newShipToAddress.email = 'test.test@gmail.com';
		ctrl.newShipToAddress.phone = '912341234';
		ctrl.newShipToAddress.city = 'Test';
		ctrl.newShipToAddress.stateCode = 'Test';
		ctrl.newShipToAddress.street1 = 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm';
		ctrl.newShipToAddress.isPostalCodeRequired = false;
		Boolean uzc = ctrl.unlockZipCode;
		ctrl.newAddressAvailableStates = new List<SelectOption>();
		ctrl.saveNewAddress();
		ctrl.newShipToAddress.street1 = 'PO Box 1234';
		ctrl.saveNewAddress();
		ISO_Country_State_Helper.getCountriesOptionsMap();
		Test.stopTest();
	}
	
	public static testMethod void testIEC_UpdateAddressController_1() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		IEC_UpdateAddressController ctrl = new IEC_UpdateAddressController();
		ctrl.dtoShipToAddress = new Address_DTO();
		ctrl.dtoShipToAddress.countryCode = 'pt';
		ctrl.dtoShipToAddress.addressName = 'test';
		ctrl.dtoShipToAddress.email = 'test.test@gmail.com';
		ctrl.dtoShipToAddress.phone = '912341234';
		ctrl.dtoShipToAddress.city = 'Test';
		ctrl.dtoShipToAddress.stateCode = 'Test';
		ctrl.dtoShipToAddress.street1 = 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm';
		ctrl.dtoShipToAddress.isPostalCodeRequired = false;
		ctrl.dtoShipToAddress.postalCode = '1111-828';
		ctrl.showShipToZip = true;
		ctrl.showShipToVAT = true;
		Test.setCurrentPageReference(new PageReference('Page.IEC_UpdateAddress')); 
		system.currentPageReference().getParameters().put('shipToStreet', 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm');
		ctrl.lstShipToState = new List<SelectOption>();
		ctrl.saveShipToAddress();
		system.currentPageReference().getParameters().put('shipToStreet', 'PO Box 1234');
		ctrl.saveShipToAddress();
		Test.stopTest();
	}
	
	public static testMethod void testIEC_UpdateAddressController_2() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		IEC_UpdateAddressController ctrl = new IEC_UpdateAddressController();
		ctrl.loggedCustomer = Customer_DTO.getCustomerByUser(UserInfo.getUserId());
		ctrl.loggedCustomer.billTo = new Address_DTO();
		ctrl.dtoBillToAddress = new Address_DTO();
		ctrl.dtoBillToAddress.countryCode = 'pt';
		ctrl.dtoBillToAddress.addressName = 'test';
		ctrl.dtoBillToAddress.email = 'test.test@gmail.com';
		ctrl.dtoBillToAddress.phone = '912341234';
		ctrl.dtoBillToAddress.city = 'Test';
		ctrl.dtoBillToAddress.stateCode = 'Test';
		ctrl.dtoBillToAddress.street1 = 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm';
		ctrl.dtoBillToAddress.isPostalCodeRequired = false;
		ctrl.dtoBillToAddress.postalCode = '1111-828';
		ctrl.showBillToZip = true;
		ctrl.showBillToVAT = true;
		Test.setCurrentPageReference(new PageReference('Page.IEC_UpdateAddress')); 
		system.currentPageReference().getParameters().put('billToStreet', 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm');
		ctrl.lstBillToState = new List<SelectOption>();
		ctrl.saveBillToAddress();
		Test.stopTest();
	}
	
	public static testMethod void testIEC_CustomerInformation() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		IEC_CustomerInformationController ctrl = new IEC_CustomerInformationController();
		ctrl.vfOrder = new Order_DTO();
		ctrl.vfOrder.billToAddress = new Address_DTO(); 
		ctrl.vfOrder.billToAddress.countryCode = 'pt';		
		List<SelectOption> opts = ctrl.availableCountries;
		Map<String, Boolean> mps = ctrl.zipCodeApplicableMap;
		Boolean uzc = ctrl.unlockZipCode;
		ctrl.isStreetAddressToLong('abc',1);
		Test.stopTest();
	}
	
	public static testMethod void testISSP_Registration1() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		ISSP_Registration ctrl = new ISSP_Registration();
		String ctZipCode = ctrl.countriesNamesWithoutZipCode;
		//ctrl.searchCountryName = 'Portugal';
		ctrl.searchCountryName = 'PT';
		Boolean reqZipCode = ctrl.requiredZipCode;
		ctrl.isGPSearchValid();
		ctrl.getCustomerTypeList();
		ctrl.sRefererCommunity = 'iec';
		ctrl.nextAsGP();
		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		List<SelectOption> opts = ctrl.shpCountry;
		Test.stopTest();
	}
	
	public static testMethod void testISSP_Registration2() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.companyName = 'test 123 tes tes';
		ctrl.searchCompany('AC 1234 AC AF', 'Test', [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id, 'Airline');
		ctrl.searchCompany('AC 1234 AC AF', 'Test', [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id, 'Agency');
		List<SelectOption> opts = ctrl.shpCountry;
		Test.stopTest();
	}
	
	public static testMethod void testISSP_Registration3() {
		List<IATA_ISO_Country__c> countries = TestDataGenerator.generateISOCountryState();
		Test.startTest();
		Test.setCurrentPageReference(new PageReference('Page.ISSP_CreateAccount')); 
		system.currentPageReference().getParameters().put('sRefererCommunity', 'iec');
		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.searchCountryAirline = countries[0].Id;
		ctrl.searchCountry = countries[0].Id;
		ctrl.getISOCountry();
		ctrl.accList = new List<Account>();
		ctrl.handleSearchResults();
		Account acc = new Account(Name='TEST');
		insert acc;
		ctrl.accList = new List<Account>{acc};
		ctrl.handleSearchResults();
		ctrl.isAirline = true;
		ctrl.searchAccount();
		ctrl.isAirline = false;
		ctrl.isAgency = true;
		ctrl.searchAccount();
		Test.stopTest();
	}
	
	public static testMethod void testISSP_Registration_ISO_State() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		List<IATA_ISO_State__c> lst = [SELECT Id, Name, IATA_ISO_Country__r.Name, Informatica_Value__c FROM IATA_ISO_State__c];
		for(IATA_ISO_State__c s : lst) {
			s.Informatica_Value__c = 'test';
		}
		update lst;
		String isoS = ISSP_Registration.isoStates;
		Test.stopTest();
	}
	
	public static testMethod void testISSP_Registration4() {
		Test.startTest();
		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.sRefererCommunity = 'iec';
		ctrl.backToAccountPage();
		ctrl = ctrl.thisCtrlForNewCaseForm;
		Boolean a1 = ctrl.showSearchAirlineDesignator;
		Boolean a2 = ctrl.showConfirmMessage;
		String a3 = ctrl.captchaAnswer;
		String a4 =ctrl.except;
		Boolean a5 = ctrl.isChina;
		String a6 = ctrl.urlpicture;
		Test.stopTest();
	}
	
	public static testMethod void testUtilitySplitAddress() {
		Test.startTest();
		Utility.splitAddress('4TH FLOOR WEST WING ADMIN BLDG SOUTHERN SUPPORT ZONE', 35);
		Utility.splitAddress('4TH FLOOR WEST WING ADMIN BUILDING SOUTHERN SUPPORT ZONE UNIT 77786', 35);
		Utility.splitAddress('4THFLOORWESTWINGADMINBUILDINGSOUTHERNSUPPORTZONEUNIT77786', 35);
		Utility.splitAddress('4TH FLOORWESTWINGADMINBUILDINGSOUTHERNSUPPORTZONEUNIT77786ssssssssssss', 35);
		Utility.splitAddress('', 35);
		Test.stopTest();
	}
	
}