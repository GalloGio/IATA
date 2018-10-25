/**  
  * Description: This class contains unit tests for the (GAD - Advanced Search) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class vfIECGADAdvanced_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static zqu__ZProduct__c oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
	private static IEC_Application_Filter__c filter1;
	private static IEC_Application_Filter__c filter2;
	private static IEC_Application_Filter__c filter3;
	private static IEC_Application_Filter__c filter4;
	private static IEC_Application_Filter__c filter5;

	private static IATA_ISO_Country__c iataCountry;
	private static IATA_ISO_Country__c iataCountry2;
	private static IATA_ISO_State__c iataState;
	private static GDP_Geo_Detail__c gdpGeoDetail;
	private static IEC_Agency_Type__c iecAgencyType;
	
	private static IECCustomer currentCustomer;
	
	static void Init() {
		System.debug('Unit Test: Start: Init');

        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GAD, true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct('PTST');
		insert oProduct;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('PRPTST', false, oProduct);
		insert oProductRatePlan;
		
		oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
    	insert oProductRatePlanCharge;
    	
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		insert oProductRatePlanInfo;
		
		currentCustomer = IECCustomer.getCurrentIECCustomer();
		Account oAccount = currentCustomer.RelatedAccount;
		
		List<Zuora__CustomerAccount__c> lstBA =
			[SELECT Id
			FROM Zuora__CustomerAccount__c
			WHERE Contact__c = :currentCustomer.RelatedContact.Id 
				AND Zuora__Account__c =: currentCustomer.RelatedAccount.Id];
		
		System.assertEquals(lstBA.size(), 1);
		
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(oAccount.Id, 'Subs 01', Date.today().addMonths(6));
        subscription.Zuora__CustomerAccount__c = lstBA.get(0).Id;
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;

		// Create a dummy country
		iataCountry = IECTestUtil.CreateSampleIATAISOCountry();
		insert iataCountry;
		iataCountry2 = IECTestUtil.CreateSampleIATAISOCountry();
		iataCountry2.ISO_Code__c = 'AB';
		insert iataCountry2;
		
		// Create a dummy country
		iataState = IECTestUtil.CreateSampleIATAISOState(iataCountry);
		insert iataState;
		
		// Create a dummy country
		gdpGeoDetail = IECTestUtil.CreateSampleGDPGeoDetail(iataCountry);
		insert gdpGeoDetail;
		
		// Create dummy saved filters
		filter1 = IECTestUtil.CreateSampleApplicationFilter(currentCustomer.RelatedContact);
        filter1.Product_Line__c = 'GAD';
		insert filter1;
		filter2 = IECTestUtil.CreateSampleApplicationFilter(currentCustomer.RelatedContact);
        filter2.Product_Line__c = 'GAD';
		insert filter2;
		filter3 = IECTestUtil.CreateSampleApplicationFilter(currentCustomer.RelatedContact);
        filter3.Product_Line__c = 'GAD';
		insert filter3;
		filter4 = IECTestUtil.CreateSampleApplicationFilter(currentCustomer.RelatedContact);
        filter4.Product_Line__c = 'GAD';
		insert filter4;
		filter5 = IECTestUtil.CreateSampleApplicationFilter(currentCustomer.RelatedContact);
        filter5.Product_Line__c = 'GAD';
		insert filter5;
		
		// Create dummy AgencyType
		iecAgencyType = IECTestUtil.CreateSampleIECAgencyType();
		insert iecAgencyType;
		
		System.debug('Unit Test: Finish: Init');
	}
	
    static testMethod void TestGADAdvanced() {
    	System.debug('Unit Test: Start: TestGADAdvanced');
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
    	//Set current page to GAD
    	PageReference pgRef = Page.IECGADAdvanced;
    	Test.setCurrentPage(pgRef);
    	
    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	Init();
            
            Test.startTest();
	    	
	    	//Instantiate Base Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

	    	//Instantiate Controller
	        vfIECGADAdvanced pgCont = new vfIECGADAdvanced();
            pgCont.defaultproduct();
	        pgCont.pageLoad();
	        
	        //Test 001: All getters and setters
	        List<SelectOption> options;
	        options = pgCont.optAgencyNameSearchCondition;
	        options = pgCont.optAgencyNameSearchType;
	        options = pgCont.optCitySearchType;
	        options = pgCont.optHierarchy;
	        options = pgCont.optZipCodeSearchType;
	        
	        String sTest;
	        sTest = pgCont.sProductCode;
	        
	        String[] stringArray;
	        stringArray = pgCont.sCountry;
	        stringArray = pgCont.sState;
	        stringArray = pgCont.sHierarchy;
	        stringArray = pgCont.sAgencyProgram;
	        
	        pgCont.sCountry = new String[] {'a', 'b'};
	        pgCont.sState = new String[] {'a', 'b'};
	        pgCont.sHierarchy = new String[] {'a', 'b'};
	        pgCont.sAgencyProgram = new String[] {'a', 'b'};

	        //Test 002: Save filter while 5 already exists 
	        //
	        
            System.debug(pgCont.ctrSavedFilters.lstSavedFilters.size());
	        pgCont.filter = IECTestUtil.CreateSampleApplicationFilter(baseCont.loggedCustomer.RelatedContact);
            System.debug(pgCont.ctrSavedFilters.lstSavedFilters.size());
	        pgCont.saveFilter();
            System.debug(pgCont.ctrSavedFilters.lstSavedFilters.size());

	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Maximum5Filters));

	        //Test 004: Save filter while 4 already exists
	        delete filter1;
	        pgCont.ctrSavedFilters.loadFilters();
	        pgCont.saveFilter();

	        //Test 006: Load sub-continent
	        options = pgCont.getListOptionsSubContinent();
	        
	        //Test 007: Load country - SubContinent:All
	        pgCont.filter.Sub_Continent__c = 'All';
	        options = pgCont.getListOptionsCountry();

			//Test 008: Load country - SubContinent:X
	        pgCont.filter.Sub_Continent__c = gdpGeoDetail.Sub_Continent__c;
	        options = pgCont.getListOptionsCountry();
	        
	        //Test 009: Load state - SubContinent:All, Country:All
	        pgCont.filter.Sub_Continent__c = 'All';
	        pgCont.filter.Country__c = 'All';
	        options = pgCont.getListOptionsState();

			//Test 010: Load state - SubContinent:X, Country:All
	        pgCont.filter.Sub_Continent__c = gdpGeoDetail.Sub_Continent__c;
	        pgCont.filter.Country__c = 'All';
	        options = pgCont.getListOptionsState();

			//Test 011: Load state - SubContinent:X, Country:Y
	        pgCont.filter.Sub_Continent__c = gdpGeoDetail.Sub_Continent__c;
	        pgCont.filter.Country__c = iataCountry.Name;
	        options = pgCont.getListOptionsState();
	        
	        //Test 012: Load area of activity
	        options = pgCont.getListOptionsAreaofActivity();
	        
	        //Test 013: Load agency program - Area Of Activity: All
	        pgCont.filter.Area_of_Activity__c = 'All';
	        options = pgCont.getListOptionsAgencyProgram();
	        
	        //Test 014: Load agency program - Area Of Activity: X
	        pgCont.filter.Area_of_Activity__c = iecAgencyType.Area_of_Activity__c;
	        options = pgCont.getListOptionsAgencyProgram();

	        //Test 015: Search Agencies
	        IEC_Application_Filter__c filterSystem = IECTestUtil.CreateSampleApplicationFilter(baseCont.loggedCustomer.RelatedContact);
	        filterSystem.System_Generated__c = true;
	        insert filterSystem;

	        pgCont.filter = IECTestUtil.CreateSampleApplicationFilter(baseCont.loggedCustomer.RelatedContact);
	        pgCont.searchAgencies();

			//Test 016: Handle Brackets for Array variables
	        IEC_Application_Filter__c filter = new IEC_Application_Filter__c();
	        filter.Country__c = 'All';
	        stringArray = pgCont.sCountry;
	        filter.Country__c = '(All)';
	        stringArray = pgCont.sCountry;


			//Test 017: Load saved filter from URL
	    	pgRef = Page.IECGADAdvanced;
	    	Test.setCurrentPage(pgRef);
	    	
	    	pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(filter3.Id));
	    	pgCont.pageLoad();

	        // Misc Coverage
	        pgCont.OnChangeCountry();
	        pgCont.onClickOKError();

    	}
        System.debug('Unit Test: Finish: TestGADAdvanced');
    }

    static testMethod void TestGADAdvanced_Errors() {
    	System.debug('Unit Test: Start: TestGADAdvanced_Errors');
    	
    	//Set current page to GAD
    	PageReference pgRef = Page.IECGADAdvanced;
    	Test.setCurrentPage(pgRef);
    	
    	//Instantiate Controller
        vfIECGADAdvanced pgCont = new vfIECGADAdvanced();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();
        
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
	    	pgCont = new vfIECGADAdvanced();

	        // Test 002: Accessing page with no subscription for CAC
	        pgCont.pageLoad();

			//system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_No_Application_Access));
    	}
        System.debug('Unit Test: Finish: TestGADAdvanced_Errors');
    }
}