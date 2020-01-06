public with sharing class IDCardPendingCaseController{


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

	public Case myCase {get;set;}
	 public ID_Card_Application__c myIdApp{get;set;}
	private String cid;
	private String apId;

	private static String IDCARD_PORTAL_LANG = 'idcard_portal_lang';

	public IDCardPendingCaseController() {


	 // check to see if the language was stored in a cookie
		Cookie langCookie = ApexPages.currentPage().getCookies().get(IDCARD_PORTAL_LANG);
		if (langCookie == null) {
			// ?
			Language = 'en_US';
			selectedLanguage = Language;
			//selectedLanguage = null;
		}
		else {
			Language = langCookie.getValue();
			selectedLanguage = Language;
		}


		if (System.currentPageReference().getParameters().containsKey('cid')){
			cid = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get('cid'));
			myCase  = [Select Id, Status,CaseNumber, IATA_Code__c,CreatedDate,Related_ID_Card_Application__r.Name,Related_ID_Card_Application__r.Type_of_application__c,Related_ID_Card_Application__r.Displayed_Name__c from Case where Id=: cid limit 1];
		}

		else if(System.currentPageReference().getParameters().containsKey('apId')){ //INC239933
			apId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get('apId'));
			myIdApp  = [Select Id, Name, Displayed_Name__c, IATA_Code__c, VER_Number__c, Start_Date_Agency_Month__c , Application_Status__c, Start_Date_Agency_Year__c, Type_of_application__c, Terms_and_Conditions_Time_Stamp__c from ID_Card_Application__c where Id=: apId limit 1];

		}

	}

}
