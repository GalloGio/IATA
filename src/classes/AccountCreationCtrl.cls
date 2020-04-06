public without sharing class AccountCreationCtrl {

	@AuraEnabled
	public static String getUIThemeDescription() {
		String theme = UserInfo.getUiThemeDisplayed();
		return theme;
	}

	@AuraEnabled
	public static String createNewAccount(Account acc) {
		try{
			acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
			insert acc;
			return 'accountId' + acc.Id;
		}
		catch(Exception e){
			return e.getMessage();
		}
	}
}