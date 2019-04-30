global with sharing class PortalSupportReachUsCtrl {

//Gets Countries according to user's Language
@AuraEnabled (cacheable=true)
public static Map<String,String> getCountryList(){

	String currentLanguage = UserInfo.getLanguage();
	Map<String,String> options = new Map<String,String>();
	list<IATA_ISO_Country__c> isoList = new list<IATA_ISO_Country__c>();
	List<IATA_ISO_Country__c> isoCountriesByCaseBSPNotNull = IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull();


	if (currentLanguage == 'es') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_SP__c');
	}
	else if (currentLanguage == 'ko') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Contry_KR__c');
	}
	else if (currentLanguage == 'zh_CN') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_ZH__c');
	}
	else if (currentLanguage == 'pt_BR') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_PT__c');
	}
	else if (currentLanguage == 'fr') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_FR__c');
	}
	else if (currentLanguage == 'ja') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_JP__c');
	}
	else if (currentLanguage == 'it') {
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_IT__c');
	}
	else{
		isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'Name');
	}

	for(IATA_ISO_Country__c iso : isoList) {
		if (currentLanguage == 'es') {
			if (iso.IATA_Country_SP__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Country_SP__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else if (currentLanguage == 'ko') {
			if (iso.IATA_Contry_KR__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Contry_KR__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else if (currentLanguage == 'zh_CN') {
			if (iso.IATA_Country_ZH__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Country_ZH__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else if (currentLanguage == 'pt_BR') {
			if (iso.IATA_Country_PT__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Country_PT__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else if (currentLanguage == 'fr') {
			if (iso.IATA_Country_FR__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Country_FR__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else if (currentLanguage == 'ja') {
			if (iso.IATA_Country_JP__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Country_JP__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else if (currentLanguage == 'it') {
			if (iso.IATA_Country_IT__c != null)
				options.put(iso.ISO_Code__c,iso.IATA_Country_IT__c);
			else
				options.put(iso.ISO_Code__c,iso.Name);
		}
		else{
			options.put(iso.ISO_Code__c,iso.Name);
		}
	}
	return options;
}


//Gets Custom Setting LiveAgentButtonSettings and grabs correct buttons to display
//Grab Account information for distinguish of other buttons to show
//Check the Sector of the Account. Related to Contact.
@AuraEnabled (cacheable=true)
public static List<LiveAgentButtonSettings__c> getLiveAgentButton(String topicName, String country){

	//lower cases the country value;
	country = country.toLowerCase();

	//adds __c to end of Topic value. Check Custom Settings or query below.
	topicName = topicName + '__c';
	List<LiveAgentButtonSettings__c> liveAgentSettings = new List<LiveAgentButtonSettings__c>();

	//Grabs User info
	User user = [SELECT Id,ContactId FROM User WHERE Id =:Userinfo.getUserId()];

	//Grabs User's associated Contact
	Contact con = [SELECT ID, Account.Region_formula__c, Account.Sector__c FROM Contact WHERE ID = :user.ContactId];

	//Make sector ready for LIKE search
	String sector = con.Account.Sector__c != null ? con.Account.Sector__c : '';
	sector = '%' + sector + '%';

	String region = con.Account.Region_formula__c != null ? con.Account.Region_formula__c : '';

	if(country != null && country != '') {
		for(LiveAgentButtonSettings__c buttonSettings : [ SELECT ID, Name, ButtonId__c, Button_Per_Topic__c, DeploymentId__c,
		                                                  Language__c, Region__c, Sectors__c, Topic__c
		                                                  FROM LiveAgentButtonSettings__c
		                                                  WHERE Sectors__c Like :sector
		                                                  AND ((Language__c = 'en' AND Region__c =:region)
		                                                       OR (Language__c =:country AND Region__c =:region))]) {
			liveAgentSettings.add(buttonSettings);
		}
	}
	else{
		for(LiveAgentButtonSettings__c buttonSettings : [ SELECT ID, Name, ButtonId__c, Button_Per_Topic__c, DeploymentId__c,
		                                                  Language__c, Region__c, Sectors__c, Topic__c
		                                                  FROM LiveAgentButtonSettings__c
		                                                  WHERE Topic__c Like :topicName]) {
			liveAgentSettings.add(buttonSettings);
		}
	}
	return liveAgentSettings;
}
}