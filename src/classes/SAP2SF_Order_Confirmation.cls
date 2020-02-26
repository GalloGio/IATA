/****************************************************************************************************
	Created by CGI, Thai 2015-11-11
		SOAP web service to be called by SAP interface Sales Order Confirmation
****************************************************************************************************/

global without sharing class SAP2SF_Order_Confirmation
{


//*** DTO for order
global class SalesOrderHeader
{
	webService String SAPSalesOrderNo;
	webService String eCommerceOrderNo;
	webService List<SalesOrderItem> SalesOrderItems = new List<SalesOrderItem>();
}


//*** DTO for order item
global class SalesOrderItem
{
	webService String MaterialNo;
	webService Decimal OrderedQuantity;
	webService Decimal ConfirmedQuantity;
	webService Date ScheduledDeliveryDate;
	webService String Status;
}


//*** method to call to confirm sales order
webService static void confirmOrder(SalesOrderHeader orderInfo)
{
	Map<String, OrderItem> mapMaterial_OrderItem;
	OrderItem updOrderItem;
	Map<String, String> mapMaterial_Product = new Map<String, String>();
//IECErrorLogger.logApexError('SAP2SF_Order_Confirmation.confirmOrder', String.valueOf(orderInfo), 'check', false);

	try
	{
		//*** quit if no order or no order item
		if (orderInfo == null || orderInfo.SalesOrderItems == null || orderInfo.SalesOrderItems.size() == 0)
		{
			logError(orderInfo, 'Missing information', null);
			return;
		}

		//*** get order items
		for (SalesOrderItem oiSAP : orderInfo.SalesOrderItems)
			mapMaterial_Product.put(oiSAP.MaterialNo, (oiSAP.MaterialNo.isNumeric()) ? String.valueOf(Long.valueOf(oiSAP.MaterialNo)) : oiSAP.MaterialNo);
		mapMaterial_OrderItem = OrderItem_Sel.getOrderItemByProductNumber(orderInfo.eCommerceOrderNo, mapMaterial_Product.values());
		if (orderInfo.SalesOrderItems.size() != mapMaterial_OrderItem.size())
		{
			logError(orderInfo, 'Unmatched list of products', null);
			return;
		}

		//*** set order items with new information
		for (SalesOrderItem oiSAP : orderInfo.SalesOrderItems)
		{
			updOrderItem = mapMaterial_OrderItem.get(mapMaterial_Product.get(oiSAP.MaterialNo));
			if (updOrderItem != null)
			{
				updOrderItem.Status__c = oiSAP.Status;
				updOrderItem.Confirmed_Quantity__c = oiSAP.ConfirmedQuantity;
				updOrderItem.Scheduled_Delivery_Date__c = oiSAP.ScheduledDeliveryDate;
			}
		}

		//*** update order items
		if (mapMaterial_OrderItem.size() > 0)
		{
			//*** update order items
			update mapMaterial_OrderItem.values();

			//*** update SAP order number if applicable
			Order_Svc.updateOrderNumber(new Map<Id, String>{ orderInfo.eCommerceOrderNo => orderInfo.SAPSalesOrderNo });
		}
	}
	catch (Exception e)
	{
		logError(orderInfo, String.valueOf(e), e.getStackTraceString());
	}
} //*** end of "confirmOrder"


/****************************************************************************************************
	Created by Thai 2016-02-23
		Log an error for follow up
****************************************************************************************************/
static void logError(SalesOrderHeader orderInfo, String strError, String strStack)
{
	if (strStack == null)
		IECErrorLogger.logApexError('SAP2SF_Order_Confirmation.confirmOrder', String.valueOf(orderInfo), strError, true);
	else
		IECErrorLogger.logApexException('SAP2SF_Order_Confirmation.confirmOrder', String.valueOf(orderInfo), strError, strStack, true);
} //*** end of "logError"


} //*** end of class
