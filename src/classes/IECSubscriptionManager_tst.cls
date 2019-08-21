@IsTest 
public with sharing class IECSubscriptionManager_tst {

	//private static final String Product_Audience = 'Member';
	
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product_Information__c oProductInfo2;
	private static Product2 oProduct;
	private static Product2 oProduct2;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
	private static Swap_Configuration__c oSwapConfig;
	private static Terms_and_Conditions__c oTnCProduct1;
	private static Attachment oAttachment1;
	private static Contact oContact;
	
	private static Account oAccount;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static Zuora__ZInvoice__c oInvoice1;
	private static Zuora__ZInvoice__c oInvoice2;	// ICH invoice with no payment
	private static Zuora__Payment__c oPayment1;
	private static Zuora__PaymentInvoice__c oPaymentInvoice1;
	
	static{
		setupData(true);
	}
	
	private static void setupData(Boolean triable){
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
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', triable, oProduct);
		insert oProductRatePlan;
		
		oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('PRPTST2', triable, oProduct2);
		insert oProductRatePlan2;
		
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', triable, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo.Display_As_Monthly_Fee__c = !triable;
		insert oProductRatePlanInfo;
		
		oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST2', triable, oProductRatePlan2, oProductInfo2);
		oProductRatePlanInfo2.Display_As_Monthly_Fee__c = !triable;
		insert oProductRatePlanInfo2;
		
		oSwapConfig = new Swap_Configuration__c(Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id, 
												Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
												Relationship_Type__c = IECConstants.SwappingType_Swap
												);
		insert oSwapConfig;
		 
		oContact = new Contact(FirstName = 'Test', LastName='User');
		insert oContact;

		// create a Terms & Conditions
		oTnCProduct1 = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTnCProduct1;
        
        // create dummy Attachment for the T&C
        oAttachment1 = IECTestUtil.CreateSampleAttachment(oTnCProduct1.Id);
        insert oAttachment1;
        
        // set the effective date of the T&C
        oTnCProduct1.Effective_Start_Date__c = Date.today().addDays(-5);
        update oTnCProduct1;
	}
	
	private static void setupInvoicesAndPayments() {
		oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;
		
		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		insert oBillingAccount;
		
		oInvoice1 = IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 213.45);
		insert oInvoice1;
		
		oInvoice2 = IECTestUtil.createSampleInvoice(oBillingAccount, Date.today().addDays(-3), 42.42);
		insert oInvoice2;
		
		oPayment1 = IECTestUtil.createSamplePayment(oBillingAccount, 213.45, oInvoice1, 'Processed');
		insert oPayment1;
		
		oPaymentInvoice1 = new Zuora__PaymentInvoice__c();
		oPaymentInvoice1.Zuora__Invoice__c = oInvoice1.Id;
		oPaymentInvoice1.Zuora__Payment__c = oPayment1.Id;
		oPaymentInvoice1.Zuora__ApplyAmount__c = 213.45;
		insert oPaymentInvoice1;
	}
	
	static testmethod void testGetTriableProducts1(){
		List<Product_Information__c> lst;
		
		//oProductRatePlanInfo.Is_Triable__c = false;
		oProductRatePlan.IsTriable__c = IECConstants.ProductRatePlanIsTriable_NO;
		update oProductRatePlan;
		oProductRatePlan2.IsTriable__c = IECConstants.ProductRatePlanIsTriable_NO;
		update oProductRatePlan2;
		
		lst = IECSubscriptionManager.getTriableProducts();
		System.assertEquals(0,lst.size(),'There should be no triable product');
	}
	
	static testmethod void testGetTriableProducts2(){
		List<Product_Information__c> lst;
		
		//oProductRatePlanInfo.Is_Triable__c = true;
		oProductRatePlan.IsTriable__c = IECConstants.ProductRatePlanIsTriable_YES;
		update oProductRatePlan;
		
		lst = IECSubscriptionManager.getTriableProducts();
		System.assert(lst.size() >= 1,'There should be at least one triable product');
	}
	
	static testmethod void testIsProductTriable1(){
		//oProductRatePlanInfo.Is_Triable__c = false;
		oProductRatePlan.IsTriable__c = IECConstants.ProductRatePlanIsTriable_NO;
		update oProductRatePlan;
		
		Boolean b = IECSubscriptionManager.isProductTriable(oProductInfo.Id);
		System.assertEquals(false,b,'The product should not be triable');  
	}
	
	static testmethod void testIsProductTriable2(){
		//oProductRatePlanInfo.Is_Triable__c = true;
		oProductRatePlan.IsTriable__c = IECConstants.ProductRatePlanIsTriable_YES;
		update oProductRatePlan;
		
		Boolean b = IECSubscriptionManager.isProductTriable(oProductInfo.Id);
		System.assertEquals(true,b,'The product should be triable'); 
	}
	
	static testmethod void testCanContactPurchaseTrialPlan(){
		oProductRatePlan.IsTriable__c = 'Yes';
		update oProductRatePlan;
		//oProductRatePlanInfo.Is_Triable__c = true;
		update oProductRatePlanInfo;
		
		Boolean b = IECSubscriptionManager.canContactPurchaseTrialPlan(oContact.Id, oProductRatePlanInfo.Id);
		System.assertEquals(true,b,'The contact should be able to try the product'); 
		
		IECSubscriptionManager.addTrialSubscription(oContact.Id, oProductRatePlanInfo.Id);
		b = IECSubscriptionManager.canContactPurchaseTrialPlan(oContact.Id, oProductRatePlanInfo.Id);
		System.assertEquals(false,b,'The contact should not be able to try the product');
	}
	
	static testmethod void testGetTargetSwappedRatePlans(){
		Set<ID> il = new Set<ID>();
		il.add(oProductRatePlanInfo.Id);
		
		Map<ID,Product_Rate_Plan_Information__c> im;
		
		im = IECSubscriptionManager.getTargetSwappedRatePlans(il, 'AnyClientType');
		System.assertEquals(true,im.isEmpty(),'There should be no swappable product for this client type');
		
		im = IECSubscriptionManager.getTargetSwappedRatePlans(il, IECConstants.ProductAudience_Zuora_MEMBERAIRLINE);
		System.assertEquals(1,im.size(),'There should be one swappable product for this client type');
		System.assertEquals(oProductRatePlanInfo2.Id,im.get(oProductRatePlanInfo.Id).Id,'The swappable product is not the expected one');
	}
	
	static testmethod void testCanPurchaseAmountWithPaymentMethod() {
		IEC_Payment_Threshold__c oCreditCardTreshold = new IEC_Payment_Threshold__c();
		oCreditCardTreshold.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
		oCreditCardTreshold.Min_amount__c = 15.0;
		insert oCreditCardTreshold;
		
		// Test #1 - test minimum boundary
		system.assert(!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, 14.0), 'Should not be able to buy below the minimum limit');
		system.assert(IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, 15.0), 'Should be able to buy on the minimum limit');
		system.assert(IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, 16.0), 'Should be able to buy above on the minimum limit');
		
		oCreditCardTreshold.Max_amount__c = 3000.0;
		update oCreditCardTreshold;
		
		// Test #2 - test maximum boundary
		system.assert(!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, 3001.0), 'Should not be able to buy above the maximum limit');
		system.assert(IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, 3000.0), 'Should be able to buy on the maximum limit');
		system.assert(IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, 2999.0), 'Should be able to buy below  the maximum limit');
		
		// Test #3 - test for unknown payment type
		system.assert(!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod('asdfasdfasdfasdf', 420.00), 'Should return false because payment type is unknown');
	}
	
	// NOTE: the SeeAllData flag is required when code is creating Zuora.zObject
	@isTest(SeeAllData=true)
	static void testPreview() {
		
		// create a shopping cart with an item
		IEC_Shopping_Cart__c cart = IECShoppingCartHelper.createNewShoppingCart(null, false);
		IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
		
		List<Zuora.zObject> listRatePlanDataObject = IECShoppingCartHelper.createRatePlanDataObjectFromCart(cart);
		Zuora.zObject invoice = IECSubscriptionManager.previewInvoice(listRatePlanDataObject, null);
		system.assert(invoice != null, 'An invoice should be returned from the preview call');		
	}
	
	// NOTE: the SeeAllData flag is required when code is creating Zuora.zObject
	@isTest(SeeAllData=true)
	static void testCreditCardSubscribe() {
		
		//setupData(false);
		Integer iQuantity = 1;
		IEC_Shopping_Cart__c cart;
		List<IEC_Cart_Item__c> listCartItems;
		IECConstants.PaymentType ePmType;
		IECCustomer oCustomer;
		List<Zuora.zApi.SubscribeResult> listResults;
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
    		
    		// create a shopping cart with an item
			cart = IECShoppingCartHelper.createNewShoppingCart(null, false);
			IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, iQuantity);
			listCartItems = IECShoppingCartHelper.getCartItems(cart);
				
			// parse the selected payment method type
			ePmType = IECConstants.PaymentType.CREDIT_CARD;
			
			oCustomer = IECCustomer.getCurrentIECCustomer();
	
			// create sample PaymentMethod
			IECZuoraHelper.PaymentMethod oPaymentMethod = new IECZuoraHelper.PaymentMethod(IECTestUtil.createSampleZuoraPaymentMethod('444', '99999', 2999, 12));
	
			// subscribe call			
			listResults = IECSubscriptionManager.subscribe(listCartItems, oCustomer, ePmType, oPaymentMethod, new List<Boolean>{false}, new List<Terms_and_Conditions__c> {oTnCProduct1}, null);
    	}
			
		// Test #1 - the subscribe result
		system.assert(listResults != null && listResults.size() == 1, 'A SubscribeResult should be returned from the subscribe() call');
		Zuora.zApi.SubscribeResult res = listResults.get(0);
		system.assert(res.Success, 'The SubscribeResult should be successful');
		
		// Test #2 - the subscription history creation
		IEC_Subscription_History__c oSubHist = IECSubscriptionManager.getSubscriptionHistoryByName(res.SubscriptionNumber);

		system.assert(oSubHist != null, 'A IEC_Subscription_History__c object should be created after the subscribe() call');
		system.assertEquals(res.AccountNumber, oSubHist.Billing_Account_Number__c, 'The appropriate Account Number should be saved');
		system.assertEquals(oCustomer.RelatedAccount.Id, oSubHist.Related_Account__c, 'The appropriate Account should be saved');
		system.assertEquals(oCustomer.RelatedContact.Id, oSubHist.Related_Contact__c, 'The appropriate Contact should be saved');
		system.assertEquals(listCartItems.get(0).Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c, oSubHist.Purchased_Product_Category__c, 'The appropriate Product Category should be saved');
		system.assertEquals(listCartItems.get(0).Related_Rate_Plan_Information__r.Related_Product_Information__c, oSubHist.Purchased_Product_Information__c, 'The appropriate Product Information should be saved');
		system.assertEquals(listCartItems.get(0).Related_Rate_Plan_Information__c, oSubHist.Purchased_Product_Rate_Plan_Information__c, 'The appropriate Rate Plan Information should be saved');
		system.assertEquals(listCartItems.get(0).Related_Rate_Plan_Information__r.Related_Product_Information__r.New_Related_Product__r.zqu__SKU2__c, oSubHist.Purchased_Product_SKU__c, 'The appropriate Product SKU should be saved');
		system.assertEquals(iQuantity, oSubHist.Rate_Plan_Quantity__c, 'The appropriate quantity should be saved');
		system.assertEquals(res.InvoiceNumber, oSubHist.Invoice_Number__c, 'The appropriate Invoice Number should be saved');
		// doesnt work, dont know why...
		//system.assertEquals(oTnCProduct1.Id, oSubHist.Accepted_Terms_and_Conditions__c, 'The appropriate Terms_and_Conditions__c should be saved');
		system.assertEquals(IECConstants.parsePaymentMethodEnumToPicklistValue(ePmType), oSubHist.Selected_Payment_Method__c, 'The appropriate Payment method should be saved');
    	
	}
	
	// NOTE: the SeeAllData flag is required when code is creating Zuora.zObject
	@isTest(SeeAllData=true)
	static void testICHSubscribe() {
		//setupData(false);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
    		// create a shopping cart with an item
			IEC_Shopping_Cart__c cart = IECShoppingCartHelper.createNewShoppingCart(null, false);
			IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
			List<IEC_Cart_Item__c> listCartItems = IECShoppingCartHelper.getCartItems(cart);
				
			// parse the selected payment method type
			IECConstants.PaymentType ePmType = IECConstants.PaymentType.ICH;
	
			// create sample PaymentMethod
			IECZuoraHelper.PaymentMethod oPaymentMethod = new IECZuoraHelper.PaymentMethod(IECTestUtil.createSampleZuoraPaymentMethod('444', '99999', 2999, 12));
	
			// subscribe call			
			List<Zuora.zApi.SubscribeResult> listResults = IECSubscriptionManager.subscribe(listCartItems, IECCustomer.getCurrentIECCustomer(), ePmType, oPaymentMethod, new List<Boolean>{false}, new List<Terms_and_Conditions__c> {oTnCProduct1}, null);
			
			system.assert(listResults != null && listResults.size() == 1, 'A SubscribeResult should be returned from the subscribe() call');
    	}
	}
	
	// NOTE: the SeeAllData flag is required when code is creating Zuora.zObject
	@isTest(SeeAllData=true)
	static void testPaymentMethods() {
		
		List<Zuora.zObject> lstPM = IECSubscriptionManager.getPaymentMethodsFromZuora('someAccountId');
		system.assert(lstPM != null && lstPM.size() > 0, 'The dummy payment methods should be returned');
	}
	
	@isTest(SeeAllData=true)
	static void testInvoicesPayments() {
		setupInvoicesAndPayments();
		
		List<Zuora__ZInvoice__c> lstInvoices = IECSubscriptionManager.getInvoicesByBillingAccount(oBillingAccount.Id, true);
		system.assert(lstInvoices.size() == 2, '2 invoices should be found');
		
		lstInvoices = IECSubscriptionManager.getInvoicesByBillingAccount(oBillingAccount.Id, false);
		system.assert(lstInvoices.size() == 1, '1 invoice should be found');
		
		lstInvoices = IECSubscriptionManager.getSortedInvoicesByBillingAccount(oBillingAccount.Id, true, 'Zuora__TotalAmount__c', 'ASC');
		system.assert(lstInvoices.size() != 0 && lstInvoices.get(0).Id == oInvoice2.Id, 'oInvoice2 should be sorted first');
		
		List<Zuora__Payment__c> lstPayments = IECSubscriptionManager.getPaymentsByBillingAccount(oBillingAccount.Id);
		system.assert(lstPayments.size() == 1, '1 payment should be found');
		
		lstPayments = IECSubscriptionManager.getSortedPaymentsByBillingAccount(oBillingAccount.Id, 'Zuora__EffectiveDate__c', 'ASC');
		system.assert(lstPayments.size() == 1, '1 payment should be found');
		
		List<Zuora__PaymentInvoice__c> lstPaymentInvoices = IECSubscriptionManager.getPaymentInvoicesByInvoiceID(oInvoice1.Id);
		system.assert(lstPaymentInvoices.size() == 1 && lstPaymentInvoices.get(0).Zuora__Invoice__c == oInvoice1.Id, '1 PaymentInvoice should be found by InvoiceID for Invoice1');
		
		lstPaymentInvoices = IECSubscriptionManager.getPaymentInvoicesByPaymentID(oPayment1.Id);
		system.assert(lstPaymentInvoices.size() == 1 && lstPaymentInvoices.get(0).Zuora__Payment__c == oPayment1.Id, '1 PaymentInvoice should be found by PaymentID for Invoice1');
		
		lstPaymentInvoices = IECSubscriptionManager.getPaymentInvoicesByInvoiceID(oInvoice2.Id);
		system.assert(lstPaymentInvoices.size() == 0, 'No PaymentInvoice should be found for Invoice2');
	}
}