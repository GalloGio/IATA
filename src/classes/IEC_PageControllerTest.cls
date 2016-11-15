@isTest
private class IEC_PageControllerTest 
{
	
	@isTest (SeeAllData=true)
	static void test_method_one() 
	{
		//-- Generate test data 
		List<Product2> products = TestDataGenerator.generateProductsWithPrice(2);
		User usr = IECTestUtil.createSampleGuestUserAndLogin();

		System.runAs(usr)
		{
			Test.setCurrentPage(Page.IEC_ProductList);


			
			//-- Add products to cookie 
			for(Product2 p : products)
				IECOrder_Svc.addProductToCookie(p.SAP_Material_Number__c, 1, true);


			IEC_PageController ctrl = new IEC_PageController();


			//-- Cart Content 
			System.assertNotEquals(null, ctrl.cartContent);
			
			//-- Page language 
			String language = ctrl.language; 
			System.assertEquals(UserInfo.getLanguage().split('_')[0], language);

			//-- mega menu topics
			Map<String, List<SelectOption>> subCategories = ctrl.subCategories; 
			List<SelectOption> categories = ctrl.categories; 
			Map<String, String> mega_menus = ctrl.mega_menus;
			ctrl.selected_mega_menu = 'publications';
			ctrl.selectedCategory = categories[0];

			//-- Page custom links 
			Map<String, List<Ecommerce_Site_Link__c>> customLinks = ctrl.customLinks;

			//-- Copyright
			String copyright = ctrl.copyright; 
			System.assertEquals(copyright, Label.copyright.replace('{Y}',Date.today().year()+''));

			//-- Topics & Customer Types 
			List<String> topics = ctrl.topics;
			System.assertEquals(topics, Utility.getPicklistValues('Product2', 'Display_Ecom_Topic__c'));
			List<String> customerTypes = ctrl.customerTypes;
			System.assertEquals(customerTypes, Utility.getPicklistValues('Product2', 'Display_Ecom_Customer_Type__c'));

			String currentPageName = ctrl.currentPageName;

			//Log message to the page 
			ctrl.addErrorMessage('Error occur');
			System.assertEquals(true, ctrl.hasError);

			ctrl.addConfirmMessage('Well done');
			System.assertEquals(true, ctrl.hasConfirm);

			//Access My Service link 
			Test.startTest();
			try{Boolean bHasAnyProdAccess = ctrl.bHasAnyProdAccess;}
			catch(Exception ex){}
			Test.stopTest();

			//-- Logout 
			ctrl.logout();

			//Mini Register
			ctrl.miniRegister();
		}
	}
	
}