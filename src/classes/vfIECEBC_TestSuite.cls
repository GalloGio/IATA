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
    	IECEBC_TestUtility.createEbcSetupAndRelatedData();
        oProductCategory = IECEBC_TestUtility.oEbcProductCategory;
        
        oProduct = IECEBC_TestUtility.oEbcProductNonMember;
        
        oProductInfo = IECEBC_TestUtility.mProductIdToProductInfoObj.get(oProduct.Id);
        
        oProductRatePlan = IECEBC_TestUtility.lEbcProductRatePlanNonMember[0];
        
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
            layoutController.getSProdCACPro();
            layoutController.getSProdGAD();
            layoutController.getSProdMDP();
            layoutController.getSProdGSS();
            layoutController.getSContactEmail();
            layoutController.getSContactSubject();
            
            vfIECEBC_Dashboard dashboardCon = new vfIECEBC_Dashboard();
            System.assertEquals(4, dashboardCon.campaignsCount);
            
            vfIECEBC_CampaignList campaignListComponent = new vfIECEBC_CampaignList();
            campaignListComponent.isLimitedComponent = true;
            
            System.assertEquals('LastModifiedDate DESC', campaignListComponent.sortBy);
            System.assertEquals(dashboardCon.campaignsCount, campaignListComponent.CampaignsCount);
            System.assertEquals(2, campaignListComponent.campaigns.size());
        }
    }
    public static void testCampaignCreate() {
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
            campaignExtCon.pageLoad();
            
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
    public static void testCampaignCreateAndExit() {
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
            campaignExtCon.pageLoad();
            
            camp.Name = 'Foo Bar';
            camp.Subject__c = 'Foo Subject';
            camp.From_Name__c = 'Foo From Name';
            camp.Is_Google_Analytics_Tracker_Active__c = true;
            camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
            
            PageReference pr = campaignExtCon.saveAndExit();
             
            System.assertNotEquals(null, campaignExtCon.con.getId());
            System.assertEquals(Page.IECEBC_Dashboard.getUrl(), pr.getUrl());
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
            
            vfIECEBC_CampaignList campaignListPageCon = new vfIECEBC_CampaignList();
            System.assertEquals('CreatedDate ASC', campaignListPageCon.sortBy);
            campaignListPageCon.getSortByOptions();
            
            vfIECEBC_CampaignList campaignListComponentCon = new vfIECEBC_CampaignList();
            campaignListComponentCon.isLimitedComponent = false;
            campaignListComponentCon.sortBy = campaignListPageCon.sortBy;
            vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE = campaigns.size() - 1;
            System.assertEquals(campaigns.size() - 1, campaignListComponentCon.campaignsCount);
            System.assert(campaignListComponentCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(1, campaignListComponentCon.page);
            System.assertEquals(1, campaignListComponentCon.maxPage);
            System.assertEquals(campaignListComponentCon.maxPage, campaignListComponentCon.getPageOptions().size());
            System.assertEquals(campaignListComponentCon.getSortByOptions()[0].getValue(), campaignListComponentCon.sortBy);
            System.assertEquals(0, campaignListComponentCon.offset);
            vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE = 3;
            
            campaignListComponentCon = new vfIECEBC_CampaignList();
            campaignListComponentCon.isLimitedComponent = false;
            campaignListComponentCon.sortBy = campaignListPageCon.sortBy;
//            campaignListCon = new vfIECEBC_CampaignList();
            System.assertEquals(campaigns.size() - 1, campaignListComponentCon.campaignsCount);
            System.assert(campaignListComponentCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(1, campaignListComponentCon.page);
            System.assertEquals(2, campaignListComponentCon.maxPage);
            System.assertEquals(campaignListComponentCon.maxPage, campaignListComponentCon.getPageOptions().size());
            System.assertEquals(campaignListComponentCon.getSortByOptions()[0].getValue(), campaignListComponentCon.sortBy);
            System.assertEquals(0, campaignListComponentCon.offset);
            
            campaignListComponentCon.page = 2;
            
            System.assertEquals(campaigns.size() - 1, campaignListComponentCon.campaignsCount);
            System.assert(campaignListComponentCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(2, campaignListComponentCon.page);
            System.assertEquals(2, campaignListComponentCon.maxPage);
            System.assertEquals(campaignListComponentCon.maxPage, campaignListComponentCon.getPageOptions().size());
            System.assertEquals(campaignListComponentCon.getSortByOptions()[0].getValue(), campaignListComponentCon.sortBy);
            System.assertEquals(vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE, campaignListComponentCon.offset);
            
            campaignListComponentCon.sortBy = campaignListComponentCon.getSortByOptions()[1].getValue();
        }

    }

    public static void testCampaignListingActions() {
		PageReference pageRef = Page.IECEBC_CampaignList;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        List<EBC_Campaign__c> campaigns = new List<EBC_Campaign__c>{
            new EBC_Campaign__c(Name = 'Foo Bar 1', Subject__c = 'Foo Bar 1', From_Name__c = 'FooBar1', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Foo Bar 2', Subject__c = 'Foo Bar 2', From_Name__c = 'FooBar2', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Foo Bar 3', Subject__c = 'Foo Bar 3', From_Name__c = 'FooBar3', Billing_Account__c = oBillingAccount.Id),
            new EBC_Campaign__c(Name = 'Foo Bar 4', Subject__c = 'Foo Bar 4', From_Name__c = 'FooBar4', Billing_Account__c = oBillingAccount.Id)
        };
            
        insert campaigns;
        
        System.runAs(usr) {
            initPostRunAs();
        	Test.startTest();
            
        	vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_CampaignList campaignListPageCon = new vfIECEBC_CampaignList();
            
            // Testing 
            vfIECEBC_CampaignList campaignListComponentCon = new vfIECEBC_CampaignList();
            campaignListComponentCon.isLimitedComponent = false;
            campaignListComponentCon.sortBy = campaignListPageCon.sortBy;
            vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE = campaigns.size();
            
         	// Duplicate
         	campaignListComponentCon.selectedCampaignId = campaigns[1].Id;
            campaignListComponentCon.selectedCampaign.Name = 'Duplicate 1';
            PageReference duplicatePR = campaignListComponentCon.duplicate();
            
            EBC_Campaign__c newCampaign = [Select Id, Name, Subject__c, From_Name__c, Billing_Account__c From EBC_Campaign__c Where name = 'Duplicate 1'];
            System.assertEquals(campaignListComponentCon.selectedCampaign.Name, newCampaign.Name);
            System.assertEquals(campaigns[1].Subject__c, newCampaign.Subject__c);
            System.assertEquals(campaigns[1].From_Name__c, newCampaign.From_Name__c);
            System.assertEquals(campaigns[1].Billing_Account__c, newCampaign.Billing_Account__c);
            System.assertNotEquals(campaigns[1].Id, newCampaign.Id);
            System.assertEquals('/iec/IECEBC_Campaign?id=' + newCampaign.Id, duplicatePR.getUrl());
            
            System.assertEquals(campaigns.size(), campaignListComponentCon.campaigns.size());
            campaignListComponentCon = new vfIECEBC_CampaignList();
            campaignListComponentCon.isLimitedComponent = false;
            campaignListComponentCon.sortBy = campaignListPageCon.sortBy;
            vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE = campaigns.size() + 1;
            System.assertEquals(campaigns.size() + 1, campaignListComponentCon.campaignsCount);
            
            // Delete
         	campaignListComponentCon.selectedCampaignId = newCampaign.Id;
            System.debug(campaignListComponentCon.selectedCampaign);
            PageReference deletePR = campaignListComponentCon.deleteCampaign();
            System.assertEquals(null, deletePR);
            System.assertEquals(campaigns.size(), campaignListComponentCon.campaignsCount);
            
            // Rename
         	campaignListComponentCon.selectedCampaignId = campaigns[1].Id;
            campaignListComponentCon.selectedCampaign.Name = 'Updated name 1';
            PageReference savePR = campaignListComponentCon.save();
            System.assertEquals(null, savePR);
            System.assertEquals(campaigns.size(), campaignListComponentCon.campaigns.size());
            EBC_Campaign__c cUpdated = [Select Id, Name From EBC_Campaign__c Where Id = :campaigns[1].Id];
            System.assertEquals('Updated name 1', cUpdated.Name);
            
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
    
    public static void testCampaignTemplate() {
        
		PageReference pageRef = Page.IECEBC_CampaignSchedule;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        masterFilter.Audience__c = 'Agency';
        masterFilter.Billing_Account__c = oBillingAccount.Id;
        insert masterFilter;
        
        EBC_Template__c tpl = new EBC_Template__c();
        insert tpl;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        // Step 1
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.Billing_Account__c = oBillingAccount.Id;
        // Step 2
//        camp.EBC_Master_Filter__c = masterFilter.Id;
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
            vfIECEBC_CampaignRecipient recipientExtCon = new vfIECEBC_CampaignRecipient(sc);
            
            // Check existing list
            List<SelectOption> masterFilters = recipientExtCon.getMasterFilters();
            System.assertEquals(1, masterFilters.size());
            
			// Step 1
            vfIECEBC_RecipientEdit recipientEditCon = new vfIECEBC_RecipientEdit();
            recipientEditCon.campaign = camp;
            System.assertEquals(1, recipientEditCon.newListStepNumber);
            recipientEditCon.newFilter.Audience__c = 'Agency';
            recipientEditCon.reset();
            recipientEditCon.newListStepNumber = 2;
            recipientEditCon.validateNewFilter();
            System.assertEquals(2, recipientEditCon.newListStepNumber);
            
            // Step 2
            for(Id geoFilterPresetId : recipientEditCon.geoFilterPresets.keySet()) {
                EBC_Master_Filter__c f = recipientEditCon.geoFilterPresets.get(geoFilterPresetId);
                if (f.Name == 'Worldwide') {
                    recipientEditCon.geoFilterPreset = geoFilterPresetId;
                    break;
                }
            }
            recipientEditCon.newListStepNumber = 3;
            recipientEditCon.validateNewFilter();
            System.assertEquals(3, recipientEditCon.newListStepNumber);
            
            Integer cnt = vfIECEBC_RecipientEdit.getNewFilterCnt(recipientEditCon.getNewFilterJSON());
            System.assert(cnt > 0);
            recipientEditCon.newFilter.Number_of_Recipients__c = cnt;
            recipientEditCon.newListStepNumber = 4;
            recipientEditCon.validateNewFilter();
            System.assertEquals(4, recipientEditCon.newListStepNumber);
            
            
            recipientEditCon.newFilter.Name = 'New filter name';
            recipientEditCon.save();
            
            EBC_Master_Filter__c nf = [Select Id From EBC_Master_Filter__c Where Name = :recipientEditCon.newFilter.Name];
            EBC_Campaign__c c = [Select Id, EBC_Master_Filter__c From EBC_Campaign__c Where Id = :camp.Id];
            
            System.assertEquals(nf.Id, c.EBC_Master_Filter__c);
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