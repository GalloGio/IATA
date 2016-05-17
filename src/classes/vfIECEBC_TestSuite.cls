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
    public static void testCampaignListing() {
		PageReference pageRef = Page.IECEBC_CampaignList;
        Test.setCurrentPage(pageRef);
        
        Account hw = new Account();
        hw.Name = 'Hello World';
        insert hw;
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        List<EBC_Campaign__c> campaigns = new List<EBC_Campaign__c>{
            new EBC_Campaign__c(Name = 'Foo Bar 1', Subject__c = 'Foo Bar 1', From_Name__c = 'FooBar1', Account__c = IECTestUtil.PortalUserAccountId),
            new EBC_Campaign__c(Name = 'Foo Bar 2', Subject__c = 'Foo Bar 2', From_Name__c = 'FooBar2', Account__c = IECTestUtil.PortalUserAccountId),
            new EBC_Campaign__c(Name = 'Foo Bar 3', Subject__c = 'Foo Bar 3', From_Name__c = 'FooBar3', Account__c = IECTestUtil.PortalUserAccountId),
            new EBC_Campaign__c(Name = 'Foo Bar 4', Subject__c = 'Foo Bar 4', From_Name__c = 'FooBar4', Account__c = IECTestUtil.PortalUserAccountId),
            new EBC_Campaign__c(Name = 'Hello World 1', Subject__c = 'Hello World 1', From_Name__c = 'HelloWorld1', Account__c = hw.Id)
        };
            
        insert campaigns;
        
        System.runAs(usr) {
            Test.startTest();
            
            init();
            
            // Layout PageLoad
        	vfIECEBC layoutController = new vfIECEBC();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_CampaignList campaignListCon = new vfIECEBC_CampaignList();
            
            vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE = campaigns.size() - 1;
            
            System.assertEquals(campaigns.size() - 1, campaignListCon.campaignsCount);
            System.assert(campaignListCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(1, campaignListCon.page);
            System.assertEquals(1, campaignListCon.maxPage);
            System.assertEquals(campaignListCon.maxPage, campaignListCon.getPageOptions().size());
            System.assertEquals(campaignListCon.getSortByOptions()[0].getValue(), campaignListCon.sortBy);
            System.assertEquals(0, campaignListCon.offset);
            
            vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE = 3;
            
            campaignListCon = new vfIECEBC_CampaignList();
            
            System.assertEquals(campaigns.size() - 1, campaignListCon.campaignsCount);
            System.assert(campaignListCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(1, campaignListCon.page);
            System.assertEquals(2, campaignListCon.maxPage);
            System.assertEquals(campaignListCon.maxPage, campaignListCon.getPageOptions().size());
            System.assertEquals(campaignListCon.getSortByOptions()[0].getValue(), campaignListCon.sortBy);
            System.assertEquals(0, campaignListCon.offset);
            
            campaignListCon.page = 2;
            
            System.assertEquals(campaigns.size() - 1, campaignListCon.campaignsCount);
            System.assert(campaignListCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(2, campaignListCon.page);
            System.assertEquals(2, campaignListCon.maxPage);
            System.assertEquals(campaignListCon.maxPage, campaignListCon.getPageOptions().size());
            System.assertEquals(campaignListCon.getSortByOptions()[0].getValue(), campaignListCon.sortBy);
            System.assertEquals(vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE, campaignListCon.offset);
            
            campaignListCon.sortBy = campaignListCon.getSortByOptions()[1].getValue();
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
    public static void testCampaignScheduling() {
		PageReference pageRef = Page.IECEBC_CampaignSchedule;
        Test.setCurrentPage(pageRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        insert masterFilter;
        EBC_Template__c tpl = new EBC_Template__c();
        insert tpl;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.Account__c = IECTestUtil.PortalUserAccountId;
        camp.EBC_Master_Filter__c = masterFilter.Id;
        camp.EBC_Template__c = tpl.Id;
        insert camp;
        
        System.runAs(usr) {
            Test.startTest();
            
            init();
            
            // Layout PageLoad
        	vfIECEBC layoutController = new vfIECEBC();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            vfIECEBC_CampaignSchedule scheduleExtCon = new vfIECEBC_CampaignSchedule(sc);
            
            System.assert(scheduleExtCon.getUserTimezoneOffset() == '-04:00' || scheduleExtCon.getUserTimezoneOffset() == '-05:00');
            System.assertEquals('Eastern Standard Time', scheduleExtCon.getUserTimezoneDisplayName());
            System.assertEquals(null, scheduleExtCon.validationMessage);
            
            Datetime dt = Datetime.now().addDays(1);
            scheduleExtCon.humanCampaignDate = dt.format('MMMM d y');
            scheduleExtCon.campaignDate = dt.month() + '/' + dt.day() + '/' + dt.year();
            scheduleExtCon.campaignHours = dt.hour() > 12 ? dt.hour() - 12 : dt.hour();
            scheduleExtCon.campaignMinutes = dt.minute();
            scheduleExtCon.campaignMeridiem = dt.hour() > 12 ? 'PM' : 'AM';
            scheduleExtCon.validate();
            System.assertNotEquals(null, scheduleExtCon.validationMessage);
            System.debug(scheduleExtCon.validationMessage);
            System.assert(scheduleExtCon.validationMessage.contains('2 business days'));
            
            dt = Datetime.now().addDays(5);
            scheduleExtCon.humanCampaignDate = dt.format('MMMM d y');
            scheduleExtCon.campaignDate = dt.month() + '/' + dt.day() + '/' + dt.year();
            scheduleExtCon.campaignHours = dt.hour() > 12 ? dt.hour() - 12 : dt.hour();
            scheduleExtCon.campaignMinutes = dt.minute();
            scheduleExtCon.campaignMeridiem = dt.hour() > 12 ? 'PM' : 'AM';
            //camp.Scheduled_Date__c = Datetime.now().addDays(5);
            scheduleExtCon.validate();
            System.assertEquals(null, scheduleExtCon.validationMessage);
            
            PageReference pr = campaignExtCon.saveAndContinue();
            
            System.assertEquals(campaignExtCon.con.getId(), pr.getParameters().get('id'));
            System.assertEquals(campaignExtCon.getPRByStepNumber(6, true).getUrl(), pr.getUrl());
        }
    }
}