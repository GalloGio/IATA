@isTest
private class ProductRatePlan_Sel_Test {

	@isTest public static void testGetRatePlanByCharge() {

		// create zuora product
		zqu__ZProduct__c oProduct = IECTestUtil.CreateSampleProduct('Test Product 1 ');
		oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
		oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
		insert oProduct;

		// create zuora rate plan
		zqu__ProductRatePlan__c oProductRatePlan1 = IECTestUtil.CreateSampleProductRatePlan('Rate plan 1', false, oProduct);
		zqu__ProductRatePlan__c oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan('Rate plan 2', false, oProduct);
		zqu__ProductRatePlan__c oProductRatePlan3 = IECTestUtil.CreateSampleProductRatePlan('Rate plan 3', false, oProduct);
		List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c> {oProductRatePlan1, oProductRatePlan2, oProductRatePlan3};
		insert productRatePlanList;

		// create dummy Zuora rate plan oProductRatePlanCharge
        zqu__ProductRatePlanCharge__c oProductRatePlanCharge1 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan1, 'CHARGETEST', 42);
		zqu__ProductRatePlanCharge__c oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 84);
		zqu__ProductRatePlanCharge__c oProductRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan3, 'CHARGETEST', 0);
		List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c> {oProductRatePlanCharge1,oProductRatePlanCharge2,oProductRatePlanCharge3};
		insert productRatePlanChargeList;

		Test.startTest();

		ProductRatePlan_Sel productRatePlan = new ProductRatePlan_Sel();

		Map<Id, zqu__ProductRatePlan__c> mapProductRatePlan = productRatePlan.getRatePlanByCharge(productRatePlanChargeList, true);

		Test.stopTest();

		System.assertEquals(3, mapProductRatePlan.size());
	}
	
}