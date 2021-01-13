/****************************************************************************************************
	Created by CGI, Thai 2015-12-03
		SOAP web service to be called by SAP interface Invoice
****************************************************************************************************/

global without sharing class SAP2SF_Order_Invoice
{


//*** DTO for order
global class InvoiceHeader
{
	webService String SAPSalesOrderNo;
	webService String eCommerceOrderNo;
	webService String InvoiceNo;
	webService Date   InvoiceDate;
	webService String DocType;      //*** possible of 3 values: INV-invoice, CRM-credit memo, DRM-debit memo
	webService List<InvoiceItem> InvoiceItems = new List<InvoiceItem>();
}


//*** DTO for order item
global class InvoiceItem
{
	webService String  MaterialNo;
	webService Decimal InvoiceAmount;
	webService String  CurrencyCode;
}


//*** method to call to update invoice information on order items
webService static void updateInvoice(InvoiceHeader invoiceInfo)
{
	Map<String, OrderItem> mapMaterial_OrderItem;
	Map<Id, Boolean> mapOrderId_PaidFlag = new Map<Id, Boolean>();
	Map<String, String> mapMaterial_Product = new Map<String, String>();
	OrderItem updOrderItem;
	List<Order_Item_Memo__c> lstMemo = new List<Order_Item_Memo__c>();
	Map<Id, Decimal> mapOrderItemId_MemoAmount = new Map<Id, Decimal>();
//IECErrorLogger.logApexError('SAP2SF_Order_Invoice.updateInvoice', String.valueOf(invoiceInfo), 'check', false);

	try
	{
		//*** quit if no order or no order item
		if (invoiceInfo == null || invoiceInfo.InvoiceItems == null || invoiceInfo.InvoiceItems.size() == 0)
		{
			logError(invoiceInfo, 'Missing information', null);
			return;
		}

		//*** get order items
		for (InvoiceItem oiSAP : invoiceInfo.InvoiceItems)
			mapMaterial_Product.put(oiSAP.MaterialNo, (oiSAP.MaterialNo.isNumeric()) ? String.valueOf(Long.valueOf(oiSAP.MaterialNo)) : oiSAP.MaterialNo);
		mapMaterial_OrderItem = OrderItem_Sel.getOrderItemByProductNumber(invoiceInfo.eCommerceOrderNo, mapMaterial_Product.values());
		if (invoiceInfo.InvoiceItems.size() != mapMaterial_OrderItem.size())
		{
			logError(invoiceInfo, 'Unmatched list of products', null);
			return;
		}

		//*** set order items with new information
		invoiceInfo.DocType = invoiceInfo.DocType.toUpperCase();
		for (InvoiceItem oiSAP : invoiceInfo.InvoiceItems)
		{
			updOrderItem = mapMaterial_OrderItem.get(mapMaterial_Product.get(oiSAP.MaterialNo));
			if (updOrderItem != null)
				if (invoiceInfo.DocType == 'INV')
				{
					//*** invoice -> set information to order item record
					updOrderItem.Status__c = 'Invoiced';
					updOrderItem.Invoice_Number__c = invoiceInfo.InvoiceNo;
					updOrderItem.Invoice_Date__c = invoiceInfo.InvoiceDate;
					updOrderItem.Invoice_Amount__c = oiSAP.InvoiceAmount;

					//*** update paid flags
					if (updOrderItem.Order.Payment_Type__c != IECConstants.PaymentThresholdType_BillMeLater)
					{
						updOrderItem.IEC_Is_Paid__c = true;
						if (updOrderItem.Order.Is_Paid__c != true)
							mapOrderId_PaidFlag.put(updOrderItem.OrderId, true);
					}
				}
				else
					//*** credit/debit memos -> insert information to invoice object
					lstMemo.add(new Order_Item_Memo__c(Name=invoiceInfo.DocType, OrderItem__c=updOrderItem.Id, CurrencyIsoCode=oiSAP.CurrencyCode
													 , Amount__c=(invoiceInfo.DocType == 'CRM' ? -oiSAP.InvoiceAmount : oiSAP.InvoiceAmount)));
					mapOrderItemId_MemoAmount.put(updOrderItem.Id, null);
		}

		//*** insert credit/debit memos
		if (lstMemo.size() > 0)
		{
			//*** create memos
			insert lstMemo;

			//*** update total of memos on order item
			for (AggregateResult ar : [select OrderItem__c, sum(Amount__c) Amount from Order_Item_Memo__c where OrderItem__c in :mapOrderItemId_MemoAmount.keySet() group by OrderItem__c])
				mapOrderItemId_MemoAmount.put(String.valueOf(ar.get('OrderItem__c')), Double.valueOf(ar.get('Amount')));
			for (String p : mapMaterial_OrderItem.keySet())
			{
				updOrderItem = mapMaterial_OrderItem.get(p);
				updOrderItem.Credit_Debit__c = mapOrderItemId_MemoAmount.get(updOrderItem.Id);
			}
		}

		//*** update order items
		if (mapMaterial_OrderItem.size() > 0)
		{
			//*** update order items
			update mapMaterial_OrderItem.values();

			//*** update SAP order number if applicable
			Order_Svc.updateOrderNumber(new Map<Id, String>{ invoiceInfo.eCommerceOrderNo => invoiceInfo.SAPSalesOrderNo });

			//*** update order status if its all order items are invoiced
			//if (0 == [select count() from OrderItem where OrderId = :invoiceInfo.eCommerceOrderNo and Status__c != 'Invoiced'])
			if (invoiceInfo.DocType == 'INV')
				if (0 != [select count() from Order where Id = :invoiceInfo.eCommerceOrderNo and Status not in ('Invoiced', 'Payment Confirmed')])
					Order_Svc.updateOrderStatus(new Map<Id, String>{ invoiceInfo.eCommerceOrderNo => 'Invoiced' }, mapOrderId_PaidFlag);
		}
	}
	catch (Exception e)
	{
		logError(invoiceInfo, String.valueOf(e), e.getStackTraceString());
	}
} //*** end of "confirmOrder"


/****************************************************************************************************
	Created by Thai 2016-02-24
		Log an error for follow up
****************************************************************************************************/
static void logError(InvoiceHeader invoiceInfo, String strError, String strStack)
{
	if (strStack == null)
		IECErrorLogger.logApexError('SAP2SF_Order_Invoice.updateInvoice', String.valueOf(invoiceInfo), strError, true);
	else
		IECErrorLogger.logApexException('SAP2SF_Order_Invoice.updateInvoice', String.valueOf(invoiceInfo), strError, strStack, true);
} //*** end of "logError"


} //*** end of class
