/****************************************************************************************************
	Created by Thai 2015-12-04
		Cover code in class "SAP2SF_Order_Invoice"
****************************************************************************************************/
@isTest
private class SAP2SF_Order_Invoice_Test
{


/****************************************************************************************************
	Created by Thai 2015-12-03
		Cover code all methods in class
		Indirectly cover
			Method "getOrderItemByProductNumber" of class "OrderItem_Sel"
****************************************************************************************************/
@isTest(SeeAllData=true) static void test_AllMethod() {
	TestDataGenerator.generateApexSetting();

	//*** generate accounts, contacts and portal users
	List<Account> lstAccount = TestDataGenerator.generateAccounts(1, true);
	List<Contact> lstContact = TestDataGenerator.generateContacts(lstAccount[0].Id, 1, true);
	List<User> lstUser = new List<User> {TestDataGenerator.generatePortalUser('ISS Portal', lstContact[0].Id, true)};

	//*** generate order and order item
	List<Order> lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, false);
	lstOrder[0].Status = 'New';
	lstOrder[0].Payment_Type__c = 'Credit Card';
	insert lstOrder;
	List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 1, true);
	lstOrderItem = [select Id, SAP_Product_Number__c, Quantity from OrderItem where Id = :lstOrderItem[0].Id];

	//*** prepare to check error log
	Integer intErrorCount = [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Invoice.updateInvoice'];

	//*** get product generated for order item and generate additional product
	List<Product2> lstProduct = [select Id, SAP_Material_Number__c from Product2 where SAP_Material_Number__c = :lstOrderItem[0].SAP_Product_Number__c];
	lstProduct.addAll(TestDataGenerator.generateProducts(1, true));

	//*** prepare input data
	SAP2SF_Order_Invoice.InvoiceHeader invoiceInfo = new SAP2SF_Order_Invoice.InvoiceHeader();
	invoiceInfo.SAPSalesOrderNo = 'sap';
	invoiceInfo.eCommerceOrderNo = lstOrder[0].Id;
	invoiceInfo.InvoiceNo = 'invoice';
	invoiceInfo.InvoiceDate = system.today();
	SAP2SF_Order_Invoice.InvoiceItem invoiceItemInfo = new SAP2SF_Order_Invoice.InvoiceItem();
	invoiceItemInfo.InvoiceAmount = 99999999999999999999.99;
	invoiceItemInfo.CurrencyCode = Utility.getDefaultCurrency();
	invoiceInfo.InvoiceItems.add(invoiceItemInfo);

	//*** cover case of no data
	SAP2SF_Order_Invoice.updateInvoice(new SAP2SF_Order_Invoice.InvoiceHeader());
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Invoice_Number__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 1 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Invoice.updateInvoice']
				, 'Wrong error logged');

	//*** cover case of provided material unmatched
	invoiceItemInfo.MaterialNo = lstProduct[1].SAP_Material_Number__c;
	SAP2SF_Order_Invoice.updateInvoice(invoiceInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Invoice_Number__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 2 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Invoice.updateInvoice']
				, 'Wrong error logged');

	//*** cover case of error
	invoiceItemInfo.MaterialNo = lstProduct[0].SAP_Material_Number__c;
	SAP2SF_Order_Invoice.updateInvoice(invoiceInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Invoice_Number__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 3 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Invoice.updateInvoice']
				, 'Wrong error logged');

	//*** cover case of updated for a credit memo
	invoiceInfo.DocType = 'DRM';
	invoiceItemInfo.InvoiceAmount = 10;
	SAP2SF_Order_Invoice.updateInvoice(invoiceInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Credit_Debit__c = :invoiceItemInfo.InvoiceAmount], 'Credit/Debit should be updated');
	system.assert(1 == [select count() from Order_Item_Memo__c where OrderItem__c = :lstOrderItem[0].Id], 'Debit memo should be created');

	//*** cover case of updated for a credit memo
	invoiceInfo.DocType = 'CRM';
	invoiceItemInfo.InvoiceAmount = 10;
	SAP2SF_Order_Invoice.updateInvoice(invoiceInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Credit_Debit__c = 0], 'Credit/Debit should be updated');
	system.assert(2 == [select count() from Order_Item_Memo__c where OrderItem__c = :lstOrderItem[0].Id], 'Credit memo should be created');

	Test.startTest();   //*** bypass limit of # queries
		//*** cover case of updated for an invoice with payment method other than "Bill me later"
		invoiceInfo.DocType = 'INV';
		invoiceItemInfo.InvoiceAmount = 100;
		SAP2SF_Order_Invoice.updateInvoice(invoiceInfo);
		system.assert(1 == [select count()
							from OrderItem
							where Id = :lstOrderItem[0].Id
							  and Status__c = 'Invoiced'
							  and IEC_Is_Paid__c = true
							  and Invoice_Amount__c = :invoiceItemInfo.InvoiceAmount], 'Order Item should be updated');
		//system.assert(1 == [select count()
		//                    from Order
		//                    where Id = :lstOrder[0].Id
		//                      and SAP_Order_Number__c = :invoiceInfo.SAPSalesOrderNo
		//                      and Is_Paid__c = true
		//                      and Status != 'New'], 'SAP Order Number must be set and order status should NOT be New');

		//*** cover case of updated with payment method "Bill me later"
		update new Order(Id=lstOrder[0].Id, Status='New', Payment_Type__c=IECConstants.PaymentThresholdType_BillMeLater, Is_Paid__c=false);
		update new OrderItem(Id=lstOrderItem[0].Id, Status__c=null, Invoice_Amount__c=null, IEC_Is_Paid__c=false);
		SAP2SF_Order_Invoice.updateInvoice(invoiceInfo);
		system.assert(1 == [select count()
							from OrderItem
							where Id = :lstOrderItem[0].Id
							  and Status__c = 'Invoiced'
							  and IEC_Is_Paid__c = false
							  and Invoice_Amount__c = :invoiceItemInfo.InvoiceAmount], 'Order Item should be updated');
		//system.assert(1 == [select count()
		//                    from Order
		//                    where Id = :lstOrder[0].Id
		//                      and SAP_Order_Number__c = :invoiceInfo.SAPSalesOrderNo
		//                      and Is_Paid__c = false
		//                      and Status != 'New'], 'SAP Order Number must be set and order status should NOT be New');
	Test.stopTest();
} //*** end of "test_AllMethod"


} //*** end of class
