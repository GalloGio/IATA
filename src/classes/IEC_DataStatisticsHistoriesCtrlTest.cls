@isTest(SeeAllData=true)
private class IEC_DataStatisticsHistoriesCtrlTest
{
	private static List<Zuora__Subscription__c> lstSubscriptionList;
	private static List<Zuora__SubscriptionProductCharge__c> lstSubscriptionCharge;

	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;

	private static void InitSubscription(User usr, boolean bCreateCharge){
        IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();

        //set all Custom setting
        TestDataGenerator.generateApexSetting();
        List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
        //List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
        List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, usr.ContactId,true); // 1 Order
        List<OrderItem> orderItems = TestDataGenerator.generateWebDownloadOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order

        lstSubscriptionList = new List<Zuora__Subscription__c>();
        
        Zuora__Subscription__c subs01 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.Today().addYears(1));
        Zuora__Subscription__c subs02 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 02', Date.Today().addYears(1));
        Zuora__Subscription__c subs03 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 03', Date.Today().addYears(1));
        Zuora__Subscription__c subs04 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 04', Date.Today().addYears(1));
        
        subs01.Zuora__Status__c = 'Active';
        subs02.Zuora__Status__c = 'Active';
        subs03.Zuora__Status__c = 'Pending Activation';
        subs03.OrderItemId__c   =  orderItems[0].Id;
        subs04.Zuora__Status__c = 'Inactive';

        
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

        //Update the orderItem with zuora external id
        for(OrderItem oi : orderItems){
            oi.Zuora_SubscriptionId__c = lstSubscriptionList[3].Zuora__External_Id__c;
        }
        update orderItems;

        //Product access by subscription number
        Datetime startDate = Datetime.now().AddDays(-2);
        Datetime endDate = Datetime.now().AddDays(2);
        IEC_Product_Access__c productAccess = new IEC_Product_Access__c(
        	Subscription_Number__c = lstSubscriptionList[3].Name,
        	Active__c = true,
        	Effective_Start_Date__c = startDate,
        	Effective_End_Date__c = endDate,
        	Usage_Unlimited__c = true
        );
        insert productAccess;

        Zuora__ZInvoice__c oInvoice = new Zuora__ZInvoice__c();
        oInvoice.Name = 'INV' + IECUtil.NewGuid();
        oInvoice.Zuora__InvoiceDate__c = IECZuoraHelper.getCurrentDate();
        oInvoice.Zuora__TotalAmount__c = 1000;
        oInvoice.Zuora__External_Id__c =
            oInvoice.Zuora__Zuora_Id__c = IECUtil.NewGuid().substring(0, 32);

        insert oInvoice;

        Invoice_Item__c invoiceItem = new Invoice_Item__c(
        	Subscription_Number__c = lstSubscriptionList[3].Name,
            Subscription__c = lstSubscriptionList[3].Id,
            Subscription_Zuora_ID__c = lstSubscriptionList[3].Zuora__External_Id__c,
        	Invoice__c = oInvoice.Id,
        	Zuora_ID__c = IECUtil.NewGuid().substring(0, 32)
        );
        insert invoiceItem;



    }


	static testMethod void testPageLoad() {
        PageReference pgRef = Page.IEC_DataStatisticsHistory;
        Test.setCurrentPage(pgRef);

        IEC_DataStatisticsHistoriesController pgContNotConnected = new IEC_DataStatisticsHistoriesController();
        pgContNotConnected.pageLoad();

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitSubscription(usr, false);
            
            Test.startTest();
    
            //Instantiate Controller
            IEC_DataStatisticsHistoriesController pgCont = new IEC_DataStatisticsHistoriesController();
            pgCont.pageLoad();
            pgCont.addToCart();
                    
            // Test 001: list of active subscriptions should be not null
            system.assertNotEquals(pgCont.lstInactiveSubscriptions, null);
            
            // Test 001: list of active subscriptions should have only 2 inactive elements
            //system.assert(pgCont.lstInactiveSubscriptions.size() == 1, 'Only '+pgCont.lstInactiveSubscriptions.size()+' subscriptions should be returned');

            Test.stopTest();
        }
    }


    static testMethod void testDTO(){
        //-- generate product 
        Product2 prod = TestDataGenerator.generateProducts(1, true)[0];

        ZuoraSubscription_DTO dto = new ZuoraSubscription_DTO(); 
        dto.idSelectedProdInfo  = prod.Id; 
        dto.productName         = prod.Name; 
        dto.ratePlanName        = 'RP';
                                          
    }
}