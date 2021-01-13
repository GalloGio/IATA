@isTest
private class ProductRatePlanChargeTier_Sel_Test
{
	@isTest(SeeAllData=true)
	static void test_ProductRatePlanChargeTier_Sel()
	{
		ProductRatePlanChargeTier_Sel selector = new ProductRatePlanChargeTier_Sel();

		TestDataGenerator.generateApexSetting();
		List<Product2> lstProducts = TestDataGenerator.generateDirectSaleProductsWithPrice(1);
		List<zqu__ProductRatePlanCharge__c> lstPrdRatePlanCharge = [select id from zqu__ProductRatePlanCharge__c];
		set<String> prpctIds = new set<String>();
		set<String> prdIds = new set<String>();

		if(lstPrdRatePlanCharge != null && lstPrdRatePlanCharge.size() > 0){
			for(zqu__ProductRatePlanCharge__c prpc : lstPrdRatePlanCharge){
				prpctIds.add(prpc.Id);
			}
		}

		//coverage getActiveTiers on ProductRatePlanChargeTier_Sel
		selector.getActiveTiers(prpctIds);
		if(lstProducts != null && lstProducts.size() > 0){
			for(Product2 prd : lstProducts){
				prdIds.add(prd.SAP_Material_Number__c);
			}
		}

		//coverage getProductTiers on ProductRatePlanChargeTier_Sel
		selector.getProductTiers(prdIds);

		system.assertEquals(1,lstProducts.size());

		Set<String> setRatePlanZId = new Set<String>();
		for (zqu__ProductRatePlan__c rp : [select zqu__ZuoraId__c from zqu__ProductRatePlan__c])
			setRatePlanZId.add(rp.zqu__ZuoraId__c);

		//coverage getProductTiersByRatePlan on ProductRatePlanChargeTier_Sel
		selector.getProductTiersByRatePlan(setRatePlanZId);

	}
}
