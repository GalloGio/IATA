public with sharing class clsIFAP_Change_Language_Tab {

	private String selectedLanguage;

	public String getSelectedLanguage() {
		return selectedLanguage;
	}
	public void setSelectedLanguage(String s) {
		selectedLanguage = s;
	}

	public List<SelectOption> getLangItems() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('en_US','English'));
		options.add(new SelectOption('es','Español'));
		options.add(new SelectOption('fr','Français'));
		options.add(new SelectOption('it','Italiano'));
		options.add(new SelectOption('ja','日本語'));
		options.add(new SelectOption('ko','한국어'));
		//options.add(new SelectOption('zh_TW','中文（繁體）'));
		options.add(new SelectOption('zh_CN','中文（简体）'));
		options.add(new SelectOption('pt_BR','Português (Brasil)'));
		options.add(new SelectOption('ru','Русский'));
		return options;
	}

	public clsIFAP_Change_Language_Tab() {

		// get current user language
		String userLanguage = UserInfo.getLanguage();

		// select it
		selectedLanguage = userLanguage;
	}

	/**
	 * Change the user language and save it
	 */
	public pageReference ChangeLanguage() {
	try{
		User[] theUser = [Select u.Username, u.ContactId, u.AccountId, u.LanguageLocaleKey From User u WHERE u.Id =: UserInfo.getUserId()];
		if (theUser != null && theUser.size() > 0){
			if (selectedLanguage != theUser[0].LanguageLocaleKey) {
				theUser[0].LanguageLocaleKey = selectedLanguage;
				update theUser[0];
			}
		}
	 }
	catch(Exception e)
	{
		System.debug('** error'+ e);
	}
		ApexPages.currentPage().setRedirect(true);
		return ApexPages.currentPage();
	}
}
