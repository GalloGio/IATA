/**  
  * Description: This class contains unit tests for the (GSS - Subscription Details) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class vfIECGSS_tst {
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
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GSS, true);
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
        
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        subscription.Zuora__Status__c = 'Active';
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;
        System.debug('Unit Test: Finish: Init');
    }
    
    static testMethod void TestGSS() {
        System.debug('Unit Test: Start: TestGSS');

        //Set current page to GSS File
        PageReference pgRef = Page.IECFD;
        pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
        Test.setCurrentPage(pgRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            
            Test.startTest();
                
            // setup data
            Init();

            // trigger the Product Access creation
            update subscription;
                
            Test.stopTest();

            //Instantiate Controller
            vfIECGSS pgCont = new vfIECGSS();
            pgCont.pageLoad();
            
            system.assertEquals(1, pgCont.lstListActiveSubscriptions.size(), 'Only one subscription should be found and then system will directly forward the page to the next detail page.');
            
            //Test 001: retrieve page parameters
            String sTest = pgCont.sApplicationTitleUpperCase;
	        pgCont.sProductCode = IECConstants.ProductCategory_SF_MDP;
	        sTest = pgCont.sApplicationTitleUpperCase;
	        pgCont.sProductCode = '';
	        sTest = pgCont.sApplicationTitleUpperCase;
        }
        System.debug('Unit Test: Finish: TestGSS');
    }

    static testMethod void TestGSS_Errors() {
        System.debug('Unit Test: Start: TestGSS_Errors');

        //Set current page to GSSFile
        PageReference pgRef = Page.IECFD;
        pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
        Test.setCurrentPage(pgRef);
        
        //Instantiate Controller
        vfIECGSS pgCont = new vfIECGSS();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();
        
        System.debug('Unit Test: Finish: TestGSS_Errors');
    }
}