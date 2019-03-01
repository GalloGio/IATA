/******************************************************************************************************************
 *  IEC_SearchResultsTest: Unit test class for IEC_SearchResultsController                                        *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
@isTest
private class IEC_SearchResultsTest 
{
	@isTest (SeeAllData=true)
	static void test_AllMethods() 
	{
		//Generate Data 
		TestDataGenerator.generateApexSetting();

		//Generate 50 products 
		List<Product2> products = TestDataGenerator.generateProducts(20, false);
		List<Id> productIds = new List<Id>();
		List<Id> en_productIds = new List<Id>();

		//Make them available for ecommerce 
		for(Integer x =0; x < products.size(); x++)
		{
			Product2 p = products[x];
			p.Post_to_Ecommerce_Date__c = Date.today().addDays(-1);
			p.Sell_through_eCommerce__c = true; 
			p.Inventory_Status__c = 'In stock';
			p.Status__c = 'A';
			p.Line_of_Business__c = 'Publications';
			p.Refinement_Language__c = (Math.mod(x, 2)==0) ? 'English' : 'French';
		}
		database.insert(products,false);

		for(Product2 p : products)
		{
			productIds.add(p.Id);
			if(p.Refinement_Language__c =='English') 
				en_productIds.add(p.Id);
		}

		Test.startTest();
			//Go to SearchResultPage 

			//-- Set result to be found 
			Test.setFixedSearchResults(productIds);

			ApexPages.currentPage().getParameters().put('site-search','Product '); //All theproducts contains "Product " in name
			IEC_SearchResultsController ctrl = new IEC_SearchResultsController();

			ctrl.onLoadAction();
			 //system.assertEquals(products.size(), ctrl.allProducts.size());
			 //system.assertEquals(1, ctrl.currentPageNumber);

			//-- Got to next page 
			ctrl.gotoNext(); 
			 //system.assertEquals(2, ctrl.currentPageNumber);

			//-- Got to previous 
			ctrl.gotoPrevious();
			 //system.assertEquals(1, ctrl.currentPageNumber);

			//-- Goto Page 3
			ApexPages.currentPage().getParameters().put('pageNum','3');
			ctrl.gotoPage();
			 //system.assertEquals(3, ctrl.currentPageNumber);

			//-- Sort Product By Name 
			ctrl.sortBy = 'Name'; 
			ctrl.sortProducts();

			//-- Refine product displayed
			Test.setFixedSearchResults(en_productIds);
			ctrl.selectedFilters = 'Refinement_Language__c|English:Short_Title__c|p';
			ctrl.refine(); 
			 //system.assertEquals(25, ctrl.allProducts.size());

			//-- Reset refinement filters 
			Test.setFixedSearchResults(productIds);
			ctrl.selectedFilters = '';
			ctrl.refine(); 
			 //system.assertEquals(50, ctrl.allProducts.size());
		Test.stopTest();
	}
	
}