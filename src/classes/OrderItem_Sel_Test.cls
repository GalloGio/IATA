@isTest
private class OrderItem_Sel_Test
{
	@isTest(SeeAllData=true)
	static void test_OrderItem_Sel()
	{
		OrderItem_Sel oiSelector = new OrderItem_Sel();

		TestDataGenerator.generateApexSetting();

		// Create Orders
		Account acc = TestDataGenerator.generateAccounts(1,true)[0];
		Contact ct = TestDataGenerator.generateContacts(acc.Id,1,true)[0];

		Order  ord = TestDataGenerator.generateOrder(1, acc.Id, ct.Id, ct.Id,true)[0];
		Integer nbItems  = 5;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nbItems,true);
		System.assertEquals(nbItems, orderItems.size());

		Set<Id> orderItemIds    = new Set<Id>();
		Set<String> itemNumbers = new Set<String>();
		Set<Id> productIds = new Set<Id>();
		Set<String> setSubscriptionNumber = new Set<String>();
		Set<String> setSubscriptionZId = new Set<String>();

		orderItems = oiSelector.getOrderItems(ord.Id);
		for(OrderItem oi : orderItems)
		{
			String zSubscriptionId = TestDataGenerator.generateZuoraFakeId();
			orderItemIds.add(oi.Id);
			itemNumbers.add(oi.OrderItemNumber);
			productIds.add(oi.Product__c);
			oi.Zuora_SubscriptionId__c = zSubscriptionId;
			oi.Zuora_Subscription_Number__c = oi.OrderItemNumber;
			setSubscriptionZId.add(zSubscriptionId);
			setSubscriptionNumber.add(oi.OrderItemNumber);
		}

		update orderItems;

		Map<Id, List<OrderItem>> orderItemsMap =  oiSelector.getOrderItems(new Set<Id>{ord.Id});
		System.assert(orderItemsMap.containsKey(ord.Id));

		Map<Id,OrderItem> orderItemById         =   oiSelector.getOrderItemById(orderItemIds);
		Map<Id,OrderItem> ordersItemsById       =   oiSelector.getOrdersItemsById(orderItemIds);
		Map<Id,OrderItem> orderItemsById        =   oiSelector.getOrderItemsById(orderItemIds);
		List<OrderItem> pendingActivation       =   oiSelector.getOrdersItemsPendingActivation(orderItemIds);
		List<OrderItem> orderItemsById2          =   oiSelector.getOrdItemsById(orderItemIds);
		Map<Id,OrderItem> itemByNumber          =   oiSelector.getOrderItemByNumber(itemNumbers);
		Map<Id,List<Id>> productsByContactId    =   oiSelector.getProductsByContactId(new Set<Id>{ct.Id}, productIds, Date.today(), Date.today());
		List<OrderItem> downloadableItem        =   oiSelector.getDownloadableItem(orderItems[0].OrderItemNumber,(String)ct.Id);

		Map<Id,Boolean> orderItemZuoraSubscribeById             =   oiSelector.getOrderItemZuoraSubscribeById(orderItemIds);
		Map<Id, List<Id>> customersWhoBuyProductsOnAutoRenew    = oiSelector.getCustomersWhoBuyProductsOnAutoRenew(productIds);

		//cover the getOrderItemCarrierAndOrderId in order Item selector
		OrderItem_Sel.getOrderItemCarrierAndOrderId(ord.Id,'123456');
		oiSelector.getOrderItemsForContract(new Set<Id>{ord.Id});


		//getOrderItemsByEventSubscription

		IEC_Event_Subscription__c evtSub = new IEC_Event_Subscription__c(
			Subscriber__c = ct.Id,
			Start_Date__c = Date.today(),
			Quantity__c = 1,
			Product__c = orderItems[0].Product__c,
			Active__c = true
		);
		insert evtSub;
		List<OrderItem> orderItemsByEventSubscription = oiSelector.getOrderItemsByEventSubscription(new Map<Id, Id>{evtSub.Id=>orderItems[0].Product__c});


		Map<String, OrderItem> orderItemBySubscriptionNumber= oiSelector.getOrderItemBySubscriptionNumber(setSubscriptionNumber);
		Map<String, OrderItem> orderItemBySubscriptionZId   = oiSelector.getOrderItemBySubscriptionZId(setSubscriptionZId);

		Map<Id,Id>              productIdByOrderItemId      = OrderItem_Sel.getProductIdByOrderItemId(orderItemIds);
		Set<String> invoiceNumber = new Set<String>{'INV-007'};
		List<OrderItem>         orderItemsByInvNumb         = OrderItem_Sel.getOrderItemsByInvNumb(invoiceNumber);
		Map<String, OrderItem>  orderItemByProductNumber    = OrderItem_Sel.getOrderItemByProductNumber(ord.Id, new List<String>{orderItems[0].Product_Number__c});


		OrderItem_Sel.deleteOrderItem(orderItems[0].Id);
	}

	@isTest(SeeAllData=true)
	static void test_DTO()
	{
		OrderItem_Sel oiSelector = new OrderItem_Sel();

		TestDataGenerator.generateApexSetting();

		// Create Orders
		Account acc = TestDataGenerator.generateAccounts(1,true)[0];
		Contact ct = TestDataGenerator.generateContacts(acc.Id,1,true)[0];

		Order  ord = TestDataGenerator.generateOrder(1, acc.Id, ct.Id, ct.Id,true)[0];
		Integer nbItems  = 5;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, nbItems,true);
		System.assertEquals(nbItems, orderItems.size());

		Order_DTO ord_dto = new Order_DTO(ord);
		List<OrderItem_DTO> item_dto = ord_dto.orderItems;
		System.assertEquals(item_dto[0].quantityStripped, item_dto[0].quantity);
		item_dto.sort();

		//-- Format with charges

		Map<Id, List<Order_Item_Charge__c>> chargesByItem = new Map<Id, List<Order_Item_Charge__c>>();
		for(OrderItem_DTO oid  : item_dto)
		{
			List<Order_Item_Charge__c> charges;
			chargesByItem.put(oid.orderItemId, charges);
		}

		item_dto = OrderItem_DTO.format2DTO(orderItems, chargesByItem);
	}


}
