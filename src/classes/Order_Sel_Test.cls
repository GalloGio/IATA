/**

	Project: eCommerce Enhancements
	   File: Order_Sel_Test.cls
	Subject: Test Class for Order_Sel Class.
	History: 2017-06-26, asantos, Initial Release.

*/
@isTest
private class Order_Sel_Test {
	private static User user;
	private static Account account;
	private static Contact contact;

	private static void setup() {
		user = IECTestUtil.createSampleGuestUserAndLogin();

		TestDataGenerator.generateApexSetting();
		account = TestDataGenerator.generateAccounts(1, true)[0];
		contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];
		contact.Account = account;
	}

	@isTest
	static void testOrderSel1() {
		Test.startTest();

		setup();

		System.runAs(user) {
			String orderId;
			String orderItemId;
			Order order;
			Order_Sel orderSel = new Order_Sel();
			Set<Id> orderIdSet = new Set<Id>();
			List<Id> accountIdList = new List<Id>();
			List<Id> contactIdList = new List<Id>();
			String orderType = 'Cart';

			List<Schema.SObjectField> sobjectFieldList = orderSel.getSObjectFieldList();
			Schema.SObjectType sobjectType = orderSel.getSObjectType();
			List<Order> orderList = orderSel.getQuotesOlderThan3Months();
			Map<Id,String> orderStatusMap = Order_Sel.getOrderStatusById(orderIdSet);
			Map<Id,Order> orderMap = orderSel.getOrderByStatus(orderIdSet);
			Map<String,IEC_Payment_Threshold__c> paymentMap = Order_Sel.getPaymentMethodThresholdByType();
			Map<String, SFDC_SAP_Mapping__c> orderSapMap;
			SFDC_SAP_Mapping__c sfdcSapMapping;

			orderList = Order_Sel.getOrdersById(orderIdSet);
			orderList = Order_Sel.getOrderForAccountOrContact(accountIdList, contactIdList);

			try {
				order = Order_Sel.getOrderForVF(orderId);
			} catch (Exception e) {
			}

			try {
				order = Order_Sel.getOrderWithItems(orderId);
			} catch (Exception e) {
			}

			orderSapMap = orderSel.getOrderMapTable();
			sfdcSapMapping = Order_Sel.getConversionSFDC_SAP(orderType, null, null);

			try {
				order = Order_Sel.getOrderForFreightAndTax(orderId, orderItemId);
			} catch (Exception e) {
			}

			orderList = Order_Sel.getOrderForContract(orderIdSet);

			order = orderSel.getPenddingOrder(user.Id);

			order = orderSel.initializeOrder(account, contact, user.Id);
			order = orderSel.initializeOrder(account, contact, user.Id, true);
			
			Test.stopTest();
			
			orderSel.cleanOrderItems(orderId);
			orderIdSet = orderSel.findOrders4SAP(orderList, orderList);
			orderList = orderSel.getOrdersReady4SAP();
			orderList = Order_Sel.getQuotesList(null);
			orderList = Order_Sel.getCustomerRenewalNotices(null);
			orderList = Order_Sel.getOrdersByContact(null, null);
			orderList = orderSel.getQuotes(null);
		}

		
	}

	@isTest
	static void testOrderSel2() {
		Test.startTest();

		setup();

		System.runAs(user) {
			String orderId;
			String orderItemId;
			Order order;
			Order_Sel orderSel = new Order_Sel();
			Set<Id> orderIdSet = new Set<Id>();
			List<Id> accountIdList = new List<Id>();
			List<Id> contactIdList = new List<Id>();
			String orderType = 'Cart';

			List<Schema.SObjectField> sobjectFieldList = orderSel.getSObjectFieldList();
			Schema.SObjectType sobjectType = orderSel.getSObjectType();
			List<Order> orderList = orderSel.getQuotesOlderThan3Months();
			Map<Id,String> orderStatusMap = Order_Sel.getOrderStatusById(orderIdSet);
			Map<Id,Order> orderMap = orderSel.getOrderByStatus(orderIdSet);
			Map<String,IEC_Payment_Threshold__c> paymentMap = Order_Sel.getPaymentMethodThresholdByType();
			Map<String, SFDC_SAP_Mapping__c> orderSapMap;
			SFDC_SAP_Mapping__c sfdcSapMapping;

			orderList = Order_Sel.getOrdersById(orderIdSet);
			orderList = Order_Sel.getOrderForAccountOrContact(accountIdList, contactIdList);

			try {
				order = Order_Sel.getOrderForVF(orderId);
			} catch (Exception e) {
			}

			try {
				order = Order_Sel.getOrderWithItems(orderId);
			} catch (Exception e) {
			}

			orderSapMap = orderSel.getOrderMapTable();
			sfdcSapMapping = Order_Sel.getConversionSFDC_SAP(orderType, null, null);

			try {
				order = Order_Sel.getOrderForFreightAndTax(orderId, orderItemId);
			} catch (Exception e) {
			}

			orderList = Order_Sel.getOrderForContract(orderIdSet);

			order = orderSel.getPenddingOrder(user.Id);

			order = orderSel.initializeOrder(account, contact, user.Id);
			order = orderSel.initializeOrder(account, contact, user.Id, true);
			
			Test.stopTest();
			
			order = orderSel.getQuoteDetails(null);
			order = Order_Sel.getQuoteDetail(null, null);
			order = Order_Sel.getOrderDetail(null, null, null);
			order = orderSel.getCustomerQuoteDetails(null, null);
			orderList = orderSel.getRenewalNotificationsForCleanUp();
			orderList = Order_Sel.getNewOrdersByLocation(new Set<Id> {});
			orderList = orderSel.getMyOrders(null);
			orderList = orderSel.getMyOrders(null, null);
		}

		
	}

}