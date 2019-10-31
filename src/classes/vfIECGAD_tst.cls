/**  
  * Description: This class contains unit tests for the (GAD - Home) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class vfIECGAD_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
	
	private static IECCustomer currentCustomer;
	
	static void Init() {
		System.debug('Unit Test: Start: Init');

        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GAD, true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
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
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;

		System.debug('Unit Test: Finish: Init');
	}
	
    static testMethod void TestGAD() {
    	System.debug('Unit Test: Start: TestGAD');

    	//Set current page to GAD
    	PageReference pgRef = Page.IECGAD;
    	Test.setCurrentPage(pgRef);
    	
    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	Init();
	    	
	    	//Instantiate Base Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

	    	//Instantiate Controller
	        vfIECGAD pgCont = new vfIECGAD();
	        pgCont.pageLoad();

	        //Test 001: All getters and setters
	        List<SelectOption> options;
	        options = pgCont.optAgencyNameSearchCondition;
	        options = pgCont.optAgencyNameSearchType;

	        //Test 002: Search with a valid IATA Code
	        pgCont.filter = new IEC_Application_Filter__c(
	        	System_Generated__c = true
	        	, Filter_Type__c = 'Basic'
	        	, IATA_Code__c = '12345678'
	        );
	        pgCont.searchAgenciesCode();
	        
	        //Test 003: Search with invalid IATA Code
	        pgCont.filter = new IEC_Application_Filter__c(
	        	System_Generated__c = true
	        	, Filter_Type__c = 'Basic'
	        	, IATA_Code__c = '12345'
	        );
	        pgCont.searchAgenciesCode();
	        system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), 'IATA Code format must only be 7 or 8 digits'));
	        
	        //Test 005: Search with an agency name
	        pgCont.filter = new IEC_Application_Filter__c(
	        	System_Generated__c = true
	        	, Filter_Type__c = 'Basic'
	        	, Agency_Name__c = '12345678'
                , Agency_Name_Search_Condition__c = 'Both'
                , Agency_Name_Search_Type__c = 'Contains'
	        );
	        pgCont.searchAgenciesName();

	        // Misc Coverage
	        pgCont.onClickOKError();
    	}
        System.debug('Unit Test: Finish: TestGAD');
    }

    static testMethod void TestGAD_Errors() {
    	System.debug('Unit Test: Start: TestGAD_Errors');
    	
    	//Set current page to GAD
    	PageReference pgRef = Page.IECGAD;
    	Test.setCurrentPage(pgRef);
    	
    	//Instantiate Controller
        vfIECGAD pgCont = new vfIECGAD();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();
        
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	//Instantiate Controller
	    	IECPageController baseCont = new IECPageController();
	    	baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
	    	pgCont = new vfIECGAD();

	        // Test 002: Accessing page with no subscription for CAC
	        pgCont.pageLoad();
    	}
        System.debug('Unit Test: Finish: TestGAD_Errors');
    }
}