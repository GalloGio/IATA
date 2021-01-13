@isTest
private class ZProduct_Sel_Test
{

	public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
		public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);

	@isTest static void test_selectById()
	{
		//-- Generate Test Data
		zqu__ZProduct__c zProdA = new zqu__ZProduct__c(
			Name = 'ZProduct A',
			zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE,
			zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE,
			zqu__SKU__c = 'SKU-A',
			zqu__ZuoraId__c = TestDataGenerator.generateZuoraFakeId()
		);
		zqu__ZProduct__c zProdB = new zqu__ZProduct__c(
			Name = 'ZProduct B',
			zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE,
			zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE,
			zqu__SKU__c = 'SKU-B',
			zqu__ZuoraId__c = TestDataGenerator.generateZuoraFakeId()
		);
		insert new List<zqu__ZProduct__c>{zProdA, zProdB};

		//-- Call Method
		ZProduct_Sel zProdSelector = new ZProduct_Sel();
		List<zqu__ZProduct__c> result = zProdSelector.selectById(new Set<Id>{zProdA.Id, zProdB.Id});
		List<zqu__ZProduct__c> result2 = zProdSelector.selectById(new Set<Id>{zProdA.Id, zProdB.Id}, new List<String>{'Name'});

		//-- Assert
		System.assertEquals(2, result.size());

		try{
			String sku = result2[0].zqu__SKU__c;
		}
		catch(Exception e)
		{
			System.assert(e.getMessage().contains('zqu__SKU__c'));
		}
	}


	@isTest static void test_getProductQueryString()
	{
		ZProduct_Sel zProdSelector = new ZProduct_Sel();

		//-- Generate Test Data
		String zId1 = TestDataGenerator.generateZuoraFakeId();
		String zId2 = TestDataGenerator.generateZuoraFakeId();

		//-- Call Method
		String zoql = zProdSelector.getProductQueryString(new Set<String>{zId1, zId2});

		//-- Assert
		System.assert(zoql.contains(zId1));
		System.assert(zoql.contains(zId2));
	}

	@isTest
	static void test_getProductByPlan()
	{
		//-- Generate Test data
		List<zqu__ZProduct__c> zProducts = TestDataGenerator.generateZProducts(2, true);

		//Generate Rate Plan for 1st ZProduct
		List<zqu__ProductRatePlan__c> rp0 =TestDataGenerator.generateZRatePlans(zProducts[0].Id, 2, false);

		//Generate Rate Plan for 2nd ZProduct
		List<zqu__ProductRatePlan__c> rp1 =TestDataGenerator.generateZRatePlans(zProducts[0].Id, 3, false);

		List<zqu__ProductRatePlan__c> ratePlans = new List<zqu__ProductRatePlan__c>();
		ratePlans.addAll(rp0);
		ratePlans.addAll(rp1);

		insert ratePlans;

		//Call functions
		ZProduct_Sel zpSelector = new ZProduct_Sel();
		Map<Id, zqu__ZProduct__c> rateplanByProduct =  zpSelector.getProductByPlan(ratePlans);
		Map<Id, Id> productByRatePlan  = zpSelector.getProductIdByPlan(ratePlans);

		//Validate function results
		System.assertEquals(5,ratePlans.size()); // 5 ratePlan are created

		System.assert(productByRatePlan.containsKey(ratePlans[0].Id));
	}

}
