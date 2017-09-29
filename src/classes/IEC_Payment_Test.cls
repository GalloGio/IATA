/**

	Project: eCommerce Enhancements
	   File: IEC_Payment_Test.cls
	Subject: Test Class for IEC Payments Enhancements.
	History: 2017-05-17, asantos, Initial Release.

*/

@isTest(SeeAllData=true)
private class IEC_Payment_Test {
	private static User user;
	private static Contact contact;
	private static Account account;
	private static Zuora__CustomerAccount__c billingAccount;
	private static Product_Category__c productCategory;
	private static Product_Information__c productInformation;
	private static Product_Information__c productInformation2;
	private static Product_Information__c productInformation3;
	private static zqu__ZProduct__c product;
	private static zqu__ProductRatePlan__c productRatePlan;
	private static zqu__ProductRatePlan__c productRatePlan2;
	private static zqu__ProductRatePlan__c productRatePlan3;
	private static zqu__ProductRatePlanCharge__c productRatePlanCharge;
	private static zqu__ProductRatePlanCharge__c productRatePlanCharge2;
	private static zqu__ProductRatePlanCharge__c productRatePlanCharge3;
	private static Product_Rate_Plan_Information__c productRatePlanInformation;
	private static Product_Rate_Plan_Information__c productRatePlanInformation2;
	private static Product_Rate_Plan_Information__c productRatePlanInformation3;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionProductCharge;

	private static final double QTY = 42.0;
	
	private static void setup() {
		user = IECTestUtil.createSampleGuestUserAndLogin();

		contact = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :user.ContactId LIMIT 1];
		account = [SELECT Id, Name FROM Account WHERE Id = :contact.AccountId LIMIT 1];

		billingAccount = IECTestUtil.createSampleBillingAccount(account, contact);

		insert billingAccount;

		product = IECTestUtil.CreateSampleProduct('Product1');
		product.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
		product.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;

		insert product;

		productRatePlan = IECTestUtil.CreateSampleProductRatePlan('RatePlan1', false, product);
		productRatePlan.zqu__Deleted__c = false;
		insert productRatePlan;

		productRatePlan2 = IECTestUtil.CreateSampleProductRatePlan('RatePlan2', false, product);
		productRatePlan2.zqu__Deleted__c = false;
		insert productRatePlan2;

		productRatePlan3 = IECTestUtil.CreateSampleProductRatePlan('RatePlan3', false, product);
		productRatePlan3.zqu__Deleted__c = false;
		insert productRatePlan3;

		productRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(productRatePlan, 'CHARGETEST', 42);
		productRatePlanCharge.zqu__Deleted__c = false;
		insert productRatePlanCharge;

		productRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(productRatePlan2, 'CHARGETEST', 84);
		productRatePlanCharge2.zqu__Deleted__c = false;
		insert productRatePlanCharge2;

		productRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(productRatePlan3, 'CHARGETEST', 0);
		productRatePlanCharge3.zqu__Deleted__c = false;
		insert productRatePlanCharge3;

		productCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
		productCategory.Active__c = true;
		insert productCategory;

		productInformation = IECTestUtil.CreateSampleProductInfo('ProductInfo', productCategory, product);
		insert productInformation;

		productRatePlanInformation = IECTestUtil.CreateSampleProductRatePlanInfo('RatePlanInformation1', false, productRatePlan, productInformation);
		productRatePlanInformation.Display_As_Monthly_Fee__c = false;
		productRatePlanInformation.Active__c = true;
		productRatePlanInformation.Order__c = 1;
		productRatePlanInformation.Subscription_Usage_Qty__c = QTY;
		insert productRatePlanInformation;

		productInformation2 = IECTestUtil.CreateSampleProductInfo('ProductInfo2', productCategory, product);
		insert productInformation2;

		productRatePlanInformation2 = IECTestUtil.CreateSampleProductRatePlanInfo('RatePlanInformation2', false, productRatePlan2, productInformation2);
		productRatePlanInformation2.Display_As_Monthly_Fee__c = false;
		productRatePlanInformation2.Active__c = true;
		productRatePlanInformation2.Order__c = 2;
		productRatePlanInformation2.Subscription_Usage_Qty__c = QTY * 2;
		insert productRatePlanInformation2;

		productInformation3 = IECTestUtil.CreateSampleProductInfo('ProductInfo3', productCategory, product);
		insert productInformation3;

		productRatePlanInformation3 = IECTestUtil.CreateSampleProductRatePlanInfo('RatePlanInformation3', false, productRatePlan3, productInformation3);
		productRatePlanInformation3.Display_As_Monthly_Fee__c = false;
		productRatePlanInformation3.Active__c = true;
		productRatePlanInformation3.Order__c = 3;
		productRatePlanInformation3.Subscription_Usage_Qty__c = 0;
		insert productRatePlanInformation3;
	}

	@isTest
	static void testUnit1() {
		IEC_ConfirmOrderController controller;

		setup();

		createOrder();

		Test.startTest();

		System.runAs(user) {
			Test.setCurrentPage(Page.IEC_ConfirmOrder);
			controller = new IEC_ConfirmOrderController();

			controller.onLoadAction();
			controller.initorder();

			controller.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
			controller.sfOrder.Zuora_Credit_Card_Id__c = '4028e6992e836e4a012e914e1dd85e22';
			controller.sfOrder.Payment_Transaction_Number__c = 'abc';
			controller.sfOrder.Zuora_Transaction_Id__c = 'aaabbbcccdddeeefff0123456789';

			controller.card = new IEC_CreditCard_DTO();

			controller.card.zId = controller.sfOrder.Zuora_Credit_Card_Id__c;
			controller.card.isDefault = true;
			controller.card.isExpired = false;
			controller.card.name = 'TEST SUCCESS';
			controller.card.creditCardType = 'VISA';
			controller.card.creditCardMaskNumber = 'xxxxxxxxxx111';
			controller.card.creditCardCVV = '123';
			controller.card.expirationMonth = 10;
			controller.card.expirationYear = 2016;
			controller.card.holderName = 'TEST VISA';
			controller.card.country = 'Canada';
			controller.card.addresLine1 = '123 Street';
			controller.card.addresLine2 = '';
			controller.card.city = 'Montreal';
			controller.card.stateProvince = 'QC';
			controller.card.postalCode = 'H0H0H0';
			controller.card.accountId = '123456accc';
			controller.card.lastTransactionStatus = 'Success';

			Zuora.zObject zPayment = controller.card.toZObjectForUpdate();

			update controller.sfOrder;

			try {
				controller.submitOrder();

				insert controller.sfOrder;
			} catch (Exception e) {
			}

			System.debug(String.valueOf(ApexPages.getMessages()));

			// ------------------------------------------- 
		}

		Zuora__Payment__c zuoraPaymentInsert = new Zuora__Payment__c(
			Name = 'P-99990001',
			Zuora__Account__c = account.Id,
			Zuora__Amount__c = controller.sfOrder.Total_Amount__c,
			Zuora__ReferenceId__c = controller.sfOrder.Payment_Transaction_Number__c,
			Zuora__PaymentMethod__c = 'Credit Card ' + controller.card.creditCardMaskNumber,
			Zuora__BillingAccount__c = billingAccount.Id,
			Zuora__EXT_ID__c = 'bbefbfbab1235bfaebecerfrc5413423',
			Zuora__Status__c = 'Error',
			Zuora__AuthTransactionId__c = controller.sfOrder.Zuora_Transaction_Id__c
		);

		try {
			insert zuoraPaymentInsert;
		} catch (Exception e) {
		}

		try {
			delete zuoraPaymentInsert;
		} catch (Exception e) {
		}

		Test.stopTest();
	}

	@isTest
	static void testUnit2() {
		IEC_ConfirmOrderController controller;

		setup();

		createOrder();

		Test.startTest();

		System.runAs(user) {
			Test.setCurrentPage(Page.IEC_ConfirmOrder);
			controller = new IEC_ConfirmOrderController();

			controller.onLoadAction();
			controller.initorder();

			controller.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
			controller.sfOrder.Zuora_Credit_Card_Id__c = '4028e6992e836e4a012e914e1dd85e22';
			controller.sfOrder.Payment_Transaction_Number__c = 'abc';
			controller.sfOrder.Zuora_Transaction_Id__c = 'aaabbbcccdddeeefff0123456789';

			controller.card = new IEC_CreditCard_DTO();

			controller.card.zId = controller.sfOrder.Zuora_Credit_Card_Id__c;
			controller.card.isDefault = true;
			controller.card.isExpired = false;
			controller.card.name = 'TEST SUCCESS';
			controller.card.creditCardType = 'VISA';
			controller.card.creditCardMaskNumber = 'xxxxxxxxxx111';
			controller.card.creditCardCVV = '123';
			controller.card.expirationMonth = 10;
			controller.card.expirationYear = 2016;
			controller.card.holderName = 'TEST VISA';
			controller.card.country = 'Canada';
			controller.card.addresLine1 = '123 Street';
			controller.card.addresLine2 = '';
			controller.card.city = 'Montreal';
			controller.card.stateProvince = 'QC';
			controller.card.postalCode = 'H0H0H0';
			controller.card.accountId = '123456accc';
			controller.card.lastTransactionStatus = 'Success';

			Zuora.zObject zPayment = controller.card.toZObjectForUpdate();

			update controller.sfOrder;

			try {
				controller.submitOrder();

				insert controller.sfOrder;
			} catch (Exception e) {
			}

			System.debug(String.valueOf(ApexPages.getMessages()));

			// ------------------------------------------- 
		}

		Zuora__Payment__c zuoraPaymentInsert2 = new Zuora__Payment__c(
			Name = 'P-99990002',
			Zuora__Account__c = account.Id,
			Zuora__Amount__c = controller.sfOrder.Total_Amount__c,
			Zuora__ReferenceId__c = controller.sfOrder.Payment_Transaction_Number__c,
			Zuora__PaymentMethod__c = 'Credit Card ' + controller.card.creditCardMaskNumber,
			Zuora__BillingAccount__c = billingAccount.Id,
			Zuora__EXT_ID__c = 'bbefbfbab1235bfaebecerfrc5413424',
			Zuora__Status__c = 'Processed',
			Zuora__AuthTransactionId__c = controller.sfOrder.Zuora_Transaction_Id__c
		);

		Zuora__Payment__c zuoraPaymentInsert3 = new Zuora__Payment__c(
			Name = 'P-99990003',
			Zuora__Account__c = account.Id,
			Zuora__Amount__c = controller.sfOrder.Total_Amount__c,
			Zuora__ReferenceId__c = controller.sfOrder.Payment_Transaction_Number__c,
			Zuora__PaymentMethod__c = 'Credit Card ' + controller.card.creditCardMaskNumber,
			Zuora__BillingAccount__c = billingAccount.Id,
			Zuora__EXT_ID__c = 'bbefbfbab1235bfaebecerfrc5413425',
			Zuora__Status__c = 'Processed',
			Zuora__AuthTransactionId__c = controller.sfOrder.Zuora_Transaction_Id__c,
			Bypass_Trigger_Logic__c = true
		);

		try {
			insert zuoraPaymentInsert2;
		} catch (Exception e) {
		}
		
		try {
			zuoraPaymentInsert2.Bypass_Trigger_Logic__c = true;

			update zuoraPaymentInsert2;
		} catch (Exception e) {
		}

		try {
			insert zuoraPaymentInsert3;
		} catch (Exception e) {
		}

		Test.stopTest();
	}

	@isTest
	static void testUnit3() {
		IEC_ConfirmOrderController controller;

		setup();

		createOrder();

		Test.startTest();

		System.runAs(user) {
			Test.setCurrentPage(Page.IEC_ConfirmOrder);
			controller = new IEC_ConfirmOrderController();

			controller.onLoadAction();
			controller.initorder();

			controller.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
			controller.sfOrder.Zuora_Credit_Card_Id__c = '4028e6992e836e4a012e914e1dd85e22';
			controller.sfOrder.Payment_Transaction_Number__c = 'abc';
			controller.sfOrder.Zuora_Transaction_Id__c = 'aaabbbcccdddeeefff0123456789';

			controller.card = new IEC_CreditCard_DTO();

			controller.card.zId = controller.sfOrder.Zuora_Credit_Card_Id__c;
			controller.card.isDefault = true;
			controller.card.isExpired = false;
			controller.card.name = 'TEST SUCCESS';
			controller.card.creditCardType = 'VISA';
			controller.card.creditCardMaskNumber = 'xxxxxxxxxx111';
			controller.card.creditCardCVV = '123';
			controller.card.expirationMonth = 10;
			controller.card.expirationYear = 2016;
			controller.card.holderName = 'TEST VISA';
			controller.card.country = 'Canada';
			controller.card.addresLine1 = '123 Street';
			controller.card.addresLine2 = '';
			controller.card.city = 'Montreal';
			controller.card.stateProvince = 'QC';
			controller.card.postalCode = 'H0H0H0';
			controller.card.accountId = '123456accc';
			controller.card.lastTransactionStatus = 'Success';

			Zuora.zObject zPayment = controller.card.toZObjectForUpdate();

			update controller.sfOrder;

			try {
				controller.submitOrder();

				insert controller.sfOrder;
			} catch (Exception e) {
			}

			System.debug(String.valueOf(ApexPages.getMessages()));

			// ------------------------------------------- 
		}

		Zuora__Payment__c zuoraPaymentInsert3 = new Zuora__Payment__c(
			Name = 'P-99990003',
			Zuora__Account__c = account.Id,
			Zuora__Amount__c = controller.sfOrder.Total_Amount__c,
			Zuora__ReferenceId__c = controller.sfOrder.Payment_Transaction_Number__c,
			Zuora__PaymentMethod__c = 'Credit Card ' + controller.card.creditCardMaskNumber,
			Zuora__BillingAccount__c = billingAccount.Id,
			Zuora__EXT_ID__c = 'bbefbfbab1235bfaebecerfrc5413425',
			Zuora__Status__c = 'Unknown',
			Zuora__AuthTransactionId__c = controller.sfOrder.Zuora_Transaction_Id__c
		);

		try {
			insert zuoraPaymentInsert3;
		} catch (Exception e) {
		}

		Test.stopTest();
	}

	@isTest
	static void testUnit4() {
		Test.startTest();

		String zqs = trgHndlrIECPayment.zoqlQueryString('Account', new List<String>{ 'Id', 'Name'}, 'Name', new List<String>{ 'Hello', 'World' });

		Zuora.zObject zp = new Zuora.zObject('Payment');
		Zuora.zObject zi = new Zuora.zObject('Invoice');
		Zuora.zObject zs = new Zuora.zObject('Subscription');

		List<IEC_Error_Log__c> errorLogList = new List<IEC_Error_Log__c>();

		zp.setValue('Id', '1231231313123');
		zp.setValue('CreatedDate', System.today());
		zp.setValue('Amount', 0.0);

		zi.setValue('Id', '1231231313123');

		zs.setValue('Id', '1231231313123');

		List<Zuora.zObject> zPaymentList = new List<Zuora.zObject>();
		List<Zuora.zObject> zInvoiceList = new List<Zuora.zObject>();
		List<Zuora.zObject> zSubscriptionList = new List<Zuora.zObject>();

		zPaymentList.add(zp);
		zInvoiceList.add(zi);
		zSubscriptionList.add(zs);

		trgHndlrIECPayment.zuoraDeletePayments(zPaymentList, errorLogList);
		trgHndlrIECPayment.zuoraDeleteInvoices(zInvoiceList, errorLogList);
		trgHndlrIECPayment.zuoraDeleteSubscriptions(zSubscriptionList, errorLogList);

		Test.stopTest();
	}

	private static void createOrder() {
		subscription = IECTestUtil.createSampleSubscription(account.Id, 'Subscription01', Date.today().addMonths(6));
		subscription.Zuora__CustomerAccount__c = billingAccount.Id;
		insert subscription;

		subscriptionProductCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), product, productRatePlan);
		insert subscriptionProductCharge;
		
		// Create Locations
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		
		SAP_CustomerMaster_Mock.returnError = 'test';
		SAP_CustomerMaster_Mock.returnOK = null;

		Location_Svc.initializeDefaultLocations(new List<Id> { contact.Id });

		Map<String,Location__c> locationMap = new Map<String,Location__c>();
		
		for (Location__c location : [SELECT Id, Type__c, SAP_Id__c FROM Location__c WHERE Account__c = :contact.AccountId]) {
			locationMap.put(location.Type__c.left(4).toLowerCase(), location);
		}

		// Create Order
		Order order = TestDataGenerator.generateOrder(1, contact.AccountId, contact.Id, contact.Id, false)[0];

		order.SoldTo_Location__c = locationMap.get('sold').Id;
		order.BillTo_Location__c = locationMap.get('bill').Id;
		order.ShipTo_Location__c = locationMap.get('ship').Id;

		order.OwnerId = user.Id;
		order.Status = 'New';
		order.Type = 'Cart';

		insert order;

		Integer nb = 2;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(order.Id, nb, false);

		for (OrderItem orderItem : orderItems) {
			orderItem.Auto_Renew__c = true;
		}

		insert orderItems;

		Set<String> productIdSet = new Set<String>();

		for (OrderItem orderItem : new OrderItem_Sel().getOrderItems(order.Id)) {
			productIdSet.add(orderItem.Product__c);

			IECOrder_Svc.addProductToCookie(orderItem.Product_Number__c, orderItem.Quantity, true);
		}
		
		List<Product2> productList = [SELECT Id, SAP_Material_Number__c, ZProduct__c FROM Product2 WHERE Id IN :productIdSet];

		List<zqu__ZProduct__c> zProductList = TestDataGenerator.generateZProducts(nb, false);

		for (Integer x = 0; x < nb; x++) {
			zqu__ZProduct__c zProduct = zProductList[x];

			Product2 prod = productList[x];

			zProduct.SAPProductMaterialNo__c = prod.SAP_Material_Number__c;
		}
		insert zProductList;

		List<zqu__ProductRatePlan__c> zRatePlanList = new List<zqu__ProductRatePlan__c>();

		for (Integer x = 0; x < productList.size(); x++) {
			Product2 prod = productList[x];

			zqu__ZProduct__c zprod = zProductList[x];

			zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans(zprod.Id, 1, false)[0];
			zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans(zprod.Id, 1, false)[0];

			zPlan.Couponcode__c = 'COUP123';
			zRatePlanList.add(zPlan);
			zRatePlanList.add(unitPricePlan);

			prod.ZProduct__c = zprod.Id;
		}
		insert zRatePlanList;

		List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
		 //Create Unit Price Charge & Discount for each Plan 
		for(zqu__ProductRatePlan__c rp : zRatePlanList)
		{
			//Unit Price Volume Price & Discount
			List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);
			charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
			charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME; 
			charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
			zCharges.addAll(charges);
		}
		insert zCharges;
		List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();
		//-- Generate Tiers for Volume Prices 
		for(zqu__ProductRatePlanCharge__c c : zCharges)
			if(c.zqu__Model__c == ZuoraUtil.ZCHARGE_MODEL_VOLUME)
				zTiers.addAll(TestDataGenerator.generateZTiers(c.Id, 3, false));
			else
				zTiers.addAll(TestDataGenerator.generateZTiers(c.Id, 1, false));
		insert zTiers;
		
		update ProductList;
	}
}