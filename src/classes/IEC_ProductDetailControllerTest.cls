@isTest
private class IEC_ProductDetailControllerTest {
	
	@isTest(SeeAllData=true) 
	static void test_method_one() {
		delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];
		Map<String, List<SelectOption>> subCategories = Utility.getDependentOptions('Product2', 'Mega_Menu__c', 'Display_Ecom_Topic__c');
		String category, subCategory;
		for(SelectOption so : Utility.getPicklistSelectOptions('Product2', 'Mega_Menu__c', false))
			if (subCategories.get(so.getValue()) != null && subCategories.get(so.getValue()).size() > 0)
			{
				category = so.getValue();
				subCategory = subCategories.get(so.getValue())[0].getValue();
				break;
			}
		List<EComProduct_DTO> products = Product_Sel.getEComProduct(null, false, 'IEC_Product_Information__c != null', null, true, null);
		update new Product2(Id=products[0].ProductId, Mega_Menu__c=category, Display_Ecom_Topic__c=subCategory);

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