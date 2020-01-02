@isTest(SeeAllData=true)
private class vfIECUpdateSecurity_tst {

	static testMethod void myUnitTest() {
		Test.startTest();
		PageReference pgRef = Page.IECUpdateSecurity;
		Test.setCurrentPage(pgRef);

		vfIECUpdateSecurity pgCont = new vfIECUpdateSecurity();
		pgCont.pageLoad();

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			pgCont.getLoginHistory();
			pgCont.getErrorsPresent();
			pgCont.closeResetPopup();
			pgCont.showResetPopup();

			// Empty Old Password
			vfIECUpdateSecurity.sOldPassword = '';
			pgCont.applyNewPassword();

			// Short new password
			vfIECUpdateSecurity.sOldPassword = 'abc';
			vfIECUpdateSecurity.sNewPassword1 = 'abc';
			pgCont.applyNewPassword();

			// Password and confirmation doesn't match
			vfIECUpdateSecurity.sNewPassword1 = 'abcdef';
			vfIECUpdateSecurity.sNewPassword2 = 'bfcdef';
			pgCont.applyNewPassword();

			// Password and confirmation match
			vfIECUpdateSecurity.sNewPassword1 = 'abcdef';
			vfIECUpdateSecurity.sNewPassword2 = 'abcdef';
			pgCont.applyNewPassword();

			Contact oContact = pgCont.oContact;
		}
		Test.stopTest();
	}
}
