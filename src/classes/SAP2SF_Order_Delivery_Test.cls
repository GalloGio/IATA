/****************************************************************************************************
	Created by Thai 2015-12-03
		Cover code in class "SAP2SF_Order_Delivery"
****************************************************************************************************/
@isTest
private class SAP2SF_Order_Delivery_Test
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
	lstOrderItem = [select Id, Product_Number__c, Quantity from OrderItem where Id = :lstOrderItem[0].Id];

	//*** prepare to check error log
	Integer intErrorCount = [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Delivery.updateShippingInfo'];

	//*** get product generated for order item and generate additional product
	List<Product2> lstProduct = [select Id, SAP_Material_Number__c from Product2 where SAP_Material_Number__c = :lstOrderItem[0].Product_Number__c];
	lstProduct.addAll(TestDataGenerator.generateProducts(1, true));

	//*** prepare input data
	SAP2SF_Order_Delivery.DeliveryNoteHeader noteInfo = new SAP2SF_Order_Delivery.DeliveryNoteHeader();
	noteInfo.SAPSalesOrderNo = 'sap';
	noteInfo.SAPDeliveryNo = 'delivery';
	noteInfo.eCommerceOrderNo = lstOrder[0].Id;
	noteInfo.CarrierName = 'UPS';
	noteInfo.CarrierShipmentNo = '1234';
	noteInfo.ShippedDate = system.today();
	SAP2SF_Order_Delivery.DeliveryNoteItem noteItemInfo = new SAP2SF_Order_Delivery.DeliveryNoteItem();
	noteItemInfo.ShippedQuantity = 99999999999999999999.99;
	noteInfo.DeliveryNoteItems.add(noteItemInfo);

	//*** cover case of no data
	SAP2SF_Order_Delivery.updateShippingInfo(new SAP2SF_Order_Delivery.DeliveryNoteHeader());
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Shipped_Quantity__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 1 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Delivery.updateShippingInfo']
				, 'Wrong error logged');

	//*** cover case of provided material unmatched
	noteItemInfo.MaterialNo = lstProduct[1].SAP_Material_Number__c;
	SAP2SF_Order_Delivery.updateShippingInfo(noteInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Shipped_Quantity__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 2 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Delivery.updateShippingInfo']
				, 'Wrong error logged');

	//*** cover case of error
	noteItemInfo.MaterialNo = lstProduct[0].SAP_Material_Number__c;
	SAP2SF_Order_Delivery.updateShippingInfo(noteInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Shipped_Quantity__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 3 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Delivery.updateShippingInfo']
				, 'Wrong error logged');

	//*** cover case of updated with payment method other than "Bill me later"
	noteItemInfo.ShippedQuantity = lstOrderItem[0].Quantity;
	SAP2SF_Order_Delivery.updateShippingInfo(noteInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = 'Shipped'
						  and IEC_Is_Paid__c = true
						  and Shipped_Quantity__c = :noteItemInfo.ShippedQuantity], 'Order Item should be updated');
	//system.assert(1 == [select count()
	//                    from Order
	//                    where Id = :lstOrder[0].Id
	//                      and SAP_Order_Number__c = :noteInfo.SAPSalesOrderNo
	//                      and Is_Paid__c = true
	//                      and Status != 'New'], 'SAP Order Number must be set and order status should NOT be New');

	//*** cover case of updated with payment method "Bill me later"
	update new Order(Id=lstOrder[0].Id, Status='New', Payment_Type__c=IECConstants.PaymentThresholdType_BillMeLater, Is_Paid__c=false);
	update new OrderItem(Id=lstOrderItem[0].Id, Status__c=null, Shipped_Quantity__c=null, IEC_Is_Paid__c=false);
	SAP2SF_Order_Delivery.updateShippingInfo(noteInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = 'Shipped'
						  and IEC_Is_Paid__c = false
						  and Shipped_Quantity__c = :noteItemInfo.ShippedQuantity], 'Order Item should be updated');
	//system.assert(1 == [select count()
	//                    from Order
	//                    where Id = :lstOrder[0].Id
	//                      and SAP_Order_Number__c = :noteInfo.SAPSalesOrderNo
	//                      and Is_Paid__c = false
	//                      and Status != 'New'], 'SAP Order Number must be set and order status should NOT be New');
} //*** end of "test_AllMethod"


} //*** end of class
