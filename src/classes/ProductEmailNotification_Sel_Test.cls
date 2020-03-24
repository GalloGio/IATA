@isTest
public class ProductEmailNotification_Sel_Test {
	@isTest(seeAllData=true)
	static void test_ProductEmailNotification_Sel()
	{
		//cover the Prevent Internal and External emails entry at the same time
	 	TestDataGenerator.generateApexSetting();

		List<Product2> lstProduct = TestDataGenerator.generateProducts(1,true);
		List<Product_Email_Notification__c> lstprdEmailNotif = TestDataGenerator.generateProductEmailNotification(lstProduct[0].Id,1,true,false);

		map<Id,List<Product_Email_Notification__c>> penMap = ProductEmailNotification_Sel.getProdIdByLstEmailNotif(new map<Id,Product2>(lstProduct).keySet());
		system.assertEquals(1, penMap.size());
	}

}
