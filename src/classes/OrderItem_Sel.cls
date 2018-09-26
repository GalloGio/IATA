/****************************************************************************************************
    Created by David D 2015-09-28
****************************************************************************************************/
public with sharing class OrderItem_Sel  extends Selector
{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> 
		{
			OrderItem.Id,
			OrderItem.Product__c,
			OrderItem.Description,
			OrderItem.OrderItemNumber,
			OrderItem.OrderId,
			OrderItem.Product_Name__c,
			OrderItem.Product_Number__c,
			OrderItem.SAP_Product_Number__c,
            OrderItem.PricebookEntryId,
			OrderItem.Quantity,
			OrderItem.Zuora_Rate_Plan_Id__c,
			OrderItem.Zuora_Rate_Plan_Charge_Id__c,
			OrderItem.Zuora_Setup_Fee_Plan_Id__c,
			OrderItem.Zuora_Setup_Fee_Charge_Id__c,
			OrderItem.UnitPrice,
			OrderItem.Setup_Fee__c,
			OrderItem.Division__c,
			OrderItem.Discount__c,
			OrderItem.Is_Electronic_Product__c,
			OrderItem.SubTotal__c,
			OrderItem.Freight_Charge__c,
			OrderItem.Tax__c,
			OrderItem.Handling_charges__c,
			OrderItem.Total__c,
			OrderItem.Auto_Renew__c,
			OrderItem.Zuora_Subscription_Number__c,
			OrderItem.Payment_Transaction_Number__c,
			OrderItem.Charge_Shipping__c,
			OrderItem.Is_Shippable_Product__c,
			OrderItem.Use_Contract_when_ordered__c,
			OrderItem.Zuora_SubscriptionId__c,
			OrderItem.Zuora_InvoiceId__c,
			OrderItem.Status__c,
			OrderItem.Confirmed_Quantity__c,
			OrderItem.Scheduled_Delivery_Date__c,
			OrderItem.Shipped_Quantity__c,
			OrderItem.Shipped_Date__c,
			OrderItem.Carrier_Name__c,
			OrderItem.Carrier_Tracking_Number__c,
			OrderItem.Carrier_Tracking_URL__c,
			OrderItem.Invoice_Number__c,
			OrderItem.Invoice_Date__c,
			OrderItem.Invoice_Amount__c,
			OrderItem.Credit_Debit__c,
			OrderItem.Coupon__c,
			OrderItem.Effective_End_Date__c,
			OrderItem.SAP_Contract_Number__c,
			OrderItem.Is_SAP_Editable__c,
			OrderItem.Is_Quantity_Integer__c,
			OrderItem.Number_of_download__c,
			OrderItem.Is_Web_Download__c,
			OrderItem.Product_Manager__c,
			OrderItem.AWS_download_link__c,
			OrderItem.Days_available_for_download_1__c,
			OrderItem.File_Path__c,
			OrderItem.Available_for_Subscription__c,
			OrderItem.IEC_Static_Cart_Quantity__c,
			OrderItem.IEC_Subscribe_to_Zuora__c,
			OrderItem.Subscription_End_Date__c,
			OrderItem.IEC_Event_Subscription__c,
			OrderItem.Zuora_Subscription_Status__c,
			OrderItem.IEC_Number_of_months_of_subscription__c  
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return OrderItem.sObjectType;
	}

	/****************************************************************************************************
    	Created by David D 2015-09-28
    		return List of OrderItem for each OrderId
	****************************************************************************************************/
	public Map<Id, List<OrderItem>> getOrderItems(Set<Id> orderIds)
	{
		System.debug('orderIds::'+orderIds);
		Map<Id, List<OrderItem>> ret = new Map<Id, List<OrderItem>>(); 

		String query = String.format(
            'SELECT {0}, Order.Payment_Type__c, PricebookEntry.Product2.SAP_Material_Number__c ' + 
        	', (SELECT Zuora_Rate_Plan_Id__c,Zuora_Rate_Plan_Charge_Id__c,Name,Discount_Type__c,Discount_Amount__c FROM Order_Item_Charges__r) ' +
            'FROM {1} ' + 
            'WHERE OrderId IN :orderIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

       
		List<OrderItem> orderItems = Database.query(query);
		System.debug('orderItems::'+orderItems);
		
		for(OrderItem oi : orderItems)
		{
			List<OrderItem> tmp = (ret.containsKey(oi.OrderId)) ? ret.get(oi.OrderId) : new List<OrderItem>(); 
				tmp.add(oi);

			ret.put(oi.OrderId, tmp);
		}

		
		return ret;
	}

	public List<OrderItem> getOrderItems(String orderId)
	{
		String query = String.format(
            'SELECT {0}  ' + 
        	', (SELECT Zuora_Rate_Plan_Id__c,Zuora_Rate_Plan_Charge_Id__c,Name,Discount_Type__c,Discount_Amount__c FROM Order_Item_Charges__r) ' +
            'FROM {1} ' + 
            'WHERE OrderId = :orderId ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return Database.query(query);
	}

	//return list of OrderItem by order id // and Is_Shippable_Product__c = false
	public Map<Id,List<OrderItem>> getOrderItemsForContract(Set<Id> orderIds){
		Map<Id, List<OrderItem>> ret = new Map<Id, List<OrderItem>>(); 

		String query = String.format(
            'SELECT {0}  ' + 
            'FROM {1} ' + 
            'WHERE OrderId IN :orderIds' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

		List<OrderItem> orderItems = Database.query(query);

		for(OrderItem oi : orderItems){
			if(!ret.containsKey(oi.OrderId)){
				ret.put(oi.OrderId, new List<OrderItem>());
			}
			ret.get(oi.OrderId).add(oi);
		}
		return ret;
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2015-10-21
    		return map of OrderItem by Id
	****************************************************************************************************/
	public Map<Id,OrderItem> getOrderItemById(set<Id> orderItemIds){
		return new Map<Id,OrderItem>((List<OrderItem>) selectSObjectById(orderItemIds));
	}
    
    /****************************************************************************************************
    	Created by Kevin Ky 2015-10-21
    		return map of OrderItem by Id
	****************************************************************************************************/
	public Map<Id,OrderItem> getOrdersItemsById(set<Id> orderItemIds){
		
        String query = String.format(
            'SELECT {0}, Order.BillToContactId ' + 
            'FROM {1} ' + 
            'WHERE Id IN :orderItemIds' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
		List<OrderItem> orderItems = Database.query(query);
		return new map<Id,OrderItem>(orderItems);
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2015-05-17
    		return the list of orderItem that are pending activation
	****************************************************************************************************/
	public List<OrderItem> getOrdersItemsPendingActivation(set<Id> orderIds){
		
		String status = 'Pending Activation';
        String query = String.format(
            'SELECT {0} ' + 
            'FROM {1} ' + 
            'WHERE orderId IN :orderIds and Zuora_Subscription_Status__c =:status and Zuora_SubscriptionId__c != null ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
		return Database.query(query);
	}

	//Return the list of order item by id
	public List<OrderItem> getOrdItemsById(set<Id> orderItemIds){
		return (List<OrderItem>) selectSObjectById(orderItemIds);
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2016-02-05
    		return map of OrderItem by orderItem number
	****************************************************************************************************/
	public Map<Id,OrderItem> getOrderItemByNumber(set<string> itemNumber){
		
		Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>();

		String query = String.format(
            'SELECT {0}  ' + 
            'FROM {1} ' + 
            'WHERE OrderItemNumber in :itemNumber' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

		List<OrderItem> orderItems = Database.query(query);
		for(OrderItem oi : orderItems){
			orderItemMap.put(oi.Id, oi);
		}

		return orderItemMap;
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2016-04-28
    		return List of OrderItem by Event Subscription
	****************************************************************************************************/
	public List<OrderItem> getOrderItemsByEventSubscription(map<Id,Id> eveSubId_prodId){

		List<OrderItem> lstOrderItem = new List<OrderItem>();
		map<Id,List<OrderItem>> subId_lstOrderItem = new map<Id,List<OrderItem>>();
		set<Id> subsId = eveSubId_prodId.keySet();
		String query = String.format(
            'SELECT {0},  ' + 
            'Order.OrderNumber, Order.Type, PricebookEntry.Product2Id, Order.IEC_Payment_Date__c ' + 
            '' + 
            ' FROM {1} ' + 
            ' WHERE IEC_Event_Subscription__c in :subsId order by CreatedDate DESC' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );


		//List of Order item for the set of subscription ids
		return  (List<OrderItem>)Database.query(query);

		//set a List of order Item by subscription
		//if(orderItems != null && orderItems.size() > 0){
		//	for(OrderItem oi :orderItems){
		//		if(!subId_lstOrderItem.containsKey(oi.Order.IEC_Event_Subscription__c))
		//			subId_lstOrderItem.put(oi.Order.IEC_Event_Subscription__c,new List<OrderItem>());
		//		subId_lstOrderItem.get(oi.Order.IEC_Event_Subscription__c).add(oi);
		//	}
		//}

		////Set the list of order item to return base on the subscription and product
		//for(Id subId : eveSubId_prodId.keySet()){
		//	Id prodId = eveSubId_prodId.get(subId);
		//	List<OrderItem> lstOi = subId_lstOrderItem.get(subId);
		//	if(lstOi != null && !lstOi.isEmpty()){
		//		for(OrderItem oi : lstOi){
		//			if(oi.PricebookEntry.Product2Id == prodId){
		//				lstOrderItem.add(oi);
		//				break;
		//			}
		//		}
		//	}
		//}

		//return the list of order item
		//return lstOrderItem;

	}


	public Map<Id,OrderItem> getOrderItemsById(set<Id> orderItemIds){
		String query = String.format(
            'SELECT {0} , Order.BillToContact.Name, Order.OrderNumber, Order.BillToContactId ' + 
            'FROM {1} ' + 
            'WHERE Id IN :orderItemIds' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

		List<OrderItem> orderItems = Database.query(query);
		return new Map<Id,OrderItem>(orderItems);
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2016-01-21
    		return a list of products by contact
	****************************************************************************************************/
	public map<Id,List<Id>> getProductsByContactId(set<Id> contactIds, set<Id> productIds, Date startDate, Date endDate){
		//Select ., o., o.Order.EffectiveDate, o.OrderId From OrderItem o
		map<Id,List<Id>> contactIds_productIds = new map<Id,List<Id>>();

		String query = String.format(
            'SELECT {0} , PricebookEntry.Product2Id, Order.BillToContactId, Order.EffectiveDate ' + 
            'FROM {1} ' + 
            'WHERE Order.BillToContactId IN :contactIds AND PricebookEntry.Product2Id IN :productIds AND ' +
            'Order.EffectiveDate > :startDate AND Order.EffectiveDate < :endDate' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

		List<OrderItem> orderItems = Database.query(query);
		if(orderItems != null && orderItems.size() > 0){
			for(OrderItem oi : orderItems){
				if(!contactIds_productIds.containsKey(oi.Order.BillToContactId)){
					contactIds_productIds.put(oi.Order.BillToContactId,new List<Id>());
				}
				contactIds_productIds.get(oi.Order.BillToContactId).add(oi.PricebookEntry.Product2Id);
			}
		}

		return contactIds_productIds;
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2015-04-07
    		return Order Item base on the order id
	****************************************************************************************************/
	public static List<OrderItem> getOrderItemsByOrderId(set<Id> orderIds){
		
		return [SELECT Id,Quantity, SubTotal__c, OrderId FROM OrderItem WHere OrderId in :orderIds];
		
	}


	//ORDER_ID => SET_OF_PRODUCT_IDS
	public Map<Id, Set<Id>> getProductIdsByOrder(set<Id> orderIds)
	{
		Map<Id, Set<Id>> ret = new Map<Id, Set<Id>>();
		List<OrderItem> orderItems = [SELECT Id, PricebookEntry.Product2Id,OrderId FROM OrderItem WHere OrderId in :orderIds];

		for(OrderItem item : orderItems)
		{
			if(!ret.containsKey(item.OrderId)){
				ret.put(item.OrderId, new set<Id>());
			}
			ret.get(item.OrderId).add(item.PricebookEntry.Product2Id);
		}
		
		return ret;
	}

	/****************************************************************************************************
    	Created by David D
    		delete orderItem
	****************************************************************************************************/
	public static void deleteOrderItem(String orderItemId)
	{
		try
		{
			OrderItem item = [SELECT Id FROM OrderItem WHERE Id = :orderItemId LIMIT 1];
			delete item;
		}
		catch(Exception ex) { ApexPages.addMessages(ex); }
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2015-10-15
    		return Order Item id by ProductId
	****************************************************************************************************/
	public static map<Id,Id> getProductIdByOrderItemId(set<Id> orderItemId){
		map<Id,Id> productIdByOrderItemId = new map<Id,Id>();
		List<OrderItem> orderItems = [SELECT Id, PricebookEntry.Product2Id,OrderId FROM OrderItem WHere Id in :orderItemId];
		for(OrderItem oi : orderItems){
			productIdByOrderItemId.put(oi.Id,oi.PricebookEntry.Product2Id);
		}
		return productIdByOrderItemId;
	}
	/****************************************************************************************************
    	Created by Kevin Ky 2015-12-21
    		return Order Item base on the invoice number
	****************************************************************************************************/
	public static List<OrderItem> getOrderItemsByInvNumb(set<String> invoiceNumber){
		
		return [SELECT Id,OrderId FROM OrderItem WHere Invoice_Number__c in :invoiceNumber];
		
	}

	public static List<OrderItem> getOrderItemCarrierAndOrderId(Id orderId, String carrierNumber){
		return [select id,Carrier_Tracking_Number__c,Order.ShipToContact_Email__c,Order.BillToContactId,OrderId,
								Order.BillToContact.Name,Carrier_Name__c,
								Product_Name__c, Carrier_Tracking_URL__c,Product_Number__c,SAP_Product_Number__c,
								Order.OrderNumber 
									from OrderItem 
									where Carrier_Tracking_Number__c = :carrierNumber
									and OrderId = :orderId ];
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2016-02-03
    		return Order Item base on the login user
	****************************************************************************************************/
	public List<OrderItem> getDownloadableItem(String orderItemNumber,String userContactId){

		String query = String.format(
            'SELECT {0} , Order.BillToContactId ' + 
            'FROM {1} ' + 
            'WHERE Order.BillToContactId = :userContactId AND OrderItemNumber = :orderItemNumber ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

		List<OrderItem> orderItems = Database.query(query);
		if(orderItems != null && orderItems.size() > 0){
			return orderItems;
		}
		return null;
	}

	/****************************************************************************************************
    	Created by Kevin Ky 2016-05-09
    		return Map of Subscribe for Zuora check by order Item id
	****************************************************************************************************/
	public Map<Id,Boolean> getOrderItemZuoraSubscribeById(set<Id> orderItemIds){
		
		Map<Id,Boolean> orderItemZuoraSubscribeById = new Map<Id,Boolean>();

		String query = String.format(
            'SELECT {0} ' + 
            'FROM {1} ' + 
            'WHERE id in :orderItemIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

		List<OrderItem> orderItems = Database.query(query);
		if(orderItems != null && orderItems.size() > 0){
			for(OrderItem oi : orderItems){
				orderItemZuoraSubscribeById.put(oi.Id, oi.IEC_Subscribe_to_Zuora__c);
			}
		}

		return orderItemZuoraSubscribeById;
	}


	/****************************************************************************************************
    	Created by Thai 2015-11-16
    		Return map of Product Number to Order Item for an order
	****************************************************************************************************/
	public static Map<String, OrderItem> getOrderItemByProductNumber(String idOrder, List<String> lstProductNumber){
		Map<String, OrderItem> mapMaterial_OrderItem = new Map<String, OrderItem>();
		for (OrderItem oi : [select Id, Product_Number__c, SAP_Product_Number__c, OrderId
		                          , Order.Name, Order.ShipToContact_Email__c  //, Order.Ship_To_Location_Contact_Email__c
		                          , Order.BillToContactId, Order.Payment_Type__c, Order.Is_Paid__c
		                     from OrderItem
		                     where OrderId = :idOrder
		                       and SAP_Product_Number__c in :lstProductNumber])
			mapMaterial_OrderItem.put(oi.SAP_Product_Number__c, oi);
		return mapMaterial_OrderItem;
	} //*** end of "getOrderItemByProductNumber"


	/****************************************************************************************************
    	Created by David D 02/2016
    		Return for each productId the listof Customer who buy the product on Auto-Renew
    		PRODUCT_ID => LIST_CONTACT_ID
	***************************************************************************************************/
	public Map<Id, List<Id>> getCustomersWhoBuyProductsOnAutoRenew(List<Id> productIds)
	{
		//-- Return Map 
		Map<Id, List<Id>> ret = new Map<Id, List<Id>>();

		//-- Validate Ids are  Id-15 format because Product__c in OrderItem is a formular field and use Id-15 format
		Set<String> productIdsFormatted = new Set<String>();
		for(Id i : productIds)
		{
			String idStr =  i; 
			productIdsFormatted.add((String)idStr.left(15));
		}

		//-- Build the Map 
		for(OrderItem item : [SELECT Order.BillToContactId, Product__c FROM OrderItem WHERE Auto_Renew__c =true AND Product__c IN :productIdsFormatted])
		{
			if(item.Order.BillToContactId == null) continue; 
			
			Set<Id> tmp = (ret.containsKey(item.Product__c)) 
                ?   new Set<Id>(ret.get(item.Product__c))
                :   new Set<Id>();
            tmp.add(item.Order.BillToContactId);
            ret.put(item.Product__c, new List<Id>(tmp));
		}
		
		return ret;
	}

	/****************************************************************************************************
	    Created by David D 02/2016
	    	Return Customers who buy products with auto-renew on (with subscription still valid)
	****************************************************************************************************/
	public Map<Id, List<Id>> getCustomersWhoBuyProductsOnAutoRenew(Set<Id> tncIds)
	{
		//-- Return Map 
		Map<Id, List<Id>> ret = new Map<Id, List<Id>>(); // TNC_ID => LIST_CONTACT_ID

		
		List<OrderItem> items = [
			SELECT Order.BillToContactId, Product__c, Accepted_Term_Condition__c , Zuora_SubscriptionId__c
			FROM OrderItem
			WHERE Auto_Renew__c = true 
				AND Accepted_Term_Condition__c IN :tncIds
				AND Subscription_End_Date__c >= :Date.today()
		];

		//-- Build the Map 
		for(OrderItem item : items)
		{
			if(item.Order.BillToContactId == null) continue; 
			
			Set<Id> tmp = (ret.containsKey(item.Accepted_Term_Condition__c)) 
                ?   new Set<Id>(ret.get(item.Accepted_Term_Condition__c))
                :   new Set<Id>();
            tmp.add(item.Order.BillToContactId);
            ret.put(item.Accepted_Term_Condition__c, new List<Id>(tmp));
		}
		
		return ret;
	}
	
	
	
	/****************************************************************************************************
	    Created by Samy S 03/2016
	    	Return OrderItems by Subscription Number
	****************************************************************************************************/
	public Map<String, OrderItem> getOrderItemBySubscriptionNumber(Set<String> setSubscriptionNumber)
	{
		List<OrderItem> lstOrderItem = 
			[SELECT Order.Is_Paid__c, Zuora_Subscription_Number__c, Id, OrderId
			FROM OrderItem
			WHERE Zuora_Subscription_Number__c IN :setSubscriptionNumber];
	
		Map<String, OrderItem> mapSubNum_OrderItem = new Map<String, OrderItem>();
			
		for(OrderItem oi : lstOrderItem)
		{
			mapSubNum_OrderItem.put(oi.Zuora_Subscription_Number__c, oi);
		}
		
		return mapSubNum_OrderItem;
	}
	
	/****************************************************************************************************
	    Created by Samy S 05/2016
	    	Return OrderItems by Subscription Zuora ID
	****************************************************************************************************/
	public Map<String, OrderItem> getOrderItemBySubscriptionZId(Set<String> setSubscriptionZId)
	{
		List<OrderItem> lstOrderItem = 
			[SELECT Order.Is_Paid__c, Zuora_SubscriptionId__c, Id, OrderId
			FROM OrderItem
			WHERE Zuora_SubscriptionId__c IN :setSubscriptionZId];
	
		Map<String, OrderItem> mapSubZId_OrderItem = new Map<String, OrderItem>();
			
		for(OrderItem oi : lstOrderItem)
		{
			mapSubZId_OrderItem.put(oi.Zuora_SubscriptionId__c, oi);
		}
		
		return mapSubZId_OrderItem;
	}
}