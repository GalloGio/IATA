@isTest
private class Selector_Test
{
	@isTest
	static void test_data_selection()
	{
		TestDataGenerator.generateUtilitySetting();
		
		//-- Generate Test Data
		Product2 prodA = new Product2(
			Name = 'Product A',
			SAP_Material_Number__c = TestDataGenerator.generateProductCode(),
			Effective_From__c = Date.today().addMonths(-1),
			Effective_To__c = Date.today().addMonths(+1)
		); 
		
		Product2 prodB = new Product2(
			Name = 'Product B',
			SAP_Material_Number__c = TestDataGenerator.generateProductCode(),
			Effective_From__c = null,
			Effective_To__c = Date.today().addMonths(+1)
		); 
		
		insert new List<Product2>{prodA, prodB};

		// Call Method 
		Product_Sel pSelector = new Product_Sel(); 

		List<String> fields = new List<String>{'Id','Name'};

		List<Product2> productInsertedDefault = pSelector.selectById(new Set<Id>{prodA.Id, prodB.Id});
		List<Product2> productInsertedWithFields = pSelector.selectById(new Set<Id>{prodA.Id}, fields);
		List<Product2> productInsertedByName = pSelector.selectSObjectByField('Name', new Set<String>{'Product A'});
		List<Product2> productInsertedByName2 = pSelector.selectSObjectByField('Name', new Set<String>{'Product B'}, fields);
		List<Product2> productInsertedByName3 = pSelector.selectSObjectByField('', new Set<String>{prodA.Id}, new List<String>());

		// Assert
		System.assertEquals(2, productInsertedDefault.size());
		System.assertEquals(prodA.Id,productInsertedByName[0].Id);

	}
}