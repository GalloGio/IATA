/**

	Project: eCommerce Enhancements
	   File: CreditCardPaymentErrorNotification_Ctrl.cls
	Subject: Controller for Component used in Email Template to notify Customer that
             Credit Card Payment was processed with error.
	History: 2017-05-12, asantos, Initial Release.

*/
public class CreditCardPaymentErrorNotification_Ctrl {
	// Component attributes
	public Id orderId 					{ get; set; }

	public String contactName			{ get; set; }
	public String accountName			{ get; set; }
	public String email 				{ get; set; }
	public String orderNumber			{ get; set; }
	public Order order 					{ get; set; }

	public Decimal discountedAmount 	{ get; set; }
	public Decimal totalAmount 			{ get; set; }

	public Boolean isSetupFee 			{ get; set; }

	public String paymentTypeMessage	{ get; set; }
	public String reasonMessage 		{ get; set; }

	public List<OrderItem> orderItemList {
		get {
			List<Order> orderList;
			List<OrderItem> orderItemList;
			Map<Id,List<OrderItem>> orderItemMap;

			if (orderId == null) {
				return null;
			}

			orderList = Order_Sel.getOrdersById(new Set<Id> { orderId });

			if (orderList != null && orderList.isEmpty() == false) {
				order = orderList[0];

				if (order != null) {
					contactName = order.BillToContact_Name__c;
					accountName = order.BillToAccount_Name__c;
					email = order.BillToContact_Email__c;
					orderNumber = order.OrderNumber;
					discountedAmount = order.Discount_Amount__c;
					totalAmount = order.Total_Amount__c;

					paymentTypeMessage = 'Unfortunately your credit card payment was not accepted.';
					reasonMessage = order.Payment_Gateway_Response__c;

					orderItemList = new List<OrderItem>();
					
					orderItemMap = new OrderItem_Sel().getOrderItems(new Set<Id> { orderId });
					
					if (orderItemMap != null) {
						if (orderItemMap.containsKey(orderId)) {
							orderItemList.addAll(orderItemMap.get(orderId));
						}
					}

					// Verify if setup fee contained in orderItems
					isSetupFee = false;
					for (OrderItem orderItem : orderItemList) {
						if (orderItem.Setup_Fee__c != null && orderItem.Setup_Fee__c > 0) {
							isSetupFee = true;
							break;
						}
					}
				}
			}

			return orderItemList;
		}
	}
}