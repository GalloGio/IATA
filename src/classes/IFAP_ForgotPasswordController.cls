/**
 * Handles the password reset feature for the IFAP customer portal
 */
public class IFAP_ForgotPasswordController {

	public String username {get; set;}
	public Boolean emailSent {get; set;}

	public String Language {get; set;}
	private static String IFAP_PORTAL_LANG = 'ifap_portal_lang';

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

	/**
	 * Constructor
	 */
	public IFAP_ForgotPasswordController() {
		emailSent = false;

		// check to see if the language was stored in a cookie
		Cookie langCookie = ApexPages.currentPage().getCookies().get(IFAP_PORTAL_LANG);
		if (langCookie == null) {
			// ?
			Language = 'en';
			selectedLanguage = Language;
		}
		else {
			Language = langCookie.getValue();
			selectedLanguage = Language;
		}
	}

	/**
	 * Reset the password and send an email to the portal user
	 */
  	public void forgotPassword() {

  		boolean success = Site.forgotPassword(username);

  		if (success) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Site.temp_password_sent));
  			emailSent = true;
  		}
		else {
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not reset the password for username ' + username + '. Please contact IATA customer support.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Cannot_Reset_Password_1, new String[] {'<i>' + username + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS));
		}
  	}
}
