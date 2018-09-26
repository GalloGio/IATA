@isTest
private class IEC_ProductListControllerTest {
	
	@isTest (SeeAllData = true)
	static void test_all() {

		Test.setCurrentPage(Page.IEC_ProductList);
		IEC_ProductListController ctrl = new IEC_ProductListController();
		List<EComProduct_DTO> prods;

		Integer TotalPages;
		Boolean hasNext;
		Boolean hasPrev;

		//-- Load Page 
		ApexPages.currentPage().getParameters().put('topic', 'Cargo');
		ApexPages.currentPage().getParameters().put('customer_type', 'Airline Member');
		ctrl.onLoadAction();

		//-- Select Topic & Customer type 
		ctrl.selectedTopic = 'Cargo';
		ctrl.selectedCustomerType = 'Airline Member'; 
		ApexPages.currentPage().getParameters().remove('topic');
		ApexPages.currentPage().getParameters().remove('customer_type');
		ctrl.onLoadAction(); 

		//--Sort product 
		ctrl.sortBy = 'Name';
		ctrl.sortProducts();

		//-- Refine 
		ctrl.selectedFilters = 'Refinement_Segment__c|Cargo'; 
		ctrl.refine(); 

		//-- Go to next 
    	//ctrl.gotoNext(); 
    	//ctrl.gotoPrevious();

    	//ApexPages.currentPage().getParameters().put('pageNum', '1');
    	//ctrl.gotoPage();

		//-- Go to next 
		ctrl.Next(); 
		ctrl.Previous();
		ctrl.First(); 
		ctrl.Last();
		ctrl.getTotalPages();
		TotalPages = ctrl.pageNumbers;
		hasNext = ctrl.hasNext;
		hasPrev = ctrl.hasPrevious;
		prods = ctrl.getProductRecordsList();




	}
	
	
	
}