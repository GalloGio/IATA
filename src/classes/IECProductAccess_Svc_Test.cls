@isTest
private class IECProductAccess_Svc_Test {

	@isTest(SeeAllData=true)
	// Set an order to paid and see that the product access gets activated
	static void testPaidOrder_With_ProductAccessActivation() {
		//-- Create Test Data
		Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
		IEC_Product_Access__c prodAccess = TestDataGenerator.generateProductAccess(oContact.Id, false, 'TESTSUB0001', true);
		Order oOrder = TestDataGenerator.generateOrder(1, oAccount.Id, oContact.Id, oContact.Id, true)[0];
		OrderItem oOrderItem = TestDataGenerator.generateOrderItem(oOrder.Id, 1, false)[0];
		oOrderItem.Zuora_Subscription_Number__c = 'TESTSUB0001';
		insert oOrderItem;

		Test.startTest();
			// Set the order is paid to true
			oOrder.Is_Paid__c = true;
			update oOrder;

			List<IEC_Product_Access__c> lstProdAccess = [SELECT Active__c FROM IEC_Product_Access__c WHERE ID = :prodAccess.Id];
			System.assertEquals(true, lstProdAccess[0].Active__c, 'Product Access must be set to true after gets paid.');
		Test.stopTest();
	}

	@isTest(SeeAllData=true)
	// Set an order to paid and see that the product access gets activated
	static void testPaidOrderItem_With_ProductAccessActivation() {
		//-- Create Test Data
		Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
		IEC_Product_Access__c prodAccess = TestDataGenerator.generateProductAccess(oContact.Id, false, 'TESTSUB0001', true);
		Order oOrder = TestDataGenerator.generateOrder(1, oAccount.Id, oContact.Id, oContact.Id, true)[0];
		OrderItem oOrderItem = TestDataGenerator.generateOrderItem(oOrder.Id, 1, false)[0];
		oOrderItem.Zuora_Subscription_Number__c = 'TESTSUB0001';
		insert oOrderItem;

		Test.startTest();
			// Set the order is paid to true
			oOrderItem.IEC_Is_Paid__c = true;
			update oOrderItem;

			List<IEC_Product_Access__c> lstProdAccess = [SELECT Active__c FROM IEC_Product_Access__c WHERE ID = :prodAccess.Id];
			System.assertEquals(true, lstProdAccess[0].Active__c, 'Product Access must be set to true after gets paid.');
		Test.stopTest();
	}
}
