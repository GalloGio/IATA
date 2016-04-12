public class vfIECEBC_TestSuite {
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static zqu__ZProduct__c oProduct;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Zuora__Subscription__c subscription;
    private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    
    private static IECCustomer currentCustomer;

    static void init() {
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_EBROADCAST, true);
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
        
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;
        
        System.debug('Unit Test: Finish: Init');
    }
    
    
    
    
    public static void testPageLoadLoginRequired() {
		PageReference pageRef = Page.IECEBC_Dashboard;
        Test.setCurrentPage(pageRef);
        
        vfIECEBC layoutController = new vfIECEBC();
        
        PageReference pr = layoutController.pageLoad();
        pr.getParameters().clear();
        
        System.assertEquals(Page.IECLogin.getUrl().toLowerCase(), pr.getUrl().toLowerCase());
        
    }
    public static void testPageLoadUnauthorized() {
		PageReference pageRef = Page.IECEBC_Dashboard;
        Test.setCurrentPage(pageRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
        	vfIECEBC layoutController = new vfIECEBC();
            
        	PageReference pr = layoutController.pageLoad();
            pr.getParameters().clear();
            
            System.assertEquals(Page.IECUnauthorized.getUrl().toLowerCase(), pr.getUrl().toLowerCase());
        }
        
    }
    public static void testPageLoadDashboard() {
		PageReference pageRef = Page.IECEBC_Dashboard;
        Test.setCurrentPage(pageRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            init();
            
        	vfIECEBC layoutController = new vfIECEBC();
            
            System.assertEquals(null, layoutController.pageLoad());
        }
    }
    
    public static void testCampaignSetup() {
		PageReference pageRef = Page.IECEBC_Campaign;
        Test.setCurrentPage(pageRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            init();
            
            // Layout PageLoad
        	vfIECEBC layoutController = new vfIECEBC();
            System.assertEquals(null, layoutController.pageLoad());
            
            EBC_Campaign__c camp = new EBC_Campaign__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            
            camp.Name = 'Foo Bar';
            camp.Subject__c = 'Foo Subject';
            camp.From_Name__c = 'Foo From Name';
            camp.Is_Google_Analytics_Tracker_Active__c = true;
            camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
            
            PageReference pr = campaignExtCon.saveAndContinue();
            
            System.assertNotEquals(null, campaignExtCon.con.getId());
            System.assertEquals(campaignExtCon.con.getId(), pr.getParameters().get('id'));
            System.assertEquals(campaignExtCon.getPRByStepNumber(2, true).getUrl(), pr.getUrl());
        }
    }
}