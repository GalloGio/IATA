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
	
	public static testMethod void testISSP_Registration() {
		TestDataGenerator.generateISOCountryState();
		Test.startTest();
		ISSP_Registration ctrl = new ISSP_Registration();
		String ctZipCode = ctrl.countriesNamesWithoutZipCode;
		ctrl.searchCountryName = 'Portugal';
		Boolean reqZipCode = ctrl.requiredZipCode;
		ctrl.isGPSearchValid();
		ctrl.sRefererCommunity = 'iec';
		ctrl.nextAsGP();
		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		Test.stopTest();
	}
}