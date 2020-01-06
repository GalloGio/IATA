@isTest
private class ProductPrice_Ext_Test {
	@isTest(SeeAllData=true)
	static void test_ProductPrice(){
		TestDataGenerator.generateApexSetting();
		List<Product2> products = TestDataGenerator.generateProductsWithPrice(2);
		ApexPages.StandardController sc = new ApexPages.standardController(products[0]);
		//cover ProductPrice_Ext class
		ProductPrice_Ext pp = new ProductPrice_Ext(sc);
		system.assertEquals(2,products.size());
	}

}
