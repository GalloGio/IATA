/**  
  * Description: This class contains unit tests for the (Trial Request) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class vfIECTrialRequest_tst {
	private static Product2 prod;
	private static zqu__ProductRatePlan__c ratePlan;
	private static zqu__ProductRatePlanCharge__c charge;
	private static Product_Category__c myProdCat;
	private static Product_Information__c myProdInfo;
	private static Product_Rate_Plan_Information__c ratePlanInfo;
	
	private static void Init(){
        // create dummy Zuora product
    	prod = IECTestUtil.CreateSampleProduct2('Product1');
    	prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	prod.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
    	insert prod;
    	
    	// create dummy Zuora rate plan
    	ratePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', true, prod);
    	ratePlan.zqu__Deleted__c = false;
    	insert ratePlan;
    	
    	// create dummy Zuora rate plan charge
    	charge = IECTestUtil.CreateSampleProductRatePlanCharge(ratePlan, 'Charge 1', 42);
    	charge.zqu__Deleted__c = false;
    	insert charge;
    	
    	// create dummy product category
        myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
        myProdCat.Active__c = true;
        insert myProdCat;
        
        // create dummy product info
        myProdInfo = IECTestUtil.CreateSampleProductInfo2('My product', myProdCat, prod);
        insert myProdInfo;
        
        // create dummy rate plan information
        ratePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', true, ratePlan, myProdInfo);
        ratePlanInfo.Display_As_Monthly_Fee__c = false;
        ratePlanInfo.Active__c = true;
        ratePlanInfo.Order__c = 1;
        insert ratePlanInfo;

        // create a Terms & Conditions
		Terms_and_Conditions__c oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', myProdInfo, true);
        insert oTC;
        
        // create dummy Attachment for the T&C
        Attachment oAttachment = IECTestUtil.CreateSampleAttachment(oTC.Id);
        insert oAttachment;
        
        // set the effective date of the T&C
        oTC.Effective_Start_Date__c = Date.today().addDays(-5);
        update oTC;
	}

  static testMethod void TestTrialRequest() {
    	System.debug('Unit Test: Start: TestTrialRequest');
    	
    	PageReference pgRef = Page.IECTrialRequest;
    	Test.setCurrentPage(pgRef);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	// Initialize Data for test scenario
	    	Init();

	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);
			//insert oBillingAddress;  //*** commented by Thai (2016-02-29) because address was inserted in the calling method
	
			// Pass the rateplan id to the page parameters    	
	    	pgRef.getParameters().put(IECConstants.PARAM_RATEPLAN_ID, IECUtil.EncryptEncodeParameter(ratePlanInfo.Id));
	    	
	    	//Instantiate Controller
	        vfIECTrialRequest pgCont = new vfIECTrialRequest();
	        pgCont.pageLoad();
	                
	        // Test 001: Parameter retrieval process
	        system.assertEquals(pgCont.sParamRatePlanId, ratePlanInfo.Id);
	        system.assert(!String.isEmpty(pgCont.sProductName));
	        
	        // Test 002: Run the request for Trial
	        
	        // First Accept the T&Cs
	        pgCont.oTnCComponentController.listProductInformationIDs = new String [] {myProdInfo.Id};
	        List<Terms_and_Conditions__c> listTC = pgCont.oTnCComponentController.listTermsAndConditions;
	        system.assert(pgCont.oTnCComponentController.hasTermsAndConditions, 'The vf component should be able to retreive a Terms And Conditions');
			system.assert(pgCont.hasAcceptedAllTnCs == false, 'T&C are not supposed to be accepted.');
	        pgCont.oTnCComponentController.lstTnCsToDisplay.get(0).checked = true;
	        system.assert(pgCont.hasAcceptedAllTnCs, 'T&C are supposed to be accepted.');
	        
	        // Submit the trial request
	        pgCont.activateTrial();
	        
	        // Misc Coverage
	        Contact oContact = pgCont.oContact;
	        Account oAccount = pgCont.oAccount;

	        List<SelectOption> lstOptions;
	        lstOptions = pgCont.lstISOCountries;
	        lstOptions = pgCont.lstStateProvince;
	        
	        pgCont.modifyContactInfo();
	        pgCont.updateContactInfo();
	        pgCont.cancelUpdateContactInfo();
	        
	        pgCont.needToFillContactInfo = true;
	        pgCont.activateTrial();
	        pgCont.needToFillContactInfo = false;
	        pgCont.inEditContactInfo = true;
	        pgCont.activateTrial();
    	}

        System.debug('Unit Test: Finish: TestTrialRequest');
    }

    static testMethod void TestTrialRequest_Errors() {
    	System.debug('Unit Test: Start: TestTrialRequest_Errors');
		Trial__c trl ;
    	PageReference pgRef = Page.IECTrialRequest;
    	Test.setCurrentPage(pgRef);
    	
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
					//Throw new transformationException('usr ' +  usr);	        

    	System.runAs(usr) {
	    	// Initialize Data for test scenario
	    	Init();

	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

	    	//Instantiate Controller
	        vfIECTrialRequest pgCont = new vfIECTrialRequest();

	        // Test 001: Page generated an error for missing rateplan ID
	        pgCont.pageLoad();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_InvalidPageParameter));

	        // Test 002: Page generated an error for unable to find the specified rateplan (this is id is just any random id)
	        pgRef.getParameters().put(IECConstants.PARAM_RATEPLAN_ID, IECUtil.EncryptEncodeParameter('a0NF00000176mlj'));
	        pgCont.pageLoad();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_InvalidRatePlanId));
	
			// Insert billing address to continue testing
			IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(baseCont.loggedCustomer.RelatedContact, 
																				IECConstants.IECAddress_AddressType_Billing);
			//insert oBillingAddress;	 //*** commented by Thai (2016-02-29) because address was inserted in the calling method

			// Prepare the T&C component
	        pgCont.oTnCComponentController.listProductInformationIDs = new String [] {myProdInfo.Id};
	        List<Terms_and_Conditions__c> listTC = pgCont.oTnCComponentController.listTermsAndConditions;
			pgRef.getParameters().put(IECConstants.PARAM_RATEPLAN_ID, IECUtil.EncryptEncodeParameter(ratePlanInfo.Id));
			pgCont.pageLoad();
	        // Test 003: T&Cs not yet accepted
	        
	        pgCont.activateTrial();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_AcceptTermAndCondition));
	
	        // Test 004: Trial already exist
	        // First Accept the T&Cs
	        system.assert(pgCont.oTnCComponentController.hasTermsAndConditions, 'The vf component should be able to retreive a Terms And Conditions');
	        pgCont.oTnCComponentController.lstTnCsToDisplay.get(0).checked = true;

	        // Insert a trial record on the contact
	       IECSubscriptionManager.addTrialSubscription(baseCont.loggedCustomer.RelatedContact.Id, ratePlanInfo.Id);	        		        	

	        pgCont.activateTrial();
	         
	    //   throw new transformationException(' messages from the page ' + ApexPages.getMessages());
	      
    	}




		//	Throw new transformationException('c.eamil ' + baseCont.loggedCustomer.RelatedContact.Id +   '    trl    '   +trl);	        
	   list<Trial__c> trl1 = [SELECT Product_Rate_Plan_Information__c,Contact__c, Trial_Date__c,Ignore__c FROM Trial__c  ];



                SYSTEM.DEBUG('SASA '+ TRL1 );   

    	  system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), IECConstants.Error_TrialConsumed));
        System.debug('Unit Test: Finish: TestTrialRequest_Errors');
    }

    static testMethod void TestTrialRequest_ContactUpdate() {
    	System.debug('Unit Test: Start: TestTrialRequest_ContactUpdate');

    	PageReference pgRef = Page.IECTrialRequest;
    	Test.setCurrentPage(pgRef);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	// Initialize Data for test scenario
	    	Init();

	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			// Pass the rateplan id to the page parameters    	
	    	pgRef.getParameters().put(IECConstants.PARAM_RATEPLAN_ID, IECUtil.EncryptEncodeParameter(ratePlanInfo.Id));
	    	
	    	//Instantiate Controller
	        vfIECTrialRequest pgCont = new vfIECTrialRequest();
	        pgCont.pageLoad();
	        
			// Reset contact for testing
	        pgCont.oContact.FirstName = null;
	        pgCont.oContact.LastName = null;
	        pgCont.oContact.Title = null;
	        pgCont.oContact.Email = null;
	        pgCont.oContact.Phone = null;

	        // Test 005: Test contact update validation
//	        baseCont.loggedCustomer.RelatedContact = new Contact();
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
	        //allow to refresh Iso countries static map
	        IATAIsoCountryDAO.resetMapIataIsoCountry();
	        
	        pgCont.oBillingAddress.ISO_Country__c = country.Id;
	        
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Tax 1 ID'));
	        pgCont.oContact.Tax_1_ID__c = 'Tax1ID';
	        pgCont.updateContactInfo();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Tax 2 ID'));
			//*** (Thai) add Test block to fix error "MIXED_DML_OPERATION"
			IECTestUtil.trgPortalUserAfterInserUpdate = true;
			ISSP_UserTriggerHandler.preventTrigger = true;
			Test.startTest();
		        pgCont.oContact.Tax_2_ID__c = 'Tax2ID';
		        pgCont.updateContactInfo();
			Test.stopTest();
	        IFAP_BusinessRulesTest.createIsoCountry();
	        // Misc Coverage
	        pgCont.oBillingAddress.ISO_Country__c = ([SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c IN ('EG')])[0].Id;
	        pgCont.onChangeBillingCountry();
    	}
        System.debug('Unit Test: Finish: TestTrialRequest_ContactUpdate');
    }
}