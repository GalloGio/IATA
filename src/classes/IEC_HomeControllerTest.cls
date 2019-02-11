@isTest
private class IEC_HomeControllerTest {
	
	@isTest (SeeAllData = true)
	static void test_home() {

		Test.setCurrentPage(Page.IEC_home);
		IEC_HomeController ctrl = new IEC_HomeController();
		List<EComProduct_DTO> prods;

		ctrl.onLoadAction();

		prods = ctrl.topSellers;

		System.assert(true, prods != null);
		System.assert(true, !prods.isEmpty());
		System.assert(true, ctrl.productListStr != '');
	}

}