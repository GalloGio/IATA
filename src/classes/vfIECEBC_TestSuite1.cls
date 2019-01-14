public class vfIECEBC_TestSuite1 {
    public static Account IECTestUtil_Account { get { return vfIECEBC_TestSuite.IECTestUtil_Account; } set { vfIECEBC_TestSuite.IECTestUtil_Account = value; } }
    public static Contact IECTestUtil_Contact { get { return vfIECEBC_TestSuite.IECTestUtil_Contact; } set { vfIECEBC_TestSuite.IECTestUtil_Contact = value; } }
    public static User IECTestUtil_User { get { return vfIECEBC_TestSuite.IECTestUtil_User; } set { vfIECEBC_TestSuite.IECTestUtil_User = value; } }
    public static Id IECTestUtil_UserId { get { return vfIECEBC_TestSuite.IECTestUtil_UserId; } set { vfIECEBC_TestSuite.IECTestUtil_UserId = value; } }
    public static Zuora__CustomerAccount__c IECTestUtil_BillingAccount { get { return vfIECEBC_TestSuite.IECTestUtil_BillingAccount; } set { vfIECEBC_TestSuite.IECTestUtil_BillingAccount = value; } }
    
    private static Product_Category__c oProductCategory { get { return vfIECEBC_TestSuite.oProductCategory; } set { vfIECEBC_TestSuite.oProductCategory = value; } }
    private static Product_Information__c oProductInfo { get { return vfIECEBC_TestSuite.oProductInfo; } set { vfIECEBC_TestSuite.oProductInfo = value; } }
    private static zqu__ZProduct__c oProduct { get { return vfIECEBC_TestSuite.oProduct; } set { vfIECEBC_TestSuite.oProduct = value; } }
    private static zqu__ProductRatePlan__c oProductRatePlan { get { return vfIECEBC_TestSuite.oProductRatePlan; } set { vfIECEBC_TestSuite.oProductRatePlan = value; } }
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge { get { return vfIECEBC_TestSuite.oProductRatePlanCharge; } set { vfIECEBC_TestSuite.oProductRatePlanCharge = value; } }
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo { get { return vfIECEBC_TestSuite.oProductRatePlanInfo; } set { vfIECEBC_TestSuite.oProductRatePlanInfo = value; } }
    private static Zuora__Subscription__c subscription { get { return vfIECEBC_TestSuite.subscription; } set { vfIECEBC_TestSuite.subscription = value; } }
    private static Zuora__SubscriptionProductCharge__c subscriptionCharge { get { return vfIECEBC_TestSuite.subscriptionCharge; } set { vfIECEBC_TestSuite.subscriptionCharge = value; } }
    private static Zuora__CustomerAccount__c oBillingAccount  { get { return vfIECEBC_TestSuite.oBillingAccount; } set { vfIECEBC_TestSuite.oBillingAccount = value; } }
    private static EBC_Preference__c oPref { get { return vfIECEBC_TestSuite.oPref; } set { vfIECEBC_TestSuite.oPref = value; } }
    
    private static IECCustomer currentCustomer { get { return vfIECEBC_TestSuite.currentCustomer; } set { vfIECEBC_TestSuite.currentCustomer = value; } }
    
    public static User initPreRunAs(Boolean grantEBCAccess) { return vfIECEBC_TestSuite.initPreRunAs(grantEBCAccess); }
    
    public static void initPostRunAs() { vfIECEBC_TestSuite.initPostRunAs(); }
    
    public static List<GDP_Products_Account_View__c> createGDPProductsAccountViews() {
        return vfIECEBC_TestSuite.createGDPProductsAccountViews();
    }
    /////////////////  
    public static void testRecipientList() { 
        PageReference pageRef = Page.IECEBC_RecipientList;
        Test.setCurrentPage(pageRef);
        
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        List<EBC_Application_Filter__c> afs = new List<EBC_Application_Filter__c>{
            new EBC_Application_Filter__c(Search_Level__c  = 'Geo-Selection', Audience__c = 'Agency', Filter_Description__c = 'Country', Data_Type__c = 'Text', Filter_Field__c = 'Country__c'),
            new EBC_Application_Filter__c(Search_Level__c  = 'Refinement', Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c')
        };
        insert afs;
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = IECEBC_TestUtility.oUser.Id, Is_Global_Filter__c = false, Billing_Account__c = IECEBC_TestUtility.oBillingAccount.Id);
        insert masterFilter;
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(5);
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_RecipientList recList = new vfIECEBC_RecipientList();
            
            System.assertNotEquals(null, recList.sortBy);
            System.assertNotEquals(null, recList.getSortByOptions());
            System.assertEquals(1, recList.getFilters().size());
            System.assertNotEquals(null, recList.maxPage);
            
            recList.selectedItemId = recList.getFilters()[0].Id;
            recList.duplicate();
            
            recList = new vfIECEBC_RecipientList();
            System.assertEquals(2, recList.getFilters().size());
            
            recList.selectedItemId = recList.getFilters()[1].Id;
            recList.getSelectedFilter().Name = 'bleh';
            recList.save();
            
            recList = new vfIECEBC_RecipientList();
            System.assertEquals(2, recList.getFilters().size());
            
            recList.selectedItemId = recList.getFilters()[1].Id;
            recList.deleteItem();
            
            recList = new vfIECEBC_RecipientList();
            System.assertEquals(1, recList.getFilters().size());
            
        }
    }
    
    public static void testReadMosaicoUploads() { 
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(5);
            Test.startTest();
            
            RestRequest req = new RestRequest();
            req.requestURI = 'https://hostname/services/apexrest/MosaicoUploads';
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            vfIECEBC_MosaicoUploads.doGet();
        }
    }
    public static void testWriteMosaicoUploads() { 
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(5);
            Test.startTest();
            
            RestRequest req = new RestRequest();
            req.requestURI = 'https://hostname/services/apexrest/MosaicoUploads';
            req.addHeader('Content-Disposition', 'attachment; filename="image.txt"');
            req.addHeader('Content-Type', 'plain/text');
            req.requestBody = Blob.valueOf('mytext');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            vfIECEBC_MosaicoUploads.doPost();
            
            
            req = new RestRequest();
            req.requestURI = 'https://hostname/services/apexrest/MosaicoUploads';
            req.addHeader('Content-Disposition', 'attachment; filename="image.png"');
            req.addHeader('Content-Type', 'image/png');
            req.requestBody = Blob.valueOf('myimage');
            RestContext.request = req;
            
            res = new RestResponse();
            RestContext.response = res;
            
            vfIECEBC_MosaicoUploads.doPost();
        }
    }
    public static void testAccountRatePlan() { 
        PageReference pageRef = Page.IECEBC_AccountRatePlan;
        Test.setCurrentPage(pageRef);
        
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(5);
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_AccountRatePlan accRP = new vfIECEBC_AccountRatePlan();
            
            System.assertNotEquals(null, accRP.isEbcPrepaid);
            System.assertNotEquals(null, accRP.productRatePlan.Name);
            System.assertNotEquals(null, accRP.showSubscriptionEnd);
            System.assertNotEquals(null, accRP.productRatePlan.EBC_Currency_Cost_Per_Email__c);
            System.assertNotEquals(null, accRP.subscription.Zuora__SubscriptionEndDate__c);
            System.assertNotEquals(null, accRP.showUpgradeOption);
            System.assertNotEquals(null, accRP.currentProductRatePlanWrapper.name);
            System.assertNotEquals(null, accRP.currentProductRatePlanWrapper.descriptions);
            System.assertNotEquals(null, accRP.showUpgradeOption);
            
            accRP.selectedRatePlanIndex = accRP.productRatePlanWrapperUpgradeList[0].index;
            accRP.productRatePlanWrapperUpgradeList[0].selected = true;
            accRP.selectRatePlan();
            
            System.assertNotEquals(null, accRP.allowSelectUpgrade);
            System.assertNotEquals(null, accRP.showPaymentConfirmation);
            System.assertNotEquals(null, accRP.newSubscriptionProductCharge.Zuora__Price__c);
            System.assertNotEquals(null, accRP.totalNewPurchaseAmount);
            accRP.goToPaymentPage();
            
        }
    }
    public static void testAccountExtras() {
        PageReference pageRef = Page.IECEBC_AccountExtras;
        Test.setCurrentPage(pageRef);
        
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(5);
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_AccountExtras accExtras = new vfIECEBC_AccountExtras();
            
            System.assertNotEquals(null, accExtras.isEbcPrepaid);
            System.assertNotEquals(null, accExtras.productRatePlanWrapperAddonCurrentList);
            System.assertNotEquals(null, accExtras.showAddOnSelection);
            
            accExtras.productRatePlanWrapperAddonOptionList[0].selected = true;
            accExtras.selectedRatePlanIndex = accExtras.productRatePlanWrapperAddonOptionList[0].index;
            accExtras.selectRatePlanAddon();
            
            System.assertNotEquals(null, accExtras.showAddOnSelection);
            System.assertNotEquals(null, accExtras.showPurchasedSelectionMessage);
            System.assertNotEquals(null, accExtras.productRatePlanWrapperAddonNewPurchaseList);
            System.assertNotEquals(null, accExtras.goToPaymentPage());
            System.assertNotEquals(null, accExtras.selectedProductRatePlan);
        }
        
    }
    public static void testAccountEmailBlocks() {
        PageReference pageRef = Page.IECEBC_AccountEmailBlocks;
        Test.setCurrentPage(pageRef);
        
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(5);
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_AccountEmailBlocks accEmailBlocks = new vfIECEBC_AccountEmailBlocks();
            
            System.assertEquals(true, accEmailBlocks.isEbcPrepaid);
            System.assertNotEquals(null, accEmailBlocks.productRatePlanWrapperOptionList);
            System.assertNotEquals(null, accEmailBlocks.showPurchasedSelectionMessage);
            
            
            accEmailBlocks.selectedRatePlanIndex = accEmailBlocks.productRatePlanWrapperOptionList[0].index;
            accEmailBlocks.productRatePlanWrapperOptionList[0].selected = true;
            accEmailBlocks.selectRatePlanEmaiLBlock();
            
            System.assertNotEquals(null, accEmailBlocks.selectedProductRatePlanWrapper.name);
            System.assertNotEquals(null, accEmailBlocks.selectedProductRatePlanWrapper.amount);
            System.assertNotEquals(null, accEmailBlocks.totalNewPurchaseAmount);
            System.assertNotEquals(null, accEmailBlocks.selectedProductRatePlan);
            System.assertNotEquals(null, accEmailBlocks.goToPaymentPage());
            
            
            
        }
    }
    public static void testAccountManage() {
        PageReference pageRef = Page.IECEBC_AccountManage;
        Test.setCurrentPage(pageRef);
        
        IECEBC_TestUtility.createTestUser(false);
//        User usr = initPreRunAs(true);
        
        System.runAs(IECEBC_TestUtility.oUser) {
//        System.runAs(usr) {
//            initPostRunAs();
			vfIECEBC_TestPaymentSuite.initPostRunAs(10);
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_AccountManage accMan = new vfIECEBC_AccountManage();
            
            System.assertNotEquals(null, accMan.monthYtdList);
            System.assertNotEquals(null, accMan.adjustmentYtdData);
            System.assertNotEquals(null, accMan.creditYtdData);
            System.assertNotEquals(null, accMan.sendYtdData);
            
            System.assertNotEquals(null, accMan.monthYayList);
            System.assertNotEquals(null, accMan.adjustmentYayData);
            System.assertNotEquals(null, accMan.creditYayData);
            System.assertNotEquals(null, accMan.sendYayData);      
            
            System.assertNotEquals(null, accMan.isEbcPrepaid);    
            System.assertNotEquals(null, accMan.productRatePlan.Name);    
            System.assertNotEquals(null, accMan.showSubscriptionEnd);    
            System.assertNotEquals(null, accMan.subscription.Zuora__SubscriptionEndDate__c); 
            
            System.assertNotEquals(null, accMan.renewalPageUrl);       
            System.assertNotEquals(null, accMan.showRenewNow);       
            System.assertNotEquals(null, accMan.showSuggestionMessage);   
            System.assertNotEquals(null, accMan.billingAccount.eBroadcast_Email_Balance__c);   
            
            System.assertNotEquals(null, accMan.totalCampaigns);
            System.assertNotEquals(null, accMan.totalSends);
            System.assertNotEquals(null, accMan.totalAdjustments);
            accMan.refreshTable();
            System.assertNotEquals(null, accMan.activityTypeWrapperList);
            System.assertNotEquals(null, accMan.activityList);
            System.assertNotEquals(null, accMan.page);
            System.assertNotEquals(null, accMan.getPageOptions());
            System.assertNotEquals(null, accMan.maxPage);
            accMan.doNothing();
        }
    }
    
    public static void testResourceListError() {
        PageReference pageRef = Page.IECEBC_ResourceList;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_ResourceList listCon = new vfIECEBC_ResourceList();
            
            Pagereference sa = listCon.SaveAttachments();
            System.assertEquals(true, listCon.MessageFlag);
            System.assertNotEquals('', listCon.MessageContent);
            listCon.ClearMessage();
            
	        //Test.setMock(HttpCalloutMock.class, new AttachmentUpload_Mock());
        }
    }
    public static void testResourceList() {
        PageReference pageRef = Page.IECEBC_ResourceList;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        Test.setMock(HttpCalloutMock.class, new AttachmentUpload_Mock());
        List<EBC_Resource__c> ress = new List<EBC_Resource__c>{
            new EBC_Resource__c(Billing_Account__c = oBillingAccount.Id, Image_Type__c = 'png', Name = 'image1.png', Image_Size__c = 12345, Thumbnail_URL__c = 'http://www.google.com/image1.png', Image_URL__c = 'http://www.google.com/image1.png'),
            new EBC_Resource__c(Billing_Account__c = oBillingAccount.Id, Image_Type__c = 'png', Name = 'image2.png', Image_Size__c = 12345, Thumbnail_URL__c = 'http://www.google.com/image2.png', Image_URL__c = 'http://www.google.com/image2.png'),
            new EBC_Resource__c(Billing_Account__c = oBillingAccount.Id, Image_Type__c = 'png', Name = 'image3.png', Image_Size__c = 12345, Thumbnail_URL__c = 'http://www.google.com/image3.png', Image_URL__c = 'http://www.google.com/image3.png')
        };
        insert ress;
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_ResourceList listCon = new vfIECEBC_ResourceList();
            System.assertNotEquals(null, listCon.sortBy);
            System.assertNotEquals(null, listCon.getSortByOptions());
            
            List<EBC_Resource__c> conTpls = listCon.getFilters();
            System.assertEquals(3, conTpls.size());
            
            System.assertNotEquals(null, listCon.gaugestorage);
            System.assertNotEquals(null, listCon.gaugepercent);
            
            Boolean isLoadMoreImage = listCon.loadmoreimage;
            Test.stopTest();
            
        }
    }
    public static void testResourceListUpload() {
        PageReference pageRef = Page.IECEBC_ResourceList;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        Test.setMock(HttpCalloutMock.class, new AttachmentUpload_Mock());
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_ResourceList listCon = new vfIECEBC_ResourceList();
            
            Attachment att;
            
            att = new Attachment(Name = 'image.png', Body = Blob.valueOf('test2'));
            listCon.attachment = att;
            
            Pagereference sa = listCon.SaveAttachments();
            System.assertEquals(false, listCon.MessageFlag);
        }
    }
    public static void testResourceListUpload1() {
        PageReference pageRef = Page.IECEBC_ResourceList;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        EBC_Resource__c er = new EBC_Resource__c();
        er.Billing_Account__c = oBillingAccount.Id;
        er.Name = 'test.png';
        er.Image_Type__c = 'png';
        er.Image_Size__c = 12;
        insert er;
        
        Attachment a = new Attachment();
        a.Name = er.Name;
        a.Body = Blob.valueOf('helloworld');
        a.ParentId = er.Id;
        insert a;
        
        String url = 'https://hostname/iec/services/apexrest/Resources/' + er.Id + '/' + er.Name + '?client=exacttarget';
        
        Test.setMock(HttpCalloutMock.class, new AttachmentUpload_Mock());
        
        RestRequest req = new RestRequest();
        req.requestURI = url;
        req.params.put('client', 'exacttarget');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        restIEC_Attachment.doGet();
        
        System.runAs(usr) {
            initPostRunAs();
            
            
            Test.startTest();
            
            IECEBC_ETPortfolioCreate.CreatePortfolioObject(new Map<String, String>{
                er.Id + '.png' => url
            });
            
            Test.stopTest();
            
        }
    }
    
    public static void testTemplateList() {
        PageReference pageRef = Page.IECEBC_TemplateList;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        Account a1 = new Account(Name = 'a1');
        insert a1;
        Contact c1 = new Contact(FirstName = 'c1', LastName = 'c2', Email = 'w00t@test.com', AccountId = a1.Id);
        insert c1;
        Zuora__CustomerAccount__c ba1 = IECTestUtil.createSampleBillingAccount(a1, c1);
        insert ba1;
        
        
        EBC_Template__c tpl = new EBC_Template__c();
        tpl.Name = 'unittesttemplate';
        tpl.Audience__c = 'Agency';
        tpl.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global');
        insert tpl;
        
        Id userRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'User_Templates');
        List<EBC_Template__c> tpls = new List<EBC_Template__c>{
            new EBC_Template__c(Name = 'a1', RecordTypeId = userRecTypeId, Audience__c = 'Agency', Billing_Account__c = oBillingAccount.Id, Is_Reusable__c = true, Parent_Template__c = tpl.Id),
                new EBC_Template__c(Name = 'a2', RecordTypeId = userRecTypeId, Audience__c = 'Agency', Billing_Account__c = oBillingAccount.Id, Is_Reusable__c = true, Parent_Template__c = tpl.Id),
                new EBC_Template__c(Name = 'a3', RecordTypeId = userRecTypeId, Audience__c = 'Agency', Billing_Account__c = oBillingAccount.Id, Is_Reusable__c = true, Parent_Template__c = tpl.Id),
                new EBC_Template__c(Name = 'a4', RecordTypeId = userRecTypeId, Audience__c = 'Agency', Billing_Account__c = ba1.Id, Is_Reusable__c = true, Parent_Template__c = tpl.Id),
                new EBC_Template__c(Name = 'a5', RecordTypeId = userRecTypeId, Audience__c = 'Agency', Billing_Account__c = oBillingAccount.Id, Is_Reusable__c = false, Parent_Template__c = tpl.Id)
                };
                    insert tpls;
        
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            vfIECEBC_TemplateList listCon = new vfIECEBC_TemplateList();
            
            System.assertNotEquals(null, listCon.sortBy);
            System.assertNotEquals(null, listCon.getSortByOptions());
            
            List<EBC_Template__c> conTpls = listCon.getFilters();
            System.assertEquals(3, conTpls.size());
            
            EBC_Resource__c res = new EBC_Resource__c(Billing_Account__c = oBillingAccount.Id);
            insert res;
            insert new Attachment(ParentId = conTpls[0].Id, Name = 'test.html', ContentType = 'plain/text', Body = Blob.valueOf('test'));
            insert new EBC_Template_Resource__c(EBC_Template__c = conTpls[0].Id, EBC_Resource__c = res.Id);
            
            
            listCon.selectedItemId = conTpls[0].Id;
            listCon.getSelectedFilter().Name = 'New Name';
            listCon.duplicate();
            
            listCon = new vfIECEBC_TemplateList();
            conTpls = listCon.getFilters();
            System.assertEquals(4, conTpls.size());
            
            listCon.selectedItemId = conTpls[0].Id;
            listCon.getSelectedFilter().Name = 'New Name 2';
            listCon.save();
            
            listCon.deleteItem();
            
            listCon = new vfIECEBC_TemplateList();
            conTpls = listCon.getFilters();
            System.assertEquals(3, conTpls.size());
        }
        
    }
    
    public static void testPageLoadDashboard() {
        PageReference pageRef = Page.IECEBC_Dashboard;
        Test.setCurrentPage(pageRef); 
        
        Account newAccount = new Account();
        newAccount.Name = 'Hello World';
        insert newAccount;
        Contact newContact = new Contact();
		newContact.FirstName = 'Name';
        newContact.Phone='5142640908';
        newContact.Email='dashboard@iata.com';
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
            layoutController.logout();
            Boolean newNow=layoutController.showRenewNow;
            String pageUrl=layoutController.renewalPageUrl;
            layoutController.getIsUserLoggedIn();
            
            vfIECEBC_Dashboard dashboardCon = new vfIECEBC_Dashboard();
            System.assertEquals(4, dashboardCon.campaignsCount);
            System.assertNotEquals(null, dashboardCon.showRenewNow);
            System.assertNotEquals(null, dashboardCon.renewalPageUrl);
            
            vfIECEBC_CampaignList campaignListComponent = new vfIECEBC_CampaignList();
            campaignListComponent.isLimitedComponent = true;
            
            System.assertEquals('LastModifiedDate DESC', campaignListComponent.sortBy);
            System.assertEquals(dashboardCon.campaignsCount, campaignListComponent.CampaignsCount);
            System.assertEquals(2, campaignListComponent.campaigns.size());
            
        }
    }
    
    public static void testRecipientListEdit() {
        User usr = initPreRunAs(true);
        
        
        List<EBC_Application_Filter__c> afs = new List<EBC_Application_Filter__c>{
            new EBC_Application_Filter__c(Search_Level__c  = 'Geo-Selection', Audience__c = 'Agency', Filter_Description__c = 'Country', Data_Type__c = 'Text', Filter_Field__c = 'Country__c'),
            new EBC_Application_Filter__c(Search_Level__c  = 'Refinement', Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c')
        };
        insert afs;
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
        insert masterFilter;
        /*
        List<EBC_Customer_Filter__c> cfs = new List<EBC_Customer_Filter__c>{
            new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = afs[0].Id, Field_Operator__c = '=', Field_Value__c = 'X0'),
            new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = afs[1].Id, Field_Operator__c = '=', Field_Value__c = 'X0')
        };
        insert cfs;
*/
        

        PageReference pageRef = Page.IECEBC_Recipient;
        pageRef.getParameters().put('id', masterFilter.Id);
        Test.setCurrentPage(pageRef);
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(masterFilter);
            
            vfIECEBC_RecipientEdit recipientEditCon = new vfIECEBC_RecipientEdit();
            recipientEditCon.filterId = masterFilter.Id;
            
            System.assertNotEquals(null, recipientEditCon.getNewFilterEscapedJSON());
            System.assertEquals(1, recipientEditCon.newListStepNumber);
            System.assertNotEquals(null, recipientEditCon.limitToAudience);
            System.assertNotEquals(null, recipientEditCon.newFilter.Audience__c);
            
            System.assertNotEquals(null, recipientEditCon.isIDCARDSelectionAllowed);
            System.assertNotEquals(null, recipientEditCon.isCodeSelectionAllowed);
            System.assertNotEquals(null, recipientEditCon.allAvailableApplicationFilterValues);
            
            // Refinement Filters
            List<SelectOption> availableRefFilers = recipientEditCon.getAvailableRefinementApplicationFilterOptions();
            recipientEditCon.addRefinementFilter();
            
            recipientEditCon.refinementFilters[1].EBC_Application_Filter__c = afs[1].Id;
            recipientEditCon.refinementFilters[1].Field_Operator__c = '=';
            recipientEditCon.refinementFilters[1].Field_Value__c = 'x0';
            
            recipientEditCon.getUniqueRefinementFiltersName();
            
            recipientEditCon.resetFilterIndex = 0;
            recipientEditCon.resetFilter();
            
            recipientEditCon.refinementFilterIndex = '0';
            recipientEditCon.removeRefinementFilter();
            
                        
            // Geo Filters
            // 
            recipientEditCon.getAvailableGeoApplicationFilterOptions();
            recipientEditCon.addGeoFilter();
            recipientEditCon.resetGeoFilter();
            
            recipientEditCon.geoFilters[0].EBC_Application_Filter__c = afs[0].Id;
            recipientEditCon.geoFilters[0].Field_Operator__c = '=';
            recipientEditCon.geoFilters[0].Field_Value__c = 'x0';
            
            recipientEditCon.resetFilterIndex = 0;
            recipientEditCon.resetFilter();
            
            recipientEditCon.geoFilterIndex = '0';
            recipientEditCon.removeGeoFilter();
            
                
//            new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = afs[0].Id, Field_Operator__c = '=', Field_Value__c = 'X0'),
            
            
            
            
            
            Test.stopTest();
        }
    }
    
    public static void testCampaignRecipient() {
        
        PageReference pageRef = Page.IECEBC_CampaignRecipients;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        /*
GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
insert grt;
Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
insert accr;

List<GDP_Products_Account_View__c> gpavs = new List<GDP_Products_Account_View__c>{
new GDP_Products_Account_View__c(Name = 'a',				Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'a@b.com',			Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'b',			Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'b@b.com',			Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'c',			Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'c@b.com',			Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'd',			Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'd@b.com',			Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'e',			Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'e@b.com',			Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'f',			Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'f@b.com',			Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'notincluded',	Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'notincluded@b.com',	Preferred_Language__c = 'X1'),
new GDP_Products_Account_View__c(Name = 'optout',		Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = false,	Email_Address__c = 'optout@b.com',		Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'duplicate',	Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'duplicate@b.com',	Preferred_Language__c = 'X0'),
new GDP_Products_Account_View__c(Name = 'duplicate1',	Related_Accreditation_Class__c = accr.Id,	GDP_Opt_In__c = true,	Email_Address__c = 'duplicate@b.com',	Preferred_Language__c = 'X0')
};
insert gpavs;*/
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
    public static void testCampaignTemplate() {
        
        PageReference pageRef = Page.IECEBC_CampaignTemplate;
        Test.setCurrentPage(pageRef);
        
        User usr = initPreRunAs(true);
        
        List<EBC_Template__c> globTpl = new List<EBC_Template__c>{
            new EBC_Template__c(Name = 'Global Agent 1', Audience__c = 'Agent', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global')),
                new EBC_Template__c(Name = 'Global Neutral 1', Audience__c = 'Neutral', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global')),
                new EBC_Template__c(Name = 'Global Agency 1', Audience__c = 'Agency', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global')),
                new EBC_Template__c(Name = 'Global Agency 2', Audience__c = 'Agency', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global')),
                new EBC_Template__c(Name = 'Custom Agency 2', External_Id__c = 'customhtml-agencytest', Audience__c = 'Agency', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'Global'))
                };
                    upsert globTpl; 
        
        insert new List<EBC_Template__c>{
            new EBC_Template__c(Is_Reusable__c = true, Billing_Account__c = oBillingAccount.Id, Name = 'UD Agent 1', Audience__c = 'Agent', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'User_Templates'), Parent_Template__c = globTpl[0].Id),
                new EBC_Template__c(Is_Reusable__c = true, Billing_Account__c = oBillingAccount.Id, Name = 'UD Neutral 1', Audience__c = 'Neutral', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'User_Templates'), Parent_Template__c = globTpl[1].Id),
                new EBC_Template__c(Is_Reusable__c = true, Billing_Account__c = oBillingAccount.Id, Name = 'UD Agency 1', Audience__c = 'Agency', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EBC_Template__c', 'User_Templates'), Parent_Template__c = globTpl[2].Id)
                };
                    
                    List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();
        
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c();
        masterFilter.Audience__c = 'Agency';
        masterFilter.Billing_Account__c = oBillingAccount.Id;
        insert masterFilter;
        
        EBC_Campaign__c camp = new EBC_Campaign__c();
        // Step 1
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        camp.Billing_Account__c = oBillingAccount.Id;
        camp.EBC_Master_Filter__c = masterFilter.Id;
        insert camp;
        
        camp = [
            Select
            Id,
            Name,
            Subject__c,
            From_Name__c,
            Is_Google_Analytics_Tracker_Active__c,
            Google_Analytics_Tracking_Code__c,
            Billing_Account__c,
            EBC_Master_Filter__c,
            Audience__c
            From EBC_Campaign__c
            Where Id = :camp.Id
        ];
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            // Layout PageLoad
            vfIECEBC_Layout layoutController = new vfIECEBC_Layout();
            System.assertEquals(null, layoutController.pageLoad());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            vfIECEBC_Campaign campaignExtCon = new vfIECEBC_Campaign(sc);
            
            vfIECEBC_CampaignTemplate templateExtCon = new vfIECEBC_CampaignTemplate(sc);
            
            vfIECEBC_TemplateCreation templateListCon = new vfIECEBC_TemplateCreation();
            templateListCon.audience = 'Agency';
            System.debug(templateListCon.globalTemplates);
            System.assertNotEquals(0, templateListCon.globalTemplates.size());
            System.assertEquals(2, templateListCon.userEditableTemplates.size());
            
            templateExtCon.selectedTemplate = templateExtCon.customHtmlTemplate.Id;
            templateExtCon.upsertDesignAndContinue();
            // next() coverage
            PageReference nextStep = campaignExtCon.next();
            // previous() coverage
            PageReference prevStep = campaignExtCon.previous();
        }
    }
    
    public static void testCampaignTracking() {
//        vfIECEBC_CampaignTracking
//        
        
        User usr = initPreRunAs(true);
        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();
        
        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id, New_Balance__c = 1000, Total_Count__c = 1000, Activity_Type__c = 'Credit', Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;
        // 
        
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = usr.Id);
        insert masterFilter;
        EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
        insert cf;
        EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = usr.Id);
        insert tpl;
        EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', External_Id__c = 'FINAL_sentid', Send_Datetime__c = Datetime.now().addHours(-2), Status__c = 'SENT', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = usr.Id);
        insert camp;
        
        IECEBC_ETCampaignTrackingAsync.initCampaignTrackingRecords(camp);
        
        
        SchdlIECEBCRetrieveCumulativeStats.Schedule();
        Test.setMock(HttpCalloutMock.class, new CampaignTracking_Mock());
/*        SchdlIECEBCRetrieveCumulativeStats n = new SchdlIECEBCRetrieveCumulativeStats();
        Database.executeBatch(n,200);*/
        
        EBC_Click_Event__c ce = new EBC_Click_Event__c(Subscriber_Key__c = '1234', External_Id__c = 'abcd', EBC_Campaign__c = camp.Id, URL__c = 'http://foo.bar/');
        insert ce;
        
        
        
        
        System.runAs(usr) {
            initPostRunAs();
            Test.startTest();
            
            System.debug(Limits.getQueries());
            List<EBC_Campaign__c> camps = [SELECT Id, Name, Send_Datetime__c, External_Id__c, Status__c,
                                           is7dFollowUpCompleted__c 
                                           FROM EBC_Campaign__c
                                           WHERE id = :camp.Id
                                          ];
            
            System.debug(Limits.getQueries());
            IECEBC_ETCampaignTrackingAsync.createCumulativeCampaignTracking(camps);
            System.debug(Limits.getQueries());
            //Test.stopTest();          
            System.debug(Limits.getQueries());  
            
        	SchdlIECEBCRetrieveCumulativeStats.cancel();
            System.debug(Limits.getQueries());
            
            camp = [
                SELECT
                Id,
                Name,
                EBC_Master_Filter__c,
                Audience__c,
                EBC_Design__c,
                Send_Datetime__c,
                External_Id__c,
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
            
            System.debug(Limits.getQueries());
            PageReference pageRef = Page.IECEBC_ManageReportsDetails;
            pageRef.getParameters().put('id', camp.Id);
            Test.setCurrentPage(pageRef);
                
            System.debug(Limits.getQueries());
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            System.debug(Limits.getQueries());
            vfIECEBC_CampaignTracking campTrackExtCon = new vfIECEBC_CampaignTracking(sc);
            
            System.debug(Limits.getQueries());
            System.assertNotEquals(null, campTrackExtCon.First24HOpensV3);
            System.debug(Limits.getQueries());
            System.assertNotEquals(null, campTrackExtCon.First24HClicksV3);
            System.debug(Limits.getQueries());
            
            System.assertNotEquals(null, campTrackExtCon.getFirst48HOpensV3());
            System.debug(Limits.getQueries());
            System.assertNotEquals(null, campTrackExtCon.getFirst48HClicksV3());
            System.debug(Limits.getQueries());
            
            System.assertNotEquals(null, campTrackExtCon.getFirst7DOpens());
            System.debug(Limits.getQueries());
            System.assertNotEquals(null, campTrackExtCon.getFirst7DClicks());
            System.debug(Limits.getQueries());
            
            System.assertNotEquals(null, campTrackExtCon.getXAxis7d());
            System.debug(Limits.getQueries());
            System.assertNotEquals(null, campTrackExtCon.SentDate);
            
            System.assertNotEquals(null, campTrackExtCon.Kpis.get('delivered7Days'));
            System.assertNotEquals(null, campTrackExtCon.Kpis.get('numberOpens7Days'));
            System.assertNotEquals(null, campTrackExtCon.Kpis.get('numberClicks7Days'));
            System.assertNotEquals(null, campTrackExtCon.Kpis.get('bounced7Days'));
            
            Integer adj =  campTrackExtCon.Adjustments;
            System.assertNotEquals(null, campTrackExtCon.campaignLinkStats);
            
        }
    }
    
 
    class CampaignTracking_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            //if (req.getBody().contains('RetrieveRequest') && req.getBody().contains('<ObjectType>SentEvent</ObjectType>')) {
	            r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:901b7768-1626-4da9-b77c-b1a16d6158bf</wsa:MessageID><wsa:RelatesTo>urn:uuid:0caa9e7d-bd29-4dab-b268-668343be00bd</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-f9ebc7d2-b029-4c4d-aa20-f17e5048298f"><wsu:Created>2016-11-07T22:33:42Z</wsu:Created><wsu:Expires>2016-11-07T22:38:42Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><RetrieveResponseMsg xmlns="http://exacttarget.com/wsdl/partnerAPI"><OverallStatus>OK</OverallStatus><RequestID>cdca8b87-b14e-4dfb-a20f-962f6c3bf988</RequestID><Results xsi:type="TriggeredSendSummary"><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><Sent>8</Sent><NotSentDueToOptOut>0</NotSentDueToOptOut><NotSentDueToUndeliverable>0</NotSentDueToUndeliverable><Bounces>1</Bounces><Opens>6</Opens><Clicks>0</Clicks><UniqueOpens>6</UniqueOpens><UniqueClicks>0</UniqueClicks><OptOuts>0</OptOuts><SurveyResponses>0</SurveyResponses><FTAFRequests>0</FTAFRequests><FTAFEmailsSent>0</FTAFEmailsSent><FTAFOptIns>0</FTAFOptIns><Conversions>0</Conversions><UniqueConversions>0</UniqueConversions><InProcess>0</InProcess><NotSentDueToError>0</NotSentDueToError><Queued>0</Queued></Results></RetrieveResponseMsg></soap:Body></soap:Envelope>');
            //}
            
            r.setStatusCode(200);
            return r;
        }
    }  
    class AttachmentUpload_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            r.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope"><wsa:Action>CreateResponse</wsa:Action><wsa:MessageID>urn:uuid:d84a3cc0-d528-4869-96f3-6e387d7ba01e</wsa:MessageID><wsa:RelatesTo>urn:uuid:db7625ad-b909-48f7-a9e6-9819f5bd3ddb</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-ebb07db4-2c98-451a-8b29-8c7cb70f35a9"><wsu:Created>2016-11-08T17:53:30Z</wsu:Created><wsu:Expires>2016-11-08T17:58:30Z</wsu:Expires></wsu:Timestamp></wsse:Security></env:Header><soap:Body><CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI"><Results><StatusCode>OK</StatusCode><StatusMessage>Media item queued for upload</StatusMessage><OrdinalID>0</OrdinalID><NewID>0</NewID><NewObjectID>5982dc8d-710d-4390-a619-b1de98cd9487</NewObjectID><Object xsi:type="Portfolio"><PartnerKey xsi:nil="true" /><ModifiedDate xsi:nil="true" /><ObjectID>5982dc8d-710d-4390-a619-b1de98cd9487</ObjectID><CustomerKey /><Source><PartnerKey xsi:nil="true" /><ModifiedDate xsi:nil="true" /><ObjectID xsi:nil="true" /><URN>http://www.google.com</URN></Source><FileName>image.png</FileName></Object></Results><RequestID>1af37a88-9a51-4eb3-8031-385180fe0549</RequestID><OverallStatus>OK</OverallStatus></CreateResponse></soap:Body></soap:Envelope>');
            
            r.setStatusCode(200);
            return r;
        }
    }
    
}