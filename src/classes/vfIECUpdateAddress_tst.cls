@isTest(SeeAllData=true)
private class vfIECUpdateAddress_tst {
    static testMethod void TestUpdateAddress() {
        System.debug('Unit Test: Start: TestUpdateAddress');

        PageReference pgRef = Page.IECUpdateAddress;
        Test.setCurrentPage(pgRef);
        
        vfIECUpdateAddress pgCont = new vfIECUpdateAddress();
        pgCont.pageLoad();

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        Contact oContact2 = new Contact_Sel().getContactById(usr.contactId);
        IECAddress__c oAddress = TestDataGenerator.generateAddresses(1, true)[0];
        List<Location__c> lstLocation = new List<Location__c>();
        lstLocation.add(new Location__c(Type__c='Sold To', SAP_Id__c='sold', Address__c=oAddress.Id, Account__c=oContact2.AccountId));
        lstLocation.add(new Location__c(Type__c='Bill To', SAP_Id__c='bill', Address__c=oAddress.Id, Account__c=oContact2.AccountId, Contact__c=oContact2.Id));
        lstLocation.add(new Location__c(Type__c='Ship To', SAP_Id__c='ship', Address__c=oAddress.Id, Account__c=oContact2.AccountId, Contact__c=oContact2.Id));
        insert lstLocation;
            // Get Country codes and IDs
            Map<String, Id> mapCountryCodeToID = new Map<String, Id>();
            for (IATA_ISO_Country__c country : [SELECT Id, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c IN ('US','CA', 'EG')])
            {
                mapCountryCodeToID.put(country.ISO_Code__c, country.Id);
            }
            
            // Get State codes and IDs
            Map<String, Id> mapStateCodeToID = new Map<String, Id>();
            for (IATA_ISO_State__c state : [SELECT Id, ISO_Code__c FROM IATA_ISO_State__c WHERE ISO_Code__c IN ('NY','ON')])
            {
                mapStateCodeToID.put(state.ISO_Code__c, state.Id);
                state.IEC_Valid_SAP__c = true;
                update state;
            }
            
            
        System.runAs(usr) {

            PageReference pageRef = Page.IECUpdateAddress;
            Test.setCurrentPage(pageRef);

            //Instantiate Controller
            IECPageController baseCont = new IECPageController();
            baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
            pgCont = new vfIECUpdateAddress();
            
            

            pgCont.oBillingAddress = null;

//            IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);

            IATA_ISO_Country__c oCountry = IECTestUtil.CreateSampleIATAISOCountry();
            oCountry.Name = 'TestCountry';
            oCountry.VAT_Validation_Required__c = true;
            oCountry.Tax_1_Label__c = 'Tax 1';
            oCountry.Tax_2_Label__c = 'Tax 2';
            oCountry.Tax_ID_Mandatory__c = true;
            //insert oBillingAddress;  //*** commented by Thai (2016-02-29) because address was inserted in the calling method
            insert oCountry;

            IATAIsoCountryDAO.resetMapIataIsoCountry();
            
//            oBillingAddress.ISO_Country__c = oCountry.Id;
//            oBillingAddress.ISO_State__c = null;
            //update oBillingAddress;

            pgCont.pageLoad();
            
            // Run misc coverage            
            pgCont.getCountries();
            pgCont.getStateProvince();
            pgCont.backToContactInfo();
            Contact oContact = pgCont.oContact;
                        
            // Reset contact for testing
            pgCont.oContact.Tax_1_ID__c = null;
            pgCont.oContact.Tax_2_ID__c = null;
            pgCont.oBillingAddress.Street__c = null;
            pgCont.oBillingAddress.City__c = null;
            pgCont.oBillingAddress.ISO_Country__c = null;
            pgCont.oBillingAddress.ISO_State__c = null;
            pgCont.oBillingAddress.ZipCode__c = null;
Test.startTest();
            // Test contact update validation
            pgCont.updateContact();
            pgCont.oBillingAddress.Street__c = '123 Street ~~~ billing test ~~~';
            pgCont.updateContact();
            pgCont.oBillingAddress.City__c = 'New York';
            pgCont.updateContact();
            pgCont.oBillingAddress.ISO_Country__c = mapCountryCodeToID.get('US');
            pgCont.updateContact();
            pgCont.oBillingAddress.ISO_State__c = mapStateCodeToID.get('NY');
            pgCont.updateContact();
            pgCont.oBillingAddress.ISO_Country__c = mapCountryCodeToID.get('CA');
            pgCont.oBillingAddress.ISO_State__c = null;
            pgCont.updateContact();
            pgCont.oBillingAddress.ISO_State__c = mapStateCodeToID.get('ON');
            pgCont.updateContact();
            pgCont.oBillingAddress.ZipCode__c = 'A9A9A9';
            pgCont.updateContact();
            pgCont.oContact.Tax_1_ID__c = '123';
            pgCont.updateContact();
            pgCont.oContact.Tax_2_ID__c = '123';
            pgCont.updateContact();
            
            // Misc Coverage
            pgCont.oBillingAddress.ISO_Country__c = mapCountryCodeToID.get('EG');
            pgCont.BillingCountryChanged();
            pgCont.updateShippingContact();

            IECAddress__c oShippingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Shipping);

            IECVATUtil.VATConfiguration varConf = IECVATUtil.GetVATConfiguration(oCountry.Name);
            
            // Reset contact for testing
            pgCont.oContact.Tax_1_ID__c = null;
            pgCont.oContact.Tax_2_ID__c = null;
            pgCont.oShippingAddress.Street__c = null;
            pgCont.oShippingAddress.City__c = null;
            pgCont.oShippingAddress.ISO_Country__c = null;
            pgCont.oShippingAddress.ISO_State__c = null;
            pgCont.oShippingAddress.ZipCode__c = null;


            // Test contact update validation
            pgCont.updateShippingContact();
            pgCont.oShippingAddress.Street__c = '123 Street ~~~ shipping test ~~~';
            pgCont.updateShippingContact();
            pgCont.oShippingAddress.City__c = 'New York';
            pgCont.updateShippingContact();
            //pgCont.oShippingAddress.ISO_Country__c = mapCountryCodeToID.get('US');
            //pgCont.updateShippingContact();
            //pgCont.oShippingAddress.ISO_State__c = mapStateCodeToID.get('NY');
            //pgCont.updateShippingContact();
            //pgCont.oShippingAddress.ISO_Country_Name__c = 'Canada';
            pgCont.oShippingAddress.ISO_Country__c = mapCountryCodeToID.get('CA');
            pgCont.oShippingAddress.ISO_State__c = null;
            pgCont.updateShippingContact();
            pgCont.oShippingAddress.ISO_State__c = mapStateCodeToID.get('ON');
            pgCont.updateShippingContact();
            pgCont.oShippingAddress.ZipCode__c = 'A9A9A9';
            pgCont.updateShippingContact();

            pgCont.oContact.Tax_1_ID__c = '123';
            pgCont.updateShippingContact();
            pgCont.oContact.Tax_2_ID__c = '123';

            pgCont.shippingVATNumber = '123';
            pgCont.vatConfigShipping = varConf;
            pgCont.updateShippingContact();

            Test.stopTest();

            System.assertEquals(varConf.VATValidationRequired, true);
            System.assertEquals(pgCont.oShippingAddress.ZipCode__c,'A9A9A9');

            // Misc Coverage
            pgCont.oShippingAddress.ISO_Country__c = mapCountryCodeToID.get('EG');
            pgCont.ShippingCountryChanged();
            pgCont.ShippingAddressChanged();

            System.assertEquals(pgCont.oShippingAddress.City__c, null);
                        
            
        }
        
        
    }
}