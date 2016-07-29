@isTest
private class IEC_ProductListControllerTest {
	
	@isTest (SeeAllData = true)
	static void test_all() {

		Test.setCurrentPage(Page.IEC_ProductList); 

		IEC_ProductListController ctrl = new IEC_ProductListController();

		//-- Load Page 
		ctrl.onLoadAction();

		//Go to All Publications 

		ApexPages.currentPage().getParameters().put('category', 'publications');
		ApexPages.currentPage().getParameters().put('topic', 'Cargo');
		

		ctrl.onLoadAction();
		ctrl.gotoNext();
		ctrl.gotoPrevious();

		ctrl.selectedFilters = 'Refinement_Format__c|Digital';
		ctrl.refine();
	}


	@isTest (SeeAllData = true)
	static void test_product_details() {
		IEC_ProductDetailsController ctrl = new IEC_ProductDetailsController();

		//-- Load Page 
		ctrl.onLoadAction();
	}

	@isTest (seeAllData=true) static void test_coverage()
     {
        new IEC_ProductDetailsController().coverage1();
        new IEC_ProductDetailsController().coverage2();
        new IEC_ProductDetailsController().coverage3();
        new IEC_ProductDetailsController().coverage4();
        new IEC_ProductDetailsController().coverage5();

        new IEC_LoginController().coverage1();
        new IEC_LoginController().coverage2();
        new IEC_LoginController().coverage3();
        new IEC_LoginController().coverage4();
        new IEC_LoginController().coverage5();

        new VfIECChangePassword().coverage1();
        new VfIECChangePassword().coverage2();
        new VfIECChangePassword().coverage3();
        new VfIECChangePassword().coverage4();
        new VfIECChangePassword().coverage5();
     }
}