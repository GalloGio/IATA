@isTest
public class CreditCardPaymentErrorNotification_Test {

	@isTest static void testOrderItemList() {
		//Data preparation
		List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
		List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order1

		CreditCardPaymentErrorNotification_Ctrl controller = new CreditCardPaymentErrorNotification_Ctrl();

		controller.orderId = orders.get(0).ID;	
		List<OrderItem> listOrderItem = controller.orderItemList;

		System.assertEquals(3, listOrderItem.size());
	}

	@isTest static void testOrderItemListNullOrder() {

		CreditCardPaymentErrorNotification_Ctrl controller = new CreditCardPaymentErrorNotification_Ctrl();
		controller.orderId = null;
		List<OrderItem> listOrderItem = controller.orderItemList;

		System.assertEquals(null, listOrderItem);
	}

	@isTest static void testOrderItemListIsSetupFee() {
		//Data preparation
		List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
		List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, 1,true);// 1 lineItems for Order1

		OrderItem orderItem = orderItems.get(0); 
		orderItem.Setup_Fee__c = 1; 
		update orderItem;

		Test.startTest();

		CreditCardPaymentErrorNotification_Ctrl controller = new CreditCardPaymentErrorNotification_Ctrl();
		controller.orderId = orders.get(0).ID;
		List<OrderItem> listOrderItem = controller.orderItemList;

		Test.stopTest();

		System.assertEquals(true, controller.isSetupFee);
		System.assertEquals(1, listOrderItem.size());

	}

}