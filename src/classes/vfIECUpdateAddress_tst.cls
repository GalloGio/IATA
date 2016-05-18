@isTest(SeeAllData=true)
private class vfIECUpdateAddress_tst {
    static testMethod void TestUpdateAddress() {
    	System.debug('Unit Test: Start: TestUpdateAddress');

	   	PageReference pgRef = Page.IECUpdateAddress;
    	Test.setCurrentPage(pgRef);
    	
    	vfIECUpdateAddress pgCont = new vfIECUpdateAddress();
    	pgCont.pageLoad();

    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	Test.startTest();
	    	
	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
	        pgCont = new vfIECUpdateAddress();
	        pgCont.pageLoad();

	    	pgCont.oBilling = null;
	    	IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);
			IATA_ISO_Country__c oCountry = IECTestUtil.CreateSampleIATAISOCountry();
			oCountry.Name = oBillingAddress.Country__c = 'TestCountry';
			oCountry.VAT_Validation_Required__c = true;
			oCountry.Tax_1_Label__c = 'Tax 1';
			oCountry.Tax_2_Label__c = 'Tax 2';
			oCountry.Tax_ID_Mandatory__c = true;
			insert oBillingAddress;
			insert oCountry;

	        pgCont.pageLoad();
	        
			// Run misc coverage	        
	        pgCont.getCountries();
	        pgCont.getCanadaProvinces();
	        pgCont.getUSAStates();
	        pgCont.backToContactInfo();
	        Contact oContact = pgCont.oContact;
	        	        
			// Reset contact for testing
			pgCont.oContact.Tax_1_ID__c = null;
			pgCont.oContact.Tax_2_ID__c = null;
	        pgCont.oBilling.Street__c = null;
	        pgCont.oBilling.City__c = null;
	        pgCont.oBilling.Country__c = null;
	        pgCont.oBilling.State__c = null;
	        pgCont.oBilling.ZipCode__c = null;

	        // Test contact update validation
	        pgCont.updateContact();
	        pgCont.oBilling.Street__c = '123 Street';
	        pgCont.updateContact();
	        pgCont.oBilling.City__c = 'New York';
	        pgCont.updateContact();
	        pgCont.oBilling.Country__c = 'United States';
	        pgCont.updateContact();
	        pgCont.oBilling.State__c = 'New York';
	        pgCont.updateContact();
	        pgCont.oBilling.Country__c = 'Canada';
	        pgCont.oBilling.State__c = '';
	        pgCont.updateContact();
	        pgCont.oBilling.State__c = 'Ontario';
	        pgCont.updateContact();
	        pgCont.oBilling.ZipCode__c = 'A9A9A9';
	        pgCont.updateContact();
	        pgCont.oContact.Tax_1_ID__c = '123';
	        pgCont.updateContact();
	        pgCont.oContact.Tax_2_ID__c = '123';
	        pgCont.updateContact();
	        
	        // Misc Coverage
	        pgCont.oBilling.Country__c = 'Teesstt';
	        pgCont.BillingCountryChanged();
	        	        
	        Test.stopTest();
    	}
    	
    	System.debug('Unit Test: Finish: TestUpdateAddress');
    }
}