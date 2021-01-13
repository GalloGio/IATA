/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProductShippedNotificationContent_Test {

    @isTest(SeeAllData=true)
    static void CustomerShippedNotificationTest() {
        TestDataGenerator.generateApexSetting();

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
 	
     	Contact oContact = IECUserManager.getContactById(usr.ContactId);
     	system.assert(oContact != null, 'Contact associated to the created user should not be null');
     	IECCustomer oCurrentCustomer;

     	System.runAs(usr) {
     		Test.startTest();
	     	oCurrentCustomer = IECCustomer.getCurrentIECCustomer();
	     	system.assert(oCurrentCustomer != null, 'Object representing the logged in use should not be null');

			//set all Custom setting
	        TestDataGenerator.generateApexSetting();
	        List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
	        List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
	        //List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[1].Id, contacts[1].Id,true); // 1 Order
            List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, usr.ContactId,true); // 1 Order
	        List<OrderItem> orderItems = TestDataGenerator.generateWebDownloadOrderItem(orders[0].Id, 3,false);// 3 lineItems for Order
	        orderItems[0].Setup_Fee__c = 10;
	        insert orderItems;

	        //Cover the ProductShippedNotificationContent_Ctrl class
        	ProductShippedNotificationContent_Ctrl prdShipNotif = new ProductShippedNotificationContent_Ctrl();
        	prdShipNotif.orderItemId = orderItems[0].Id;
        	prdShipNotif.getOrderItems();

        	//Cover the ProductSoldManagerNotification_Ctrl Class
        	ProductSoldManagerNotification_Ctrl prdSoldManagerNotif = new ProductSoldManagerNotification_Ctrl();
        	prdSoldManagerNotif.idOrder = orders[0].Id;
        	prdSoldManagerNotif.sOrderNumber = orders[0].OrderNumber;
        	prdSoldManagerNotif.getOrder();
        	prdSoldManagerNotif.idOrderItem = orderItems[1].Id;
        	prdSoldManagerNotif.productName = orderItems[1].Product_Name__c;
        	prdSoldManagerNotif.getOrderItem();

        	//Cover the OrderProcessNotificationContent_Ctrl Class
        	OrderProcessNotificationContent_Ctrl ordProcNotif = new OrderProcessNotificationContent_Ctrl();
        	ordProcNotif.idOrder = orders[0].Id;
        	ordProcNotif.getOrderItems();

        	system.assertEquals(3,orderItems.size());

			Test.stopTest();

		}

    }
}