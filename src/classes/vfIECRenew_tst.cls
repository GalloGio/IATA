/**  
  * Description: This class contains unit tests for the (Renew Subscription) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
private class vfIECRenew_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
	private static Terms_and_Conditions__c oTnC;
	private static Attachment oAttachment;
	
	static void Init() {
        // create dummy Zuora product
    	oProduct = IECTestUtil.CreateSampleProduct2('Product1');
    	oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
    	insert oProduct;
    	
    	// create dummy Zuora rate plan
    	oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct);
    	oProductRatePlan.zqu__Deleted__c = false;
    	insert oProductRatePlan;
    	
    	zqu__ProductRatePlanCharge__c oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 42);
    	oProductRatePlanCharge.zqu__Deleted__c = false;
    	insert oProductRatePlanCharge;
    	
    	insert new List<zqu__ProductRatePlanChargeTier__c> {
    		TestDataGenerator.generateZTiers(oProductRatePlanCharge.Id, 1, false)[0]
    	};
    	
    	// create dummy product category
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
        oProductCategory.Active__c = true;
        insert oProductCategory;
        
        // create dummy product info
        oProductInfo = IECTestUtil.CreateSampleProductInfo2('My product', oProductCategory, oProduct);
        insert oProductInfo;
        
        // create dummy rate plan information
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, oProductRatePlan, oProductInfo);
        oProductRatePlanInfo.Display_As_Monthly_Fee__c = false;
        oProductRatePlanInfo.Active__c = true;
        oProductRatePlanInfo.Order__c = 1;
        insert oProductRatePlanInfo;
        
        List<Product2> lstProduct = TestDataGenerator.generateProducts(2, true);
		lstProduct[0].SAP_Material_Number__c = 'TESTPRODCODE';
		
		lstProduct[1].IEC_Parent_Product__c = lstProduct[0].Id;
		lstProduct[1].IEC_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
		
		update lstProduct;        
        
		IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
        
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;

        // create a Terms & Conditions
		oTnC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTnC;
        
        // create dummy Attachment for the T&C
        oAttachment = IECTestUtil.CreateSampleAttachment(oTnC.Id);
        insert oAttachment;
        
        // set the effective date of the T&C
        oTnC.Effective_Start_Date__c = Date.today().addDays(-5);
        update oTnC;
    }
    
    static testMethod void TestRenew() {
    	System.debug('Unit Test: Start: TestRenew');

    	//Set current page to Renewal page
    	PageReference pgRef = Page.IECRenew;
    	Test.setCurrentPage(pgRef);

    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	Init();

			Test.startTest();

	    	pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscription.Id));
	    	pgRef.getParameters().put(IECConstants.PARAM_PRODINFO_ID, IECUtil.EncryptEncodeParameter(oProductInfo.Id));
	    	pgRef.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUtil.EncryptEncodeParameter(oProductRatePlanInfo.Id));
	    	
	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer(); 
			IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);
			//insert oBillingAddress;  //*** commented by Thai (2016-02-29) because address was inserted in the calling method
			
	        vfIECRenew pgCont = new vfIECRenew();
	        pgCont.pageLoad();
	        
	        // Test 001: URL Parameter should be loaded
	        system.assertEquals(pgCont.sParamSubscriptionId, subscription.Id, 'Subscription Id must be loaded');
	        system.assertEquals(pgCont.sParamProdInfoId, oProductInfo.Id, 'Prod Info Id must be loaded');
	        system.assertEquals(pgCont.sParamRatePlanInfoId, oProductRatePlanInfo.Id, 'Rate Plan Info Id must be loaded');
	        
	        // First Accept the T&Cs
	        pgCont.oTnCComponentController.listProductInformationIDs = new String [] {oProductInfo.Id};
	        List<VfIECTermsAndConditionsComponent.UITermsAndConditions> listTC = pgCont.oTnCComponentController.listTermsAndConditionsToDisplay;
	        system.assert(pgCont.oTnCComponentController.hasTermsAndConditions, 'The vf component should be able to retreive a Terms And Conditions');
			system.assert(pgCont.oTnCComponentController.hasAcceptedAllTCs == false, 'T&C are not supposed to be accepted.');
	        pgCont.oTnCComponentController.lstTnCsToDisplay.get(0).checked = true;
	        system.assert(pgCont.oTnCComponentController.hasAcceptedAllTCs, 'T&C are supposed to be accepted.');
	        
	        // Second: Set Auto-Renewal to true
	        pgCont.lstLineItemAutoRenew.get(0).autoRenewFlag = 'true';
	        system.assert(pgCont.hasFilledAutoRenewFlags, 'All Auto-renew radios should be filled');
	        
	        // Set Payment Method Type
	        pgCont.selectedPaymentMethodType = 'CREDIT_CARD';
	        pgCont.selectedCreditCardPaymentId = pgCont.defaultPaymentMethodId;

	       // Test 002: renewal method
	        pgCont.proceedToPayment();
	        
	        // Test 003: Make sure an email has been triggered to the contact
	        List<IEC_Email_Notification__c> lstEmails = [SELECT Email_Sent__c FROM IEC_Email_Notification__c WHERE To_Email__c = :baseCont.loggedCustomer.RelatedContact.Email];
	        
	        system.assertNotEquals(lstEmails.size(), 0, 'An email notification must be recorded in the system.');
	        system.assertEquals(lstEmails.get(0).Email_Sent__c, true, 'Workflow must kick in and flag the email as sent.');
	        
	        Test.stopTest();
    	}
    	
    	System.debug('Unit Test: Finish: TestRenew');
    }
    
    static testMethod void TestRenew_Errors() {
    	System.debug('Unit Test: Start: TestRenew_Errors');

    	PageReference pgRef = Page.IECRenew;
    	Test.setCurrentPage(pgRef);
    	
    	//Instantiate Controller
        vfIECRenew pgCont = new vfIECRenew();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	Test.startTest();
    	IECPageController baseCont;
    	System.runAs(usr) {
	    	// Initialize Data for test scenario
	    	Init();

	    	//Instantiate Controller
	    	baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer(); 
			IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);
			//insert oBillingAddress;  //*** commented by Thai (2016-02-29) because address was inserted in the calling method
    	
	    	//Instantiate Controller
	        pgCont = new vfIECRenew();
	
	        // Test 002: Page generated an error for missing rateplan ID
	        pgCont.pageLoad();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_InvalidPageParameter));

			// Prepare the T&C component
	        pgCont.oTnCComponentController.listProductInformationIDs = new String [] {oProductInfo.Id};
	        List<VfIECTermsAndConditionsComponent.UITermsAndConditions> listTC = pgCont.oTnCComponentController.listTermsAndConditionsToDisplay;
	
	        // Test 003: T&Cs not yet accepted
	    	pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscription.Id));
	    	pgRef.getParameters().put(IECConstants.PARAM_PRODINFO_ID, IECUtil.EncryptEncodeParameter(oProductInfo.Id));
	    	pgRef.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUtil.EncryptEncodeParameter(oProductRatePlanInfo.Id));
	        pgCont.pageLoad();
	        pgCont.proceedToPayment();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_AcceptTermAndCondition));
	
	        // Accept the T&Cs
	        system.assert(pgCont.oTnCComponentController.hasTermsAndConditions, 'The vf component should be able to retreive a Terms And Conditions');
	        pgCont.oTnCComponentController.lstTnCsToDisplay.get(0).checked = true;
	        
	        // Test 004: Must Select Payment
	        pgCont.selectedPaymentMethodType = '';
	        pgCont.proceedToPayment();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_PleaseSelectPaymentMethod));
    	}
        
        // Test 005: ICH Member must have ICH Code
        pgCont.selectedPaymentMethodType = 'ICH';
        Account currentAccount = IECUserManager.getAccountById(baseCont.loggedCustomer.RelatedAccount.Id);
		currentAccount.ICH_Member__c = false;
		update currentAccount;
        pgCont.proceedToPayment();
        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_ICHCodeNotAvailable));
        
        Test.stopTest();
        System.debug('Unit Test: Finish: TestRenew_Errors');
    }
    
    static testMethod void TestRenew_Misc() {
    	System.debug('Unit Test: Start: TestRenew_Misc');

    	//Set current page to Renewal page
    	PageReference pgRef = Page.IECRenew;
    	Test.setCurrentPage(pgRef);

    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	Init();
	    	
	    	Test.startTest();

	    	pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscription.Id));
	    	pgRef.getParameters().put(IECConstants.PARAM_PRODINFO_ID, IECUtil.EncryptEncodeParameter(oProductInfo.Id));
	    	pgRef.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUtil.EncryptEncodeParameter(oProductRatePlanInfo.Id));
	    	
	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
	        vfIECRenew pgCont = new vfIECRenew();
	        String sTest = pgCont.sProductName;
	        Boolean bTest = pgCont.hasFilledAutoRenewFlags;
	        pgCont.pageLoad();
	        
			// Run misc coverage	        
	        pgCont.displayCallBackfailure();
	        bTest = pgCont.defaultPaymentMethodIsBankTransfer;
	        bTest = pgCont.defaultPaymentMethodIsICH;
	        sTest = pgCont.TC_COMPONENT_KEY;
	        sTest = pgCont.getExtraParamString();
	        sTest = pgCont.sProductName;
	        Date dTest = pgCont.renewalEndDate;
	        Integer iTest = pgCont.subscriptionChargeQuantity;
	        Zuora__SubscriptionProductCharge__c zTest = pgCont.subscriptionCharge;
	        system.assert(pgCont.hasPaymentMethods, 'User should have payment methods');
	        
	        Contact oContact = pgCont.oContact;
	        Account oAccount = pgCont.oAccount;
	        List<SelectOption> lstOptions = pgCont.lstISOCountries;
	        lstOptions = pgCont.lstStateProvince;
	        pgCont.hasAcceptedAllTnCs = true;
	        
	        // Click on cancel
	        PageReference pgSubRef = pgCont.onClickCancel();
	        system.assertNotEquals(pgSubRef, null, 'Must contain pagereference for the Active Subscription Page');
	        
	        pgCont.needToFillContactInfo = true;
	        pgCont.proceedToPayment();
	        pgCont.needToFillContactInfo = false;
	        pgCont.inEditContactInfo = true;
	        pgCont.proceedToPayment();
	        
	        pgCont.inEditContactInfo = false;
	        pgCont.hasAcceptedAllTnCs = true;
	        pgCont.selectedPaymentMethodType = 'BANK_TRANSFER';
	        pgCont.proceedToPayment();
	        pgCont.selectedPaymentMethodType = 'CREDIT_CARD';
	        pgCont.proceedToPayment();
	        
	        pgCont.modifyContactInfo();
	        
			// Reset contact for testing
	        pgCont.oContact.FirstName = null;
	        pgCont.oContact.LastName = null;
	        pgCont.oContact.Title = null;
	        pgCont.oContact.Email = null;
	        pgCont.oContact.Phone = null;

	        // Test 005: Test contact update validation
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' First Name'));
	        pgCont.oContact.FirstName = 'FirstName';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Last Name'));
	        pgCont.oContact.LastName = 'LastName';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Job Title'));
	        pgCont.oContact.Title = 'Title';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Email'));
	        pgCont.oContact.Email = 'a@a.com';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Phone'));
	        pgCont.oContact.Phone = '4169494949';

			pgCont.oBillingLocation = new Location__c(
            	Active__c = true
            	, Account__c = pgCont.oAccount.Id
            	, Contact__c = pgCont.oContact.Id
            	, Type__c = IECConstants.IECAddress_AddressType_Billing
			);
			pgCont.oBillingAddress = new IECAddress__c();
			
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Address'));
	        pgCont.oBillingAddress.Street__c = 'Address';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' City'));
	        pgCont.oBillingAddress.City__c = 'City';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Country'));
	        
	        // Setup a VAT Configuration
	        IATA_ISO_Country__c country = IECTestUtil.CreateSampleIATAISOCountry();
	        country.VAT_Validation_Required__c =
	        	country.Tax_ID_Mandatory__c = true;
	        country.Tax_1_Label__c = 'Tax 1 ID';
        	country.Tax_2_Label__c = 'Tax 2 ID';
	        insert country;

	        //refresh Iso Country static map 
	        IATAIsoCountryDAO.resetMapIataIsoCountry();
	        pgCont.oBillingAddress.ISO_Country__c = country.Id;

	        
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Tax 1 ID'));
	        pgCont.oContact.Tax_1_ID__c = 'Tax1ID';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Tax 2 ID'));
	        pgCont.oContact.Tax_2_ID__c = 'Tax2ID';
	        pgCont.updateContactInfo();
	        

			IFAP_BusinessRulesTest.createIsoCountry();

	        // Misc Coverage
	        pgCont.oBillingAddress.ISO_Country__c = ([SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c IN ('EG')])[0].Id;
	        pgCont.onChangeBillingCountry();
	        
	        pgCont.cancelUpdateContactInfo(); 
	        pgCont.closePopup();
	        pgCont.showPopUp();
	        pgCont.toggleBilling();
	        pgCont.toggleTCs();
	        pgCont.toggleAutoRenew();
	        pgCont.togglePaymentMethod();
	        
	        Test.stopTest();
    	}
    	
    	System.debug('Unit Test: Finish: TestRenew_Misc');
    }
}