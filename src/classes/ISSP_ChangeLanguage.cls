public with sharing class ISSP_ChangeLanguage {

	public ISSP_ChangeLanguage(){

	}
	 public Pagereference changeUserLanguage(){
		 List<Preferred_Language_on_ISS_Portal__c> pLangcs = Preferred_Language_on_ISS_Portal__c.getall().values();

		 string lang = ApexPages.currentPage().getParameters().get('lang');
		 User user = [select Id,ContactId from User where Id=:Userinfo.getUserId()];
				user.LanguageLocaleKey = lang;
				update user;
				List<Contact> contacts = [select Id,Preferred_Language__c  from Contact where Id=:user.ContactId];
				if (contacts.isEmpty())
					return null;
				Contact con = contacts[0];

				if(pLangcs!= null || !pLangcs.isEmpty()){
						for(Preferred_Language_on_ISS_Portal__c language : pLangcs){
							if(language.languageLocalKey__c == lang){
								con.Preferred_Language__c = language.Language__c;
							}
						}
				}
				//con.Preferred_Language__c = lanMap.get(lang);
				update con;
				string retURL = ApexPages.currentPage().getParameters().get('retURL');
				if (retURL == '/ISSP_Case')
					retURL = '/ISSP_CaseList';
				Pagereference pr = new Pagereference(retURL);
				pr.setCookies(new Cookie[]{new Cookie('lang',lang,null,100000000,false)});
				return pr;
	 }
}
