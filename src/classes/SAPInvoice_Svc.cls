/**
 *
 * @author: Kevin Ky <kevin.ky@cgi.com>
 * @date: 2015-12-03
 *
 *
 **/
public without sharing class SAPInvoice_Svc {

	/****************************************************************************************************
		Created by Kevin Ky 2015-12-03
		Update order status to Payment Confirmed when a payment is confirm by SAP
	****************************************************************************************************/
	public static void updateOrderStatus(List<SAP_Invoice__c> sapInvoices){
		Map<Id, String> mapOrderId_Invoice = new Map<Id, String>();
		List<Order> lstOrder;
		List<OrderItem> lstOrderItem;

		//*** prepare to query data
		for(SAP_Invoice__c sapInvoice : sapInvoices)
			mapOrderId_Invoice.put(sapInvoice.Order__c, sapInvoice.Invoice_Number__c);

		if (mapOrderId_Invoice.size() > 0)
		{
			lstOrder = Order_Sel.getOrdersById(mapOrderId_Invoice.keySet());
			if (lstOrder != null && lstOrder.size() > 0)
			{
				//*** update status of orders
				for (Order ord : lstOrder)
				{
					ord.Status = IECConstants.ORDER_PAYMENT_CONFIRMED;
					if (ord.Payment_Type__c != IECConstants.PaymentThresholdType_BillMeLater && ord.Is_Paid__c != true)
					{
						ord.Is_Paid__c = true;
						ord.IEC_Payment_Date__c = Date.today();
					}
				}

				set<Id> orderIds = new set<Id>();
				//update lstOrder;
				Database.SaveResult[] srList = Database.update(lstOrder, false);

				// Iterate through each returned result
				for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
						// Operation was successful, so get the ID of the record that was processed
						orderIds.add(sr.getId());
					}
				}

				//*** update flag Is Paid of order items
				lstOrderItem = [select Id, OrderId, Invoice_Number__c
								from OrderItem
								where IEC_Is_Paid__c != true
								  and OrderId in :mapOrderId_Invoice.keySet() and Invoice_Number__c in :mapOrderId_Invoice.values()];
				if (lstOrderItem.size() > 0)
				{
					for (OrderItem oi : lstOrderItem)
						if (mapOrderId_Invoice.get(oi.OrderId) == oi.Invoice_Number__c)
							oi.IEC_Is_Paid__c = true;
					update lstOrderItem;
				}

				//Check if orderItems for Orders have Pending Activation subscription in Zuora
				if(orderIds.size() > 0){
					Order_Svc.orderItemsToUpdateInZuora(orderIds);
				}
			}
		}
	}

}
