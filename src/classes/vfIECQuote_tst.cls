/**  
  * Description: Test the class vfIECQuote
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class vfIECQuote_tst {

	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static zqu__ZProduct__c oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;

	private static Account oAccount;
	private static Contact oContact;
	private static IECAddress__c oBillingAddress;
	private static Zuora__CustomerAccount__c oBillingAccount;
	
	static{
		setupData(true);
	}
	
	private static void setupData(Boolean triable){
		
		// create product/rateplan
		
		oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct('PTST');
		insert oProduct;

		oProductInfo = IECTestUtil.CreateSampleProductInfo('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;

		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('PRPTST', triable, oProduct);
		insert oProductRatePlan;

		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', triable, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo.Display_As_Monthly_Fee__c = !triable;
		insert oProductRatePlanInfo;
		
		oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'PRPC', 42);
		insert oProductRatePlanCharge;
	}


    static testMethod void testPage() {
        setupData(false);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		
		oContact = IECUserManager.getContactById(usr.ContactId);
		
		oBillingAddress = TestDataGenerator.generateAddresses(1, true)[0];
		
		// Add the location record required to link all Account/Contact/Address records
		TestDataGenerator.generateLocations(IECConstants.IECAddress_AddressType_Billing, oBillingAddress.Id, oContact.AccountId, oContact.Id);
		
    	System.runAs(usr) {
    		
    		Test.startTest();
			
			PageReference pgRef = Page.IECQuote;
    		Test.setCurrentPage(pgRef);
	
	        vfIECQuote pgCont;
	        
	        // Test #1 - don't provide page parameter
	        try {
	        	pgCont = new vfIECQuote();
	        	
	        	system.assertEquals(null, pgCont.oQuoteRatePlanInfo, 'The oQuoteRatePlanInfo should be null initially');
	        	system.assertEquals(false, pgCont.bQuoteSubmitSucessful, 'The bQuoteSubmitSucessful should be false initially');
	        	system.assertEquals(false, pgCont.bHasAllAutoRenew, 'The bHasAllAutoRenew should be false initially');
	        	system.assertEquals(true, pgCont.bExpandedBilling, 'The bExpandedBilling should be true initially');
	        	system.assertEquals(true, pgCont.bExpandedAutoRenewal, 'The bExpandedAutoRenewal should be true initially');
	        	system.assertEquals(1, pgCont.iQuantity, 'The iQuantity should be 1 initially');
	        	system.assertEquals(null, pgCont.oQuoteRatePlanInfo, 'The oQuoteRatePlanInfo should be null initially');
	        	system.assertEquals('', pgCont.autoRenewFlag, 'The autoRenewFlag should be empty initially');
	        	
				pgCont.pageLoad();
				system.assert(false, 'pageLoad should throw an error when theres no parameter');
	        }
	        catch (Exception ex) {
	        	system.assert(true, 'pageLoad should throw an error when theres no parameter');
	        }
	        
	        // Test #2 - provide rate plan info id as parameter
	        pgRef.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUtil.EncryptEncodeParameter(oProductRatePlanInfo.Id));
    		Test.setCurrentPage(pgRef);
    		
    		// re-trigger pageLoad
    		pgCont = new vfIECQuote();
    		pgCont.pageLoad();
			system.assert(true, 'pageLoad should not throw an error when a parameter');
			
			// check some variables
			system.assert(String.isNotBlank(pgCont.sProductRatePlanInfoId), 'The sProductRatePlanInfoId should not be blank');
			system.assert(pgCont.oQuoteRatePlanInfo != null, 'The Product Rate Plan Info should be loaded');
			system.assert(!pgCont.lstQuoteRatePlanCharges.isEmpty(), 'The product rate plan charges should be found');
			
			system.assertEquals(false, pgCont.cartIsEmpty, 'The cart should not be considered empty');
			system.assertEquals(false, pgCont.hasFilledAutoRenewFlags, 'hasFilledAutoRenewFlags should be initially false');
			
			// perform some actions on the page
			pgCont.refreshShoppingCartTotal();
			pgCont.modifyContactInfo();
			pgCont.cancelUpdateContactInfo();
			pgCont.modifyContactInfo();
			pgCont.onChangeBillingCountry();
			pgCont.updateContactInfo();
			pgCont.showPopUp();
			pgCont.closePopup();
			pgCont.toggleBilling();
			pgCont.toggleAutoRenew();
			pgCont.cancelQuote();
			List<SelectOption> lstTemp = pgCont.lstISOCountries;
			lstTemp = pgCont.lstStateProvince;
			Account testAccount = pgCont.oAccount;
			
			// Test #3 - generate the quote and opportunity
			try {
		        zqu__Quote_Template__c zqt = new zqu__Quote_Template__c(Name = 'sqt',zqu__Template_Id__c = 'asdsad');
		        insert zqt;
		        
		        IEC_Settings__c iecs = IEC_Settings__c.getOrgDefaults();
		        iecs.Quote_Template_ID_New_Subscription__c=zqt.id;
		       
		        update iecs;
						
				pgCont.generateQuote();
				system.assert(pgCont.oQuote != null, 'The quote should be generated');

			}catch (Exception ex) {
	        	system.assert(false, 'Should be able to generate the quote. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
	        }
	        
	        Test.stopTest();
    	}
    }


    static testMethod void testPageUpdateContactInfoCheckError() {

    	setupData(false);
    	Account account = IECTestUtil.createSampleAccount();
    	insert account;
    	Contact c = IECTestUtil.createSampleContact(account);
    	insert c;
		
		User usr = IECTestUtil.createSampleUser(c);
		PageReference pgRef;
		
    	System.runAs(usr) {
    
			pgRef = Page.IECQuote;
			Test.setCurrentPage(pgRef);

	        vfIECQuote pgCont = new vfIECQuote();
	        Test.startTest();
	        pgCont.oBillingAddress = new IECAddress__c();

	        pgCont.updateContactInfo();

			Test.stopTest();
	    }

	    //Check error messages 
	    System.assert(ApexPages.getMessages().get(0).getDetail().contains('The following field is required: Address'));
	    System.assert(ApexPages.getMessages().get(1).getDetail().contains('The following field is required: City'));
	    System.assert(ApexPages.getMessages().get(2).getDetail().contains('The following field is required: Country'));

    }
}