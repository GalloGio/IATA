public with sharing class IDCard_ConfirmationPageController {

	private static String IDCARD_PORTAL_LANG = 'idcard_portal_lang';

	public String Language {get; set;}

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
		return options;
	}

	public IDCard_ConfirmationPageController() {
		// check to see if the language was stored in a cookie
		Cookie langCookie = ApexPages.currentPage().getCookies().get(IDCARD_PORTAL_LANG);
		if (langCookie == null) {
			Language = 'en_US';
			selectedLanguage = Language;
		}
		else {
			Language = langCookie.getValue();
			selectedLanguage = Language;
		}
	}
}
