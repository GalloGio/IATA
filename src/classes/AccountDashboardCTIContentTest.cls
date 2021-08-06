@isTest
public with sharing class AccountDashboardCTIContentTest {

	@isTest
	public static void getUIThemeDescriptionTest() {
		test.startTest();
		String nameTheme = AccountDashboardCTIContentCtrl.getUIThemeDescription();
		test.stopTest();
		System.assert(nameTheme != '', 'No UITheme found!');
	}
}