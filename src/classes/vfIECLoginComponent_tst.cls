@isTest
private class vfIECLoginComponent_tst {
	static testMethod void myUnitTest() {
		Test.startTest();

		//Set current page to login page
		PageReference pgRef = Page.IECLogin;
		Test.setCurrentPage(pgRef);

		VfIECLoginComponent pgCont = new VfIECLoginComponent();

		pgRef.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter('http://www.iata.org'));
		pgRef.getParameters().put(IECConstants.PARAM_RESETPASSWORD, IECUtil.EncryptEncodeParameter('true'));

		pgCont = new VfIECLoginComponent();

		//001: Login
		pgCont.sPrefillUsername = '';
		pgCont.login();
		pgCont.sPrefillUsername = 'test@iata.org.test';
		pgCont.password = '';
		pgCont.login();
		pgCont.password = 'P@$$w0rD';
		pgCont.login();

		//002: Register
		pgCont.register();

		//003: Forgot Password
		pgCont.forgotPassword();

		//004: Forgot Password Redirect
		pgCont.forgotPasswordRedirect();

		//006: Reset Password
		pgCont.resetPasswordEmail = '';
		pgCont.resetPassword();
		pgCont.resetPasswordEmail = 'test@iata.org.test';
		pgCont.resetPassword();

		//Misc
		Boolean bTest = pgCont.isUserLoggedIn;
		pgCont.closePopup();
		pgCont.showPopup();
		Test.stopTest();
	}
}
