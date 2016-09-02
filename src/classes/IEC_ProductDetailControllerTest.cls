@isTest
private class IEC_ProductDetailControllerTest {
	
	@isTest(SeeAllData=true) 
	static void test_method_one() {
		List<EComProduct_DTO> products = Product_Sel.getEComProduct(null, false, 'IEC_Product_Information__c != null', null, true);

		Test.setCurrentPage(Page.IEC_ProductDetail);
		ApexPages.currentPage().getParameters().put('id', products[0].ProductNumber);
		IEC_ProductDetailController ctrl = new IEC_ProductDetailController(); 
		ctrl.onLoadAction();

		//Add To Cart 
		ctrl.addToCart();
		ctrl.getQuote();
		ctrl.tryMe();
		ctrl.register();
	}
	
}