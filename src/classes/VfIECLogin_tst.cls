@isTest(SeeAllData=true)
private class VfIECLogin_tst {

	static testMethod void myUnitTest() {
		Test.startTest();
		//Set current page to login page
		PageReference pgRef = Page.IECLogin;
		Test.setCurrentPage(pgRef);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			pgRef.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter('http://www.iata.org'));
			pgRef.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter('Be Warned!'));

			vfIECLogin pgCont = new vfIECLogin();
			Boolean bTest = pgCont.isUserLoggedIn;
			String sTest = pgCont.sClientType;
		}
		Test.stopTest();
	}
}
