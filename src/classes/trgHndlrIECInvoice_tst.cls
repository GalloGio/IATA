/**  
  * Description: This class contains unit tests for the (Zuora Invoice) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
public class trgHndlrIECInvoice_tst {
	private static zqu__ZProduct__c oProduct;
	private static zqu__ZProduct__c oProductTax;
	private static zqu__ZProduct__c oProductShip;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlanTax;
	private static zqu__ProductRatePlan__c oProductRatePlanShip;
	private static Zuora__Subscription__c oSubscription;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionChargeTax;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionChargeShip;
	private static Zuora__ZInvoice__c oInvoice;
	private static SAP_Account__c oSAPAccount;
	private static IEC_Subscription_History__c oSubHistory;
    public static boolean stopCallout {get;set;}


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
		
		Zuora.zObject zInvoiceItemTax = new Zuora.zObject('InvoiceItem'); 
		zInvoiceItemTax.setValue('Id', IECUtil.NewGuid().substring(0, 32));
		zInvoiceItemTax.setValue('ChargeAmount', 10);
		zInvoiceItemTax.setValue('ChargeDate', DateTime.now());
		zInvoiceItemTax.setValue('ChargeName', 'CHARGETESTTax');
		zInvoiceItemTax.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
		zInvoiceItemTax.setValue('ProductId', oProductTax.zqu__ZuoraId__c);
		zInvoiceItemTax.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
		zInvoiceItemTax.setValue('SubscriptionNumber', oSubscription.Name);
		zInvoiceItemTax.setValue('RatePlanChargeId', oSubscriptionChargeTax.Zuora__External_Id__c);
		zInvoiceItemTax.setValue('Quantity', 1);
		zInvoiceItemTax.setValue('ServiceStartDate', DateTime.now());
		zInvoiceItemTax.setValue('ServiceEndDate', DateTime.now().addYears(1));
		zInvoiceItemTax.setValue('UnitPrice', 10);
		
		Zuora.zObject zInvoiceItemShip = new Zuora.zObject('InvoiceItem'); 
		zInvoiceItemShip.setValue('Id', IECUtil.NewGuid().substring(0, 32));
		zInvoiceItemShip.setValue('ChargeAmount', 10);
		zInvoiceItemShip.setValue('ChargeDate', DateTime.now());
		zInvoiceItemShip.setValue('ChargeName', 'CHARGETESTShip');
		zInvoiceItemShip.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
		zInvoiceItemShip.setValue('ProductId', oProductShip.zqu__ZuoraId__c);
		zInvoiceItemShip.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
		zInvoiceItemShip.setValue('SubscriptionNumber', oSubscription.Name);
		zInvoiceItemShip.setValue('RatePlanChargeId', oSubscriptionChargeShip.Zuora__External_Id__c);
		zInvoiceItemShip.setValue('Quantity', 1);
		zInvoiceItemShip.setValue('ServiceStartDate', DateTime.now());
		zInvoiceItemShip.setValue('ServiceEndDate', DateTime.now().addYears(1));
		zInvoiceItemShip.setValue('UnitPrice', 10);
		
		return new List<Zuora.zObject> {zInvoiceItem, zInvoiceItemTax, zInvoiceItemShip};
	}
	
	static void Init(IECCustomer loggedCustomer) {

		//-- Generate Zuora related items 
        try{
            //-- ZProduct 1 for Tax & 1 for Shipping
            List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(2, true);
    
            //-- Generate one Rate plan for each
            zqu__ProductRatePlan__c taxPlan  = TestDataGenerator.generateZRatePlans(zProducts[0].Id,1,false)[0];
                taxPlan.zqu__ZuoraId__c = Utility.getTextSetting('Zuora tax Plan id');
            zqu__ProductRatePlan__c shipPlan = TestDataGenerator.generateZRatePlans(zProducts[1].Id,1,false)[0];
                shipPlan.zqu__ZuoraId__c = Utility.getTextSetting('Zuora shipping Plan id');
            upsert new List<zqu__ProductRatePlan__c>{taxPlan, shipPlan} zqu__ZuoraId__c;
    
            //-- Generate Rate Plan Charges 
            zqu__ProductRatePlanCharge__c taxCharge = TestDataGenerator.generateZCharges(taxPlan.Id, 1, false)[0];
                taxCharge.zqu__ZuoraId__c = Utility.getTextSetting('Zuora tax Charge id');
            zqu__ProductRatePlanCharge__c shipCharge = TestDataGenerator.generateZCharges(shipPlan.Id, 1, false)[0];
                shipCharge.zqu__ZuoraId__c = Utility.getTextSetting('Zuora shipping Charge id');
            upsert new List<zqu__ProductRatePlanCharge__c>{taxCharge, shipCharge} zqu__ZuoraId__c;
        }
        catch(Exception ex){}
            

		
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
        oSubscription.Zuora__Version__c = 3;
        insert oSubscription;
        
        // create dummy oSubscription charge
        oSubscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(oSubscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert oSubscriptionCharge;
        
        // Create dummy tax charge
        oProductRatePlanTax = [SELECT Name, zqu__Description__c, zqu__EffectiveEndDate__c, zqu__ZProduct__c FROM zqu__ProductRatePlan__c WHERE zqu__ZuoraId__c = :Utility.getTextSetting('Zuora tax Plan id')][0];
        oProductTax = [SELECT zqu__ZuoraId__c, Name, zqu__SKU__c, zqu__EffectiveEndDate__c FROM zqu__ZProduct__c WHERE Id =:oProductRatePlanTax.zqu__ZProduct__c][0];
        
        oSubscriptionChargeTax = IECTestUtil.createSampleSubscriptionCharge(oSubscription.Id, Date.today().addMonths(-6), oProductTax, oProductRatePlanTax);
        oSubscriptionChargeTax.Product_Rate_Plan_Charge__r = new zqu__ProductRatePlanCharge__c(zqu__ZuoraId__c = Utility.getTextSetting('Zuora tax Charge id'));
        insert oSubscriptionChargeTax;
        
		// Create dummy shipping charge
        oProductRatePlanShip = [SELECT Name, zqu__Description__c, zqu__EffectiveEndDate__c, zqu__ZProduct__c FROM zqu__ProductRatePlan__c WHERE zqu__ZuoraId__c = :Utility.getTextSetting('Zuora shipping Plan id')][0];
        oProductShip = [SELECT zqu__ZuoraId__c, Name, zqu__SKU__c, zqu__EffectiveEndDate__c FROM zqu__ZProduct__c WHERE Id =:oProductRatePlanTax.zqu__ZProduct__c][0];

        oSubscriptionChargeShip = IECTestUtil.createSampleSubscriptionCharge(oSubscription.Id, Date.today().addMonths(-6), oProductShip, oProductRatePlanShip);
        oSubscriptionChargeShip.Product_Rate_Plan_Charge__r = new zqu__ProductRatePlanCharge__c(zqu__ZuoraId__c = Utility.getTextSetting('Zuora shipping Charge id'));
        insert oSubscriptionChargeShip;
        
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
        trgHndlrIECInvoice_tst.stopCallout = true;
    	System.debug('Unit Test: Start: TestInvoice');
		List<Zuora__CustomerAccount__c> lstBillingAccount;
		IECCustomer loggedCustomer;
		
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	        loggedCustomer = IECCustomer.getCurrentIECCustomer();
    	}

    	Contact oContact = new Contact_Sel().getContactById(usr.contactId);
    	Account oAccount = new Account_Sel().getAccountById(oContact.AccountId);
		//-- Generate locations
		List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(1, true);
		Location__c soldToLocation = TestDataGenerator.generateLocations(IECConstants.SOLDTO, addresses[0].Id, oContact.AccountId, null);
		Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId, usr.contactId);
		Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId, usr.contactId);

		oAccount.SoldTo_Location__c = soldToLocation.Id;
		update oAccount;
		
		oContact.BillTo_Location__c = billToLocation.Id;
		oContact.ShipTo_Location__c = shipToLocation.Id;
		update oContact;

		Test.startTest();   //*** (Thai) to increase # SOQL and to complete future

		// Initialize Data    	
    	Init(loggedCustomer);
		lstBillingAccount =
			[SELECT Id, Zuora__Account__c, CRMContactID__c, Contact__c
			FROM Zuora__CustomerAccount__c
			WHERE Zuora__Account__c = :loggedCustomer.RelatedAccount.Id
				AND CRMContactID__c = :loggedCustomer.RelatedContact.Id];
				
	    // Create Zuora Paymen Method
	    Zuora__PaymentMethod__c zPaymentMethod_CC = new Zuora__PaymentMethod__c (
	    	Zuora__Type__c = 'CreditCard'
	    	, Zuora__External_Id__c = TestDataGenerator.generateZuoraFakeId()
	    	, Zuora__BillingAccount__c = lstBillingAccount[0].Id
	    );
	    insert zPaymentMethod_CC;
	    
        // Set the default payment on one of the zAccounts to CreditCard
        lstBillingAccount[0].Zuora__Default_Payment_Method__c = zPaymentMethod_CC.Id;
        lstBillingAccount[0].Zuora__Zuora_Id__c = TestDataGenerator.generateZuoraFakeId();
        update lstBillingAccount[0];
    	
        IECTestUtil.InvoiceTestOrigin = 'trgHndlrIECInvoice_tst';
        oInvoice = IECTestUtil.createSampleInvoice(lstBillingAccount.get(0), Date.today(), 113.0);
        insert oInvoice;

        Test.stopTest();   //*** (Thai) stop to complete future method

        IECTestUtil.InvoiceTestOrigin = '';
        
        
        // 001: Make sure that the invoice item has been downloaded and linked properly
        List<Invoice_Item__c> lstInvoiceItem = [SELECT Product__c, Subscription_Zuora_ID__c, Subscription_Product_Charge_Zuora_ID__c FROM Invoice_Item__c WHERE Invoice__c = :oInvoice.Id];
        
      /*  system.assertNotEquals(lstInvoiceItem.size(), 0, trgHndlrIECInvoice_tst.getSampleInvoiceItems());
        system.assertEquals(lstInvoiceItem.get(0).Product__c, oProduct.Id);
        system.assertEquals(lstInvoiceItem.get(0).Subscription_Zuora_ID__c, oSubscription.Zuora__External_Id__c);
        system.assertEquals(lstInvoiceItem.get(0).Subscription_Product_Charge_Zuora_ID__c, oSubscriptionCharge.Zuora__External_Id__c);*/
        
        // 002: Make sure that a Sales Order has been created by the invoice
       /* List<OrderItem> lstOrderItem = [SELECT Id FROM OrderItem WHERE Zuora_Subscription_Number__c = :oSubscription.Name];
        system.assertEquals(lstOrderItem.size(), 1);
        
    	System.debug('Unit Test: Finish: TestInvoice');*/
    }
}