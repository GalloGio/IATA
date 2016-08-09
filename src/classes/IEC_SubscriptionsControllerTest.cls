@isTest(SeeAllData=true)
private class IEC_SubscriptionsControllerTest
{
	private static List<Zuora__Subscription__c> lstSubscriptionList;
	private static List<Zuora__SubscriptionProductCharge__c> lstSubscriptionCharge;

	private static zqu__ZProduct__c oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;

	private static void InitSubscription(boolean bCreateCharge){

        Test.startTest();

        SAP_Contract_Mock.lstContractNumber = new List<String>{'111', '222', null};
        Test.setMock(WebServiceMock.class, new SAP_Contract_Mock());


        IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
        lstSubscriptionList = new List<Zuora__Subscription__c>();
        
        Zuora__CustomerAccount__c zCustomerAccount = [select id, CRMContactID__c, Contact__c,Zuora__Default_Payment_Method__c from Zuora__CustomerAccount__c where id =:currentCustomer.RelatedBillingAccount.Id ];

        Zuora__Subscription__c subs01 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.Today().addYears(1));
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
                IECTestUtil.createSampleSubscriptionCharge(subs01.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
                , IECTestUtil.createSampleSubscriptionCharge(subs02.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
                , IECTestUtil.createSampleSubscriptionCharge(subs03.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
                , IECTestUtil.createSampleSubscriptionCharge(subs04.Id, Date.Today().addYears(1), oProduct, oProductRatePlan)
            };
            insert lstSubscriptionCharge;

            Zuora__Subscription__c test = IECSubscriptionManager.getSubscriptionById(subs01.Id);
            System.assertEquals(test.Product_Rate_Plan_Information__c, oProductRatePlanInfo.Id);
        }

        Zuora__Subscription__c subscription = [select Id, Name, Zuora__External_Id__c,Zuora__Account__c,Zuora__CustomerAccount__c from Zuora__Subscription__c where Name = 'Subs 01'];

        //Product access by subscription number
        Datetime startDate = Datetime.now().AddDays(-2);
        Datetime endDate = Datetime.now().AddDays(2);
        IEC_Product_Access__c productAccess = new IEC_Product_Access__c(
        	Subscription_Number__c = subscription.Name,
        	Active__c = true,
        	Effective_Start_Date__c = startDate,
        	Effective_End_Date__c = endDate,
        	Usage_Unlimited__c = true
        );
        insert productAccess;

        // create dummy Zuora product
        zqu__ZProduct__c prod = IECTestUtil.CreateSampleProduct('Product1');
        prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
        prod.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
        insert prod;
        
        // create dummy Zuora rate plan
        zqu__ProductRatePlan__c ratePlan = IECTestUtil.CreateSampleProductRatePlan('Rate plan 1', false, prod);
        ratePlan.zqu__Deleted__c = false;
        insert ratePlan;
        
        // create dummy Zuora rate plan charge
        zqu__ProductRatePlanCharge__c charge = IECTestUtil.CreateSampleProductRatePlanCharge(ratePlan, 'Charge 1', 42);
        charge.zqu__Deleted__c = false;
        insert charge;
        
        // create dummy product category
        Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        myProdCat.Active__c = true;
        insert myProdCat;
        
        // create dummy product info
        Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo('My product', myProdCat, prod);
        myProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
        insert myProdInfo;

        //Create term and condition record
        Terms_and_Conditions__c termCondition = new Terms_and_Conditions__c(
            Product_Information__c = myProdInfo.Id
        );
        insert termCondition;
        system.assertEquals(termCondition.Product_Information__c, myProdInfo.Id);

        //Create terms and conditions attachment
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=termCondition.id;
        insert attach;

        //Create a subscription history
        IEC_Subscription_History__c subHistory = new IEC_Subscription_History__c(
            Subscription_Number__c = lstSubscriptionList[0].Name,
            Billing_Account_Number__c = 'A00000393',
            Invoice_Number__c  = 'Invoice_Number__c',
            Accepted_Terms_and_Conditions__c = termCondition.Id
        );
        insert subHistory;

        Zuora__CustomerAccount__c ca = [select id, Contact__c,Zuora__Default_Payment_Method__r.Zuora__Type__c from Zuora__CustomerAccount__c where id =:subscription.Zuora__CustomerAccount__c];
        
        Zuora__ZInvoice__c oInvoice = new Zuora__ZInvoice__c();
        oInvoice.Name = 'INV' + IECUtil.NewGuid();
        oInvoice.Zuora__InvoiceDate__c = Date.today();
        oInvoice.Zuora__TotalAmount__c = 1000;
        oInvoice.Zuora__Account__c = subscription.Zuora__Account__c;
        oInvoice.Zuora__BillingAccount__c = subscription.Zuora__CustomerAccount__c;
        oInvoice.Zuora__External_Id__c = oInvoice.Zuora__Zuora_Id__c = IECUtil.NewGuid().substring(0, 32);

        insert oInvoice;

        Invoice_Item__c invoiceItem = new Invoice_Item__c(
        	Subscription_Number__c = subscription.Name,
            Subscription__c = subscription.Id,
            Subscription_Zuora_ID__c = subscription.Zuora__External_Id__c,
        	Invoice__c = oInvoice.Id,
        	Zuora_ID__c = IECUtil.NewGuid().substring(0, 32)
        );
        insert invoiceItem;

        system.assertEquals(oInvoice.Id, invoiceItem.Invoice__c);

        Test.stopTest();
    }

	@isTest
	static void testPageLoad(){
		PageReference pgRef = Page.IEC_DataStatisticsSubscriptions;
        Test.setCurrentPage(pgRef);



        IEC_SubscriptionsController pgContNotConnect = new IEC_SubscriptionsController();
        pgContNotConnect.pageLoad();

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        
        System.runAs(usr) {
            // Initialize Data for test scenario
            InitSubscription(false);
    
            //Instantiate Controller
            IEC_SubscriptionsController pgCont = new IEC_SubscriptionsController();
            pgCont.pageLoad();

            List<Zuora__Subscription__c> lstSubscription = [Select id from Zuora__Subscription__c where Name='Subs 01'];
            pgCont.subsId = lstSubscription[0].id;
            pgCont.toggleAutoRenew();

            pgCont.refreshPage();
            pgCont.subscriptionToUpgradeId = lstSubscription[0].id;
            pgCont.upgrade();

            pgCont.subscriptionToRenewId = lstSubscription[0].id;
            pgCont.idSelectedRatePlanInfo = lstSubscription[0].id;

            pgCont.renewRatePlan();
                    
            // Test 001: list of active subscriptions should be not null
            system.assertNotEquals(pgCont.lstActiveSubscriptions, null);
            
            
        }
	}
}