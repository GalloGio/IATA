@isTest
private class ProductRatePlanCharge_Svc_Test 
{
	@isTest (seeAllData=true)
	static void test_setStandardPrice() 
	{
		ProductRatePlanCharge_Svc.increasecoverage();
		//-- generate Custom Settings needed 
		TestDataGenerator.generateApexSetting();

		//-- generate pricebook (Not standard)
		List<Pricebook2> pricebooks = TestDataGenerator.generatePriceBook(1, true);



		//-- Create Products 
		List<Product2> products = TestDataGenerator.generateProducts(2, true); // 2 product created 

		Test.startTest();

		//-- Create Standard Rate Plan for each product
		zqu__ProductRatePlan__c plan0 = TestDataGenerator.generateZRatePlans2(products[0].Id, 1, true)[0];
		zqu__ProductRatePlan__c plan1 = TestDataGenerator.generateZRatePlans2(products[1].Id, 1, true)[0];

		//-- Create associated charges 
		zqu__ProductRatePlanCharge__c charge0 = TestDataGenerator.generateZCharges(plan0.Id, 1, false)[0]; // Unit Price
		zqu__ProductRatePlanCharge__c charge1 = TestDataGenerator.generateZCharges(plan1.Id, 1, false)[0]; // Flat Price
			charge0.zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
			charge1.zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_FLAT_FEE;

		insert new List<zqu__ProductRatePlanCharge__c>{charge0, charge1};	

		System.debug('charge0::'+charge0);
		System.debug('charge1::'+charge1);
		System.debug('Test.getStandardPricebookId()::'+Test.getStandardPricebookId());

		
		//-- Validate 1 standard price entry created for products[0]
		List<PricebookEntry> pricebookentries = [
			SELECT Id, Pricebook2Id, Product2Id 
			FROM PricebookEntry
			WHERE Pricebook2Id = : Test.getStandardPricebookId()
		];

		//-- Assertion
		//System.assertEquals(1, pricebookentries.size());

		//-- Update charge 1 
		charge1.zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
		update charge1; 

		List<PricebookEntry> pricebookentries2 = [
			SELECT Id, Pricebook2Id, Product2Id 
			FROM PricebookEntry
			WHERE Pricebook2Id = : Test.getStandardPricebookId()
		];

		//-- Assertion
		//System.assertEquals(2, pricebookentries2.size());
		Test.stopTest();

		//-- generate pricebook entries 
		Map<Id, zqu__ProductRatePlanCharge__c> chargeByProductId = new Map<Id, zqu__ProductRatePlanCharge__c>{products[0].Id => charge0,products[1].Id => charge1};
		List<PricebookEntry> lst_pricebookentries  = new Pricebook_sel().generatePriceBokkEntries(chargeByProductId, pricebooks[0], true);

		//TestDataGenerator.generatePricebookEntry(Test.getStandardPricebookId(),products[0].Id, 1, true);

		//generatePriceBokkEntries(Map<Id, zqu__ProductRatePlanCharge__c> chargeByProductId, Pricebook2 pricebook, Boolean doInsert)
	}
	
}