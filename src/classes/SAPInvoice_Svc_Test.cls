/**
 *
 * @author: Kevin Ky <kevin.ky@cgi.com>
 * @date: 2015-12-03
 *
 *
 **/
@isTest
public class SAPInvoice_Svc_Test {

	@isTest(SeeAllData=true)
	public static void test_SAPInvoices() {

		TestDataGenerator.generateApexSetting();

		//Create order and Order ITems
		List<Account> accounts = TestDataGenerator.generateAccounts(1,true);
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true);
		List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,false);
		orders[0].Payment_Type__c = IECConstants.PaymentThresholdType_BillMeLater;
		insert orders;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, 3, false);
		orderItems[0].Invoice_Number__c = 'invoice 1';
		orderItems[1].Invoice_Number__c = 'invoice 2';
		orderItems[2].Invoice_Number__c = 'invoice 2';
		insert orderItems;

		//Create new SAP_Invoice with payment method "Bill me later"
		SAP_Invoice__c sapInvoice = new SAP_Invoice__c();
		sapInvoice.Clearance_Date__c = Date.today();
		sapInvoice.Invoice_Number__c = 'invoice 1';
		sapInvoice.Order__c = orders[0].Id;
		insert sapInvoice;
		system.assert(1 ==[select count() from Order where Id = :orders[0].Id and Status = 'Payment Confirmed' and Is_Paid__c = false], 'Status must be changed and Order is NOT paid');
		system.assert(1 ==[select count() from OrderItem where OrderId = :orders[0].Id and IEC_Is_Paid__c = true], 'Order Item must be paid');

		//Create new SAP_Invoice with payment method other than "Bill me later"
		update new Order(Id=orders[0].Id, Status='New', Payment_Type__c='Credit Card');
		sapInvoice = new SAP_Invoice__c();
		sapInvoice.Clearance_Date__c = Date.today();
		sapInvoice.Invoice_Number__c = 'invoice 2';
		sapInvoice.Order__c = orders[0].Id;
		insert sapInvoice;
		system.assert(1 ==[select count() from Order where Id = :orders[0].Id and Status = 'Payment Confirmed' and Is_Paid__c = true], 'Status must be changed and Order is paid');
		system.assert(3 ==[select count() from OrderItem where OrderId = :orders[0].Id and IEC_Is_Paid__c = true], 'Order Item must be paid');
	}

}
