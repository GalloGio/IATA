@isTest(SeeAllData=true)
private class vfIECSiteHeaderComponent_tst {

	static testMethod void myUnitTest() {
		Test.startTest();
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			VfIECSiteHeaderComponent pgCont = new VfIECSiteHeaderComponent();

			Boolean bTest = pgCont.isUserLoggedIn;
			String sTest = pgCont.sContactEmail;
			sTest = pgCont.sContactSubject;

			pgCont.logout();
		}
		Test.stopTest();
	}
}
