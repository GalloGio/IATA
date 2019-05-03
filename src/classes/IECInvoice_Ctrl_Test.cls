@isTest
private class IECInvoice_Ctrl_Test {

	@isTest(SeeAllData=true)
	static void test_IECInvoice(){

		TestDataGenerator.generateApexSetting();

		//Create Orders 
		List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
		List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order1
     	orderItems[0].Invoice_Number__c = '123456';
		update orderItems;

		PageReference pageRef = Page.IECInvoice;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getParameters().put('invoice',orderItems[0].Invoice_Number__c);

		Test.startTest();
		Test.setMock(WebServiceMock.class, new MockSAPDigitalInvoice());
		IECInvoice_Ctrl invoice = new IECInvoice_Ctrl();
		invoice.getInvoice();
		IECInvoice_Ctrl.CallSAPToGetInvoice_Static(orderItems[0].Invoice_Number__c);
		Test.stopTest();

		List<Attachment> lstAttachment = [select id, Name from Attachment where Name =:orders[0].Id];

		system.assertEquals(3,orderItems.size());
		system.assertEquals(1,lstAttachment.size());

	}

}