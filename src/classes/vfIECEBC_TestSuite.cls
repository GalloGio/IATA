public class vfIECEBC_TestSuite {
    public static Account IECTestUtil_Account;
    public static Contact IECTestUtil_Contact;
    public static User IECTestUtil_User;
    public static Id IECTestUtil_UserId;
    public static Zuora__CustomerAccount__c IECTestUtil_BillingAccount;
    
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static zqu__ZProduct__c oProduct;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Zuora__Subscription__c subscription;
    private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    private static Zuora__CustomerAccount__c oBillingAccount {
        get { return IECTestUtil_BillingAccount; }
    }
    private static EBC_Preference__c oPref;
    
    private static IECCustomer currentCustomer;

    public static User initPreRunAs(Boolean grantEBCAccess) {
        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        if (grantEBCAccess) {
            oBillingAccount.eBroadcast_Product_Access__c = true;
            update oBillingAccount;
        }
        
        return usr;
    }
    
    static void initPostRunAs() {
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_EBROADCAST, true);
        insert oProductCategory;
        
        oProduct = IECTestUtil.CreateSampleProduct('eBroadcast for Non-Members');
        insert oProduct;
        
        oProductInfo = IECTestUtil.CreateSampleProductInfo('eBroadcast for IATA Non Member Airlines', oProductCategory, oProduct);
        oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert oProductInfo;
        
        oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('Enterprise Edition', false, oProduct);
        insert oProductRatePlan;
        
        oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
        insert oProductRatePlanCharge;
        
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Starter Edition', false, oProductRatePlan, oProductInfo);
        insert oProductRatePlanInfo; 
        
        currentCustomer = IECCustomer.getCurrentIECCustomer(); 
        
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(IECTestUtil_Account.Id, IECTestUtil_BillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;
        
        oPref = new EBC_Preference__c(Billing_Account__c = IECTestUtil_BillingAccount.Id, PrimaryContact_Email__c = 'hello@world.com', Default_From_Name__c = 'w00t', PrimaryContact_Name__c = 'w00t');
        
        insert oPref;
    }
    
    //////////////////// TESTS /////////////////////
    public static void testPageLoadDashboard() {
		PageReference pageRef = Page.IECEBC_Dashboard;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            
            System.assertEquals(null, layoutController.pageLoad());
        }
    }
    public static void testCampaignSetup() {
		PageReference pageRef = Page.IECEBC_Campaign;
        Test.setCurrentPage(pageRef);

        User usr = initPreRunAs(true);
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
            // Layout PageLoad
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
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
    
    public static void testCampaignListing() {
		PageReference pageRef = Page.IECEBC_CampaignList;
        Test.setCurrentPage(pageRef);
        
        Account newAccount = new Account();
        newAccount.Name = 'Hello World';
        insert newAccount;
        Contact newContact = new Contact();
        newContact.LastName = 'w00t';
        insert newContact;
        
        Zuora__CustomerAccount__c otherBillingAccount = IECTestUtil.createSampleBillingAccount(newAccount, newContact);
        insert otherBillingAccount;  
        
        User usr = initPreRunAs(true);
        
        List<EBC_Campaign__c> campaigns = new List<EBC_Campaign__c>{
            new EBC_Campaign__c(Name = 'Foo Bar 1', Subject__c = 'Foo Bar 1', From_Name__c = 'FooBar1', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Foo Bar 2', Subject__c = 'Foo Bar 2', From_Name__c = 'FooBar2', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Foo Bar 3', Subject__c = 'Foo Bar 3', From_Name__c = 'FooBar3', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Foo Bar 4', Subject__c = 'Foo Bar 4', From_Name__c = 'FooBar4', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Hello World 1', Subject__c = 'Hello World 1', From_Name__c = 'HelloWorld1', Billing_Account__c = otherBillingAccount.Id)
        };
            
        insert campaigns;
        
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
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
    
    public static void testCampaignScheduling() {
        
		PageReference pageRef = Page.IECEBC_CampaignSchedule;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        masterFilter.Audience__c = 'Agency';
        insert masterFilter;
        
        EBC_Template__c tpl = new EBC_Template__c();
        insert tpl;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        System.debug(IECTestUtil_Account.Id);
        camp.Billing_Account__c = oBillingAccount.Id;
        camp.EBC_Master_Filter__c = masterFilter.Id;
        camp.EBC_Design__c = tpl.Id;
        insert camp;
        
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
            // Layout PageLoad
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            
            System.debug(campaignExtCon.campaign);
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
            
        	System.assertEquals(0, ApexPages.getMessages().size());
            
            System.assertEquals(campaignExtCon.con.getId(), pr.getParameters().get('id'));
            System.assertEquals(campaignExtCon.getPRByStepNumber(6, true).getUrl(), pr.getUrl());
        }
    }
    
    public static void testCampaignPreview() {
		PageReference pageRef = Page.IECEBC_CampaignPreview;
        Test.setCurrentPage(pageRef);
        

        User usr = initPreRunAs(true);
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        masterFilter.Audience__c = 'Agency';
        insert masterFilter;
        EBC_Template__c tpl = new EBC_Template__c();
        insert tpl;
        
        String attchBody = 'this is my preview';
        Attachment attch = new Attachment();
        attch.ParentId = tpl.Id;
        attch.Body = Blob.valueOf(attchBody);
        attch.ContentType = 'text/html';
        attch.Name = 'template.xml';
        insert attch;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.EBC_Master_Filter__c = masterFilter.Id;
        camp.EBC_Design__c = tpl.Id;
        insert camp;
        
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
            // Layout PageLoad
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(tpl);
            vfIECEBC_CampaignPreview campaignExtCon = new vfIECEBC_CampaignPreview(sc);
            
            System.assertEquals(attchBody, campaignExtCon.getBody());
        }
    }
    
    public static void testCampaignRecipientsExistingList() {
		PageReference pageRef = Page.IECEBC_CampaignRecipients;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        List<EBC_Master_Filter__c> existingFilters = new List<EBC_Master_Filter__c>{
            new EBC_Master_Filter__c(Audience__c = 'Agency', Billing_Account__c  = oBillingAccount.Id),
            new EBC_Master_Filter__c(Audience__c = 'Agency'), // assign to a different account
            new EBC_Master_Filter__c(Audience__c = 'Agency', Billing_Account__c  = oBillingAccount.Id) // Make sure the count result in 1 result as per described in the assertion
        };
        insert existingFilters;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.Billing_Account__c = oBillingAccount.Id;
        insert camp;
        
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
            // Layout PageLoad
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            vfIECEBC_CampaignRecipient scheduleExtCon = new vfIECEBC_CampaignRecipient(sc);
            
            System.assertEquals(existingFilters.size() - 1, scheduleExtCon.getMasterFilters().size());
            
            scheduleExtCon.campaign.EBC_Master_Filter__c = existingFilters[2].Id;
            Integer lastFilterRecipientCount = vfIECEBC_CampaignRecipient.getExistingFilterCnt(existingFilters[2].Id);
            System.assert(lastFilterRecipientCount >= 1);
            
            PageReference pr = campaignExtCon.saveAndContinue();
            System.assertEquals(0, ApexPages.getMessages().size()); 
            
            System.assertEquals(campaignExtCon.con.getId(), pr.getParameters().get('id'));
            System.assertEquals(campaignExtCon.getPRByStepNumber(3, true).getUrl(), pr.getUrl());
        }
    }
    
    
    /*
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
    
    public static void testCampaignApprovalRejected() {
		PageReference pageRef = Page.IECEBC_CampaignPreview;
        Test.setCurrentPage(pageRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        insert masterFilter;
        EBC_Template__c tpl = new EBC_Template__c();
        insert tpl;
        
        String attchBody = 'this is my preview';
        Attachment attch = new Attachment();
        attch.ParentId = tpl.Id;
        attch.Body = Blob.valueOf(attchBody);
        attch.ContentType = 'text/html';
        attch.Name = 'template.xml';
        insert attch;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.Account__c = IECTestUtil.PortalUserAccountId;
        camp.EBC_Master_Filter__c = masterFilter.Id;
        camp.EBC_Design__c = tpl.Id;
        
        System.runAs(usr) {
        insert camp;
            Test.startTest();
            
            init();
            
            // Layout PageLoad
        	vfIECEBC layoutController = new vfIECEBC();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            campaignExtCon.submitForApproval();
        }
        
        EBC_Campaign__c campResult = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
        
        System.assertEquals('PENDING_APPROVAL', campResult.Status__c);
        
		pageRef = Page.EBC_CampaignApproval;
        Test.setCurrentPage(pageRef); 
         
        ApexPages.StandardController adminSc = new ApexPages.StandardController(camp);
        vfEBC_CampaignApproval campaignApprovalExtCon = new vfEBC_CampaignApproval(adminSc);
        campaignApprovalExtCon.Reject();
        
        campResult = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
        
        System.assertEquals('REJECTED', campResult.Status__c);
    }
    
    public static void testPageLoadAccountSettings() {
		PageReference pageRef = Page.IECEBC_AccountSettings;
        Test.setCurrentPage(pageRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        setup(true);
        
        System.runAs(usr) {
            init();
            
            // Layout PageLoad
        	vfIECEBC layoutController = new vfIECEBC();
            System.assertEquals(null, layoutController.pageLoad());
            
            EBC_Campaign__c camp = new EBC_Campaign__c();
            vfIECEBC_AccountSettings accountSettingsController = new vfIECEBC_AccountSettings();
            
            accountSettingsController.getPreference().Default_From_Name__c = 'helloRandomName';
            
            PageReference pr = accountSettingsController.save();
            
            
            List<ApexPages.Message> messages = ApexPages.getMessages();
            String stringMessages = '';
            for(ApexPages.Message m : messages) {
                stringMessages += m.getSummary() + '\n';
            }
            System.assertEquals('Apex Messages: ', stringMessages);

            
            System.assertEquals(null, pr);
        }
    }

    public static void testCampaignApproval() {
		PageReference pageRef = Page.IECEBC_CampaignPreview;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        masterFilter.Audience__c = 'Agency';
        insert masterFilter;
        EBC_Template__c tpl = new EBC_Template__c();
        insert tpl;
        
        String attchBody = 'this is my preview';
        Attachment attch = new Attachment();
        attch.ParentId = tpl.Id;
        attch.Body = Blob.valueOf(attchBody);
        attch.ContentType = 'text/html';
        attch.Name = 'template.xml';
        insert attch;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.EBC_Master_Filter__c = masterFilter.Id;
        camp.EBC_Design__c = tpl.Id;
        
        insert camp;
        
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
            // Layout PageLoad
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            campaignExtCon.submitForApproval();
        }
        
        EBC_Campaign__c campResult = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
        
        System.assertEquals('PENDING_APPROVAL', campResult.Status__c);
        
		pageRef = Page.EBC_CampaignApproval;
        Test.setCurrentPage(pageRef); 
         
        ApexPages.StandardController adminSc = new ApexPages.StandardController(camp);
        vfEBC_CampaignApproval campaignApprovalExtCon = new vfEBC_CampaignApproval(adminSc);
        campaignApprovalExtCon.Approve();
        
        campResult = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
        
        System.assertEquals('APPROVED', campResult.Status__c);
    }
*/
}