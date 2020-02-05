/****************************************************************************************************
	Created by Thai 2015-12-02
		Cover code in class "SAP2SF_Order_Confirmation"
****************************************************************************************************/
@isTest
private class SAP2SF_Order_Confirmation_Test
{


/****************************************************************************************************
	Created by Thai 2015-12-02
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
	List<Order> lstOrder = TestDataGenerator.generateOrder(1, lstAccount[0].Id, lstContact[0].Id, lstContact[0].Id, true);
	List<OrderItem> lstOrderItem = TestDataGenerator.generateOrderItem(lstOrder[0].Id, 1, true);
	lstOrderItem = [select Id, Product_Number__c, Quantity from OrderItem where Id = :lstOrderItem[0].Id];

	//*** prepare to check error log
	Integer intErrorCount = [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Confirmation.confirmOrder'];

	//*** get product generated for order item and generate additional product
	List<Product2> lstProduct = [select Id, SAP_Material_Number__c from Product2 where SAP_Material_Number__c = :lstOrderItem[0].Product_Number__c];
	lstProduct.addAll(TestDataGenerator.generateProducts(1, true));

	//*** prepare input data
	SAP2SF_Order_Confirmation.SalesOrderHeader orderInfo = new SAP2SF_Order_Confirmation.SalesOrderHeader();
	orderInfo.SAPSalesOrderNo = 'sap';
	orderInfo.eCommerceOrderNo = lstOrder[0].Id;
	SAP2SF_Order_Confirmation.SalesOrderItem orderItemInfo = new SAP2SF_Order_Confirmation.SalesOrderItem();
	orderItemInfo.OrderedQuantity = lstOrderItem[0].Quantity;
	orderItemInfo.ConfirmedQuantity = 99999999999999999999.99;
	orderItemInfo.ScheduledDeliveryDate = system.today().addDays(1);
	orderItemInfo.Status = 'Confirmed';
	orderInfo.SalesOrderItems.add(orderItemInfo);

	//*** cover case of no data
	SAP2SF_Order_Confirmation.confirmOrder(new SAP2SF_Order_Confirmation.SalesOrderHeader());
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Scheduled_Delivery_Date__c = null
						  and Confirmed_Quantity__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 1 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Confirmation.confirmOrder']
				, 'Wrong error logged');

	//*** cover case of provided material unmatched
	orderItemInfo.MaterialNo = lstProduct[1].SAP_Material_Number__c;
	SAP2SF_Order_Confirmation.confirmOrder(orderInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Scheduled_Delivery_Date__c = null
						  and Confirmed_Quantity__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 2 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Confirmation.confirmOrder']
				, 'Wrong error logged');

	//*** cover case of error
	orderItemInfo.MaterialNo = lstProduct[0].SAP_Material_Number__c;
	SAP2SF_Order_Confirmation.confirmOrder(orderInfo);
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = null
						  and Scheduled_Delivery_Date__c = null
						  and Confirmed_Quantity__c = null], 'Order Item should NOT be updated');
	system.assert(intErrorCount + 3 == [select count() from IEC_Error_Log__c where CreatedById = :UserInfo.getUserId() and CreatedDate >= today and Source__c = 'SAP2SF_Order_Confirmation.confirmOrder']
				, 'Wrong error logged');

	//*** cover case of updated
	orderItemInfo.ConfirmedQuantity = lstOrderItem[0].Quantity;

	Test.startTest();
	SAP2SF_Order_Confirmation.confirmOrder(orderInfo);
	Test.stopTest();
	system.assert(1 == [select count()
						from OrderItem
						where Id = :lstOrderItem[0].Id
						  and Status__c = :orderItemInfo.Status
						  and Scheduled_Delivery_Date__c = :orderItemInfo.ScheduledDeliveryDate
						  and Confirmed_Quantity__c = :orderItemInfo.ConfirmedQuantity], 'Order Item should be updated');
	//system.assert(1 == [select count()
	//                    from Order
	//                    where Id = :lstOrder[0].Id
	//                      and SAP_Order_Number__c = :orderInfo.SAPSalesOrderNo], 'SAP Order Number must be set');
} //*** end of "test_AllMethod"


} //*** end of class
