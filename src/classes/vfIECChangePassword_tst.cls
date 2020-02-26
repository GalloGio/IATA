@isTest(SeeAllData=true)
private class vfIECChangePassword_tst {

		static testMethod void myUnitTest() {
			Test.startTest();
			PageReference pgRef = Page.IECChangePassword;
			Test.setCurrentPage(pgRef);

			User usr = IECTestUtil.createSampleGuestUserAndLogin();
			System.runAs(usr) {
					VfIECChangePassword pgCont = new VfIECChangePassword();

					// Test 001: Leave all fields blank
					pgCont.currentPassword = '';
					pgCont.newPassword = '';
					pgCont.confirmNewPassword = '';
					pgCont.changePassword();

					// Test 001: Leave all fields blank
					pgCont.currentPassword = 'a';
					pgCont.newPassword = 'b';
					pgCont.confirmNewPassword = 'b';
					pgCont.changePassword();


			}
			Test.stopTest();
		}
}
