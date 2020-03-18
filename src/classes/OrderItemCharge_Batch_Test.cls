@isTest
private class OrderItemCharge_Batch_Test {

	@isTest static void test_OrderItemCharge_Batch() {
		// Implement test code
		List<Order_Item_Charge__c> lstOrderITemCharge = TestDataGenerator.generateOrderItemChargeToDelete();

		List<Order_Item_Charge__c> toDelete = [SELECT id FROM Order_Item_Charge__c WHERE Order_Item__c = null];
		System.assertEquals(toDelete.size(), 2);
		Test.startTest();
		OrderItemCharge_Batch batch = new OrderItemCharge_Batch('CleanUpOrderItemCharges',toDelete);
		Database.ExecuteBatch(batch);
		Test.stopTest();

		Integer i = [SELECT COUNT() FROM Order_Item_Charge__c WHERE Order_Item__c = null];
		System.assertEquals(i, 0);

	}

	@isTest static void test_DTO()
	{
		//-- Generate Order_Item_Charge__c
		List<Order_Item_Charge__c> charges = new List<Order_Item_Charge__c>();
		charges.add(new Order_Item_Charge__c(Name = 'C1',Discount_Amount__c=50));
		charges.add(new Order_Item_Charge__c(Name = 'C2',Discount_Amount__c=20));
		insert charges;

		List<OrderItemCharge_DTO> dtos = OrderItemCharge_DTO.format2DTO(charges);
		System.assertEquals(2,dtos.size());
	}

}
