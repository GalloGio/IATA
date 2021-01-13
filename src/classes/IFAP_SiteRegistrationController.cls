public class IFAP_SiteRegistrationController {

	public String email {get; set;}
	//public String password {get; set {password = value == null ? value : value.trim(); } }
	//public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
	public String lang {get; set;}
	public Boolean userRegistered {get; set;}

	public String Language {get; set;}


	private static Id ORG_ID = '00D2000000008TF'; //PROD

   private static Id PORTAL_ID = '06020000000UPu7'; // PROD

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

		options.add(new SelectOption('zh_CN','中文（简体）'));
		options.add(new SelectOption('pt_BR','Português (Brasil)'));
		options.add(new SelectOption('ru','Русский'));
		return options;
	}

	/**
	 * Constructor
	 */
	public IFAP_SiteRegistrationController() {

		userRegistered = false;

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
	 * List of languages
	 */
	public List<selectOption> lstLanguages {
		get{
			List<selectOption> options = new List<selectOption>();

			options.add(new SelectOption('en_US','English'));
			options.add(new SelectOption('es','Español'));
			options.add(new SelectOption('fr','Français'));
			options.add(new SelectOption('it','Italiano'));
			options.add(new SelectOption('ja','日本語'));
			options.add(new SelectOption('ko','한국어'));
			options.add(new SelectOption('zh_TW','中文（繁體）'));
			options.add(new SelectOption('zh_CN','中文（简体）'));
			options.add(new SelectOption('pt_BR','Português (Brasil)'));
			options.add(new SelectOption('ru','Русский'));
			return options;
		}
	}

	/**
	 * Methods that registers an IFAP customer portal user
	 */
	public PageReference registerUser() {

		Contact associatedContact = null;
		Profile IFAPprofile = [Select p.Name, p.Id From Profile p where Name = 'IFAP Customer Portal User' order by Name];

		// check if the user is already created based on the email
		User[] usersWithSameEmail = [Select u.LastName, u.FirstName, u.Email, u.IsActive From User u where u.Email = :+email and u.IsActive = true];
		if (usersWithSameEmail != null && usersWithSameEmail.size() > 0) {

			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Portal_User_Already_Exists, new String[] {'<i>' + email + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS);
			ApexPages.addMessage(msg);
			return null;
		}

		// search for the contact associated to the provided email
		List<Contact> contacts = [select c.Id, c.Financial_Assessment_Contact__c, c.Email, c.AccountId, c.FirstName, c.LastName from Contact c where c.Financial_Assessment_Contact__c = true and c.Email = :email];

		// check if at least one contact was found
		if (contacts == null || contacts.size() == 0) {
			// Could not find a contact associated to the email <email>. Please contact IATA customer portal in order to correct the situation.
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Registration_Email_Not_Found, new String[] {'<i>' + email + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS);
			ApexPages.addMessage(msg);
			return null;
		}

		for (Contact c: contacts) {
			if (c.Financial_Assessment_Contact__c == true)
				associatedContact = c;
		}

		if (associatedContact == null) {
			// The contact(s) found for email <email> have not been flagged as a 'Financial Assessment Contact'. Please contact IATA customer portal in order to correct the situation.
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Contact_Not_Flagged_IFAP_1, new String[] {'<i>' + email + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS);
			ApexPages.addMessage(msg);
			return null;
		}
		else {
			List<User> users = [Select u.Email From User u where u.ContactId = :+associatedContact.Id limit 1];
			if (users != null && users.size() > 0 && users[0].Email != associatedContact.Email) {
				//ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A user already exists for contact ' + email + ', but has a different email (' + users[0].Email + '). Please contact <a href="http://www.iata.org/cs">IATA customer portal</a> in order to correct the situation.');
				//A user already exists for contact <email>, but has a different email (<email2>). Please contact IATA customer portal in order to correct the situation.
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Registration_Email_mismatch_1, new String[] {'<i>' + email + '</i>', '<i>' + users[0].Email + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS);
				ApexPages.addMessage(msg);
				return null;
			}
		}

		User u = new User();
		u.Username = email;
		u.Email = email;
		u.CommunityNickname = email;
		u.ProfileId = IFAPprofile.Id;
		u.LanguageLocaleKey = lang;
		u.ContactId = associatedContact.Id;
		try {
			// create the portal user
			//String userId = Site.createPortalUser(u, associatedContact.AccountId, null, true);
			String userId = createIFAPPortalUser(u);

			// login with the user that was created
			if (userId != null) {

				//ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'The registration to the IFAP portal is successful. An email has been sent to ' + u.Email + ' containing your login information.');
				//ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, Label.IFAP_Registration_Successful_1 + ' <i>' + email + '</i> ' + Label.IFAP_Registration_Successful_2 + '.');
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, String.Format(Label.IFAP_Registration_Successful_1, new String[] {'<i>' + email + '</i>'}));
				ApexPages.addMessage(msg);
				userRegistered = true;
			}
			else {

				//ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not register user for email ' + u.Email + '. Please contact your IATA customer support.');
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Registration_Failed, new String[] {'<i>' + email + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS);
				ApexPages.addMessage(msg);
			}
		}
		catch (Exception ex) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + ex.getMessage());
			ApexPages.addMessage(msg);
		}

		return null;
	}

	public static String createIFAPPortalUser(User u){

		String userIdCreated;
		String aliasName;
		String commName;

		/*if(u.email.length() >= 40){
			commName = u.email.substring(0, u.email.lastIndexOf('.'));*/
		if(u.email.length() > 40){
			commName = u.email.substring(0, 39);
		} else{

			commName = u.email;
		}
		Database.DMLOptions dmo = new Database.DMLOptions();

			// create portal user
			User newUser = new User(alias = u.email.substring(0, 3),
							email = u.Email,
							emailencodingkey = 'UTF-8',
							//firstname = u.email,
							lastname = u.email,
							languagelocalekey = 'en_US',
							localesidkey = 'en_US',
							contactId = u.contactId,
							timezonesidkey = 'America/New_York',
							username = u.email,
							CommunityNickname = commName,
							ProfileId = u.ProfileId,
							IsActive = true);

			dmo.EmailHeader.triggerUserEmail = true;
			newUser.setOptions(dmo);

			insert newUser;

		return newUser.Id;

	}
}
