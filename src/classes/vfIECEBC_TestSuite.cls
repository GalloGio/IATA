public class vfIECEBC_TestSuite {
    public static Account IECTestUtil_Account;
    public static Contact IECTestUtil_Contact;
    public static User IECTestUtil_User;
    public static Id IECTestUtil_UserId;
    public static Zuora__CustomerAccount__c IECTestUtil_BillingAccount;

    public static Product_Category__c oProductCategory;
    public static Product_Information__c oProductInfo;
    public static Product2 oProduct;
    public static zqu__ProductRatePlan__c oProductRatePlan;
    public static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    public static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    public static Zuora__Subscription__c subscription;
    public static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    public static Zuora__CustomerAccount__c oBillingAccount {
        get { return IECTestUtil_BillingAccount; }
    }
    public static EBC_Preference__c oPref;

    public static IECCustomer currentCustomer;

    public static User initPreRunAs(Boolean grantEBCAccess) {
//        User usr = IECTestUtil.createSampleGuestUserAndLogin();
//

        Account a = new Account();
        a.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        a.BillingStreet = '123 main street';
        a.BillingPostalCode = 'H0H 0H0';
        a.BillingCountry = 'Canada';
        a.BillingCity = 'Montreal';
        a.Customer_Type__c = 'Third Party';
        a.Name = 'Company';
        a.OwnerId = '00520000002MSDBAA4';
        insert a;

        Contact c = new Contact();
        c.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        c.AccountId = a.Id;
        c.OwnerId = a.OwnerId;
        c.FirstName = 'Test';
        c.LastName = 'User';
        c.Title = 'TestTitle';
        c.Email = 'testIECGuest@test.iata.org';
        c.Phone = '514123345';
        c.User_IECPortal_Status__c = 'Privilege - Approved';
        insert c;
        system.debug('contact id is ' + c.id);

        Zuora__CustomerAccount__c ba = new Zuora__CustomerAccount__c(
            Zuora__Account__c = a.Id
                                , Contact__c = c.Id
                                               , Name = a.Name
                                                       , CRMContactID__c = String.valueOf(c.Id)
                                                               , Zuora__DefaultPaymentMethod__c = 'CreditCard'
                                                                       , Zuora__BillToCity__c = 'Toronto'
                                                                               , Zuora__BillToCountry__c = 'Canada'
                                                                                       , Zuora__BillToState__c = 'Ontario'
                                                                                               , Zuora__BillToAddress1__c = '123 Test St'
                                                                                                       , Zuora__BillToPostalCode__c = 'A9A9A9'
        );

        if (grantEBCAccess) {
            ba.eBroadcast_Product_Access__c = true;
        }
        insert ba;



        User usr = new User(
            Username = 'testIECGuest.test.iata.org@partner.iata.org'
                       , Email = 'testIECGuest@test.iata.org'
                                 , emailencodingkey = 'UTF-8'
                                         , Alias = 'testu'
                                                 , FirstName = c.FirstName
                                                         , LastName = c.LastName
                                                                 , LocaleSidKey = 'en_US'
                                                                         , CommunityNickname = 'testIECGuest@iata.org'
                                                                                 , ProfileId = [Select Id From Profile p where p.Name = 'ISS Portal (Partner)'].Id
                                                                                         , LanguageLocaleKey = 'en_US'
                                                                                                 , timezonesidkey = 'America/New_York'
                                                                                                         , ContactId = c.Id
                                                                                                                 , IsActive = true
                                                                                                                         , ReceivesAdminInfoEmails = false
                                                                                                                                 , ReceivesInfoEmails = false
        );
        insert usr;


        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        String userId = Site.createPortalUser(usr, a.Id, 'testpassword');
        IECUserManager.login(usr.Username, 'testpassword', null);

        IECTestUtil_Account = a;
        IECTestUtil_Contact = c;
        IECTestUtil_BillingAccount = ba;
        IECTestUtil_User = usr;
        IECTestUtil_UserId = userId;


        return usr;
    }

    public static void initPostRunAs() {
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
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;

        oPref = new EBC_Preference__c(Billing_Account__c = IECTestUtil_BillingAccount.Id, PrimaryContact_Email__c = 'hello@world.com', Default_From_Name__c = 'w00t', PrimaryContact_Name__c = 'w00t');

        insert oPref;
    }

    public static List<GDP_Products_Account_View__c> createGDPProductsAccountViews() {
        GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
        insert grt;
        Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
        insert accr;

        List<GDP_Products_Account_View__c> gpavs = new List<GDP_Products_Account_View__c> {
            new GDP_Products_Account_View__c(Name = 'a',                Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'a@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c = '111110911'),
            new GDP_Products_Account_View__c(Name = 'b',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'b@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c = '111110912'),
            new GDP_Products_Account_View__c(Name = 'c',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'c@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c = '111110913'),
            new GDP_Products_Account_View__c(Name = 'd',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'd@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c = '111110914'),
            new GDP_Products_Account_View__c(Name = 'e',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'e@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c = '111110915'),
            new GDP_Products_Account_View__c(Name = 'f',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'f@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c = '111110916'),
            new GDP_Products_Account_View__c(Name = 'notincluded',  Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'notincluded@b.com', Preferred_Language__c = 'X1',    IATA_Code__c = '111110917'),
            new GDP_Products_Account_View__c(Name = 'optout',       Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = false,  Email_Address__c = 'optout@b.com',      Preferred_Language__c = 'X0',    IATA_Code__c = '111110918'),
            new GDP_Products_Account_View__c(Name = 'duplicate',    Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'duplicate@b.com',   Preferred_Language__c = 'X0',    IATA_Code__c = '111110919'),
            new GDP_Products_Account_View__c(Name = 'duplicate1',   Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'duplicate@b.com',   Preferred_Language__c = 'X0',    IATA_Code__c = '111110920')
        };
        insert gpavs;
        return gpavs;
    }
    public static List<ID_CARD__c> createIDCARD(id ProductAccountViewId) {

        List<ID_CARD__c> gpavs = new List<ID_CARD__c> {
            new ID_CARD__c(Valid_From_Date__c = System.Today(), Valid_To_Date__c = System.Today().AddDays(2), Opt_in__c = true, Name_on_ID_Card__c = 'IATA1', Agency_Name__c = 'IATA', Card_Status__c = 'Sent ID Card', GDP_Products_Account_View__c = ProductAccountViewId, Email__c = 'ldebono@iata.org', firstname__c = 'Luc', lastname__c = 'Debono', Agency_IATA_Code__c = '11111092'),
            new ID_CARD__c(Valid_From_Date__c = System.Today(), Valid_To_Date__c = System.Today().AddDays(2), Opt_in__c = true, Name_on_ID_Card__c = 'IATA2', Agency_Name__c = 'IATA', Card_Status__c = 'Sent ID Card', GDP_Products_Account_View__c = ProductAccountViewId, Email__c = 'ldebono@iata.org', firstname__c = 'Luc', lastname__c = 'Debono', Agency_IATA_Code__c = '11111092'),
            new ID_CARD__c(Valid_From_Date__c = System.Today(), Valid_To_Date__c = System.Today().AddDays(2), Opt_in__c = true, Name_on_ID_Card__c = 'IATA3', Agency_Name__c = 'IATA', Card_Status__c = 'Sent ID Card', GDP_Products_Account_View__c = ProductAccountViewId, Email__c = 'ldebono@iata.org', firstname__c = 'Luc', lastname__c = 'Debono', Agency_IATA_Code__c = '11111092'),
            new ID_CARD__c(Valid_From_Date__c = System.Today(), Valid_To_Date__c = System.Today().AddDays(2), Opt_in__c = true, Name_on_ID_Card__c = 'IATA4', Agency_Name__c = 'IATA', Card_Status__c = 'Sent ID Card', GDP_Products_Account_View__c = ProductAccountViewId, Email__c = 'ldebono@iata.org', firstname__c = 'Luc', lastname__c = 'Debono', Agency_IATA_Code__c = '11111092')
        };
        insert gpavs;
        return gpavs;
    }
    //////////////////// TESTS /////////////////////
    public static void testPageLoadDashboard() {
        PageReference pageRef = Page.IECEBC_Dashboard;
        Test.setCurrentPage(pageRef);

        Account newAccount = new Account();
        newAccount.Name = 'Hello World';
        insert newAccount;
        Contact newContact = new Contact();
        newContact.FirstName = 'Name';
        newContact.Phone = '5142640908';
        newContact.Email = 'dashboard@iata.com';
        newContact.LastName = 'w00t';
        insert newContact;

        Zuora__CustomerAccount__c otherBillingAccount = IECTestUtil.createSampleBillingAccount(newAccount, newContact);
        insert otherBillingAccount;

        User usr = initPreRunAs(true);

        List<EBC_Campaign__c> campaigns = new List<EBC_Campaign__c> {
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
        newContact.FirstName = 'Name';
        newContact.Phone = '5142640908';
        newContact.Email = 'campaigns@iata.com';
        newContact.LastName = 'w00t';
        insert newContact;

        Zuora__CustomerAccount__c otherBillingAccount = IECTestUtil.createSampleBillingAccount(newAccount, newContact);
        insert otherBillingAccount;

        User usr = initPreRunAs(true);

        List<EBC_Campaign__c> campaigns = new List<EBC_Campaign__c> {
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
            System.assertEquals(0, campaignListComponentCon.offset);

            campaignListComponentCon.page = 2;

            System.assertEquals(campaigns.size() - 1, campaignListComponentCon.campaignsCount);
            System.assert(campaignListComponentCon.campaigns.size() <= vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE);
            System.assertEquals(2, campaignListComponentCon.page);
            System.assertEquals(2, campaignListComponentCon.maxPage);
            System.assertEquals(campaignListComponentCon.maxPage, campaignListComponentCon.getPageOptions().size());
            System.assertEquals(vfIECEBC_CampaignList.CAMPAIGNS_PER_PAGE, campaignListComponentCon.offset);

            campaignListComponentCon.sortBy = campaignListComponentCon.getSortByOptions()[1].getValue();
        }

    }

    public static void testCampaignListingActions() {
        PageReference pageRef = Page.IECEBC_CampaignList;
        Test.setCurrentPage(pageRef);

        User usr = initPreRunAs(true);

        List<EBC_Campaign__c> campaigns = new List<EBC_Campaign__c> {
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
            System.debug('duplicatePR.getUrl()>>>' + String.ValueOf(duplicatePR.getUrl()));
            System.assertEquals('/apex/IECEBC_Campaign?id=' + newCampaign.Id, duplicatePR.getUrl());

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

            //saveAsTemplate() coverage
            PageReference pref = campaignExtCon.saveAsTemplate();

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
            //System.assertNotEquals(null, scheduleExtCon.validationMessage);
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
    public static void testCampaignConfirmUpdateCount() {

        User usr = initPreRunAs(true);

        IECTestUtil_BillingAccount.eBroadcast_Trusted_Sender__c = true;
        update IECTestUtil_BillingAccount;

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = IECTestUtil_BillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency');
        insert masterFilter;
        EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
        insert cf;
        EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true);
        insert tpl;
        EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id);
        insert camp;
        /*
        List<GDP_Products_Account_View__c> gpavs = new List<GDP_Products_Account_View__c>{
            new GDP_Products_Account_View__c(Name = 'a',            GDP_Opt_In__c = true,   Email_Address__c = 'a@b.com',           Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'b',            GDP_Opt_In__c = true,   Email_Address__c = 'b@b.com',           Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'c',            GDP_Opt_In__c = true,   Email_Address__c = 'c@b.com',           Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'd',            GDP_Opt_In__c = true,   Email_Address__c = 'd@b.com',           Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'e',            GDP_Opt_In__c = true,   Email_Address__c = 'e@b.com',           Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'f',            GDP_Opt_In__c = true,   Email_Address__c = 'f@b.com',           Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'notincluded',  GDP_Opt_In__c = true,   Email_Address__c = 'notincluded@b.com', Preferred_Language__c = 'X1'),
            new GDP_Products_Account_View__c(Name = 'optout',       GDP_Opt_In__c = false,  Email_Address__c = 'optout@b.com',      Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'duplicate',    GDP_Opt_In__c = true,   Email_Address__c = 'duplicate@b.com',   Preferred_Language__c = 'X0'),
            new GDP_Products_Account_View__c(Name = 'duplicate1',   GDP_Opt_In__c = true,   Email_Address__c = 'duplicate@b.com',   Preferred_Language__c = 'X0')
        };
        insert gpavs;*/

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        PageReference pageRef = Page.IECEBC_CampaignConfirm;
        pageRef.getParameters().put('id', camp.Id);
        Test.setCurrentPage(pageRef);

        camp = [
                   SELECT
                   Id,
                   Name,
                   EBC_Master_Filter__c,
                   Audience__c,
                   EBC_Design__c,
                   From_Name__c,
                   Google_Analytics_Tracking_Code__c,
                   Is_Google_Analytics_Tracker_Active__c,
                   Is_Step1_Valid__c, Is_Step2_Valid__c, Is_Step3_Valid__c, Is_Step4_Valid__c , Is_Step5_Valid__c , Is_Step6_Valid__c,
                   Maximum_Allowed_Step__c,
                   Billing_Account__c,
                   Number_of_Recipients__c,
                   Scheduled_Date__c,
                   Scheduled_Date_Valid_Until__c,
                   Status__c,
                   Subject__c
                   FROM
                   EBC_Campaign__c
                   WHERE
                   Id = :camp.Id
               ];

        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CampaignPayWithCredit_Mock());

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            System.assertEquals(7, campaignExtCon.campaign.Maximum_Allowed_Step__c);

            PageReference pageLoadPR = campaignExtCon.pageLoad();
            //System.assertEquals(pageRef.getUrl().toLowerCase(), pageLoadPR.getUrl().toLowerCase());
        }
    }

    public static void testCampaignSendMassMailing() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;

        GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
        insert grt;
        Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
        insert accr;

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();


        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        System.runAs(usr) {
            initPostRunAs();
            Test.setMock(HttpCalloutMock.class, new ET_SendMassMailingSuccess_Mock());


            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', Billing_Account__c = oBillingAccount.Id, OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Status__c = 'APPROVED', Send_Datetime__c = Datetime.now());
            insert camp;


            Test.startTest();

            SchdlIECEBCStartCampaign.prepare(camp, 'test', 'test', 'test', 'test', 'test');
            SchdlIECEBCStartCampaign.Schedule(null);
            Test.stopTest();

        }
    }

    public static void testElasticQuery() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;

        GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
        insert grt;
        Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
        insert accr;

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();
        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        System.runAs(usr) {
            initPostRunAs();

            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', Billing_Account__c = oBillingAccount.Id, OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Status__c = 'APPROVED', Send_Datetime__c = Datetime.now());
            insert camp;
            Test.startTest();

            boolean elastic_switch = true;
            String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, camp.EBC_Master_Filter__c, elastic_switch);
            IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter();
            Integer counter = req.execute(cntQuery, true);
            Test.stopTest();

        }
    }



    public static void testCampaignIDCardSendMassMailing() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;

        GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
        insert grt;
        Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
        insert accr;

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();
        List<ID_CARD__c> gidcard = createIDCARD(gpavs[0].Id);

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id,
                New_Balance__c = 1000,
                Total_Count__c = 1000,
                Activity_Type__c = 'Credit',
                Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agent',
                Search_Level__c = null,
                Filter_Description__c = 'Preferred Language',
                Data_Type__c = 'Text',
                Filter_Field__c = 'Agency_Name__c');
        insert af;

        System.runAs(usr) {
            initPostRunAs();

            Test.setMock(HttpCalloutMock.class, new ET_SendMassMailingSuccess_Mock());


            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agent',
                    Billing_Account__c = oBillingAccount.Id,
                    OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id,
                    EBC_Application_Filter__c = af.Id,
                    Field_Operator__c = '=',
                    Field_Value__c = 'IATA');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar',
                    Number_of_Recipients__c = 4,
                    Subject__c = 'Foo Subject',
                    From_Name__c = 'Foo From Name',
                    Is_Google_Analytics_Tracker_Active__c = true,
                    Google_Analytics_Tracking_Code__c = 'UA-XXXXXX',
                    Billing_Account__c = oBillingAccount.Id,
                    EBC_Master_Filter__c = masterFilter.Id,
                    EBC_Design__c = tpl.Id,
                    OwnerId = usr.Id,
                    Status__c = 'APPROVED',
                    Send_Datetime__c = Datetime.now());
            insert camp;

            Test.startTest();

            SchdlIECEBCStartCampaign.prepare(camp, 'test', 'test', 'test', 'test', 'test');
            SchdlIECEBCStartCampaign.Schedule(null);
            Test.stopTest();

        }
    }
    /*
     * Test the Fix ID CARD batch. relation between ID CARD and GDP Product Account View
     */
    public static void testFixIDCard() {
        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();
        List<ID_CARD__c> gidcard = createIDCARD(null);

        Test.startTest();
        SchdlEBCFixIdCardAgencyLink.prepare();
        SchdlEBCFixIdCardAgencyLink.Schedule(null);
        Test.stopTest();
    }

    public static void testCampaignPayWithCreditTrusted() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        System.runAs(usr) {
            initPostRunAs();


            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id);
            insert camp;

            PageReference pageRef = Page.IECEBC_CampaignConfirm;
            pageRef.getParameters().put('id', camp.Id);
            Test.setCurrentPage(pageRef);

            camp = [
                       SELECT
                       Id,
                       Name,
                       EBC_Master_Filter__c,
                       Audience__c,
                       EBC_Design__c,
                       From_Name__c,
                       Google_Analytics_Tracking_Code__c,
                       Is_Google_Analytics_Tracker_Active__c,
                       Is_Step1_Valid__c, Is_Step2_Valid__c, Is_Step3_Valid__c, Is_Step4_Valid__c , Is_Step5_Valid__c , Is_Step6_Valid__c,
                       Maximum_Allowed_Step__c,
                       Billing_Account__c,
                       Number_of_Recipients__c,
                       Scheduled_Date__c,
                       Scheduled_Date_Valid_Until__c,
                       Status__c,
                       Subject__c
                       FROM
                       EBC_Campaign__c
                       WHERE
                       Id = :camp.Id
                   ];


            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CampaignPayWithCredit_Mock());

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            System.assertEquals(7, campaignExtCon.campaign.Maximum_Allowed_Step__c);
            sc = new ApexPages.StandardController(camp);
            campaignExtCon = new vfIECEBC_Campaign(sc);
            vfIECEBC_Cart cartExtCon = new vfIECEBC_Cart(sc);
            ApexPages.currentPage().getParameters().put('id', camp.Id);
            vfIECEBC_CampaignConfirm confExtCon = new vfIECEBC_CampaignConfirm(sc);

            System.assertEquals(7, campaignExtCon.numberOfRecipients);
            System.assertEquals(1000, campaignExtCon.billingAccount.eBroadcast_Email_Balance__c);
            System.assertEquals(993, confExtCon.absoluteNewEmailBalance);

            PageReference prDebit = confExtCon.debitCredits();

            EBC_Campaign__c cPostDebit = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
            System.assertEquals('APPROVED', cPostDebit.Status__c);

            vfIECEBC_CampaignList campaignListComponent = new vfIECEBC_CampaignList();
            campaignListComponent.isLimitedComponent = true;
            campaignListComponent.selectedCampaignId = camp.Id;
            campaignListComponent.cancel();

            cPostDebit = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
            System.assertEquals('DRAFT', cPostDebit.Status__c);

//            cancel


        }
    }
    public static void testCampaignPayWithCreditNotTrusted() {

        User usr = initPreRunAs(true);

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        System.runAs(usr) {
            initPostRunAs();


            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Scheduled_Date__c = Datetime.now().addDays(5), Scheduled_Date_Valid_Until__c = Datetime.now().addDays(5));
            insert camp;

            PageReference pageRef = Page.IECEBC_CampaignConfirm;
            pageRef.getParameters().put('id', camp.Id);
            Test.setCurrentPage(pageRef);

            camp = [
                       SELECT
                       Id,
                       Name,
                       EBC_Master_Filter__c,
                       Audience__c,
                       EBC_Design__c,
                       From_Name__c,
                       Google_Analytics_Tracking_Code__c,
                       Is_Google_Analytics_Tracker_Active__c,
                       Is_Step1_Valid__c, Is_Step2_Valid__c, Is_Step3_Valid__c, Is_Step4_Valid__c , Is_Step5_Valid__c , Is_Step6_Valid__c,
                       Maximum_Allowed_Step__c,
                       Billing_Account__c,
                       Number_of_Recipients__c,
                       Scheduled_Date__c,
                       Scheduled_Date_Valid_Until__c,
                       Status__c,
                       Subject__c
                       FROM
                       EBC_Campaign__c
                       WHERE
                       Id = :camp.Id
                   ];


            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CampaignPayWithCredit_Mock());

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            System.assertEquals(7, campaignExtCon.campaign.Maximum_Allowed_Step__c);
            sc = new ApexPages.StandardController(camp);
            campaignExtCon = new vfIECEBC_Campaign(sc);
            vfIECEBC_Cart cartExtCon = new vfIECEBC_Cart(sc);
            ApexPages.currentPage().getParameters().put('id', camp.Id);
            vfIECEBC_CampaignConfirm confExtCon = new vfIECEBC_CampaignConfirm(sc);

            System.assertEquals(7, campaignExtCon.numberOfRecipients);
            System.assertEquals(1000, campaignExtCon.billingAccount.eBroadcast_Email_Balance__c);
            System.assertEquals(993, confExtCon.absoluteNewEmailBalance);

            PageReference prDebit = confExtCon.debitCredits();

            EBC_Campaign__c cPostDebit = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
            System.assertEquals('PENDING_APPROVAL', cPostDebit.Status__c);

            vfIECEBC_CampaignList campaignListComponent = new vfIECEBC_CampaignList();
            campaignListComponent.isLimitedComponent = true;
            campaignListComponent.selectedCampaignId = camp.Id;
            campaignListComponent.cancel();

            cPostDebit = [Select Id, Status__c From EBC_Campaign__c Where Id = :camp.Id];
            System.assertEquals('DRAFT', cPostDebit.Status__c);

//            cancel


        }
    }
    public static void testCampaignConfirm() {

        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = IECEBC_TestUtility.oBillingAccount.Id, New_Balance__c = 0, Total_Count__c = 0, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

//        System.runAs(usr) {
        System.runAs(IECEBC_TestUtility.oUser) {
            User usr = IECEBC_TestUtility.oUser;
            vfIECEBC_TestPaymentSuite.initPostRunAs(5);


            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = IECEBC_TestUtility.oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Scheduled_Date__c = Datetime.now().addDays(5), Scheduled_Date_Valid_Until__c = Datetime.now().addDays(5));
            insert camp;

            PageReference pageRef = Page.IECEBC_CampaignConfirm;
            pageRef.getParameters().put('id', camp.Id);
            Test.setCurrentPage(pageRef);

            camp = [
                       SELECT
                       Id,
                       Name,
                       EBC_Master_Filter__c,
                       Audience__c,
                       EBC_Design__c,
                       From_Name__c,
                       Google_Analytics_Tracking_Code__c,
                       Is_Google_Analytics_Tracker_Active__c,
                       Is_Step1_Valid__c, Is_Step2_Valid__c, Is_Step3_Valid__c, Is_Step4_Valid__c , Is_Step5_Valid__c , Is_Step6_Valid__c,
                       Maximum_Allowed_Step__c,
                       Billing_Account__c,
                       Number_of_Recipients__c,
                       Scheduled_Date__c,
                       Scheduled_Date_Valid_Until__c,
                       Status__c,
                       Subject__c
                       FROM
                       EBC_Campaign__c
                       WHERE
                       Id = :camp.Id
                   ];


            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CampaignPayWithCredit_Mock());

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            System.assertEquals(7, campaignExtCon.campaign.Maximum_Allowed_Step__c);
            sc = new ApexPages.StandardController(camp);
            campaignExtCon = new vfIECEBC_Campaign(sc);
            vfIECEBC_Cart cartExtCon = new vfIECEBC_Cart(sc);
            ApexPages.currentPage().getParameters().put('id', camp.Id);
            vfIECEBC_CampaignConfirm confExtCon = new vfIECEBC_CampaignConfirm(sc);

            confExtCon.clickPayWithEmailPackage();
            confExtCon.clickPayWithExactAmount();
            confExtCon.clickPayWithRatePlan();

            System.assertNotEquals(null, confExtCon.newBalanceLabel);
            System.assertNotEquals(null, confExtCon.showPaymentItemMessage);
            System.assertNotEquals(null, confExtCon.showPaymentItemEmailCredit);
            System.assertNotEquals(null, confExtCon.showPaymentItemRatePlan);
            System.assertNotEquals(null, confExtCon.emailCreditPurchased);
            System.assertNotEquals(null, confExtCon.emailUnitCost);
            System.assertNotEquals(null, confExtCon.paymentItemDescription);
            System.assertNotEquals(null, confExtCon.paymentItemAmount);
            System.assertNotEquals(null, confExtCon.totalPurchaseAmount);
        }
    }

    public static void testTemplateNew() {
        PageReference pageRef = Page.IECEBC_TemplateNew;
        Test.setCurrentPage(pageRef);

        User usr = initPreRunAs(true);

        EBC_Template__c tpl = new EBC_Template__c();
        tpl.Name = 'unittesttemplate';
        tpl.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global');
        insert tpl;

        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            vfIECEBC_TemplateList listController = new vfIECEBC_TemplateList();
            System.assertEquals(1, listController.newTemplateStepNumber);
            listController.newTemplate.Audience__c = 'Agency';
            listController.newTemplateStepNumber = 2;
            listController.validateNewTemplate();

            System.assertEquals(2, listController.newTemplateStepNumber);

            vfIECEBC_TemplateCreation compController = new vfIECEBC_TemplateCreation();
            compController.audience = listController.newTemplate.Audience__c;
            System.assert(compController.globalTemplates.size() > 0);
            for (EBC_Template__c t : compController.globalTemplates) {
                if (t.Name == 'unittesttemplate') {
                    listController.selectedTemplateId = t.Id;
                    break;
                }
            }
            listController.newTemplateStepNumber = 3;
            listController.validateNewTemplate();

            System.assertEquals(3, listController.newTemplateStepNumber);
            listController.newTemplate.Name = 'Test';
            listController.newTemplateStepNumber = 4;
            PageReference pr = listController.createTemplate();

            System.assertEquals(4, listController.newTemplateStepNumber);
            System.assertEquals(true, listController.isSaved);
            System.debug('duplicatePR.getUrl() >>>' + String.ValueOf(pr.getUrl()));
            System.assertEquals('/apex/IECEBC_TemplateEdit?id=' + listController.newTemplate.Id, pr.getUrl());

            pageRef = Page.IECEBC_MosaicoEditor;
            pageRef.getParameters().put('Id', listController.newTemplate.Id);
            Test.setCurrentPage(pr);

            ApexPages.StandardController sc = new ApexPages.StandardController(listController.newTemplate);
            vfIECEBC_MosaicoEditor mosaicoCon = new vfIECEBC_MosaicoEditor(sc);

            vfIECEBC_MosaicoEditor.saveTemplate(mosaicoCon.template.Id, '{metadata: ""}', '{content: ""}', '<html>test</html>');
        }
    }
    public static void testMosaicoEditorSendTestSuccess() {
        EBC_Template__c parentTpl = new EBC_Template__c();
        parentTpl.Name = 'unittesttemplate';
        parentTpl.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global');
        insert parentTpl;

        EBC_Template__c childTpl = new EBC_Template__c();
        childTpl.Name = 'User tpl';
        childTpl.Parent_Template__c = parentTpl.Id;
        childTpl.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'User_Templates');
        insert childTpl;

        PageReference pageRef = Page.IECEBC_MosaicoEditor;
        pageRef.getParameters().put('Id', childTpl.Id);
        Test.setCurrentPage(pageRef);

        User usr = initPreRunAs(true);

        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            ApexPages.StandardController sc = new ApexPages.StandardController(childTpl);
            vfIECEBC_MosaicoEditor mosaicoCon = new vfIECEBC_MosaicoEditor(sc);

            Test.setMock(HttpCalloutMock.class, new ET_SendTestSuccess_Mock());
            vfIECEBC_MosaicoEditor.sendTest(childTpl.Id, 'foo@bar.com');
        }
    }

    public static void testMosaicoEditorSendTestListDetective() {
        EBC_Template__c parentTpl = new EBC_Template__c();
        parentTpl.Name = 'unittesttemplate';
        parentTpl.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global');
        insert parentTpl;

        EBC_Template__c childTpl = new EBC_Template__c();
        childTpl.Name = 'User tpl';
        childTpl.Parent_Template__c = parentTpl.Id;
        childTpl.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'User_Templates');
        insert childTpl;

        PageReference pageRef = Page.IECEBC_MosaicoEditor;
        pageRef.getParameters().put('Id', childTpl.Id);
        Test.setCurrentPage(pageRef);

        User usr = initPreRunAs(true);

        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();

            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());

            ApexPages.StandardController sc = new ApexPages.StandardController(childTpl);
            vfIECEBC_MosaicoEditor mosaicoCon = new vfIECEBC_MosaicoEditor(sc);

            Test.setMock(HttpCalloutMock.class, new ET_SendTestListDetective_Mock());
            Boolean IsAsExpected = false;
            try {
                vfIECEBC_MosaicoEditor.sendTest(childTpl.Id, 'foo@bar.com');
            } catch (Exception e) {
                IsAsExpected = true;
            }
            System.assertEquals(true, IsAsExpected);
        }
    }


    public static void testCampaignTemplate() {

        PageReference pageRef = Page.IECEBC_CampaignSchedule;
        Test.setCurrentPage(pageRef);
        IEC_SEttings__c customsetting = [Select eBroadcast_Counter_AWS_API_KEY__c, eBroadcast_Counter_AWS_URL__c, eBroadcast_Counter_Switch__c
                                         From IEC_SEttings__c limit 1];
        if (customsetting == null) customsetting = new IEC_SEttings__c();
        customsetting.eBroadcast_Counter_Switch__c = false;

        upsert customsetting;

        User usr = initPreRunAs(true);

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

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
            for (Id geoFilterPresetId : recipientEditCon.geoFilterPresets.keySet()) {
                EBC_Master_Filter__c f = recipientEditCon.geoFilterPresets.get(geoFilterPresetId);
                if (f.Name == 'Worldwide') {
                    recipientEditCon.geoFilterPreset = geoFilterPresetId;
                    break;
                }
            }
            recipientEditCon.newListStepNumber = 3;
            recipientEditCon.validateNewFilter();
            System.assertEquals(3, recipientEditCon.newListStepNumber);

            recipientEditCon.newFilter.Name = 'EBC_TEST_RUN';
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

        List<EBC_Master_Filter__c> existingFilters = new List<EBC_Master_Filter__c> {
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
            /*Integer lastFilterRecipientCount = vfIECEBC_CampaignRecipient.getExistingFilterCnt(existingFilters[2].Id);
            System.assert(lastFilterRecipientCount >= 1);*/

            PageReference pr = campaignExtCon.saveAndContinue();
            System.assertEquals(0, ApexPages.getMessages().size());

            System.assertEquals(campaignExtCon.con.getId(), pr.getParameters().get('id'));
            System.assertEquals(campaignExtCon.getPRByStepNumber(3, true).getUrl(), pr.getUrl());
        }
    }

    public static void testCampaignRecipientsExistingListMock() {
        PageReference pageRef = Page.IECEBC_CampaignRecipients;
        Test.setCurrentPage(pageRef);


        IEC_SEttings__c customsetting = [Select eBroadcast_Counter_AWS_API_KEY__c, eBroadcast_Counter_AWS_URL__c, eBroadcast_Counter_Switch__c
                                         From IEC_SEttings__c limit 1];
        if (customsetting == null) customsetting = new IEC_SEttings__c();
        customsetting.eBroadcast_Counter_AWS_API_KEY__c = 'Sr96oKUqaap4CXicrEMl5NXp6SerQNsAg701Gnf0';
        customsetting.eBroadcast_Counter_AWS_URL__c = 'https://rb5luiyoea.execute-api.eu-west-1.amazonaws.com/prod/TestElasticSearchQuery';
        customsetting.eBroadcast_Counter_Switch__c = true;

        upsert customsetting;

        User usr = initPreRunAs(true);

        List<EBC_Master_Filter__c> existingFilters = new List<EBC_Master_Filter__c> {
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
            Test.setMock(HttpCalloutMock.class, new vfIECEBC_TestSuiteMock());
            //existingFilters[2].Id;

            Integer lastFilterRecipientCount = vfIECEBC_CampaignRecipient.getCounter(existingFilters[2].Id);
            lastFilterRecipientCount = vfIECEBC_CampaignRecipient.getExistingFilterCnt(existingFilters[2].Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_CampaignRecipient campaignExtCon = new vfIECEBC_CampaignRecipient(sc);

            campaignExtCon.getMasterFilters();
        }
    }
    public static void testRecipientsCountExistingListMock() {
        PageReference pageRef = Page.IECEBC_CampaignRecipients;
        Test.setCurrentPage(pageRef);
        IEC_SEttings__c customsetting = [Select eBroadcast_Counter_AWS_API_KEY__c, eBroadcast_Counter_AWS_URL__c, eBroadcast_Counter_Switch__c
                                         From IEC_SEttings__c limit 1];
        if (customsetting == null) customsetting = new IEC_SEttings__c();
        customsetting.eBroadcast_Counter_AWS_API_KEY__c = 'Sr96oKUqaap4CXicrEMl5NXp6SerQNsAg701Gnf0';
        customsetting.eBroadcast_Counter_AWS_URL__c = 'https://rb5luiyoea.execute-api.eu-west-1.amazonaws.com/prod/TestElasticSearchQuery';
        customsetting.eBroadcast_Counter_Switch__c = true;

        upsert customsetting;
        User usr = initPreRunAs(true);

        List<EBC_Master_Filter__c> existingFilters = new List<EBC_Master_Filter__c> {
            new EBC_Master_Filter__c(Audience__c = 'Agency', Billing_Account__c  = oBillingAccount.Id),
            new EBC_Master_Filter__c(Audience__c = 'Agency'), // assign to a different account
            new EBC_Master_Filter__c(Audience__c = 'Agency', Billing_Account__c  = oBillingAccount.Id) // Make sure the count result in 1 result as per described in the assertion
        };
        insert existingFilters;
        System.currentPageReference().getParameters().put('id', existingFilters[2].Id);


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
            Test.setMock(HttpCalloutMock.class, new vfIECEBC_TestSuiteMock());
            //existingFilters[2].Id;

            Integer lastFilterRecipientCount = restIECEBC_RecipientsCount.getCount(existingFilters[2].Id);
            lastFilterRecipientCount = restIECEBC_RecipientsCount.doGet();

            restIECEBC_RecipientsCount campaignExtCon = new restIECEBC_RecipientsCount();

            campaignExtCon.getCount();

        }

    }
    class vfIECEBC_TestSuiteMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"counter":6}');
            res.setStatusCode(200);
            return res;
        }
    }



    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2024';

    public static void testOptOut() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;

        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        System.runAs(usr) {
            initPostRunAs();


            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Status__c = 'SENT');
            insert camp;

            PageReference pageRef = Page.iecebc_optout;
            pageRef.getParameters().put('c', IECUtil.EncryptParameter(camp.Id));
            pageRef.getParameters().put('e', IECUtil.EncryptParameter(gpavs[0].Email_Address__c));
            pageRef.getParameters().put('bai', IECUtil.EncryptParameter(camp.Billing_Account__c));
            pageRef.getParameters().put('ban', IECUtil.EncryptParameter('Foo Bar'));
            Test.setCurrentPage(pageRef);


            Test.startTest();
            vfIECEBC_OptOut con = new vfIECEBC_OptOut();

            System.assertEquals(gpavs[0].Email_Address__c, con.email);
            System.assertEquals('Foo Bar', con.billingAccountName);

            con.sender = con.billingAccountId;
            //con.reasons.put('The content is not relevant to me', true);
            con.getemailurl();
            con.reasons.put('The content is not relevant for me', true);
            PageReference pr = con.unsubscribe();

            //
            // Schedule the test job
            String jobId = System.schedule('SchdlIECEBCEmailExclusionRelation',
                                           CRON_EXP,
                                           new SchdlIECEBCEmailExclusionRelation());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id
                              , CronExpression
                              , TimesTriggered
                              , NextFireTime
                              FROM CronTrigger
                              WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);

            // Verify the next time the job will run
            System.assertEquals('2024-03-15 00:00:00', String.valueOf(ct.NextFireTime));
            //
            System.abortJob(jobId);
            //old code SchdlIECEBCEmailExclusionRelation.Schedule();
            Test.stopTest();

        }
    }

    public static void testResubscribe() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;
       
        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
        insert masterFilter;
        EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
        insert cf;
        EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
        insert tpl;
        EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Status__c = 'SENT');
        insert camp;

        EBC_Email_Exclusion__c ee = new EBC_Email_Exclusion__c(Email__c = gpavs[8].Email_Address__c, Unsubscribe_From__c = oBillingAccount.Id, Type__c = 'OPTOUT');
        insert ee;
        System.debug(ee);


        List<EBC_Email_Exclusion_Relation__c> eers = new List<EBC_Email_Exclusion_Relation__c> {
            new EBC_Email_Exclusion_Relation__c(Billing_Account__c  = oBillingAccount.Id, EBC_Email_Exclusion__c = ee.Id, External_Id__c = ee.Email__c.toLowerCase() + '_' + gpavs[8].Id + '_' + ee.Unsubscribe_From__c, GDP_Products_Account_View__c = gpavs[8].Id, Is_Global__c = false),
            new EBC_Email_Exclusion_Relation__c(Billing_Account__c  = oBillingAccount.Id, EBC_Email_Exclusion__c = ee.Id, External_Id__c = ee.Email__c.toLowerCase() + '_' + gpavs[9].Id + '_' + ee.Unsubscribe_From__c, GDP_Products_Account_View__c = gpavs[9].Id, Is_Global__c = false)
        };
        insert eers;


        System.runAs(usr) {
            initPostRunAs();



            PageReference pageRef = Page.IECEBC_Resubscribe;
            pageRef.getParameters().put('c', IECUtil.EncryptParameter(camp.Id));
            pageRef.getParameters().put('e', IECUtil.EncryptParameter(gpavs[0].Email_Address__c));
            pageRef.getParameters().put('bai', IECUtil.EncryptParameter(camp.Billing_Account__c));
            pageRef.getParameters().put('ban', IECUtil.EncryptParameter('Foo Bar'));
            Test.setCurrentPage(pageRef);


            Test.startTest();
            vfIECEBC_Resubscribe con = new vfIECEBC_Resubscribe();

            con.agencyCode = '1234';
            con.fullName = '1234';
            con.newEmail = '12@34.com';
            con.subscribe();

            Test.stopTest();
        }
    }
    public static void testCleanOutOfDateOptOut() {

        User usr = initPreRunAs(true);

        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;
        
        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();

        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;

        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
        insert masterFilter;
        EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
        insert cf;
        EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
        insert tpl;
        EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id, Status__c = 'SENT');
        insert camp;

        EBC_Email_Exclusion__c ee = new EBC_Email_Exclusion__c(Email__c = gpavs[8].Email_Address__c, Unsubscribe_From__c = oBillingAccount.Id, Type__c = 'OPTOUT');
        insert ee;
        System.debug(ee);


        List<EBC_Email_Exclusion_Relation__c> eers = new List<EBC_Email_Exclusion_Relation__c> {
            new EBC_Email_Exclusion_Relation__c(Billing_Account__c  = oBillingAccount.Id, EBC_Email_Exclusion__c = ee.Id, External_Id__c = ee.Email__c.toLowerCase() + '_' + gpavs[8].Id + '_' + ee.Unsubscribe_From__c, GDP_Products_Account_View__c = gpavs[8].Id, Is_Global__c = false),
            new EBC_Email_Exclusion_Relation__c(Billing_Account__c  = oBillingAccount.Id, EBC_Email_Exclusion__c = ee.Id, External_Id__c = ee.Email__c.toLowerCase() + '_' + gpavs[9].Id + '_' + ee.Unsubscribe_From__c, GDP_Products_Account_View__c = gpavs[9].Id, Is_Global__c = false)
        };
        insert eers;


        System.runAs(usr) {
            initPostRunAs();


            Test.startTest();

            eers = [Select Id From EBC_Email_Exclusion_Relation__c WHERE EBC_Email_Exclusion__c = :ee.Id];
            System.assertEquals(2, eers.size());

            gpavs[8].Email_Address__c = 'diff@erent.com';
            update gpavs[8];

            SchdlIECEBCEmailExclusionRelClean.Schedule();
            SchdlIECEBCEmailExclusionRelClean n = new SchdlIECEBCEmailExclusionRelClean();
            Database.executeBatch(n, SchdlIECEBCEmailExclusionRelClean.BATCH_SIZE);

            Test.stopTest();
            eers = [Select Id From EBC_Email_Exclusion_Relation__c WHERE EBC_Email_Exclusion__c = :ee.Id];
            System.assertEquals(1, eers.size());
        }
    }
    class ET_SendMassMailingSuccess_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            if (req.getBody().contains('UpdateRequest') && req.getBody().contains('<Objects xsi:type="ns1:Email"')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:931209e7-4685-4010-94c4-b9b039e5c98e</wsa:MessageID><wsa:RelatesTo>urn:uuid:bd61d290-7e80-46b6-9e03-46e63a89eb68</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-457d5977-6b84-4842-a6e8-0c61e0cc9fa4"><wsu:Created>2016-10-06T12:21:31Z</wsu:Created><wsu:Expires>2016-10-06T12:26:31Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</NewObjectID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</ObjectID><CustomerKey>tue322</CustomerKey><Name>tue322</Name><SendClassification><PartnerKey xsi:nil="true" /><ObjectID>c1e1715a-a970-e611-8844-0025b3d7f36a</ObjectID><SenderProfile><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>10691121</CustomerKey></SenderProfile></SendClassification><Email><PartnerKey xsi:nil="true" /><ID>173905</ID><ObjectID xsi:nil="true" /></Email><List><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /></List><AutoAddSubscribers>false</AutoAddSubscribers><EmailSubject>Test of large xml</EmailSubject><IsMultipart>true</IsMultipart></Object></Results><RequestID>42bc6718-ac24-45a1-ba6b-acca18994289</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="SenderProfile">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:bd3d1a1a-ec41-480e-afb7-b40ecc759053</wsa:MessageID><wsa:RelatesTo>urn:uuid:0caa9e7d-bd29-4dab-b268-668343be00bd</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-e161038d-4385-48e6-b71b-cbd772cc87ab"><wsu:Created>2016-10-14T15:52:12Z</wsu:Created><wsu:Expires>2016-10-14T15:57:12Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>SenderProfile created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>6744b526-2692-e611-8302-8cdcd4afd9e9</NewObjectID><Object xsi:type="SenderProfile"><PartnerKey xsi:nil="true" /><ObjectID>6744b526-2692-e611-8302-8cdcd4afd9e9</ObjectID><CustomerKey>12345</CustomerKey><Name>API Created Sender Profile</Name><Description>API Created Sender Profile</Description><FromName>Angel Cruz</FromName><FromAddress>acruz@example.com</FromAddress></Object></Results><RequestID>b5fdf1fc-34cf-4496-9d2e-21c9c3d734f8</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="SendClassification">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:f7259669-a862-45cf-acee-70a26417371d</wsa:MessageID><wsa:RelatesTo>urn:uuid:0caa9e7d-bd29-4dab-b268-668343be00bd</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-b8ba713f-454e-4ba0-8783-94d9f41bb8f2"><wsu:Created>2016-10-14T16:21:00Z</wsu:Created><wsu:Expires>2016-10-14T16:26:00Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>SendClassification created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>56529c2d-2a92-e611-8302-8cdcd4afd9e9</NewObjectID><Object xsi:type="SendClassification"><PartnerKey xsi:nil="true" /><ObjectID>56529c2d-2a92-e611-8302-8cdcd4afd9e9</ObjectID><CustomerKey>12345</CustomerKey><Name>12345</Name><SenderProfile><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>12345</CustomerKey></SenderProfile><DeliveryProfile><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>eBroadcast</CustomerKey></DeliveryProfile></Object></Results><RequestID>4a124448-0576-4930-bec4-b2c075fa6001</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSendDefinition">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:931209e7-4685-4010-94c4-b9b039e5c98e</wsa:MessageID><wsa:RelatesTo>urn:uuid:bd61d290-7e80-46b6-9e03-46e63a89eb68</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-457d5977-6b84-4842-a6e8-0c61e0cc9fa4"><wsu:Created>2016-10-06T12:21:31Z</wsu:Created><wsu:Expires>2016-10-06T12:26:31Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</NewObjectID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</ObjectID><CustomerKey>tue322</CustomerKey><Name>tue322</Name><SendClassification><PartnerKey xsi:nil="true" /><ObjectID>c1e1715a-a970-e611-8844-0025b3d7f36a</ObjectID><SenderProfile><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>10691121</CustomerKey></SenderProfile></SendClassification><Email><PartnerKey xsi:nil="true" /><ID>173905</ID><ObjectID xsi:nil="true" /></Email><List><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /></List><AutoAddSubscribers>false</AutoAddSubscribers><EmailSubject>Test of large xml</EmailSubject><IsMultipart>true</IsMultipart></Object></Results><RequestID>42bc6718-ac24-45a1-ba6b-acca18994289</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('UpdateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSendDefinition">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>UpdateResponse</wsa:Action><wsa:MessageID>urn:uuid:816a24b2-236f-497e-8aa1-7e46e870d894</wsa:MessageID><wsa:RelatesTo>urn:uuid:4c4de283-ad44-4121-8b9c-1f8e7fc25779</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-1e94f5a9-cd81-4ddc-9b2f-b6d587550db8"><wsu:Created>2016-10-06T12:22:35Z</wsu:Created><wsu:Expires>2016-10-06T12:27:35Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><UpdateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition updated</StatusMessage><OrdinalID>0</OrdinalID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>tue322</CustomerKey><TriggeredSendStatus>Active</TriggeredSendStatus></Object></Results><RequestID>599a5821-fd43-4e91-9051-e3909f52a1cb</RequestID><OverallStatus>OK</OverallStatus></UpdateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSend">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:ac01a04d-f2d9-4e4c-88d3-ebe3adbb35bb</wsa:MessageID><wsa:RelatesTo>urn:uuid:f10eaef0-353b-4dd1-9968-1b8c86956352</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-8486ebe9-6036-4851-b36b-858334ebb529"><wsu:Created>2016-10-06T12:24:58Z</wsu:Created><wsu:Expires>2016-10-06T12:29:58Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results xsi:type="TriggeredSendCreateResult"><StatusCode>OK</StatusCode><StatusMessage>Created TriggeredSend</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID></Results><RequestID>aafc81b7-6a77-499d-a961-19fc6cbc3e82</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>   ');
            }

            r.setStatusCode(200);
            return r;
        }
    }
    class ET_SendTestSuccess_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="Email">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:edcc6710-7f98-4b2d-8255-de1fe067a007</wsa:MessageID><wsa:RelatesTo>urn:uuid:0caa9e7d-bd29-4dab-b268-668343be00bd</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-29666917-fb74-421a-af90-57f452f59caa"><wsu:Created>2016-10-06T11:58:25Z</wsu:Created><wsu:Expires>2016-10-06T12:03:25Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>Created Email.</StatusMessage><OrdinalID>0</OrdinalID><NewID>1</NewID><Object xsi:type="Email"><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><Name>a7B8E000000D0kbUAC</Name><HTMLBody></HTMLBody><Subject>This is a rendering test for eBroadcast</Subject><IsHTMLPaste>true</IsHTMLPaste><EmailType>HTML</EmailType></Object></Results><RequestID>6dea7ca7-6fc1-4cbb-af71-74adfa1d082f</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSendDefinition">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:931209e7-4685-4010-94c4-b9b039e5c98e</wsa:MessageID><wsa:RelatesTo>urn:uuid:bd61d290-7e80-46b6-9e03-46e63a89eb68</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-457d5977-6b84-4842-a6e8-0c61e0cc9fa4"><wsu:Created>2016-10-06T12:21:31Z</wsu:Created><wsu:Expires>2016-10-06T12:26:31Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</NewObjectID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</ObjectID><CustomerKey>tue322</CustomerKey><Name>tue322</Name><SendClassification><PartnerKey xsi:nil="true" /><ObjectID>c1e1715a-a970-e611-8844-0025b3d7f36a</ObjectID><SenderProfile><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>10691121</CustomerKey></SenderProfile></SendClassification><Email><PartnerKey xsi:nil="true" /><ID>173905</ID><ObjectID xsi:nil="true" /></Email><List><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /></List><AutoAddSubscribers>false</AutoAddSubscribers><EmailSubject>Test of large xml</EmailSubject><IsMultipart>true</IsMultipart></Object></Results><RequestID>42bc6718-ac24-45a1-ba6b-acca18994289</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('UpdateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSendDefinition">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>UpdateResponse</wsa:Action><wsa:MessageID>urn:uuid:816a24b2-236f-497e-8aa1-7e46e870d894</wsa:MessageID><wsa:RelatesTo>urn:uuid:4c4de283-ad44-4121-8b9c-1f8e7fc25779</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-1e94f5a9-cd81-4ddc-9b2f-b6d587550db8"><wsu:Created>2016-10-06T12:22:35Z</wsu:Created><wsu:Expires>2016-10-06T12:27:35Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><UpdateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition updated</StatusMessage><OrdinalID>0</OrdinalID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>tue322</CustomerKey><TriggeredSendStatus>Active</TriggeredSendStatus></Object></Results><RequestID>599a5821-fd43-4e91-9051-e3909f52a1cb</RequestID><OverallStatus>OK</OverallStatus></UpdateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSend">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:ac01a04d-f2d9-4e4c-88d3-ebe3adbb35bb</wsa:MessageID><wsa:RelatesTo>urn:uuid:f10eaef0-353b-4dd1-9968-1b8c86956352</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-8486ebe9-6036-4851-b36b-858334ebb529"><wsu:Created>2016-10-06T12:24:58Z</wsu:Created><wsu:Expires>2016-10-06T12:29:58Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results xsi:type="TriggeredSendCreateResult"><StatusCode>OK</StatusCode><StatusMessage>Created TriggeredSend</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID></Results><RequestID>aafc81b7-6a77-499d-a961-19fc6cbc3e82</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>   ');
            }

            r.setStatusCode(200);
            return r;
        }
    }
    class ET_SendTestListDetective_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="Email">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:edcc6710-7f98-4b2d-8255-de1fe067a007</wsa:MessageID><wsa:RelatesTo>urn:uuid:0caa9e7d-bd29-4dab-b268-668343be00bd</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-29666917-fb74-421a-af90-57f452f59caa"><wsu:Created>2016-10-06T11:58:25Z</wsu:Created><wsu:Expires>2016-10-06T12:03:25Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>Created Email.</StatusMessage><OrdinalID>0</OrdinalID><NewID>1</NewID><Object xsi:type="Email"><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><Name>a7B8E000000D0kbUAC</Name><HTMLBody></HTMLBody><Subject>This is a rendering test for eBroadcast</Subject><IsHTMLPaste>true</IsHTMLPaste><EmailType>HTML</EmailType></Object></Results><RequestID>6dea7ca7-6fc1-4cbb-af71-74adfa1d082f</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSendDefinition">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:931209e7-4685-4010-94c4-b9b039e5c98e</wsa:MessageID><wsa:RelatesTo>urn:uuid:bd61d290-7e80-46b6-9e03-46e63a89eb68</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-457d5977-6b84-4842-a6e8-0c61e0cc9fa4"><wsu:Created>2016-10-06T12:21:31Z</wsu:Created><wsu:Expires>2016-10-06T12:26:31Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition created</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</NewObjectID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID>63f8a167-bf8b-e611-8844-0025b3d7f36a</ObjectID><CustomerKey>tue322</CustomerKey><Name>tue322</Name><SendClassification><PartnerKey xsi:nil="true" /><ObjectID>c1e1715a-a970-e611-8844-0025b3d7f36a</ObjectID><SenderProfile><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>10691121</CustomerKey></SenderProfile></SendClassification><Email><PartnerKey xsi:nil="true" /><ID>173905</ID><ObjectID xsi:nil="true" /></Email><List><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /></List><AutoAddSubscribers>false</AutoAddSubscribers><EmailSubject>Test of large xml</EmailSubject><IsMultipart>true</IsMultipart></Object></Results><RequestID>42bc6718-ac24-45a1-ba6b-acca18994289</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('UpdateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSendDefinition">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>UpdateResponse</wsa:Action><wsa:MessageID>urn:uuid:816a24b2-236f-497e-8aa1-7e46e870d894</wsa:MessageID><wsa:RelatesTo>urn:uuid:4c4de283-ad44-4121-8b9c-1f8e7fc25779</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-1e94f5a9-cd81-4ddc-9b2f-b6d587550db8"><wsu:Created>2016-10-06T12:22:35Z</wsu:Created><wsu:Expires>2016-10-06T12:27:35Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><UpdateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>TriggeredSendDefinition updated</StatusMessage><OrdinalID>0</OrdinalID><Object xsi:type="TriggeredSendDefinition"><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>tue322</CustomerKey><TriggeredSendStatus>Active</TriggeredSendStatus></Object></Results><RequestID>599a5821-fd43-4e91-9051-e3909f52a1cb</RequestID><OverallStatus>OK</OverallStatus></UpdateResponse></soap:Body></soap:Envelope>');
            } else if (req.getBody().contains('CreateRequest') && req.getBody().contains('<Objects xsi:type="TriggeredSend">')) {
                r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:4b20ee68-dd01-4109-86c1-68e0bcc57f59</wsa:MessageID><wsa:RelatesTo>urn:uuid:d5339cef-c42d-4ac0-8294-f932663f6deb</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-0f3a915e-ac8a-4f03-89a2-6fde3b6dacf4"><wsu:Created>2016-10-06T12:31:27Z</wsu:Created><wsu:Expires>2016-10-06T12:36:27Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results xsi:type="TriggeredSendCreateResult"><StatusCode>Error</StatusCode><StatusMessage>Unable to queue Triggered Send request.  There are no valid subscribers.</StatusMessage><OrdinalID>0</OrdinalID><ErrorCode>180008</ErrorCode><NewID>0</NewID><SubscriberFailures><Subscriber><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><EmailAddress>a768E000000CvM6QAK@cubicmedia.ca</EmailAddress><SubscriberKey>a768E000000CvM6QAK@cubicmedia.ca</SubscriberKey></Subscriber><ErrorCode>TriggeredSendSubscriberProcessingError</ErrorCode><ErrorDescription>Error Code: 24 - Subscriber was excluded by List Detective.</ErrorDescription></SubscriberFailures></Results><RequestID>2c3a2150-4d37-430d-a25e-b19f65311940</RequestID><OverallStatus>Error</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            }

            r.setStatusCode(200);
            return r;
        }
    }
    class CampaignPayWithCredit_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            if (req.getEndpoint().toLowerCase().contains('iecebc_recipientcount')) {
                r.setBody('7');
            }

            r.setStatusCode(200);
            return r;
        }
    }


}