public class ProductShippedNotificationContent_Ctrl{
	
	public Id orderItemId{get;set;}
	public String contactName{get;set;}
	public String trackingNumber{get;set;}
	public String trackingURL{get;set;}
	public Boolean showUrl{get;set;}
	public String orderNumber {get;set;}

	//get orderItems for shippment email template contains
	public List<OrderItem> getOrderItems(){

		List<OrderItem> orderItemToSend = new List<OrderItem>();

		set<Id> orderItemIds = new set<Id>{orderItemId};
		Map<Id,OrderItem> orderItemById = new OrderItem_Sel().getOrderItemsById(orderItemIds);

		//get orderItems for shippment email template contains
		List<OrderItem> lstOrderItems = orderItemById.values(); 
		if(lstOrderItems != null && lstOrderItems.size() > 0){
			trackingNumber = lstOrderItems[0].Carrier_Tracking_Number__c;
			trackingURL = lstOrderItems[0].Carrier_Tracking_URL__c;
			contactName = lstOrderItems[0].Order.BillToContact.Name;
			orderNumber = lstOrderItems[0].Order.OrderNumber;
			showUrl = false;
			if(lstOrderItems[0].Carrier_Name__c != null){
				showUrl = true;
			}
			orderItemToSend = OrderItem_Sel.getOrderItemCarrierAndOrderId(lstOrderItems[0].OrderId,lstOrderItems[0].Carrier_Tracking_Number__c); 
		}

		return orderItemToSend;
	}

}