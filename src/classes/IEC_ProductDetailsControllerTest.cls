@isTest
private class IEC_ProductDetailsControllerTest {
	
	@isTest(SeeAllData=true)
	static void test_all() {
		//-- Generate Ecom Products
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
		EComProduct_DTO selectedProduct;
		List<EComProduct_DTO> products = Product_Sel.getEComProduct(null, true, '', null, false, null);
		for (EComProduct_DTO p : products)
			if (p.PriceInfo != null)
			{
				selectedProduct = p;
				break;
			}
		if (selectedProduct == null)
			selectedProduct = products[0];
		List<Product2> lstProductToUpdate = new List<Product2>();
		lstProductToUpdate.add(new Product2(Id=selectedProduct.ProductId, Mega_Menu__c=category, Display_Ecom_Topic__c=subCategory));
		lstProductToUpdate.add(new Product2(Id=products[1].ProductId, Recommended__c=true, Recommended_Ranking__c=1));
		update lstProductToUpdate;
		insert new Recommended_Product__c(Product__c=selectedProduct.ProductId, Related_Product__c=products[1].ProductId);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();

		Test.setCurrentPage(Page.IEC_ProductDetails);
		ApexPages.currentPage().getParameters().put('id', selectedProduct.ProductNumber);
		IEC_ProductDetailsController ctrl;

		//*** cover case of Publication product 
		system.runAs(usr)
		{
			ctrl = new IEC_ProductDetailsController();
			ctrl.onLoadAction();
			ctrl.discounts = null;

			String productWrapper = ctrl.productWrapper;
			//ctrl.addToCart();
		}

		//*** cover case of GDP product
		//products = Product_Sel.getEComProduct(null, true, 'IEC_Product_Information__c != null', null, false);
		if (products.size() > 0)
		{
			//ApexPages.currentPage().getParameters().put('id', products[0].ProductNumber);
			//ctrl = new IEC_ProductDetailsController();
			//ctrl.onLoadAction();
		}
	}
	
}