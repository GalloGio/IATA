@isTest
private class IEC_ProductDetailsControllerTest {
	
	@isTest(SeeAllData=true)
	static void test_all() {
		//-- Generate Ecom Products
		List<EComProduct_DTO> products = Product_Sel.getEComProduct(null, true, '', null, false);

		//List<Product2> products = TestDataGenerator.generateProductsWithPrice(2);
		//for(Integer x =0; x < products.size(); x++)
		//{
		//	Product2 p = products[x];
		//	p.Post_to_Ecommerce_Date__c = Date.today().addDays(-1);
		//	p.Sell_through_eCommerce__c = true; 
		//	p.Inventory_Status__c = 'In stock';
		//	p.Status__c = (Math.mod(x,2)==0) ? 'A' : 'Z4';
		//	p.Line_of_Business__c = (Math.mod(x,2)==0) ? 'Publications' : 'GDP';
		//	p.Mega_Menu__c = (Math.mod(x,2)==0) ? 'publications' : 'data-and-statistics';
		//	p.Refinement_Language__c = (Math.mod(x,2)==0) ? 'English' : 'French';
		//}
		//update products;


		Test.setCurrentPage(Page.IEC_ProductDetails);
		ApexPages.currentPage().getParameters().put('id', products[0].ProductNumber);
		IEC_ProductDetailsController ctrl = new IEC_ProductDetailsController();

		//-- Load Page 
		ctrl.onLoadAction();
		ctrl.discounts = null;

		ctrl.addToCart();


	}
	
}