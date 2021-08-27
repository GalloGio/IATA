public with sharing class AccountDashboardCTIContentCtrl {
	@AuraEnabled
	public static String getUIThemeDescription() {
		String theme = UserInfo.getUiThemeDisplayed();
		return theme;
	}
}