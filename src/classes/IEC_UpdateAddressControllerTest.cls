/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test controller "IEC_UpdateAddressController"
****************************************************************************************************/
@isTest
private class IEC_UpdateAddressControllerTest {


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test all methods related to Bill To
        Test methods "onPageLoad", "copyAddress", "checkAddress", "isEmailValid", "isAddressModified"
        and "findAddresses"
****************************************************************************************************/
@isTest(SeeAllData=false) static void testBillToMethods() {
    Integer i1, errCount, addressCount, locationCount;
    Id idLocationProvQC, idLocationProvON;

    TestDataGenerator.generateApexSetting();

    List<IATA_ISO_Country__c> lstCountryState = new List<IATA_ISO_Country__c>();
    for (IATA_ISO_Country__c country : TestDataGenerator.generateISOCountryState())
        lstCountryState.add(new IATA_ISO_Country__c(Id=country.Id, IEC_Zip_Postal_Code_required__c=true, VAT_Validation_Required__c=true));
    update lstCountryState;

    List<IECAddress__c> lstAddress;

    User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
    Contact conPortal = IECUserManager.getContactById(usrPortal.ContactId);
    Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Start Street 1', BillingCity='City', BillingPostalCode='H0H0H0'
                                  , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
                                  , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
                                  , ShippingStreet='Start Street 2', ShippingCity='City', ShippingPostalCode='H0H0H0'
                                  , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
    update accPortal;
    
    Test.setCurrentPageReference(new PageReference('/apex/IEC_UpdateAddress'));

    //*** cover method "onPageLoad" not logged part -> nothing to assert
    IEC_UpdateAddressController cls = new IEC_UpdateAddressController();
    cls.onPageLoad();

    system.runAs(usrPortal)
    {
        //*** cover methods "onPageLoad" logged as first time customer i.e. the rest of method
        //*** cover methods "buildShipToAddressPicklist", "changeShipToAddress", "copyAddress"
        cls = new IEC_UpdateAddressController();
        Test.startTest();
            cls.onPageLoad();
        Test.stopTest();
        
        //system.assert([select count() from Location__c] == 3, '# Locations should be 3');
        system.assert(cls.dtoBillToAddress.locationId != null, 'Wrong default Bill To location');
        system.assert(cls.dtoShipToAddress.locationId != null && cls.lstShipToAddress.size() == 1, 'Wrong default Ship To location');

        
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
        cls.dtoBillToAddress.street1     = 'street';
        ApexPages.currentPage().getParameters().put('billToStreet', cls.dtoBillToAddress.street1);
        cls.dtoBillToAddress.postalCode  = null;
        cls.saveBillToAddress();
        system.assert(ApexPages.getMessages().size() == errCount + 2, 'Should have ' + (errCount + 2) + ' messages: ' + ApexPages.getMessages());
        cls.dtoBillToAddress.postalCode  = 'pc';
        cls.dtoBillToAddress.city        = null;
        cls.saveBillToAddress();
        system.assert(ApexPages.getMessages().size() == errCount + 3, 'Should have ' + (errCount + 3) + ' messages: ' + ApexPages.getMessages());
        cls.dtoBillToAddress.city        = 'city';
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
        cls.showBillToVAT = true;
        cls.dtoBillToAddress.vatNumber   = 'zzz'; //*** no assert because it is a callout
        cls.saveBillToAddress();

        //*** reset
        cls.onPageLoad();
        errCount = ApexPages.getMessages().size();

        //*** cover method "saveBillToAddress" - case of no change
        cls.saveBillToAddress();
        system.assert(ApexPages.getMessages().size() == errCount + 0, 'Should have ' + (errCount + 0) + ' messages: ' + ApexPages.getMessages());

        Test.startTest();  //*** bypass limit of # queries
            //*** cover methods "isAddressModified" and "saveBillToAddress" - case of only changes on location
            cls.dtoBillToAddress.phone = '999-999-9999';
            cls.saveBillToAddress();
            system.assert([select count() from Location__c where Id = :cls.dtoBillToAddress.locationId and Phone__c = :cls.dtoBillToAddress.phone and Street__c = :cls.dtoBillToAddress.street1] == 1, 'Location should have new phone');
            
            //*** cover method "saveBillToAddress" - case of new address within same country/province
            addressCount = [select count() from IECAddress__c];
            cls.dtoBillToAddress.postalCode = 'new code';
            cls.saveBillToAddress();
            system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
            system.assert([select count() from Location__c where Id = :cls.dtoBillToAddress.locationId and ZipCode__c = :cls.dtoBillToAddress.postalCode] == 1, 'Location should have new address');
            
            //*** cover method "saveBillToAddress" - case of different country/province and new location
            locationCount = [select count() from Location__c];
            idLocationProvQC = cls.dtoBillToAddress.locationId;
            cls.dtoBillToAddress.stateCode = 'CA-ON';
            cls.saveBillToAddress();
            lstAddress = [select Id, ISO_State_Code__c from IECAddress__c];
            system.assert(lstAddress.size() == addressCount + 2, 'Should have ' + (addressCount + 2) + ' addresses');
            system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = false] == 1, 'Location for QC should be inactive');
            system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
            system.assert(idLocationProvQC != cls.dtoBillToAddress.locationId, 'Should have 2 locations');
            system.assert([select count() from Location__c where Id = :cls.dtoBillToAddress.locationId and ISO_State_Code__c = :cls.dtoBillToAddress.stateCode] == 1, 'Location for ON should have new address');
            
            //*** cover method "saveBillToAddress" - case of different country/province and reuse inactive location
            idLocationProvON = cls.dtoBillToAddress.locationId;
            cls.dtoBillToAddress.stateCode = 'CA-QC';
            cls.saveBillToAddress();
            system.assert([select count() from IECAddress__c] == addressCount + 2, 'Should have ' + (addressCount + 2) + ' addresses');
            system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
            system.assert(idLocationProvQC == cls.dtoBillToAddress.locationId, 'Should have 2 locations' + 'QC ' + idLocationProvQC + ' ON ' + idLocationProvON + ' DTL ' + cls.dtoBillToAddress.locationId);
            system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = true] == 1, 'Location for QC should be active');
            system.assert([select count() from Location__c where Id = :idLocationProvON and Active__c = false] == 1, 'Location for ON should be inactive');
            
            //*** cover methods of autocomplete "findAddresses" and "getBillToAutoCompleteAddress" -> no need to assert
            List<String> lstAddressAuto = IEC_UpdateAddressController.findAddresses(cls.dtoBillToAddress.street1, null, null);
            cls.autocompleteFullAddress = lstAddressAuto[0];
            cls.getBillToAutoCompleteAddress();
        Test.stopTest();
    }
} //*** end of "testBillToMethods"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Test all methods related to Ship To
        Test method "checkAddress" related with Ship To
****************************************************************************************************/
@isTest(SeeAllData=false) static void testShipToMethods() {
    Integer i1, errCount, addressCount, locationCount;
    Id idLocationProvQC, idLocationProvON;
    Location__c locationShipTo;

    TestDataGenerator.generateApexSetting();

    List<IATA_ISO_Country__c> lstCountryState = new List<IATA_ISO_Country__c>();
    for (IATA_ISO_Country__c country : TestDataGenerator.generateISOCountryState())
        lstCountryState.add(new IATA_ISO_Country__c(Id=country.Id, IEC_Zip_Postal_Code_required__c=true, VAT_Validation_Required__c=true));
    update lstCountryState;

    User usrPortal = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
    Contact conPortal = IECUserManager.getContactById(usrPortal.ContactId);
    Account accPortal = new Account(Id=conPortal.AccountId, BillingStreet='Start Street 1', BillingCity='City', BillingPostalCode='H0H0H0'
                                  , BillingCountry='Canada', IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA')
                                  , BillingState='Quebec', IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC')
                                  , ShippingStreet='Start Street 2', ShippingCity='City', ShippingPostalCode='H0H0H0'
                                  , ShippingCountry='Canada', ShippingState='Quebec', IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'CA-QC'));
    update accPortal;

    List<IECAddress__c> lstAddress = new List<IECAddress__c>();
    lstAddress.add(new IECAddress__c(Street__c='Street zzz', City__c=accPortal.ShippingCity, ZipCode__c=accPortal.ShippingPostalCode, ISO_Country__r=new IATA_ISO_Country__c(ISO_Code__c='CA'), ISO_State__r=new IATA_ISO_State__c(ISO_Code__c='CA-QC')));
    insert lstAddress;
    
    Test.setCurrentPageReference(new PageReference('/apex/IEC_UpdateAddress'));
    IEC_UpdateAddressController cls = new IEC_UpdateAddressController();

    system.runAs(usrPortal)
    {
        cls = new IEC_UpdateAddressController();
        cls.onPageLoad();

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

        //*** cover method "cancelShipToAddress"
        cls.cancelShipToAddress();
        system.assert(cls.dtoShipToAddress.countryCode != 'MX', 'Wrong value for country');
        
        //*** cover methods "prepareNewShipToAddress" and "saveShipToAddress" - case of new address and location
        idLocationProvQC = cls.currentShipToLocationId;  //*** for later use
        cls.prepareNewShipToAddress();
        cls.dtoShipToAddress.countryCode = 'CA';
        cls.changeShipToCountry();
        cls.dtoShipToAddress.addressName = 'shop 1';
        cls.dtoShipToAddress.street1     = 'new street';
        ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
        cls.dtoShipToAddress.city        = 'city';
        cls.dtoShipToAddress.stateCode   = 'CA-QC';
        cls.dtoShipToAddress.postalCode  = 'H1H1H1';
        addressCount = [select count() from IECAddress__c];
        locationCount = [select count() from Location__c];
        cls.isDefaultShipTo = false;
        cls.makeShipToDefault = true;
        cls.saveShipToAddress();
        system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
        system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
        system.assert(cls.currentShipToLocationId != idLocationProvQC, 'Default ship to should be changed');
    }
    
    Test.startTest();  //*** bypass limit of # queries
        locationShipTo = new Location__c(Contact__c=conPortal.Id, Address__c=lstAddress[0].Id, Active__c=false, Type__c=IECConstants.SHIPTO);
        insert locationShipTo;
        
        system.runAs(usrPortal)
        {
            //*** cover method "saveShipToAddress" - case of new address already in system
            errCount = ApexPages.getMessages().size();
            cls.dtoShipToAddress.locationId = null;
            cls.saveShipToAddress();
            system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());
            
            //*** cover method "saveShipToAddress" - case of new address by re-activate a location
            cls.prepareNewShipToAddress();
            cls.dtoShipToAddress.countryCode = 'CA';
            cls.changeShipToCountry();
            cls.dtoShipToAddress.addressName = 'shop 2';
            cls.dtoShipToAddress.street1     = lstAddress[0].Street__c;
            ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
            cls.dtoShipToAddress.city        = lstAddress[0].City__c;
            cls.dtoShipToAddress.postalCode  = lstAddress[0].ZipCode__c;
            cls.dtoShipToAddress.stateCode   = 'CA-QC';
            cls.saveShipToAddress();
            system.assert([select count() from Location__c where Id = :locationShipTo.Id and Active__c = true] == 1, 'Location should become active');

            //*** cover method "saveShipToAddress" - case of only changes on location
            cls.dtoShipToAddress.phone = '888-888-8888';
            cls.saveShipToAddress();
            system.assert([select count() from Location__c where Id = :cls.dtoShipToAddress.locationId and Phone__c = :cls.dtoShipToAddress.phone] == 1, 'Location should have new phone');

            //*** cover method "saveShipToAddress" - case of updating address already in system
            cls.dtoShipToAddress.street1     = 'new street';
            ApexPages.currentPage().getParameters().put('ShipToStreet', cls.dtoShipToAddress.street1);
            cls.dtoShipToAddress.city        = 'city';
            cls.dtoShipToAddress.stateCode   = 'CA-QC';
            cls.dtoShipToAddress.postalCode  = 'H1H1H1';
            errCount = ApexPages.getMessages().size();
            cls.saveShipToAddress();
            //*** count does not change because same error message already in list
            //system.assert(ApexPages.getMessages().size() == errCount + 1, 'Should have ' + (errCount + 1) + ' messages: ' + ApexPages.getMessages());

            //*** cover method "saveShipToAddress" - case of different country/province and new location
            cls.cancelShipToAddress();
            addressCount = [select count() from IECAddress__c];
            locationCount = [select count() from Location__c];
            idLocationProvQC = cls.dtoShipToAddress.locationId;
            cls.dtoShipToAddress.stateCode = 'CA-ON';
            cls.saveShipToAddress();
            system.assert([select count() from IECAddress__c] == addressCount + 1, 'Should have ' + (addressCount + 1) + ' addresses');
            system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
            system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = false] == 1, 'Location for QC should be inactive');
            system.assert(idLocationProvQC != cls.dtoShipToAddress.locationId, 'Should have 2 locations');
            system.assert([select count() from Location__c where Id = :cls.dtoShipToAddress.locationId and ISO_State_Code__c = :cls.dtoShipToAddress.stateCode] == 1, 'Location for ON should have new address');

            //*** cover method "saveShipToAddress" - case of different country/province and reuse inactive location
            idLocationProvON = cls.dtoShipToAddress.locationId;
            cls.dtoShipToAddress.stateCode = 'CA-QC';
            cls.saveShipToAddress();
            system.assert([select count() from IECAddress__c] == addressCount + 2, 'Should have ' + (addressCount + 1) + ' addresses');
            system.assert([select count() from Location__c] == locationCount + 1, 'Should have ' + (locationCount + 1) + ' locations');
            system.assert(idLocationProvQC == cls.dtoShipToAddress.locationId, 'Should have 2 locations' + 'QC ' + idLocationProvQC + ' ON ' + idLocationProvON + ' DTL ' + cls.dtoShipToAddress.locationId);
            system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = true] == 1, 'Location for QC should be active');
            system.assert([select count() from Location__c where Id = :idLocationProvON and Active__c = false] == 1, 'Location for ON should be inactive');

            //*** cover method "saveShipToAddress" - case of new address in same country and province
            cls.dtoShipToAddress.postalCode  = 'H2H2H2';
            cls.saveShipToAddress();
            system.assert([select count() from IECAddress__c] == addressCount + 3, 'Should have ' + (addressCount + 3) + ' addresses' + [select Street__c from IECAddress__c]);

            //*** cover method "saveShipToAddress" - case of no change but default -> cannot assert because no access to field
            cls.isDefaultShipTo = false;
            cls.makeShipToDefault = true;
            cls.saveShipToAddress();

            //*** cover method "deleteShipToAddress"
            idLocationProvQC = cls.dtoShipToAddress.locationId;
            cls.deleteShipToAddress();
            system.assert([select count() from Location__c where Id = :idLocationProvQC and Active__c = false] == 1, 'Location should be inactive');

            //*** cover methods of autocomplete "findAddresses" and "getShipToAutoCompleteAddress" -> no need to assert
            List<String> lstAddressAuto = IEC_UpdateAddressController.findAddresses(cls.dtoShipToAddress.street1, null, null);
            cls.autocompleteFullAddress = lstAddressAuto[0];
            cls.getShipToAutoCompleteAddress();
        }
    Test.stopTest();
} //*** end of "testShipToMethods"


} //*** end of class