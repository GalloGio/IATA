@isTest
private class Attachment_Batch_Test {

	@isTest static void test_Attachment_Batch() {

		TestDataGenerator.generateApexSetting();

		//Create Order with Attachments
		Account account = TestDataGenerator.generateAccounts(1, true)[0];
		Contact contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];

		List<Order> orders = TestDataGenerator.generateOrder(10, account.Id, contact.Id, contact.Id, true);

		//Create Attachments
		List<Attachment> attachments = new List<Attachment>();
		for(Order order : orders){
			Attachment attachment = TestDataGenerator.createAttachment(order.Id, order.Id, 'test content');
			attachments.add(attachment);
		}

		System.assertEquals(attachments.size(),10);

		//Test the schedule and the batch
		Test.startTest();
		Attachment_Sch.scheduleDeleteSAPInvoices('0 0 20 * * ?');
		Test.stopTest();
		System.assertEquals(attachments.size(),10);

	}


}
