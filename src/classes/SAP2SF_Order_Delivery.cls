/****************************************************************************************************
	Created by CGI, Thai 2015-11-11
		SOAP web service to be called by SAP interface Delivery Note
****************************************************************************************************/

global without sharing class SAP2SF_Order_Delivery
{


//*** DTO for order
global class DeliveryNoteHeader
{
	webService String SAPDeliveryNo;
	webService String SAPSalesOrderNo;
	webService String eCommerceOrderNo;
	webService String CarrierName;
	webService String CarrierShipmentNo;
	webService Date ShippedDate;
	webService List<DeliveryNoteItem> DeliveryNoteItems = new List<DeliveryNoteItem>();
}


//*** DTO for order item
global class DeliveryNoteItem
{
	webService String MaterialNo;
	webService Decimal ShippedQuantity;
}


//*** method to call to update shipping information on order items
webService static void updateShippingInfo(DeliveryNoteHeader noteInfo)
{
	Map<String, OrderItem> mapMaterial_OrderItem;
	Map<Id, Boolean> mapOrderId_PaidFlag = new Map<Id, Boolean>();
	Map<String, String> mapMaterial_Product = new Map<String, String>();
	OrderItem updOrderItem;
//IECErrorLogger.logApexError('SAP2SF_Order_Delivery.updateShippingInfo', String.valueOf(noteInfo), 'check', false);

	//Boolean error = false;

	try
	{
		//*** quit if no order or no order item
		if (noteInfo == null || noteInfo.DeliveryNoteItems == null || noteInfo.DeliveryNoteItems.size() == 0)
		{
			logError(noteInfo, 'Missing information', null);
			return;
		}

		//*** get order items
		for (DeliveryNoteItem oiSAP : noteInfo.DeliveryNoteItems)
			mapMaterial_Product.put(oiSAP.MaterialNo, (oiSAP.MaterialNo.isNumeric()) ? String.valueOf(Long.valueOf(oiSAP.MaterialNo)) : oiSAP.MaterialNo);
		mapMaterial_OrderItem = OrderItem_Sel.getOrderItemByProductNumber(noteInfo.eCommerceOrderNo, mapMaterial_Product.values());
		if (noteInfo.DeliveryNoteItems.size() != mapMaterial_OrderItem.size())
		{
			logError(noteInfo, 'Unmatched list of products', null);
			return;
		}

		//*** set order items with new information
		for (DeliveryNoteItem oiSAP : noteInfo.DeliveryNoteItems)
		{
			updOrderItem = mapMaterial_OrderItem.get(mapMaterial_Product.get(oiSAP.MaterialNo));
			if (updOrderItem != null)
			{
				updOrderItem.Status__c = 'Shipped';
				updOrderItem.Shipped_Quantity__c = oiSAP.ShippedQuantity;
				updOrderItem.Shipped_Date__c = noteInfo.ShippedDate;
				updOrderItem.Carrier_Name__c = noteInfo.CarrierName;
				updOrderItem.Carrier_Tracking_Number__c = noteInfo.CarrierShipmentNo;
				updOrderItem.Delivery_Number__c = noteInfo.SAPDeliveryNo;

				//*** update paid flags
				if (updOrderItem.Order.Payment_Type__c != IECConstants.PaymentThresholdType_BillMeLater)
				{
					updOrderItem.IEC_Is_Paid__c = true;
					if (updOrderItem.Order.Is_Paid__c != true)
						mapOrderId_PaidFlag.put(updOrderItem.OrderId, true);
				}
			}
		}

		//*** update order items
		if (mapMaterial_OrderItem.size() > 0)
		{
			//*** update order items
			update mapMaterial_OrderItem.values();

			//*** update SAP order number if applicable
			Order_Svc.updateOrderNumber(new Map<Id, String>{ noteInfo.eCommerceOrderNo => noteInfo.SAPSalesOrderNo });

			//*** update order status if its all order items are shipped
			//if (0 == [select count() from OrderItem where OrderId = :noteInfo.eCommerceOrderNo and Status__c != 'Shipped' and Status__c != 'Invoiced'])
			if (0 != [select count() from Order where Id = :noteInfo.eCommerceOrderNo and Status not in ('Delivery', 'Invoiced', 'Payment Confirmed')])
				Order_Svc.updateOrderStatus(new Map<Id, String>{ noteInfo.eCommerceOrderNo => 'Delivery' }, mapOrderId_PaidFlag);

			//*** Send notification to the customer when a item is shipped
			OrderItem_Svc.orderItemShippedNotification(mapMaterial_OrderItem);
		}
	}
	catch (Exception e)
	{
		//error = true;
		logError(noteInfo, String.valueOf(e), e.getStackTraceString());
	}

	//Send notification to the customer when a item is shipped
	//if(!error && mapMaterial_OrderItem != null && mapMaterial_OrderItem.size() > 0){
		//OrderItem_Svc.orderItemShippedNotification(mapMaterial_OrderItem);
	//}

} //*** end of "updateShippingInfo"


/****************************************************************************************************
	Created by Thai 2016-02-23
		Log an error for follow up
****************************************************************************************************/
static void logError(DeliveryNoteHeader noteInfo, String strError, String strStack)
{
	if (strStack == null)
		IECErrorLogger.logApexError('SAP2SF_Order_Delivery.updateShippingInfo', String.valueOf(noteInfo), strError, true);
	else
		IECErrorLogger.logApexException('SAP2SF_Order_Delivery.updateShippingInfo', String.valueOf(noteInfo), strError, strStack, true);
} //*** end of "logError"


} //*** end of class
