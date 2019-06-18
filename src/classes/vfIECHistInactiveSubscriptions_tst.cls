/**  
  * Description: This class contains the controller for the Visualforce page (Inactive Subscription) 
  * Author: Salvador Ponticelli
  * Version: 1.0
  * History:
  * NOTE: Invoices and Payments relationship cannot be well tested since thy require API calls to Zuora 
  */
@isTest(SeeAllData=true)
public class vfIECHistInactiveSubscriptions_tst {
    private static List<Zuora__Subscription__c> lstSubscriptionList;
    private static List<Zuora__SubscriptionProductCharge__c> lstSubscriptionCharge;
    private static Zuora__ZInvoice__c invoice;
    private static Zuora__Payment__c payment;
    private static Zuora__CustomerAccount__c customerAccount;

    private static void InitSubscription(boolean bCreateCharge){
        IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
        lstSubscriptionList = new List<Zuora__Subscription__c>();
        
        Zuora__Subscription__c subs01 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.Today().addYears(-1));
        Zuora__Subscription__c subs02 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 02', Date.Today().addYears(1));
        Zuora__Subscription__c subs03 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 03', Date.Today().addYears(1));
        Zuora__Subscription__c subs04 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 04', Date.Today().addYears(1));
        
        subs01.Zuora__Status__c = 'Active';
        subs02.Zuora__Status__c = 'Active';
        subs03.Zuora__Status__c = 'Pending Activation';
        subs04.Zuora__Status__c = 'Active';
        
        lstSubscriptionList.add(subs01);
        lstSubscriptionList.add(subs02);
        lstSubscriptionList.add(subs03);
        lstSubscriptionList.add(subs04);
        
        insert lstSubscriptionList;
        
        if (bCreateCharge) {
            // create dummy subscription charge
            lstSubscriptionCharge = new List<Zuora__SubscriptionProductCharge__c> {
                IECTestUtil.createSampleSubscriptionCharge2(subs01.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
                , IECTestUtil.createSampleSubscriptionCharge2(subs02.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
                , IECTestUtil.createSampleSubscriptionCharge2(subs03.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
                , IECTestUtil.createSampleSubscriptionCharge2(subs04.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
            };
            insert lstSubscriptionCharge;

            Zuora__Subscription__c test = IECSubscriptionManager.getSubscriptionById(subs01.Id);
            System.assertEquals(test.Product_Rate_Plan_Information__c, oProductRatePlanInfo.Id);
            //System.assertEquals(test.Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c, IECUserManager.getClientType());
        }
    }
    
    private static void InitInvoicesAndPayments() {
        Account account = IECTestUtil.createSampleAccount();
        insert account;
        
        Zuora__CustomerAccount__c ba = IECTestUtil.createSampleBillingAccount(account);
        insert ba;
        
        IECTestUtil.InvoiceTestOrigin = 'vfIECHistInactiveSubscriptions_tst';
        invoice = IECTestUtil.createSampleInvoice(ba, Date.today(), 213.45);
        insert invoice;
        IECTestUtil.InvoiceTestOrigin = '';
        
        payment = IECTestUtil.createSamplePayment(ba, 213.45, invoice, 'Processed');
        insert payment;
    }
    
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static Product_Information__c oProductInfo2;
    private static Product2 oProduct;
    private static Product2 oProduct2;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlan__c oProductRatePlan2;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge2;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
    private static Swap_Configuration__c oSwapConfig;
    private static Terms_and_Conditions__c oTC;
    private static Attachment oAttachment;

    public static List<Zuora.zObject> getSampleInvoiceItems() {
        List<Zuora.zObject> lstInvoiceItems = new List<Zuora.zObject>();
        
        Integer i = 0;
        for (Zuora__Subscription__c sub : lstSubscriptionList) {
            Zuora.zObject zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
            zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
            zInvoiceItem.setValue('ChargeAmount', 100);
            zInvoiceItem.setValue('ChargeDate', DateTime.now());
            zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
            zInvoiceItem.setValue('InvoiceId', invoice.Zuora__External_Id__c);
            zInvoiceItem.setValue('ProductId', oProduct.zqu__ZuoraId__c);
            zInvoiceItem.setValue('SubscriptionId', sub.Zuora__External_Id__c);
            zInvoiceItem.setValue('SubscriptionNumber', sub.Name);
            zInvoiceItem.setValue('RatePlanChargeId', lstSubscriptionCharge.get(i).Zuora__External_Id__c);
            zInvoiceItem.setValue('Quantity', 22);
            zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
            zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
            zInvoiceItem.setValue('TaxAmount', 13);
            zInvoiceItem.setValue('UnitPrice', 100);
            lstInvoiceItems.add(zInvoiceItem);
            i++;
        }
        
        return lstInvoiceItems;
    }
    
    private static void InitProduct() {
        oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
        insert oProductCategory;
        
        oProduct = IECTestUtil.CreateSampleProduct2('PTST');
        insert oProduct;
        
        oProduct2 = IECTestUtil.CreateSampleProduct2('PTST2');
        insert oProduct2;
        
        oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
        oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert oProductInfo;
        
        oProductInfo2 = IECTestUtil.CreateSampleProductInfo2('PITST2', oProductCategory, oProduct2);
        oProductInfo2.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
        insert oProductInfo2;
        
        oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
        insert oProductRatePlan;
        
        oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('PRPTST2', false, oProduct2);
        insert oProductRatePlan2;
        
        oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
        insert oProductRatePlanCharge;
        
        oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 1);
        insert oProductRatePlanCharge2;
        
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
        insert oProductRatePlanInfo;
        
        oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST2', false, oProductRatePlan2, oProductInfo2);
        insert oProductRatePlanInfo2;

        // create a Terms & Conditions
        oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTC;
        
        // create dummy Attachment for the T&C
        oAttachment = IECTestUtil.CreateSampleAttachment(oTC.Id);
        insert oAttachment;
        
        // set the effective date of the T&C
        oTC.Effective_Start_Date__c = Date.today().addDays(-5);
        update oTC;
        
        oSwapConfig = new Swap_Configuration__c (
            Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id, 
            Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
            Relationship_Type__c = IECConstants.SwappingType_Swap);
        insert oSwapConfig;
    }

    static testMethod void testPageLoad() {
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitSubscription(false);
            
            Test.startTest();
    
            //Instantiate Controller
            vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
            pgCont.pageLoad();
                    
            // Test 001: list of active subscriptions should be not null
            system.assertNotEquals(pgCont.lstListInactiveSubscriptions, null);
            
            // Test 001: list of active subscriptions should have only 2 inactive elements
            //system.assert(pgCont.lstListInactiveSubscriptions.size() == 2, 'Only 2 subscriptions should be returned');

            Test.stopTest();
        }
    }
    
    static testMethod void testSelectSubscription() {
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitSubscription(false);
            
            Test.startTest();

            //Get one subscription from the list created on Init
            Zuora__Subscription__c subscription = lstSubscriptionList.get(0);       
                    
            //Instantiate Controller
            vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
                    
            // Test 001: Subscription objet should have the same values as first element on the list 
            pgCont.sSelectedSubscriptionId = subscription.Id;
            pgCont.selectSubscription();
            Zuora__Subscription__c resultObj = pgCont.subscriptionObj;
            
            system.assertNotEquals(resultObj, null);
            system.assertEquals(resultObj.Name, subscription.Name);
            
            // Misc Coverage
            String sTest;
            sTest = pgCont.sPaymentMethod;
            sTest = pgCont.sProductName;
            sTest = pgCont.sOptionName;
            
            Test.stopTest();
        }       
    }

    static testMethod void testSelectInvoice() {
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);        
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        Test.startTest();

        InitProduct();
        System.runAs(usr) {
            InitSubscription(true);
        }        
        InitInvoicesAndPayments();
        Test.stopTest();

        //Instantiate Controller
        vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
    
        // Pass the subscription id to the page parameters      
        pgCont.sSelectedInvoiceID = invoice.Id;          
                    
        // Test 001
        Pagereference reference = pgCont.selectInvoice();
        system.assertNotEquals(reference, null);
    }
    
    static testMethod void testSelectPayment() {
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        Test.startTest();

        InitProduct();
        System.runAs(usr) {
            InitSubscription(true);
        }        
        InitInvoicesAndPayments();
        Test.stopTest();

        //Instantiate Controller
        vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
    
        // Pass the subscription id to the page parameters      
        pgCont.sSelectedPaymentID = payment.Id;              
                    
        // Test 001
        Pagereference reference = pgCont.selectPayment();
        system.assertNotEquals(reference, null);
    }

    static testMethod void TestSimilarProductsAndAddToCart() {
        System.debug('Unit Test: Start: TestSimilarProductsAndAddToCart');
        
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
        
        Test.startTest();
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitProduct();
            InitSubscription(true);
    
            IEC_Subscription_History__c oSubHist = IECTestUtil.createSampleSubscriptionHistory(IECCustomer.getCurrentIECCustomer(), lstSubscriptionList.get(0).Name, oProductCategory.Id, oProductInfo.Id, oProductRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
            insert oSubHist;

            //Get one subscription from the list created on Init
            Zuora__Subscription__c subscription = lstSubscriptionList.get(0);
                    
            //Instantiate Controller
            vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
                    
            pgCont.sSelectedSubscriptionId = subscription.Id;
            pgCont.selectSubscription();

            // Test 001: Subscription History object should have the same values as first element on the list 
            system.assertNotEquals(pgCont.oSubscriptionHistory, null);
            system.assertEquals(pgCont.oSubscriptionHistory.Subscription_Number__c, subscription.Name);

            // Test 002: Make sure the Rateplan info match
            //system.assertEquals(pgCont.idSelectedRatePlanInfo, oProductRatePlanInfo.Id);
            
            // Test 003: Navigation to Similar Pages
            Pagereference referenceProduct = pgCont.navigateSimilarProducts();
            system.assertNotEquals(referenceProduct, null);
            
            // Test 004: Buy New Item
            Pagereference referenceCart = pgCont.addToCart();
            //system.assertNotEquals(referenceCart, null);
        }
        Test.stopTest();
        System.debug('Unit Test: Finish: TestSimilarProductsAndAddToCart');
    }
    
    static testMethod void TestSwapUpRatePlan() {

        System.debug('Unit Test: Start: TestSwapUpRatePlan');
        
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitProduct();
            InitSubscription(true);
    
            IEC_Subscription_History__c oSubHist = IECTestUtil.createSampleSubscriptionHistory(IECCustomer.getCurrentIECCustomer(), lstSubscriptionList.get(0).Name, oProductCategory.Id, oProductInfo.Id, oProductRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
            insert oSubHist;

            //Get one subscription from the list created on Init
            Zuora__Subscription__c subscription = lstSubscriptionList.get(0);
                    
            //Instantiate Controller
            vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
                    
            pgCont.sSelectedSubscriptionId = subscription.Id;
            pgCont.selectSubscription();

            // Test 002: Make sure the Rateplan info is swapped up to a member type
            //system.assertEquals(pgCont.idSelectedRatePlanInfo, oProductRatePlanInfo2.Id);
        }

        System.debug('Unit Test: Finish: TestSwapUpRatePlan');
    }
    
    static testMethod void TestSwapDownRatePlan() {
        System.debug('Unit Test: Start: TestSwapDownRatePlan');
        
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitProduct();
            InitSubscription(true);
    
            IEC_Subscription_History__c oSubHist = IECTestUtil.createSampleSubscriptionHistory(IECCustomer.getCurrentIECCustomer(), lstSubscriptionList.get(0).Name, oProductCategory.Id, oProductInfo2.Id, oProductRatePlanInfo2.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
            insert oSubHist;

            //Get one subscription from the list created on Init
            Zuora__Subscription__c subscription = lstSubscriptionList.get(0);
                    
            //Instantiate Controller
            vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
                    
            pgCont.sSelectedSubscriptionId = subscription.Id;
            pgCont.selectSubscription();

            // Test 002: Make sure the Rateplan info is swapped down to default type
            //system.assertEquals(pgCont.idSelectedRatePlanInfo, oProductRatePlanInfo.Id);
        }

        System.debug('Unit Test: Finish: TestSwapDownRatePlan');
    }

    static testMethod void TestTermsAndConditions() {
        System.debug('Unit Test: Start: TestTermsAndConditions');
        
        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitProduct();
            InitSubscription(true);
    
            IEC_Subscription_History__c oSubHist = IECTestUtil.createSampleSubscriptionHistory(IECCustomer.getCurrentIECCustomer(), lstSubscriptionList.get(0).Name, oProductCategory.Id, oProductInfo.Id, oProductRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
            insert oSubHist;

            //Get one subscription from the list created on Init
            Zuora__Subscription__c subscription = lstSubscriptionList.get(0);
                    
            //Instantiate Controller
            vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();
                    
            pgCont.sSelectedSubscriptionId = subscription.Id;
            pgCont.selectSubscription();

            // Test 001: Subscription History object should have the same values as first element on the list 
            system.assertNotEquals(pgCont.oSubscriptionHistory, null);
            system.assertEquals(pgCont.oSubscriptionHistory.Subscription_Number__c, subscription.Name);

            // Test 002: Make sure the Attachment ID has been loaded and match
            system.assertEquals(pgCont.sAttachTermsId, oAttachment.Id);
        }

        System.debug('Unit Test: Finish: TestTermsAndConditions');
    }
    
    static testMethod void TestInvalidLogin() {
        System.debug('Unit Test: Start: TestInvalidLogin');

        PageReference pgRef = Page.IECHistInactiveSubscriptions;
        Test.setCurrentPage(pgRef);
        
        //Instantiate Controller
        vfIECHistInactiveSubscriptions pgCont = new vfIECHistInactiveSubscriptions();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();
        
        System.debug('Unit Test: Finish: TestInvalidLogin');
    }
}