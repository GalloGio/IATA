@isTest(SeeAllData=true)
private class IECComponentControllerBase_tst {

	static testMethod void myUnitTest() {
		Test.startTest();
		IECComponentControllerBase base = new IECComponentControllerBase();
		IECPageController pgCont = new IECPageController();

		base.pageController = pgCont;
		base.key = '123';

		pgCont.addErrorMessage(new IECApplicationException('Test'));
		pgCont.addInfoMessage(new List<String> {'1' , '2'});
		pgCont.addConfirmMessage(new List<String> {'1' , '2'});
		pgCont.addWarningMessages(new List<String> {'1' , '2'});
		pgCont.getComponentControllerMap();
		pgCont.setComponentController(base);
		pgCont.getThis();

		Test.stopTest();
	}
}
