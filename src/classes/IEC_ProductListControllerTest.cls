@isTest
private class IEC_ProductListControllerTest {
	
	@isTest (SeeAllData = true)
	static void test_all() {

		Test.setCurrentPage(Page.IEC_ProductList);
		IEC_ProductListController ctrl = new IEC_ProductListController();

		//-- Load Page 
		ctrl.onLoadAction();

		//-- Select Topic & Customer type 
		ctrl.selectedTopic = 'Cargo';
		ctrl.selectedCustomerType = 'Airline Member'; 
		ctrl.onLoadAction(); 

		//--Sort product 
		ctrl.sortBy = 'Name';
		ctrl.sortProducts();

		//-- Refine 
		ctrl.selectedFilters = 'Refinement_Segment__c|Cargo'; 
		ctrl.refine(); 

		//-- Go to next 
		ctrl.gotoNext(); 
		ctrl.gotoPrevious();

		ApexPages.currentPage().getParameters().put('pageNum', '1');
		ctrl.gotoPage();

	}
	
	
	
}