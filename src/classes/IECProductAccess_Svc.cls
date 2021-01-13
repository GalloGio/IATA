public with sharing class IECProductAccess_Svc {

	// Determines which product access are inactive and set them to true based on Paid orders
	public void ActivateProductAccessForPaidOrders(List<Order> lstCurrentOrder, Map<Id, Order> mapOldOrder)
	{
		try
		{
			Set<Id> setPaidOrderId = new Set<Id>();

			// First retrieve Order Ids for Paid orders
			for (Order ord : lstCurrentOrder)
			{
				if (ord.Is_Paid__c && !mapOldOrder.get(ord.Id).Is_Paid__c)
				{
					setPaidOrderId.add(ord.Id);
				}
			}

			// Now retrieve the Order Items with subscription numbers
			Map<Id, List<OrderItem>> mapOrderId_OrderItem = new OrderItem_Sel().getOrderItems(setPaidOrderId);

			//Map of subscription number by number of month of subscription
			Map<String,Decimal> numberOfMonthOfSubscriptionByNumber = new Map<String,Decimal>();

			// Get the subscription number from the order items
			Set<String> setSubscriptionNumber = new Set<String>();

			for (List<OrderItem> lstOrdItem : mapOrderId_OrderItem.values())
			{
				for (OrderItem oi : lstOrdItem)
				{
					if (String.isNotBlank(oi.Zuora_Subscription_Number__c)){
						setSubscriptionNumber.add(oi.Zuora_Subscription_Number__c);
						if(oi.Order.Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer)
							numberOfMonthOfSubscriptionByNumber.put(oi.Zuora_Subscription_Number__c,oi.IEC_Number_of_months_of_subscription__c);
					}
				}
			}

			// Now retrieve inactive product access by subscription number
			List<IEC_Product_Access__c> lstProdAccess = new IECProductAccess_Sel().getInactiveProductAccessBySubscriptionNumber(setSubscriptionNumber);

			// Set all these product access to active since the orders has been paid
			for (IEC_Product_Access__c prodAccess: lstProdAccess)
			{
				prodAccess.Active__c = true;
				//set the Effective start and end date
				Decimal nbMonth = numberOfMonthOfSubscriptionByNumber.get(prodAccess.Subscription_Number__c);
				if(nbMonth != null){
					prodAccess.Effective_Start_Date__c = Datetime.now();
					prodAccess.Effective_End_Date__c = Datetime.now().AddMonths(Integer.valueOf(nbMonth));
				}
			}

			update lstProdAccess;
		}
		catch (Exception e){IECErrorLogger.logApexException('IECProductAccess_Svc.ActivateProductAccessForPaidOrders', 'Exception thrown while activating product access:\nlstCurrentOrder: ' + lstCurrentOrder + '\nmapOldOrder: ' + mapOldOrder, e.getMessage(), e.getStackTraceString());}
	}

	// Determines which product access are inactive and set them to true based on Paid OrderItems
	public void ActivateProductAccessForPaidOrderItems(List<OrderItem> lstCurrentOrderItem, Map<Id, OrderItem> mapOldOrderItem)
	{
		try
		{
			Set<String> setSubscriptionNumber = new Set<String>();

			// Get the subscription number from the OrderItem items with Paid flag set to true
			for (OrderItem oi : lstCurrentOrderItem)
			{
				if (oi.IEC_Is_Paid__c && (mapOldOrderItem == null || !mapOldOrderItem.get(oi.Id).IEC_Is_Paid__c))
				{
					if (String.isNotBlank(oi.Zuora_Subscription_Number__c))
						setSubscriptionNumber.add(oi.Zuora_Subscription_Number__c);
				}
			}

			// Now retrieve inactive product access by subscription number
			List<IEC_Product_Access__c> lstProdAccess = new IECProductAccess_Sel().getInactiveProductAccessBySubscriptionNumber(setSubscriptionNumber);

			// Set all these product access to active since the OrderItems has been paid
			for (IEC_Product_Access__c prodAccess: lstProdAccess)
			{
				prodAccess.Active__c = true;
			}

			update lstProdAccess;
		}
		catch (Exception e){IECErrorLogger.logApexException('IECProductAccess_Svc.ActivateProductAccessForPaidOrderItems', 'Exception thrown while activating product access:\nlstCurrentOrderItem: ' + lstCurrentOrderItem + '\nmapOldOrderItem: ' + mapOldOrderItem , e.getMessage() , e.getStackTraceString());}
	}
}
