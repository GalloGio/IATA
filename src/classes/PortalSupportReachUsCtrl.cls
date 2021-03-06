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

	//lower cases the country value;
	country = country.toLowerCase();

	topicName = topicName + '__c';

	Contact con = contactInfo;


	String countryLbl=System.Label.ISSP_Topics_To_Exclude_Country_PL;
	//Make sector ready for LIKE search
	String sector = con.Account.Sector__c != null ? con.Account.Sector__c : '';
	sector = '%' + sector + '%';

	String region = con.Account.Region_formula__c != null ? con.Account.Region_formula__c : '';

	String selectedCountryRegion;
	String lang;

	Set<String> newset = new Set<String>();
	if(country != null && country != '') {
		newset.add(country.toUpperCase());
		//Sets the region of either the Country selected from the picklist or the one from the user's account.
		IATA_ISO_Country__c IATA_ISO_country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(newset)[0];
		selectedCountryRegion = IATA_ISO_country.Region__c;
		lang = IATA_ISO_country.LVA_CountryLanguage__c;
	}else{
		selectedCountryRegion =  con.Account.Region_formula__c != null ? con.Account.Region_formula__c : '';
	}
	
	String query='SELECT ID, Name, ButtonId__c, Button_Per_Topic__c, DeploymentId__c,'+
	'Language__c, Region__c, Sectors__c, Topic__c '+
	'FROM LiveAgentButtonSettings__c ';
	string criteria='';
	if(isEmergency) {
		criteria='WHERE Name = \'Emergency\'';
	}else 
	if(country != null && country != '' && countryLbl.indexOf(topicName)==-1 ) {
		criteria='WHERE Sectors__c Like : sector '+
				' AND ((Language__c = \'en\' AND Region__c =: selectedCountryRegion) '+
				' OR (Language__c =: lang AND Region__c =: selectedCountryRegion))';
	}
	else{

		//adds __c to end of Topic value. Check Custom Settings or query below.
		topicName = '%' + topicName + '%';
		criteria='WHERE Topic__c Like : topicName';
	}

	list<LiveAgentButtonSettings__c> btnList=Database.query(query+criteria);
	//update btn label
	for(LiveAgentButtonSettings__c lbt:btnList ){
		string lbkey=lbt.language__c.substring(0,2).toLowerCase();
		if(CSP_Utils.langlabelMap.containskey(lbkey)){				
			lbt.language__C=CSP_Utils.langlabelMap.get(lbkey);				
		}
	}

	return btnList;

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
public static User  getContactInfo(){
	//Grabs User info		
	return [SELECT profile.name,contactID, contact.FirstName, contact.Name, contact.Email, contact.Phone,contact.Account.Name, contact.Account.Sector__c,
			contact.Account.Category__c, contact.Account.id, contact.Account.Country_ISO_Code__c,contact.ISO_Country__r.ISO_Code__c,
			contact.Account.Region_formula__c,contact.Account.Is_General_Public_Account__c
			FROM User WHERE Id =:Userinfo.getUserId()];
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

//Returns the list of topics that the user has access to and if they are L2 dependent
@AuraEnabled (cacheable=true)
public static string getTopicsWithL2Dep(){

	set<string> reqL2TopicSet= new set<string>();
	//Get topic list that require L2 Registration
	list<PortalKnowledge__c> pkList= [SELECT Id, DataTopicName__c
	FROM PortalKnowledge__c
	WHERE DataCategoryName__c <> ''
	AND DataTopicName__c <> ''
	AND DataSubtopicName__c = ''
	AND Requires_Level2_Registration__c = true];
	
	for(PortalKnowledge__c pk:pkList){
		reqL2TopicSet.add(pk.DataTopicName__c);
	}

	set<string> recentTopicSet= new set<string>();

	Id contactId=[select contactId from user where id=:Userinfo.getUserId() limit 1].contactId;
	list<AggregateResult> mostRecentTopicList=[SELECT topic__c, count(id) FROM case 
	WHERE origin='Portal' 
	AND Visible_on_ISS_Portal__c =true 
	AND contactId=:contactId 
	AND topic__c !=null 
	AND createdDate =LAST_90_DAYS 
	GROUP BY topic__C 
	ORDER BY count(id) DESC];
	

	for(Integer i=0;i<3 && i<mostRecentTopicList.size() ;i++){ // we only want to retrieve the 3 topics, limit not possible in this SOQL 
		recentTopicSet.add((String)mostRecentTopicList.get(i).get('topic__c'));
	}

	//retrieve full tree with the topics the user has access
	List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> structureTreeList=PortalFAQsCtrl.getFAQsInfo();

	List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> topicList = new List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>();
	
	map<string,map<string,string>> topicsMap= new map<string,map<string,string>>();

	for(DescribeDataCategoryGroupStructures.DataCategoryWrapper dc :structureTreeList){
		//Matches the topics that require L2 with the topics the user has access
		if (!topicsMap.containsKey(dc.topicName) && dc.topicName != 'All') {
			Map<string,string> valMap= new Map<string,string>();
			valMap.put('topicName',dc.topicName);
			valMap.put('topicLabel',dc.topicLabel);
			valMap.put('reqL2',String.valueOf(reqL2TopicSet.contains(dc.topicName)));
			valMap.put('topicLabelEN',dc.topicLabelEn);
			valMap.put('recentTopic',String.valueOf(recentTopicSet.contains(dc.topicLabelEn)));

			topicsMap.put(dc.topicName,valMap);
		}
	}		

	return JSON.serialize(topicsMap.values());

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
