@isTest
private class IEC_ProductListControllerTest {
	
	@isTest (SeeAllData = true)
	static void test_all() {
		IEC_ProductListController ctrl = new IEC_ProductListController();

		//-- Load Page 
		ctrl.onLoadAction();
	}
	
	
	
}