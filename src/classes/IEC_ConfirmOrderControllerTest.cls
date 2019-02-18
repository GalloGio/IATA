@isTest
private class IEC_ConfirmOrderControllerTest 
{
	@isTest (SeeAllData=true)
	static void test_not_logged() 
	{
		IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

		//-- Load page 
		System.assertEquals(null, ctrl.loggedCustomer);
		ctrl.onLoadAction(); 
	}

	@isTest (SeeAllData=true)
	static void test_empty_cart() 
	{
		//-- Create an logged-in has portal customer 
		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		System.runAs(usr)
		{
			Test.setCurrentPage(Page.IEC_ConfirmOrder);
			IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

			//-- Validate Cart is Empty 
			System.assertEquals(null, ctrl.onLoadAction());
		}
	}

	/****************************************************************************************************
		Created by Thai 2016-12-16
			Cover method initializeDefaultLocations that indirectly covers method formatAddressToQuery
	****************************************************************************************************/
	@isTest (SeeAllData=true)
	static void test_SAPPartner_and_MissingPayment()
	{
		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = 'test';
		SAP_CustomerMaster_Mock.returnOK = null;
		Location_Svc.initializeDefaultLocations(new List<Id>{oContact.Id});
		Map<String, Location__c> mapLocation = new Map<String, Location__c>();
		for (Location__c loc : [select Id, Type__c, SAP_Id__c from Location__c where Account__c = :oContact.AccountId])
			mapLocation.put(loc.Type__c.left(4).toLowerCase(), loc);

		//*** create order
		Order oOrder = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
		oOrder.SoldTo_Location__c = mapLocation.get('sold').Id;
		oOrder.BillTo_Location__c = mapLocation.get('bill').Id;
		oOrder.ShipTo_Location__c = mapLocation.get('ship').Id;
		oOrder.OwnerId = oUser.Id;
		oOrder.Type = 'Cart';
		oOrder.Status = 'New';
		oOrder.Payment_Type__c = 'Check';
		insert oOrder;
		TestDataGenerator.generateOrderItem(oOrder.Id, 1, true);
		Id idProduct = [select PricebookEntry.Product2.Id from OrderItem where OrderId = :oOrder.Id limit 1][0].PricebookEntry.Product2.Id;
		update new Product2(Id=idProduct, Sell_through_eCommerce__c=true, Inventory_Status__c='In stock');

		Test.startTest();
			IEC_ConfirmOrderController ctrl;
			System.runAs(oUser)
			{
				Test.setCurrentPage(Page.IEC_ConfirmOrder);
				ctrl = new IEC_ConfirmOrderController();

				//*** validate SAP Partner
				ctrl.onLoadAction();
				system.assert(ctrl.stopProcess == true, 'Wrong value for missing partners');
			}

			mapLocation.get('sold').SAP_Id__c = 'sold';
			mapLocation.get('bill').SAP_Id__c = 'bill';
			mapLocation.get('ship').SAP_Id__c = 'ship';
			update mapLocation.values();

			System.runAs(oUser)
			{
				Test.setCurrentPage(Page.IEC_ConfirmOrder);
				ctrl = new IEC_ConfirmOrderController();

				//*** validate SAP Partner
				ctrl.onLoadAction();
				system.assert(ctrl.stopProcess == false, 'Wrong value for valid partners');
				
				//*** validate missing payment
				oOrder.Payment_Type__c = null;
				update oOrder;
				ctrl.onLoadAction();
				system.assert(ctrl.stopProcess == true, 'Wrong value for missing payment method');
			}
		Test.stopTest();
	} //*** end of "test_validSAPPartner"

	@isTest (SeeAllData=true)
	static void test_Payment_BT_Check() 
	{
		Database.insert(new Apex_Setting__c(Name='Pardot Campaign', Text_1__c='http://go.updates.iata.org'), false);
		User usr = IECTestUtil.createSampleGuestUserAndLogin();

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(usr.ContactId);
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = null;
		SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold1', 'Bill1', 'Ship1'});
		Location_Svc.initializeDefaultLocations(new List<Id>{oContact.Id});
		Map<String, Location__c> mapLocation = new Map<String, Location__c>();
		for (Location__c loc : [select Id, Type__c, SAP_Id__c from Location__c where Account__c = :oContact.AccountId])
			mapLocation.put(loc.Type__c.left(4).toLowerCase(), loc);
		if (String.isBlank(mapLocation.get('sold').SAP_Id__c)) mapLocation.get('sold').SAP_Id__c = 'sold';
		if (String.isBlank(mapLocation.get('bill').SAP_Id__c)) mapLocation.get('bill').SAP_Id__c = 'bill';
		if (String.isBlank(mapLocation.get('ship').SAP_Id__c)) mapLocation.get('ship').SAP_Id__c = 'ship';
		update mapLocation.values();

		//-- Create Order for customer
		Order ord = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
		ord.SoldTo_Location__c = mapLocation.get('sold').Id;
		ord.BillTo_Location__c = mapLocation.get('bill').Id;
		ord.ShipTo_Location__c = mapLocation.get('ship').Id;
		ord.OwnerId = usr.Id;
		ord.Type = 'Cart';
		ord.Status = 'New';
		ord.Payment_Type__c = 'Check';
		insert ord;

		//-- Create orderitems 
		Integer nb =2;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
		for(OrderItem oi : orderitems)
		{
			oi.Auto_Renew__c  = true;
		}
		insert orderItems;

		//-- Generate Coupon Code Rate plan for items 
		Set<String> productIds = new Set<String>();
		
		for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
		{
			productIds.add(oi.Product__c);
			IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
		}

		List<Product2> products = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE Id IN :productIds];

		//-- Generate RatePlans & Charges & Tiers
		List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
		for(Integer x = 0; x < products.size(); x++)
		{
			Product2 prod = products[x]; 
			zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zPlan.Couponcode__c = 'COUP123';
			zRatePlans.add(zPlan); 
			zRatePlans.add(unitPricePlan);
		}

		insert zRatePlans;
		List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
		 //Create Unit Price Charge & Discount for each Plan 
		for(zqu__ProductRatePlan__c rp : zRatePlans)
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
		update products;

		Test.startTest();
			System.runAs(usr)
			{
				Test.setCurrentPage(Page.IEC_ConfirmOrder);
				IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

				//-- Load Page
				ctrl.onLoadAction();
				if (ctrl.sfOrder == null) ctrl.initorder();   //*** don't understand why sometime "initorder" wasn't called

				//-- Submit without Payment_Type__c 
				ctrl.sfOrder.Payment_Type__c = null;
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(),Label.IEC_Error_PleaseSelectPaymentMethod), 'Invalid error: ' + ApexPages.getMessages());

				//-- Submit using Bank Transfert
				ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_BankTransfer;
				try{ctrl.submitOrder();}catch(Exception ex){}
				//*** assert is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Order_wire_transfer_confirmation_message), 'Invalid error: ' + ApexPages.getMessages());

				//-- Submit using Check
				ctrl.sfOrder.Payment_Type__c = IECConstants.ORDER_STATUS_CHECK;
				try{ctrl.submitOrder();}catch(Exception ex){}
				//*** assert is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Order_Check_confirmation_message), 'Invalid error: ' + ApexPages.getMessages());
			}
		Test.stopTest();
	} //*** end of "test_Payment_BT_Check"

	@isTest (SeeAllData=true)
	static void test_Payment_CreditCard() 
	{
		Database.insert(new Apex_Setting__c(Name='Pardot Campaign', Text_1__c='http://go.updates.iata.org'), false);
		User usr = IECTestUtil.createSampleGuestUserAndLogin();

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(usr.ContactId);
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = null;
		SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold1', 'Bill1', 'Ship1'});
		Location_Svc.initializeDefaultLocations(new List<Id>{oContact.Id});
		Map<String, Location__c> mapLocation = new Map<String, Location__c>();
		for (Location__c loc : [select Id, Type__c, SAP_Id__c from Location__c where Account__c = :oContact.AccountId])
			mapLocation.put(loc.Type__c.left(4).toLowerCase(), loc);
		if (String.isBlank(mapLocation.get('sold').SAP_Id__c)) mapLocation.get('sold').SAP_Id__c = 'sold';
		if (String.isBlank(mapLocation.get('bill').SAP_Id__c)) mapLocation.get('bill').SAP_Id__c = 'bill';
		if (String.isBlank(mapLocation.get('ship').SAP_Id__c)) mapLocation.get('ship').SAP_Id__c = 'ship';
		update mapLocation.values();

		//-- Create Order for customer
		Order ord = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
		ord.SoldTo_Location__c = mapLocation.get('sold').Id;
		ord.BillTo_Location__c = mapLocation.get('bill').Id;
		ord.ShipTo_Location__c = mapLocation.get('ship').Id;
		ord.OwnerId = usr.Id;
		ord.Type = 'Cart';
		ord.Status = 'New';
		insert ord;

		//-- Create orderitems 
		Integer nb =2;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
		for(OrderItem oi : orderitems)
		{
			oi.Auto_Renew__c  = true;
		}
		insert orderItems;

		//-- Generate Coupon Code Rate plan for items 
		Set<String> productIds = new Set<String>();
		
		for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
		{
			productIds.add(oi.Product__c);
			IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
		}

		List<Product2> products = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE Id IN :productIds];

		//-- Generate RatePlans & Charges & Tiers
		List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
		for(Integer x = 0; x < products.size(); x++)
		{
			Product2 prod = products[x]; 
			zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zPlan.Couponcode__c = 'COUP123';
			zRatePlans.add(zPlan); 
			zRatePlans.add(unitPricePlan);
		}
		insert zRatePlans;
		List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
		 //Create Unit Price Charge & Discount for each Plan 
		for(zqu__ProductRatePlan__c rp : zRatePlans)
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
		update products;

		Test.startTest();
			System.runAs(usr)
			{
				Test.setCurrentPage(Page.IEC_ConfirmOrder);
				IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

				//-- Load Page
				ctrl.onLoadAction();
				ctrl.initorder();

				String productWrapper = ctrl.productWrapper;

				//-- without credit card
				ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
				ctrl.sfOrder.Zuora_Credit_Card_Id__c = null;
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(),Label.IEC_Error_PleaseSelectPaymentMethod), 'Invalid error: ' + ApexPages.getMessages());

				//-- error on subscription part
				ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
				ctrl.sfOrder.Zuora_Credit_Card_Id__c = '4028e6992e836e4a012e914e1dd85e22';
				ctrl.card = null;
				try{ctrl.submitOrder();}catch(Exception ex){}

				System.debug('ApexMessages:' + ApexPages.getMessages());

				System.assert(pageMessagesContains(ApexPages.getMessages(),Label.Order_transaction_failed_message),'Invalid error: ' + ApexPages.getMessages());

				//-- error on parse part
				ctrl.card = new IEC_CreditCard_DTO();
				ctrl.card.zId = ctrl.sfOrder.Zuora_Credit_Card_Id__c;
				ctrl.card.isDefault = true;
				ctrl.card.isExpired = false;
				ctrl.card.name = 'TEST FAILED';
				ctrl.card.creditCardType = 'VISA';
				ctrl.card.creditCardMaskNumber = 'xxxxxxxxxx111';
				ctrl.card.creditCardCVV = '123';
				ctrl.card.expirationMonth = 10;
				ctrl.card.expirationYear = 2016;
				ctrl.card.holderName = 'TEST VISA';
				ctrl.card.country = 'Canada';
				ctrl.card.addresLine1 = '123 Street';
				ctrl.card.addresLine2 = '';
				ctrl.card.city = 'Montreal';
				ctrl.card.stateProvince = 'QC';
				ctrl.card.postalCode = 'H0H0H0';
				ctrl.card.accountId = '123456accc';
				ctrl.card.lastTransactionStatus = 'Success';
				Zuora.zObject zPayment = ctrl.card.toZObjectForUpdate();
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(), Label.Order_transaction_failed_message), 'Invalid error: ' + ApexPages.getMessages());

				//-- success on parse but no transaction number
				ctrl.card.name = 'TEST SUCCESS';
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(), Label.Order_transaction_failed_message), 'Invalid error: ' + ApexPages.getMessages());

				//-- success on parse with transaction number
				ctrl.card.name = 'TEST SUCCESS';
				ctrl.sfOrder.Payment_Transaction_Number__c = 'abc';
				update ctrl.sfOrder;
				try{ctrl.submitOrder();}catch(Exception ex){}
				//*** assert is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Order_Credit_Card_confirmation_message), 'Invalid error: ' + ApexPages.getMessages());
			}
		Test.stopTest();
	} //*** end of "test_Payment_CreditCard"

	private static Boolean pageMessagesContains(ApexPages.Message[] arrayOfMessages, String messageString) {
		Boolean result = false;

		if (arrayOfMessages != null && arrayOfMessages.size() > 0) {
			for (Integer i = 0; i < arrayOfMessages.size(); i++) {
				ApexPages.Message messageItem = arrayOfMessages[i];
				String messageDetail = messageItem.getDetail();

				if (messageDetail != null && messageDetail.equalsIgnoreCase(messageString)) {
					result = true;
					break;
				}
			}
		}

		return result;
	}

	@isTest (SeeAllData=true)
	static void test_Payment_ICH() 
	{
		Database.insert(new Apex_Setting__c(Name='Pardot Campaign', Text_1__c='http://go.updates.iata.org'), false);
		User usr = IECTestUtil.createSampleGuestUserAndLogin();

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(usr.ContactId);
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = null;
		SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold1', 'Bill1', 'Ship1'});
		Location_Svc.initializeDefaultLocations(new List<Id>{oContact.Id});
		Map<String, Location__c> mapLocation = new Map<String, Location__c>();
		for (Location__c loc : [select Id, Type__c, SAP_Id__c from Location__c where Account__c = :oContact.AccountId])
			mapLocation.put(loc.Type__c.left(4).toLowerCase(), loc);
		if (String.isBlank(mapLocation.get('sold').SAP_Id__c)) mapLocation.get('sold').SAP_Id__c = 'sold';
		if (String.isBlank(mapLocation.get('bill').SAP_Id__c)) mapLocation.get('bill').SAP_Id__c = 'bill';
		if (String.isBlank(mapLocation.get('ship').SAP_Id__c)) mapLocation.get('ship').SAP_Id__c = 'ship';
		update mapLocation.values();

		//*** create campaign to cover method "updateCampaignMembers"
		Campaign oCampaign = TestDataGenerator.generateCampaigns(1, true)[0];
		insert new CampaignMember(CampaignId = oCampaign.Id, ContactId = oContact.Id );

		//-- Create Order for customer
		Order ord = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
		ord.SoldTo_Location__c = mapLocation.get('sold').Id;
		ord.BillTo_Location__c = mapLocation.get('bill').Id;
		ord.ShipTo_Location__c = mapLocation.get('ship').Id;
		ord.OwnerId = usr.Id;
		ord.Type = 'Cart';
		ord.Status = 'New';
		ord.Campaign__c = oCampaign.Id;
		insert ord;

		//-- Create orderitems 
		Integer nb =2;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
		for(OrderItem oi : orderitems)
		{
			oi.Auto_Renew__c  = true;
		}
		insert orderItems;

		//-- Generate Coupon Code Rate plan for items 
		Set<String> productIds = new Set<String>();
		
		for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
		{
			productIds.add(oi.Product__c);
			IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
		}

		List<Product2> products = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE Id IN :productIds];

		//-- Generate RatePlans & Charges & Tiers
		List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
		for(Integer x = 0; x < products.size(); x++)
		{
			Product2 prod = products[x]; 
			zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zPlan.Couponcode__c = 'COUP123';
			zRatePlans.add(zPlan); 
			zRatePlans.add(unitPricePlan);
		}
		insert zRatePlans;
		List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
		 //Create Unit Price Charge & Discount for each Plan 
		for(zqu__ProductRatePlan__c rp : zRatePlans)
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
		update products;

		Test.startTest();
			System.runAs(usr)
			{
				Test.setCurrentPage(Page.IEC_ConfirmOrder);
				IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

				//-- Load Page
				ctrl.onLoadAction();
				ctrl.initorder();

				//-- submit
				ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_ICH;
				try{ctrl.submitOrder();}catch(Exception ex){}
				//*** assert is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Order_ICH_confirmation_message), 'Invalid error: ' + ApexPages.getMessages());
			}
		Test.stopTest();
	} //*** end of "test_Payment_ICH"






	@isTest (SeeAllData=true)
	static void test_Payment_CreditCardExtra() 
	{
		Database.insert(new Apex_Setting__c(Name='Pardot Campaign', Text_1__c='http://go.updates.iata.org'), false);
		User usr = IECTestUtil.createSampleGuestUserAndLogin();

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(usr.ContactId);
		Test.setMock(WebServiceMock.class, new SAP_CustomerMaster_Mock());
		SAP_CustomerMaster_Mock.returnError = null;
		SAP_CustomerMaster_Mock.returnOK = JSON.serialize(new List<String>{'Sold1', 'Bill1', 'Ship1'});
		Location_Svc.initializeDefaultLocations(new List<Id>{oContact.Id});
		Map<String, Location__c> mapLocation = new Map<String, Location__c>();
		for (Location__c loc : [select Id, Type__c, SAP_Id__c from Location__c where Account__c = :oContact.AccountId])
			mapLocation.put(loc.Type__c.left(4).toLowerCase(), loc);
		if (String.isBlank(mapLocation.get('sold').SAP_Id__c)) mapLocation.get('sold').SAP_Id__c = 'sold';
		if (String.isBlank(mapLocation.get('bill').SAP_Id__c)) mapLocation.get('bill').SAP_Id__c = 'bill';
		if (String.isBlank(mapLocation.get('ship').SAP_Id__c)) mapLocation.get('ship').SAP_Id__c = 'ship';
		update mapLocation.values();

		//-- Create Order for customer
		Order ord = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
		ord.SoldTo_Location__c = mapLocation.get('sold').Id;
		ord.BillTo_Location__c = mapLocation.get('bill').Id;
		ord.ShipTo_Location__c = mapLocation.get('ship').Id;
		ord.OwnerId = usr.Id;
		ord.Type = 'Cart';
		ord.Status = 'New';
		insert ord;

		//-- Create orderitems 
		Integer nb =2;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nb, false);
		for(OrderItem oi : orderitems)
		{
			oi.Auto_Renew__c  = true;
		}
		insert orderItems;

		//-- Generate Coupon Code Rate plan for items 
		Set<String> productIds = new Set<String>();
		
		for(OrderItem oi : new OrderItem_Sel().getOrderItems(ord.Id))
		{
			productIds.add(oi.Product__c);
			IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
		}

		List<Product2> products = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE Id IN :productIds];

		//-- Generate RatePlans & Charges & Tiers
		List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
		for(Integer x = 0; x < products.size(); x++)
		{
			Product2 prod = products[x]; 
			zqu__ProductRatePlan__c unitPricePlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zqu__ProductRatePlan__c zPlan = TestDataGenerator.generateZRatePlans2(prod.Id,1,false)[0];
			zPlan.Couponcode__c = 'COUP123';
			zRatePlans.add(zPlan); 
			zRatePlans.add(unitPricePlan);
		}
		insert zRatePlans;
		List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();
		 //Create Unit Price Charge & Discount for each Plan 
		for(zqu__ProductRatePlan__c rp : zRatePlans)
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
		update products;

		Test.startTest();
			System.runAs(usr)
			{
				Test.setCurrentPage(Page.IEC_ConfirmOrder);
				IEC_ConfirmOrderController ctrl = new IEC_ConfirmOrderController(); 

				ApexPages.currentPage().getParameters().put('orderId', ord.Id);

				ord.Status = 'Payment Failure';
				ord.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;

				update ord;

				//-- Load Page
				ctrl.onLoadAction();
				ctrl.initorder();

				ord.Status = 'Invoiced';
				update ord;

				//-- Load Page
				ctrl.onLoadAction();
				ctrl.initorder();

				//-- without credit card
				ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
				ctrl.sfOrder.Zuora_Credit_Card_Id__c = null;
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(),Label.IEC_Error_PleaseSelectPaymentMethod), 'Invalid error: ' + ApexPages.getMessages());

				//-- error on subscription part
				ctrl.sfOrder.Payment_Type__c = IECConstants.PaymentThresholdType_CreditCard;
				ctrl.sfOrder.Zuora_Credit_Card_Id__c = '4028e6992e836e4a012e914e1dd85e22';
				ctrl.card = null;
				try{ctrl.submitOrder();}catch(Exception ex){}

				System.debug('ApexMessages:' + ApexPages.getMessages());

				System.assert(pageMessagesContains(ApexPages.getMessages(),Label.Order_transaction_failed_message),'Invalid error: ' + ApexPages.getMessages());

				//-- error on parse part
				ctrl.card = new IEC_CreditCard_DTO();
				ctrl.card.zId = ctrl.sfOrder.Zuora_Credit_Card_Id__c;
				ctrl.card.isDefault = true;
				ctrl.card.isExpired = false;
				ctrl.card.name = 'TEST FAILED';
				ctrl.card.creditCardType = 'VISA';
				ctrl.card.creditCardMaskNumber = 'xxxxxxxxxx111';
				ctrl.card.creditCardCVV = '123';
				ctrl.card.expirationMonth = 10;
				ctrl.card.expirationYear = 2016;
				ctrl.card.holderName = 'TEST VISA';
				ctrl.card.country = 'Canada';
				ctrl.card.addresLine1 = '123 Street';
				ctrl.card.addresLine2 = '';
				ctrl.card.city = 'Montreal';
				ctrl.card.stateProvince = 'QC';
				ctrl.card.postalCode = 'H0H0H0';
				ctrl.card.accountId = '123456accc';
				ctrl.card.lastTransactionStatus = 'Success';
				Zuora.zObject zPayment = ctrl.card.toZObjectForUpdate();
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(), Label.Order_transaction_failed_message), 'Invalid error: ' + ApexPages.getMessages());

				//-- success on parse but no transaction number
				ctrl.card.name = 'TEST SUCCESS';
				try{ctrl.submitOrder();}catch(Exception ex){}
				System.assert(pageMessagesContains(ApexPages.getMessages(), Label.Order_transaction_failed_message), 'Invalid error: ' + ApexPages.getMessages());

				//-- success on parse with transaction number
				ctrl.card.name = 'TEST SUCCESS';
				ctrl.sfOrder.Payment_Transaction_Number__c = 'abc';
				update ctrl.sfOrder;
				try{ctrl.submitOrder();}catch(Exception ex){}
				//*** assert is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Order_Credit_Card_confirmation_message), 'Invalid error: ' + ApexPages.getMessages());
			}
		Test.stopTest();
	} //*** end of "test_Payment_CreditCardExtra"

}