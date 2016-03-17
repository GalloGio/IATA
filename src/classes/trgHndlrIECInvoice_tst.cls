/**  
  * Description: This class contains unit tests for the (Zuora Invoice) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
public class trgHndlrIECInvoice_tst {
	private static zqu__ZProduct__c oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Zuora__Subscription__c oSubscription;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge;
	private static Zuora__ZInvoice__c oInvoice;
	private static SAP_Account__c oSAPAccount;
	private static IEC_Subscription_History__c oSubHistory;

	public static List<Zuora.zObject> getSampleInvoiceItems() {
		Zuora.zObject zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
		zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
		zInvoiceItem.setValue('ChargeAmount', 100);
		zInvoiceItem.setValue('ChargeDate', DateTime.now());
		zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
		zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
		zInvoiceItem.setValue('ProductId', oProduct.zqu__ZuoraId__c);
		zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
		zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
		zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionCharge.Zuora__External_Id__c);
		zInvoiceItem.setValue('Quantity', 22);
		zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
		zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
		zInvoiceItem.setValue('TaxAmount', 13);
		zInvoiceItem.setValue('UnitPrice', 100);
		
		return new List<Zuora.zObject> {zInvoiceItem};
	}
	
	static void Init(IECCustomer loggedCustomer) {
        // create dummy Zuora product
    	oProduct = IECTestUtil.CreateSampleProduct('Product1');
    	oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
    	insert oProduct;
    	
    	// create dummy Zuora rate plan
    	oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('Rate plan 1', false, oProduct);
    	oProductRatePlan.zqu__Deleted__c = false;
    	insert oProductRatePlan;

    	oSAPAccount = IECTestUtil.CreateSampleSAPAccount(loggedCustomer.RelatedAccount.Id);
    	insert oSAPAccount;
    	
        // create dummy oSubscription
        oSubscription = IECTestUtil.createSampleSubscription(loggedCustomer.RelatedAccount.Id, 'Subs 01', Date.today().addMonths(6));
        insert oSubscription;
        
        // create dummy oSubscription charge
        oSubscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(oSubscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert oSubscriptionCharge;
        
        // create dummy product category
        Product_Category__c oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
        oProductCategory.Active__c = true;
        insert oProductCategory;
        
        // create dummy product info
        Product_Information__c oProductInfo = IECTestUtil.CreateSampleProductInfo('My product', oProductCategory, oProduct);
        oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
        insert oProductInfo;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c oRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, oProductRatePlan, oProductInfo);
        oRatePlanInfo.Display_As_Monthly_Fee__c = false;
        insert oRatePlanInfo;
        
        oSubHistory = IECTestUtil.createSampleSubscriptionHistory(loggedCustomer, 'S-9876543210', oProductCategory.Id, oProductInfo.Id, oRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, null);
        insert oSubHistory;
	}
	
    static testMethod void TestInvoice() {
    	System.debug('Unit Test: Start: TestInvoice');
		List<Zuora__CustomerAccount__c> lstBillingAccount;
		IECCustomer loggedCustomer;
		
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	        loggedCustomer = IECCustomer.getCurrentIECCustomer();
    	}

		// Initialize Data    	
    	Init(loggedCustomer);
		lstBillingAccount =
			[SELECT Id, Zuora__Account__c
			FROM Zuora__CustomerAccount__c
			WHERE Zuora__Account__c = :loggedCustomer.RelatedAccount.Id
				AND CRMContactID__c = :loggedCustomer.RelatedContact.Id];
    	
        Test.startTest();

        IECTestUtil.InvoiceTestOrigin = 'trgHndlrIECInvoice_tst';
        oInvoice = IECTestUtil.createSampleInvoice(lstBillingAccount.get(0), Date.today(), 113.0);
        insert oInvoice;

        Test.stopTest();

        IECTestUtil.InvoiceTestOrigin = '';
        
        
        // 001: Make sure that the invoice item has been downloaded and linked properly
        List<Invoice_Item__c> lstInvoiceItem = [SELECT Product__c, Subscription_Zuora_ID__c, Subscription_Product_Charge_Zuora_ID__c FROM Invoice_Item__c WHERE Invoice__c = :oInvoice.Id];
        system.assertNotEquals(lstInvoiceItem.size(), 0);
        system.assertEquals(lstInvoiceItem.get(0).Product__c, oProduct.Id);
        system.assertEquals(lstInvoiceItem.get(0).Subscription_Zuora_ID__c, oSubscription.Zuora__External_Id__c);
        system.assertEquals(lstInvoiceItem.get(0).Subscription_Product_Charge_Zuora_ID__c, oSubscriptionCharge.Zuora__External_Id__c);
        
    	System.debug('Unit Test: Finish: TestInvoice');
    }
}