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
public static List<LiveAgentButtonSettings__c> getLiveAgentButton(String topicName, String country, Contact contactInfo, Boolean isEmergency){

	if(isEmergency) {
		return [SELECT ID, Name, ButtonId__c, Button_Per_Topic__c, DeploymentId__c, Language__c, Region__c, Sectors__c, Topic__c
		        FROM LiveAgentButtonSettings__c
		        WHERE Name =: 'Emergency'];
	}

	//lower cases the country value;
	country = country.toLowerCase();

	//adds __c to end of Topic value. Check Custom Settings or query below.
	topicName = '%' + topicName + '__c' + '%';

	Contact con = contactInfo;

	//Make sector ready for LIKE search
	String sector = con.Account.Sector__c != null ? con.Account.Sector__c : '';
	sector = '%' + sector + '%';

	String region = con.Account.Region_formula__c != null ? con.Account.Region_formula__c : '';

	String selectedCountryRegion;

	Set<String> newset = new Set<String>();
	if(country != null && country != '') {
		newset.add(country.toUpperCase());
		//Sets the region of either the Country selected from the picklist or the one from the user's account.
		IATA_ISO_Country__c IATA_ISO_country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(newset)[0];
		selectedCountryRegion = IATA_ISO_country.Region__c;
	}else{
		selectedCountryRegion =  con.Account.Region_formula__c != null ? con.Account.Region_formula__c : '';
	}

	if(country != null && country != '') {
		return [ SELECT ID, Name, ButtonId__c, Button_Per_Topic__c, DeploymentId__c,
		         Language__c, Region__c, Sectors__c, Topic__c
		         FROM LiveAgentButtonSettings__c
		         WHERE Sectors__c Like : sector
		         AND ((Language__c = 'en' AND Region__c =: selectedCountryRegion)
		              OR (Language__c =: country AND Region__c =: selectedCountryRegion))];

	}
	else{
		return [ SELECT ID, Name, ButtonId__c, Button_Per_Topic__c, DeploymentId__c,
		         Language__c, Region__c, Sectors__c, Topic__c
		         FROM LiveAgentButtonSettings__c
		         WHERE Topic__c Like : topicName];
	}
}


//sets a Map with the Type of Case and Country for the Live Agent Case
@AuraEnabled (cacheable=true)
public static Map<String,String> getCaseTypeAndCountry(Contact contactInfo, String country){

	Map<String,String> caseInformation = new Map<String,String>();
	Set<String> newset = new Set<String>();

	if(country != null && country != '') {
		newset.add(country);
	}else{
		if(contactInfo.Account.Country_ISO_Code__c != null && contactInfo.Account.Country_ISO_Code__c != '') {
			newset.add(contactInfo.Account.Country_ISO_Code__c);
		}
	}

	//Sets the region of either the Country selected from the picklist or the one from the user's account.
	IATA_ISO_Country__c IATA_ISO_country = new IATA_ISO_Country__c();
	if(!newset.isEmpty()) {
		IATA_ISO_country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(newset)[0];
	}

	String recordType;

	if(IATA_ISO_country != null) {
		if (IATA_ISO_country.Region__c == 'Europe') {
			recordType = 'CasesEurope';
		}else if(IATA_ISO_country.Region__c == 'Americas') {
			recordType =  'CasesAmericas';
		}else if(IATA_ISO_country.Region__c == 'Africa & Middle East') {
			recordType = 'CasesMENA';
		}else if(IATA_ISO_country.Region__c == 'Asia & Pacific') {
			recordType = 'ExternalCasesIDFSglobal';
		}else if(IATA_ISO_country.Region__c == 'China & North Asia') {
			recordType = 'Cases_China_North_Asia';
		}
		//Sets the Region
		caseInformation.put('Region',IATA_ISO_country.Region__c);
	}else{
		recordType = 'InternalCasesEuropeSCE';
	}

	ID recordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', recordType);

	caseInformation.put('RecordType', recordTypeID);

	//Sets the Country from either the Country selection or the User's Account's
	caseInformation.put('Country',IATA_ISO_country.Name);

	//return the map with the info
	return caseInformation;

}



@AuraEnabled (cacheable=true)
public static Contact getContactInfo(){
	//Grabs User info
	User user = [SELECT Id,ContactId FROM User WHERE Id =:Userinfo.getUserId()];

	//Grabs User's associated Contact
	return [SELECT ID, FirstName, Name, Email, Phone, Account.Name, Account.Sector__c,
	        Account.Category__c, Account.id, Account.Country_ISO_Code__c,
	        Account.Region_formula__c FROM Contact WHERE ID = : user.ContactId];

}

@AuraEnabled (cacheable=true)
public static List<ISSP_FAQ2Case_Emergencies__c> getEmergencyDependencies(){

	//Grabs ISSP_FAQ2Case_Emergencies__c Custom Setting records
	return [SELECT Id, Name, Subtopic__c FROM ISSP_FAQ2Case_Emergencies__c];

}

@AuraEnabled (cacheable=true)
public static List<LVA_CallUsConfigClass> getCallUsPhoneNumber(){
	List<LVA_CallUsConfigClass> listCallConfigs = new List<LVA_CallUsConfigClass>();
	for(LVA_CallUsConfig__mdt callConfig : [SELECT DeveloperName,
	                                        IsoCountry__c,
	                                        Sector__c,
	                                        Topic__c,
	                                        PhoneNumber__c,
	                                        AvailableHours__c
	                                        FROM LVA_CallUsConfig__mdt]) {
		LVA_CallUsConfigClass auxCallConfig =
			new LVA_CallUsConfigClass(
				callConfig.DeveloperName,
				callConfig.IsoCountry__c,
				callConfig.Sector__c,
				callConfig.Topic__c,
				callConfig.PhoneNumber__c,
				callConfig.AvailableHours__c);

		listCallConfigs.add(auxCallConfig);
	}

	return listCallConfigs;

}

//This wrapper was constructed to hide the ID from the users view
//The remaining data is public and can be shown
public class LVA_CallUsConfigClass {

@AuraEnabled
public String DeveloperName;
@AuraEnabled
public String IsoCountry;
@AuraEnabled
public String Sector;
@AuraEnabled
public String Topic;
@AuraEnabled
public String PhoneNumber;
@AuraEnabled
public String AvailableHours;

public LVA_CallUsConfigClass(String developerName, String isoCountry, String sector, String topic, String phoneNumber, String availableHours) {
	this.DeveloperName = developerName;
	this.IsoCountry = isoCountry;
	this.Sector = sector;
	this.Topic = topic;
	this.PhoneNumber = phoneNumber;
	this.AvailableHours = availableHours;
}
}
}