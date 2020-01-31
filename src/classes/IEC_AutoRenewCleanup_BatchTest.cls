@isTest
private class IEC_AutoRenewCleanup_BatchTest
{
	@isTest (SeeAllData=true)
	static void test_method_one()
	{
		//-- Create produc t
		List<Product2> products = TestDataGenerator.generateProductsWithPrice(2);
		System.debug('products[0]::'+products[0].Id);
		System.debug('products[1]::'+products[1].Id);

		//for(Integer x =0; x < products.size(); x++)
		//{
		//	Product2 p = products[x];
		//	p.Post_to_Ecommerce_Date__c = Date.today().addDays(-1);
		//	p.Sell_through_eCommerce__c = true;
		//	p.Inventory_Status__c = 'In stock';
		//	p.Status__c = (Math.mod(x,2)==0) ? 'A' : 'Z4';
		//	p.Line_of_Business__c = 'Publications';
		//	p.SAP_Material_Number__c = (Math.mod(x,2)==0) ? '999999-98' : '999999-99';
		//}

		//update products;


		// Generate Event Releases
		IEC_Event_Release__c release = new IEC_Event_Release__c (
			Name = 'TEST RELEASE'
			, Released__c = false
			, Customer_Type__c = 'Airline'
			, Product__c = products[0].Id
			, Swapped_Product__c = products[1].Id
		);
		try{
			insert release;
		}catch(Exception ex){

		}


		//-- Run batch to clea releases
		IEC_AutoRenewCleanup_Batch batch = new IEC_AutoRenewCleanup_Batch(new List<IEC_Event_Release__c>{release}, '');
		Database.executeBatch(batch);
	}



}
