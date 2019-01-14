/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test controller "IEC_UpdateAddressController"
****************************************************************************************************/
@isTest
private class IEC_UpdateAddressControllerTest {


/****************************************************************************************************
    Created by CGI, Thai 2016-12-22
        Test method "onPageLoad" and partially called methods from it
****************************************************************************************************/
@isTest(SeeAllData=false) static void test_onPageLoad()
{
	//*** not logged
	Test.setCurrentPage(Page.IEC_UpdateAddress);
	IEC_UpdateAddressController ctrl = new IEC_UpdateAddressController(); 
	System.assert(ctrl.onPageLoad() != null, 'Should return login page');

	//*** create portal user and test data
	TestDataGenerator.generateApexSetting();
	TestDataGenerator.generateISOCountryState();

	User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
	Contact conPortal = new Contact_Sel().getContactById(usrPortal.ContactId);
	Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Billing Street 1', BillingCity='City', BillingPostalCode='H0H0H0'
	                              , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
	                              , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
	                              , ShippingStreet='Shipping Street 1', ShippingCity='City', ShippingPostalCode='H0H0H0'
	                              , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA'), IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
	update accPortal;

	//*** logged
	Test.startTest();
		System.runAs(usrPortal)
		{
			//*** wrong partners
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = 'test';
			SAP_CustomerMaster_Mock.returnOK = null;
			Test.setCurrentPage(Page.IEC_UpdateAddress);
			ctrl = new IEC_UpdateAddressController(); 
			ctrl.onPageLoad();
			system.assert(ctrl.stopProcess == true, 'Wrong value for missing partners');

			//*** valid partners
			Map<String, Location__c> mapLocation = new Map<String, Location__c>();
			for (Location__c loc : [select Id, Type__c, SAP_Id__c from Location__c where Account__c = :conPortal.AccountId])
				mapLocation.put(loc.Type__c.left(4).toLowerCase(), loc);
			mapLocation.get('sold').SAP_Id__c = 'sold';
			update mapLocation.get('sold');
			Test.setCurrentPage(Page.IEC_UpdateAddress);
			ctrl = new IEC_UpdateAddressController(); 
			ctrl.onPageLoad();
			system.assert(ctrl.stopProcess == false, 'Wrong value for valid partners');
		}
	Test.stopTest();
} //*** end of "test_onPageLoad"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test all methods related to Bill To
****************************************************************************************************/
@isTest(SeeAllData=false) static void testBillToMethods() {
	Integer i1, errCount, addressCount, locationCount;
	Id idLocationProvQC, idLocationProvON;

	//*** create portal user and test data
	TestDataGenerator.generateApexSetting();
	TestDataGenerator.generateISOCountryState();

	User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
	Contact conPortal = new Contact_Sel().getContactById(usrPortal.ContactId);
	Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Billing Street 1', BillingCity='City', BillingPostalCode='H0H0H0'
	                              , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
	                              , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
	                              , ShippingStreet='Shipping Street 1', ShippingCity='City', ShippingPostalCode='H0H0H0'
	                              , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
	List<IECAddress__c> lstAddress = new List<IECAddress__c>();
	lstAddress.add(new IECAddress__c(Street__c = accPortal.BillingStreet, City__c = accPortal.BillingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Billing_State__r, ZipCode__c = accPortal.BillingPostalCode));
	lstAddress.add(new IECAddress__c(Street__c = accPortal.ShippingStreet, City__c = accPortal.ShippingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Shipping_State__r, ZipCode__c = accPortal.ShippingPostalCode));
	insert lstAddress;
	List<Location__c> lstLocation = new List<Location__c>();
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Sold', Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Bill', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship', Type__c = 'Ship To', Address__c = lstAddress[1].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	insert lstLocation;
	accPortal.SoldTo_Location__c = lstLocation[0].Id;
	update accPortal;
	update new Contact(Id = conPortal.Id, BillTo_Location__c = lstLocation[1].Id, ShipTo_Location__c = lstLocation[2].Id);

	system.runAs(usrPortal)
	{
		Test.setCurrentPage(Page.IEC_UpdateAddress);
		IEC_UpdateAddressController cls = new IEC_UpdateAddressController();
		cls.onPageLoad();

		Test.startTest();
			//*** cover method "cancelBillToAddress"
			cls.dtoBillToAddress.street1 = 'zzz';
			cls.cancelBillToAddress();
			system.assert(cls.dtoBillToAddress.street1 != 'zzz', 'Wrong value for street');

			//*** cover method "changeBillToCountry"
			cls.dtoBillToAddress.countryCode = 'MX';
			cls.dtoBillToAddress.stateCode = 'zzz';
			cls.changeBillToCountry();
			system.assert(cls.dtoBillToAddress.stateCode == null, 'Wrong value for state');

			//*** cover methods "checkAddress", "isEmailValid" and "saveBillToAddress" on the checking address part
			cls.showBillToZip = false;
			cls.showBillToVAT = false;
			cls.dtoBillToAddress.street1     = null;
			cls.dtoBillToAddress.countryCode = null;
			errCount = ApexPages.getMessages().size();
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());
			cls.showBillToZip = true;
			cls.dtoBillToAddress.street1     = accPortal.BillingStreet;
			ApexPages.currentPage().getParameters().put('billToStreet', cls.dtoBillToAddress.street1);
			cls.dtoBillToAddress.postalCode  = null;
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 2, 'Should have ' + (errCount + 2) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.postalCode  = accPortal.BillingPostalCode;
			cls.dtoBillToAddress.city        = null;
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 3, 'Should have ' + (errCount + 3) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.city        = accPortal.BillingCity;
			cls.dtoBillToAddress.countryCode = null;
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 4, 'Should have ' + (errCount + 4) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.countryCode = 'CA';
			cls.changeBillToCountry();
			cls.dtoBillToAddress.stateCode   = null;
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 5, 'Should have ' + (errCount + 5) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.stateCode   = 'CA-QC';
			cls.dtoBillToAddress.email       = null;
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 6, 'Should have ' + (errCount + 6) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.email       = 'invalid';
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 7, 'Should have ' + (errCount + 7) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.email       = usrPortal.Email;
			cls.dtoBillToAddress.phone       = null;
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 8, 'Should have ' + (errCount + 8) + ' messages: ' + ApexPages.getMessages());
			cls.dtoBillToAddress.phone       = '111-111-1111';
			cls.showBillToZip = true;
			cls.showBillToVAT = true;
			cls.dtoBillToAddress.vatNumber   = 'zzz'; //*** no assert because it is a callout
			cls.saveBillToAddress();

			//*** reset
			cls.onPageLoad();
			cls.showBillToZip = true;
			errCount = ApexPages.getMessages().size();

			//*** cover method "saveBillToAddress" - case of no change
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());

			//*** cover methods "isAddressModified" and "saveBillToAddress" - case of only changes on location
			cls.dtoBillToAddress.phone = '999-999-9999';
			cls.saveBillToAddress();
			system.assert([select count() from Location__c where Id = :cls.dtoBillToAddress.locationId and Phone__c = :cls.dtoBillToAddress.phone] == 1, 'Location should have new phone');

			//*** cover method "saveBillToAddress" - case of new address within same country/province
			//*** skip addressCount and assert because error "Too many query rows" in production
			//addressCount = [select count() from IECAddress__c];
			cls.dtoBillToAddress.postalCode = 'new code';
			cls.saveBillToAddress();
			//system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
			system.assert([select count() from Location__c where Id = :cls.dtoBillToAddress.locationId and ZipCode__c = :cls.dtoBillToAddress.postalCode] == 1, 'Location should have new address');
		Test.stopTest();
	}
} //*** end of "testBillToMethods"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test all methods related to Bill To
****************************************************************************************************/
@isTest(SeeAllData=false) static void testBillToMethods2() {
	Integer i1, errCount, addressCount, locationCount;
	Id idLocationProvQC, idLocationProvON;

	//*** create portal user and test data
	TestDataGenerator.generateApexSetting();
	TestDataGenerator.generateISOCountryState();

	User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
	Contact conPortal = new Contact_Sel().getContactById(usrPortal.ContactId);
	Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Billing Street 1', BillingCity='City', BillingPostalCode='H0H0H0'
	                              , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
	                              , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
	                              , ShippingStreet='Shipping Street 1', ShippingCity='City', ShippingPostalCode='H0H0H0'
	                              , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
	List<IECAddress__c> lstAddress = new List<IECAddress__c>();
	lstAddress.add(new IECAddress__c(Street__c = accPortal.BillingStreet, City__c = accPortal.BillingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Billing_State__r, ZipCode__c = accPortal.BillingPostalCode));
	lstAddress.add(new IECAddress__c(Street__c = accPortal.ShippingStreet, City__c = accPortal.ShippingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Shipping_State__r, ZipCode__c = accPortal.ShippingPostalCode));
	insert lstAddress;
	List<Location__c> lstLocation = new List<Location__c>();
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Sold', Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Bill', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship', Type__c = 'Ship To', Address__c = lstAddress[1].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	insert lstLocation;
	accPortal.SoldTo_Location__c = lstLocation[0].Id;
	update accPortal;
	update new Contact(Id = conPortal.Id, BillTo_Location__c = lstLocation[1].Id, ShipTo_Location__c = lstLocation[2].Id);

	system.runAs(usrPortal)
	{
		Test.setCurrentPage(Page.IEC_UpdateAddress);
		IEC_UpdateAddressController cls = new IEC_UpdateAddressController();
		cls.onPageLoad();

		Test.startTest();
			//*** cover method "saveBillToAddress" - case of different country/province
			cls.showBillToZip = true;
			ApexPages.currentPage().getParameters().put('billToStreet', cls.dtoBillToAddress.street1);
			//*** skip addressCount, locationCount and assert because error "Too many query rows" in production
			//addressCount = [select count() from IECAddress__c];
			//locationCount = [select count() from Location__c];
			errCount = ApexPages.getMessages().size();
			idLocationProvQC = cls.dtoBillToAddress.locationId;
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = 'test';
			SAP_CustomerMaster_Mock.returnOK = null;
			cls.dtoBillToAddress.stateCode = 'CA-ON';
			cls.saveBillToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());
			SAP_CustomerMaster_Mock.returnError = null;
			SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold2', 'Bill2', 'Ship2'});
			cls.saveBillToAddress();
			//system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
			system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = false] == 1, 'Location for QC should be inactive');
			//system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
			system.assert(idLocationProvQC != cls.dtoBillToAddress.locationId, 'Should have 2 locations');
			system.assert([select count() from Location__c where Id = :cls.dtoBillToAddress.locationId and ISO_State_Code__c = :cls.dtoBillToAddress.stateCode] == 1, 'Location for ON should have new address');

			//*** cover methods of autocomplete "findAddresses" and "getBillToAutoCompleteAddress" -> no need to assert
			List<String> lstAddressAuto = IEC_UpdateAddressController.findAddresses(cls.dtoBillToAddress.street1, null, null);
			cls.autocompleteFullAddress = lstAddressAuto[0];
			cls.getBillToAutoCompleteAddress();
		Test.stopTest();
	}
} //*** end of "testBillToMethods2"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test all methods related to Ship To
****************************************************************************************************/
@isTest(SeeAllData=false) static void testShipToMethods() {
	Integer i1, errCount, addressCount, locationCount, locationCount2;
	Id idLocationProvQC, idLocationProvON;

	//*** create portal user and test data
	TestDataGenerator.generateApexSetting();
	TestDataGenerator.generateISOCountryState();

	User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
	Contact conPortal = new Contact_Sel().getContactById(usrPortal.ContactId);
	Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Billing Street', BillingCity='City', BillingPostalCode='H0H0H0'
	                              , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
	                              , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
	                              , ShippingStreet='Shipping Street', ShippingCity='City', ShippingPostalCode='H0H0H0'
	                              , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
	List<IECAddress__c> lstAddress = new List<IECAddress__c>();
	lstAddress.add(new IECAddress__c(Street__c = accPortal.BillingStreet, City__c = accPortal.BillingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Billing_State__r, ZipCode__c = accPortal.BillingPostalCode));
	lstAddress.add(new IECAddress__c(Street__c = accPortal.ShippingStreet, City__c = accPortal.ShippingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Shipping_State__r, ZipCode__c = accPortal.ShippingPostalCode));
	insert lstAddress;
	List<Location__c> lstLocation = new List<Location__c>();
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Sold', Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Bill', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship1', Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship2', Type__c = 'Ship To', Address__c = lstAddress[1].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	insert lstLocation;
	accPortal.SoldTo_Location__c = lstLocation[0].Id;
	update accPortal;
	update new Contact(Id = conPortal.Id, BillTo_Location__c = lstLocation[1].Id, ShipTo_Location__c = lstLocation[2].Id);

	system.runAs(usrPortal)
	{
		Test.setCurrentPage(Page.IEC_UpdateAddress);
		IEC_UpdateAddressController cls = new IEC_UpdateAddressController();
		cls.onPageLoad();

		Test.startTest();
			//*** cover method "cancelShipToAddress"
			cls.dtoShipToAddress.street1 = 'zzz';
			cls.cancelShipToAddress();
			system.assert(cls.dtoShipToAddress.street1 != 'zzz', 'Wrong value for street');

			//*** cover method "changeShipToCountry"
			cls.dtoShipToAddress.countryCode = 'MX';
			cls.dtoShipToAddress.stateCode = 'zzz';
			cls.changeShipToCountry();
			system.assert(cls.dtoShipToAddress.stateCode == null, 'Wrong value for state');

			//*** cover methods "checkAddress" and "saveShipToAddress" on the checking address part related ship to -> don't test all possibilities because already already covered in "testBillToMethods"
			errCount = ApexPages.getMessages().size();
			cls.showShipToZip = false;
			cls.showShipToVAT = false;
			cls.dtoShipToAddress.addressName = null;
			cls.saveShipToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());

			//*** cover methods "prepareNewShipToAddress" and "saveShipToAddress" - case of new address already exist
			cls.prepareNewShipToAddress();
			cls.dtoShipToAddress.countryCode = 'CA';
			cls.changeShipToCountry();
			cls.showShipToZip = true;
			cls.dtoShipToAddress.addressName = 'ship 1';
			cls.dtoShipToAddress.street1     = accPortal.ShippingStreet;
			ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
			cls.dtoShipToAddress.city        = accPortal.ShippingCity;
			cls.dtoShipToAddress.stateCode   = 'CA-QC';
			cls.dtoShipToAddress.postalCode  = accPortal.ShippingPostalCode;
			errCount = ApexPages.getMessages().size();
			cls.saveShipToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());

			//*** cover method "saveShipToAddress" - case of updating address already exist
			cls.cancelShipToAddress();
			cls.showShipToZip = true;
			cls.dtoShipToAddress.addressName = 'ship 1';
			cls.dtoShipToAddress.street1     = accPortal.ShippingStreet;
			ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
			cls.dtoShipToAddress.city        = accPortal.ShippingCity;
			cls.dtoShipToAddress.postalCode  = accPortal.ShippingPostalCode;
			errCount = ApexPages.getMessages().size();
			cls.saveShipToAddress();   //*** count of msg does not change because new message is same as the latest
			system.assert(ApexPages.getMessages().size() == errCount + 0, 'Should have ' + (errCount + 0) + ' messages: ' + ApexPages.getMessages());

			//*** cover method "saveShipToAddress" - case of new address
			cls.prepareNewShipToAddress();
			cls.dtoShipToAddress.countryCode = 'CA';
			cls.changeShipToCountry();
			cls.showShipToZip = true;
			cls.dtoShipToAddress.addressName = 'ship 3';
			cls.dtoShipToAddress.street1     = accPortal.ShippingStreet + ' new';
			ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
			cls.dtoShipToAddress.city        = accPortal.ShippingCity;
			cls.dtoShipToAddress.stateCode   = 'CA-QC';
			cls.dtoShipToAddress.postalCode  = accPortal.ShippingPostalCode;
			cls.isDefaultShipTo = false;
			cls.makeShipToDefault = false;
			//*** skip addressCount, locationCount and assert because error "Too many query rows" in production
			//addressCount = [select count() from IECAddress__c];
			//locationCount = [select count() from Location__c];
			locationCount2 = cls.loggedCustomer.shipTos.size();
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = 'test';
			SAP_CustomerMaster_Mock.returnOK = null;
			errCount = ApexPages.getMessages().size();
			cls.saveShipToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());
			SAP_CustomerMaster_Mock.returnError = null;
			SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold', 'Bill', 'Ship3'});
			errCount = ApexPages.getMessages().size();
			cls.saveShipToAddress();
			//system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
			//system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
			system.assert(cls.loggedCustomer.shipTos.size() == locationCount2 + 1, 'Should have ' + (locationCount2 + 1) + ' locations');

			//*** cover method "saveShipToAddress" - case of setting address as default
			errCount = ApexPages.getMessages().size();
			cls.isDefaultShipTo = false;
			cls.makeShipToDefault = true;
			cls.saveShipToAddress();   //*** count of msg does not change because new message is same as the latest
			system.assert(ApexPages.getMessages().size() == errCount + 0, 'Should have ' + (errCount + 0) + ' messages: ' + ApexPages.getMessages());

			//*** cover method "saveShipToAddress" - case of new address within same country/province
			//*** skip addressCount and assert because error "Too many query rows" in production
			//addressCount = [select count() from IECAddress__c];
			cls.dtoShipToAddress.postalCode = 'new code';
			cls.saveShipToAddress();
			//system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
			system.assert([select count() from Location__c where Id = :cls.dtoShipToAddress.locationId and ZipCode__c = :cls.dtoShipToAddress.postalCode] == 1, 'Location should have new address');
		Test.stopTest();
	}
} //*** end of "testShipToMethods"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test all methods related to Ship To
****************************************************************************************************/
@isTest(SeeAllData=false) static void testShipToMethods2() {
	Integer i1, errCount, addressCount, locationCount, locationCount2;
	Id idLocationProvQC, idLocationProvON;

	//*** create portal user and test data
	TestDataGenerator.generateApexSetting();
	TestDataGenerator.generateISOCountryState();

	User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
	Contact conPortal = new Contact_Sel().getContactById(usrPortal.ContactId);
	Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Billing Street', BillingCity='City', BillingPostalCode='H0H0H0'
	                              , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
	                              , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
	                              , ShippingStreet='Shipping Street', ShippingCity='City', ShippingPostalCode='H0H0H0'
	                              , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
	List<IECAddress__c> lstAddress = new List<IECAddress__c>();
	lstAddress.add(new IECAddress__c(Street__c = accPortal.BillingStreet, City__c = accPortal.BillingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Billing_State__r, ZipCode__c = accPortal.BillingPostalCode));
	lstAddress.add(new IECAddress__c(Street__c = accPortal.ShippingStreet, City__c = accPortal.ShippingCity, ISO_Country__r = accPortal.IATA_ISO_Country__r, ISO_State__r = accPortal.IATA_ISO_Shipping_State__r, ZipCode__c = accPortal.ShippingPostalCode));
	insert lstAddress;
	List<Location__c> lstLocation = new List<Location__c>();
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Sold', Type__c = 'Sold To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Bill', Type__c = 'Bill To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship1', Type__c = 'Ship To', Address__c = lstAddress[0].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	lstLocation.add(new Location__c(Active__c = true, SAP_Id__c = 'Ship2', Type__c = 'Ship To', Address__c = lstAddress[1].Id, Account__c = accPortal.Id, Contact__c = conPortal.Id, Email__c = conPortal.Email, Phone__c = '123-555-8888'));
	insert lstLocation;
	accPortal.SoldTo_Location__c = lstLocation[0].Id;
	update accPortal;
	update new Contact(Id = conPortal.Id, BillTo_Location__c = lstLocation[1].Id, ShipTo_Location__c = lstLocation[2].Id);

	system.runAs(usrPortal)
	{
		Test.setCurrentPage(Page.IEC_UpdateAddress);
		IEC_UpdateAddressController cls = new IEC_UpdateAddressController();
		cls.onPageLoad();

		Test.startTest();
			//*** cover method "saveShipToAddress" - case of different country/province
			cls.showShipToZip = true;
			ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
			//*** skip addressCount, locationCount and assert because error "Too many query rows" in production
			//addressCount = [select count() from IECAddress__c];
			//locationCount = [select count() from Location__c];
			errCount = ApexPages.getMessages().size();
			idLocationProvQC = cls.dtoShipToAddress.locationId;
			Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
			SAP_CustomerMaster_Mock.returnError = 'test';
			SAP_CustomerMaster_Mock.returnOK = null;
			cls.dtoShipToAddress.addressName = 'ship 2';
			cls.dtoShipToAddress.stateCode = 'CA-ON';
			cls.saveShipToAddress();
			system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());
			SAP_CustomerMaster_Mock.returnError = null;
			SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold', 'Bill', 'Ship3'});
			cls.saveShipToAddress();
			//system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses' + '\n' + cls.dtoShipToAddress + '\n' + ApexPages.getMessages());
			system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = false] == 1, 'Location for QC should be inactive');
			//system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
			system.assert(idLocationProvQC != cls.dtoShipToAddress.locationId, 'Should have 2 locations');
			system.assert([select count() from Location__c where Id = :cls.dtoShipToAddress.locationId and ISO_State_Code__c = :cls.dtoShipToAddress.stateCode] == 1, 'Location for ON should have new address');

			//*** cover method "deleteShipToAddress"
			idLocationProvQC = cls.dtoShipToAddress.locationId;
			cls.deleteShipToAddress();
			system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = false] == 1, 'Location should be inactive');

			//*** cover methods of autocomplete "findAddresses" and "getShipToAutoCompleteAddress" -> no need to assert
			List<String> lstAddressAuto = IEC_UpdateAddressController.findAddresses(cls.dtoShipToAddress.street1, null, null);
			cls.autocompleteFullAddress = lstAddressAuto[0];
			cls.getShipToAutoCompleteAddress();
		Test.stopTest();
	}
} //*** end of "testShipToMethods2"



} //*** end of class