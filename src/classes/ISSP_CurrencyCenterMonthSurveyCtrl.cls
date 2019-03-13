/*
	Class Name: ISSP_CurrencyCenterMonthSurveyCtrl

	Related Page: ISSP_CurrencyCenterReportingActionMonth.page
	
	Copyright © [IATA]
	
	Purpose: This class aims to implement all actions from month survey page                                                      
	
	VERSION  AUTHOR            DATE              DETAIL/CHANGE REFERENCE
	1.0 -    Luís Ferreira     15/11/2018       	INITIAL DEVELOPMENT
*/
/*COMMENTS*/
/*FALTA */
//verificar a delete list se esta a ser preenchida corretamente
//verificar o load
//criar as tabs
//panel grid

public without sharing class ISSP_CurrencyCenterMonthSurveyCtrl {


	public Map<String, String>							minSalesPeriodEndMap			{ get; set; }
/*	public string 										minSalesPeriodEnd				{ get; set; }*/
	public String 										lastSaveDate					{ get; set; }
/*	public String 										reportDateMin					{ get; set; }*/
	public Boolean 										displayPopupDeleteBankRow		{ get; set; }
	public Boolean 										displayPopupDeleteSection		{ get; set; }
	public Boolean 										errorMessage 					{ get; set; }
	public String 										surveyStatus 					{ get; set; }					//survey status
	public Boolean 										surveyStatusBoolean				{ get; set; }					
	public Date 										reportingDate 					{ get; set; }					//REMOVE
	public String 										sectionReportKey 				{ get; set; }             		// get reporting type of the section
	public String 										sectionCurrencyKey				{ get; set; }					// get currency of the section
	public String 										selectedCountrySurvey 			{ get; set; }					// get current country
	public Integer 										numRow 							{ get; set; }
	public Integer 										numRowCountryCommentsPanel 		{ get; set; }
	public Integer 										yearSurvey 						{ get; set; }					//year of the survey
	public Integer 										monthSurvey 					{ get; set; }					//month of the survey
	public String 										monthSurveyString 				{ get; set; }					//month string 
	public String 										airlineId						{ get; set; }					//airline if of the online user
	public Boolean 										loadSuccessful 					{ get; set; }
	public String 										countriesNamesString 			{ get; set; }					//string with all existing countries
	public String 										countryProfileID 				{ get; set; }					//REMOVE
	public Currency_Center_Survey__c 					countryQueryResult 				{ get; set; }					//REMOVE
	public wrapperCurrencyCenterSurvey 					wccsObject 						{ get; set; }					//currente country
	public Set<Currency_Center_Survey__c> 				deleteCurrencyCenterSet 		{ get; set; }					//set of records to delete
	public List<Currency_Center_Survey__c> 				reportingTypeRecords 			{ get; set; }					//list sections to show in the table
	public List<Currency_Center_Survey__c>				countryCommentsQueryResult 		{ get; set; }					//REMOVE
	public List<Currency_Center_Survey__c> 				reportingTypeListQueryResult 	{ get; set; }					//REMOVE
	public List<Currency_Center_Survey__c> 				bankListQueryResult 			{ get; set; }					//REMOVE
	public List<Country_Profile__c> 					countriesProfileList 			{ get; set; }
	public Map<String, Country_Profile__c>				countriesProfileMap				{ get; set; }
	public Map<String, List<String>>					countriesKeysMap 				{ get; set; }
	public Map<String, wrapperCurrencyCenterSurvey> 	wccsObjectMap 					{ get; set; }					//map with all countries from the survey
	/* LOAD variables */
	public String 										countriesSurveyString 			{ get; set; }
	public List<Id> 									countryIds 						{ get; set; }
	public List<Id> 									reportingTypesIds 				{ get; set; }
	public Currency_Center_Survey__c 					parentQueryResult 				{ get; set; }
	public List<Currency_Center_Survey__c> 				countriesResult 				{ get; set; }
	public List<Currency_Center_Survey__c> 				reportingTypesResult 			{ get; set; }
	public List<Currency_Center_Survey__c> 				bankResult 						{ get; set; }
	public Map<String, Country_Profile__c>				countriesProfileIdMap			{ get; set; }
	public Map<String, IATA_ISO_Country__c>				iataIsoCountryMap				{ get; set; }

	public String defaultSectionKey {
		get {
			String countryCurrency = countryCurrentCurrency();

			String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);

			return key;
		}
	}


	//section visibility
	public Boolean isSectionVisible { get; set; }

	//get country from object Country_Profile__c
	public Country_Profile__c countryProfile { get; set; }

	

	//selected reporting type
	public String selectedReportingType {get; set;}
	/*
		Purpose:  get all reporting type                                                         
		Parameters: none 
		Returns: reportingTypeList
		Throws: none                                                        
	*/
	public List<SelectOption> getReportingType() {
		List<SelectOption> reportingTypeList = new List<SelectOption>();

		Schema.DescribeFieldResult fieldResult = Currency_Center_Survey__c.Reporting_Type__c.getDescribe();

		for(Schema.PicklistEntry val : fieldResult.getPicklistValues()) {
			reportingTypeList.add(new SelectOption(val.getLabel(), val.getLabel()));
		}
		
		

		return reportingTypeList;
	}

	//selected currency
	public String selectedCurrency {get; set;}

	/*
		Purpose:  get all currencies                                                         
		Parameters: none 
		Returns:  List<SelectOption>
		Throws: none                                                        
	*/
	public List<SelectOption> getCurrencyType() {
		List<SelectOption> currencyList = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Country_Profile__c.BSP_Currency_1__c.getDescribe();

		String countryCurrency = countryCurrentCurrency();

		for(Schema.PicklistEntry val : fieldResult.getPicklistValues()) {

			/*if(!countryCurrency.equals(val.getLabel())){*/
				currencyList.add(new SelectOption(val.getLabel(), val.getLabel()));
			/*}*/
		}
		return currencyList;
	}

	/*
		Purpose:  get banks from specific country                                                        
		Parameters: none 
		Returns:  List<SelectOption>
		Throws: none                                                        
	*/
	public List<SelectOption> getBankOptions() {
		List<SelectOption> banksListOptions = new List<SelectOption>();
		

		List<Financial_Institution__c> countryBanksList = [SELECT Id, Name FROM Financial_Institution__c WHERE Country__c = :selectedCountrySurvey AND Institution_Type__c = 'Bank' AND (NOT Name LIKE '*%') ORDER BY Name LIMIT 999];

		if(!countryBanksList.isEmpty()) {
			Set<String> bankNames = new Set<String>();
			banksListoptions.add(new SelectOption('', 'Select Bank'));
			for(Financial_Institution__c bank: countryBanksList) {
				if(!bankNames.contains(bank.Name)){
					bankNames.add(bank.Name);
					banksListoptions.add(new SelectOption(bank.Id, bank.Name));
				}
			}
		}
		return banksListOptions;
	}

	/*
		Purpose:  sum all total amount USD of each country to get the grand Total
		Parameters: none
		Returns: Decimal
		Throws: none
	*/
	public Decimal getGrandTotal() {

		//grand total variable
		Decimal totalAmount = 0;

		for(String mapKeySet: wccsObjectMap.keySet()) {

			if(countriesKeysMap.containsKey(mapKeySet)) {

				for(String countryKey: countriesKeysMap.get(mapKeySet)) {
					//get the type report key in the map of keys
					/*String typeReportKey = countriesKeysMap.get(mapKeySet);*/

					//only can sum if the value isn't null
					if(wccsObjectMap.get(mapKeySet).typeReportMap.get(countryKey).Total_Amount_USD__c != null) {

						//sum total amount usd of each country
						totalAmount += wccsObjectMap.get(mapKeySet).typeReportMap.get(countryKey).Total_Amount_USD__c;
					}
				}

				

			}
		}
		return totalAmount;
	}

	/*
		Purpose:  get all country for a selectList
		Parameters: none
		Returns:  List<SelectOption>
		Throws: none
	*/
	public List<SelectOption> getCountriesList() {
		List<SelectOption> countriesList = new List<SelectOption>();

		for(Country_Profile__c val : countriesProfileList) {
			countriesList.add(new SelectOption(val.Name, val.Name));
		}

		return countriesList;
	}

	// Constructor
	public ISSP_CurrencyCenterMonthSurveyCtrl() {
		buildCountriesMap();
		buildCountriesNameString();
		userInformation();
		init();
		loadAll();
		surveyDate();
	}

	/*
		Purpose:  retrieve the information of the user
		Parameters: none
		Returns: Decimal
		Throws: none
	*/
	public void userInformation() {

		//get the user Id
		String userId = UserInfo.getUserId();

		//get the details of the user

		User[] contactUser = [SELECT id,
								Contact.Account.id
								From User 
								where id = :userId 
								LIMIT 1];

		for(User cont: contactUser) {

			airlineId = cont.Contact.Account.id;
			
		}
	}

	/*
		Purpose: inicialize all the variables in construtor                                                    
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void init() {
		//Initialize list of country surveys
		wccsObjectMap = new Map<String, wrapperCurrencyCenterSurvey>();
		wccsObject = new wrapperCurrencyCenterSurvey();
		deleteCurrencyCenterSet = new Set<Currency_Center_Survey__c>();
		countriesKeysMap = new Map<String, List<String>>();							

		//add first reporting type record
		reportingTypeRecords = new List<Currency_Center_Survey__c>(); 
		Currency_Center_Survey__c newRecordReportingType = new Currency_Center_Survey__c();
		reportingTypeRecords.add(newRecordReportingType);

		//standard value visibility of sections
		//if load successful, show section
		isSectionVisible = true;

		//default reporting type value
		selectedReportingType = 'Blocked Amount';

		//default Currency
		selectedCurrency = 'AED';
	}

	public void  closePopupDeleteSection() {
		displayPopupDeleteSection = false;
	}

	public void showPopupDeleteSection() {
		String countryCurrency = countryCurrentCurrency();

		String key = buildReportTypeMapKey(sectionReportKey, sectionCurrencyKey);
		if(!key.equals('Blocked Amount|'+countryCurrency)) {
			displayPopupDeleteSection = true;
		}
	}

	public void  closePopupDeleteBankRow() {
		displayPopupDeleteBankRow = false;
	}

	public void showPopupDeleteBankRow() {

		numRow = Integer.valueof(system.currentpagereference().getparameters().get('index'));

		displayPopupDeleteBankRow = true;
	}
	/*
		Purpose: get month of the survey                                                  
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void surveyDate() {
		DateTime myDate = DateTime.newInstance(yearSurvey, monthSurvey, 1);
		monthSurveyString = myDate.format('MMMMM');
	}

	/*
		Purpose: build the countries Map                                                       
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void buildCountriesMap() {

		//get all countries from country profile object
		countriesProfileList = [SELECT ID, Name, Currency__c, Currency_Exchange_Rate__c FROM Country_Profile__c ORDER BY Name ASC];

		//inicialize the map of countries
		countriesProfileMap = new Map<String, Country_Profile__c>();

		for(Country_Profile__c countryObj: countriesProfileList) {
			countriesProfileMap.put(countryObj.Name, countryObj);
		}
	}

	/*
		Purpose:  return the currency of the current country
		Parameters: none
		Returns: String
		Throws: none
	*/
	public String countryCurrentCurrency() {
		String countryCurrency;

		if(countriesProfileMap.containsKey(selectedCountrySurvey)) {
			countryCurrency = countriesProfileMap.get(selectedCountrySurvey).Currency__c;
		}

		return countryCurrency;
	}

	/*
		Purpose: build the countrynamestring for the selectlist in the 'add country to survey' tab                                                       
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void buildCountriesNameString() {
		countriesNamesString = '';
		for(Country_Profile__c countryName: countriesProfileList){
			countriesNamesString += countryName.Name + '|';
		}
	}

	/*
		Purpose:  change the selected country when tab is clicked                                                       
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void countryObject() {
		this.selectedCountrySurvey = ApexPages.CurrentPage().getParameters().get('countryName');
		
		System.debug('Country ' + selectedCountrySurvey);
		wccsObject = wccsObjectMap.get(selectedCountrySurvey);

		/*if(wccsObject.country.Reporting_Date__c != null) {

			Datetime dT = wccsObject.country.Reporting_Date__c;
			reportDateMin = dT.format('yyyy-MM-dd');
		}*/
	}

	/*
		Purpose: when create the a new tab, we load the data from salesforce and put in the wrapper object                                                     
		Parameters: none
		Returns: wrapperCurrencyCenterSurvey
		Throws: none                                                      
	*/

	public void buildSurvey() {

		this.selectedCountrySurvey = ApexPages.CurrentPage().getParameters().get('countryName');
		System.debug('Country ' + selectedCountrySurvey);

		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = '1' + buildReportTypeMapKey('Blocked Amount', countryCurrency);

		if(!wccsObjectMap.containsKey(selectedCountrySurvey)) {

			//create a wrapper for the new country
			wccsObjectMap.put(selectedCountrySurvey, new wrapperCurrencyCenterSurvey());

			//inicialize the list of bankMap
			wccsObjectMap.get(selectedCountrySurvey).bankMap.put(key, new List<Currency_Center_Survey__c>());

			//add parent to wrapper country
			wccsObjectMap.get(selectedCountrySurvey).parent = parentQueryResult;

			wccsObjectMap.get(selectedCountrySurvey).country = new Currency_Center_Survey__c(Country__c = countriesProfileMap.get(selectedCountrySurvey).Id, Country_Name__c = selectedCountrySurvey, Section__c = 'Country Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlyCountry);

			//add to the list of reporting type
			wccsObjectMap.get(selectedCountrySurvey).typeReportMap.put(key, new Currency_Center_Survey__c(Reporting_Type__c = 'Blocked Amount', Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey, Section__c = 'Report Type Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlyReportType));
			
			//get exchange rate for report type
			if(!countryCurrency.equals('USD')) {
				if((!iataIsoCountryMap.get(selectedCountrySurvey).CurrencyIsoCode.equals('USD') && iataIsoCountryMap.get(selectedCountrySurvey).CurrencyIsoCode.equals(countryCurrency)) 
					|| !countriesProfileMap.get(selectedCountrySurvey).Currency__c.equals('USD')) {
					wccsObjectMap.get(selectedCountrySurvey).typeReportMap.get(key).Average_Exchange_Rate__c = countriesProfileMap.get(selectedCountrySurvey).Currency_Exchange_Rate__c;
				}
			} else {
				
				wccsObjectMap.get(selectedCountrySurvey).typeReportMap.get(key).Average_Exchange_Rate__c = 1;
			}
			//add empty bank if list of banks is empty
			/*wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key).add(new Currency_Center_Survey__c(Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey, Section__c = 'Bank Record'));*/
		}

		wccsObject = wccsObjectMap.get(selectedCountrySurvey);

		//save on a map the key of each country
		countriesKeysMap.put(selectedCountrySurvey, new List<String>());
		countriesKeysMap.get(selectedCountrySurvey).add(key);
		System.debug('buildSurvey ' + wccsObjectMap.get(selectedCountrySurvey));
	}

	/*
		Purpose:  delete all records from a specific country when the user click on the "x" in the tab
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void deleteCountry() {
		String countryToDelete = ApexPages.CurrentPage().getParameters().get('countryName');

		List<Currency_Center_Survey__c> deleteCountrySurvey = new List<Currency_Center_Survey__c>();

		if(wccsObjectMap.get(countryToDelete).country != null) {

			//remove report type to salesforce
			List<Currency_Center_Survey__c> reportsList = new List<Currency_Center_Survey__c>();

			if(!wccsObjectMap.get(countryToDelete).typeReportMap.keySet().isEmpty()) {

				for(String reportKey: wccsObjectMap.get(countryToDelete).typeReportMap.keySet()){

					Currency_Center_Survey__c report = wccsObjectMap.get(countryToDelete).typeReportMap.get(reportKey);

					if(report.id != null) {
						deleteCountrySurvey.add(report);
						reportsList.add(report);
					}
				}
			}

			if(!reportsList.isEmpty()) {

				for(Currency_Center_Survey__c report :reportsList){

					String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);

					if(wccsObjectMap.get(countryToDelete).bankMap.containsKey(key)) {

						for(Currency_Center_Survey__c bank: wccsObjectMap.get(countryToDelete).bankMap.get(key)){

							if(bank.id != null) {
								deleteCountrySurvey.add(bank);
							}
						}
					}
				}
			}

			if(wccsObjectMap.get(countryToDelete).country.Id != null) {
				//add country to delete list
				deleteCountrySurvey.add(wccsObjectMap.get(countryToDelete).country);
			}
			wccsObjectMap.remove(countryToDelete);
			countriesKeysMap.remove(countryToDelete);
		}
		System.debug('Delete this ' + deleteCountrySurvey);
		deleteCurrencyCenterSet.addAll(deleteCountrySurvey);
	}

	/*
		Purpose:  save all records into salesforce                                                         
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public PageReference save() {

		System.debug('errorMessage ' + errorMessage);
		if(errorMessage == false) {
			System.debug('***** Save - wccsObjectMap: ' + wccsObjectMap);
			Integer count = 0;
			for(String countrySurvey:wccsObjectMap.keySet()){

				wccsObject = wccsObjectMap.get(countrySurvey);

				System.debug('***** Save - wccsObject: ' + wccsObject);


				//add parent to salesforce if doesnt exist
				if(wccsObject.parent.id == null) {
					insert wccsObject.parent;
				} else if(count < 1){
					count++;
					update wccsObject.parent;
				}

				//add country to salesforce
				if(wccsObject.country.id == null) {
					//associate parent id
					wccsObject.country.Parent_Id__c = wccsObject.parent.id;
					wccsObject.country.Reporting_Date__c = reportingTypeRecords.get(0).Reporting_Date__c;
					System.debug('***** Save - country: ' + wccsObject.country);
					insert wccsObject.country;
				}
				else{
					update wccsObject.country;
				}

				//add report type to salesforce
				List<Currency_Center_Survey__c> reportsList = new List<Currency_Center_Survey__c>();
				for(String reportKey:wccsObject.typeReportMap.keySet()){
					Currency_Center_Survey__c report = wccsObject.typeReportMap.get(reportKey);
					if(report.Parent_Id__c == null){
						report.Parent_Id__c = wccsObject.country.id;
					}
					reportsList.add(report);
				}
				if(!reportsList.isEmpty()){
					System.debug('***** Save - reportsList: ' + reportsList);
					upsert reportsList;
				}

				// add banks list to salesforce
				List<Currency_Center_Survey__c> bankListToInsert = new List<Currency_Center_Survey__c>();

				Currency_Center_Survey__c emptyBank = new Currency_Center_Survey__c();

				for(Currency_Center_Survey__c report:reportsList){

					String countryCurrency;

					if(countriesProfileMap.containsKey(report.Country_Name__c)) {
						countryCurrency = countriesProfileMap.get(report.Country_Name__c).Currency__c;
					}

					String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);

					if(report.Reporting_Type__c == 'Blocked Amount' && report.Currency__c == countryCurrency){
						key = '1' + key;
					}

					if(wccsObject.bankMap.containsKey(key)) {

						for(Currency_Center_Survey__c bank:wccsObject.bankMap.get(key)){

							if(bank.Parent_Id__c == null && bank != emptyBank){

								bank.Parent_Id__c = report.id;
								bank.Section__c = 'Bank Record';
								bank.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlyBank;
							}

							if(bank != emptyBank && bank.Bank__c != null) { /*|| !bank.Bank__c.equals('default')*/
								System.debug('bank.Bank__c ' + bank.Bank__c);
								bankListToInsert.add(bank);
							}
						}
					}
				}
				if(!bankListToInsert.isEmpty()){
					System.debug('***** Save - bankListToInsert: ' + bankListToInsert);
					upsert bankListToInsert;
				}
			}

			// clean-up removed report type and/or bank
			if(!deleteCurrencyCenterSet.isEmpty()) {
				System.debug('***** Save - deleteCurrencyCenterSet: ' + deleteCurrencyCenterSet);
				deleteRecords();
			}
			deleteCurrencyCenterSet.clear();
			System.debug('***** Save END - deleteCurrencyCenterSet: ' + deleteCurrencyCenterSet);

			PageReference retURL = new PageReference('/ISSP_CurrencyCenterReportingActionsMonth?id=' + parentQueryResult.id);
	      	retURL.setRedirect(true);
	      	return retURL;
		} else {
			System.debug('***** UNSAVED - wccsObjectMap: ' + wccsObjectMap);
			return null;
		}
	}

	/*
		Purpose:  submit the survey in the object Currency_Center_Survey__c                                                         
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public PageReference submit() {

		//Change the parent status do submitted
		parentQueryResult.Status__c = 'Submitted';
		save();
		sendEmail();
		PageReference pageRef = new PageReference('/ISSP_CurrencyCenterReportingActionsSrv');
		pageRef.setRedirect(true);
		return pageRef;
	}

	/*
		Purpose:  send email to countrys managers when survey is submitted                                                         
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void sendEmail() {

		String orgWideEmail = 'IATA Noreply';

		String emailReportTemplate = 'Currency_Center_Monthly_Survey_Submitted';

		Set<Id> setOfContactEmails = loadEmails(); 

		if(!setOfContactEmails.isEmpty()) {

			//get email adress
			List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :orgWideEmail LIMIT 1];

			//get the email template
			List<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :emailReportTemplate LIMIT 1];

			if(!owa.isEmpty() && !et.isEmpty()) {
			 	Messaging.Email[] mailMsgs = new Messaging.Email[]{};
			 	List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();

                for(String cid : setOfContactEmails) {
                    Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
                    mailMsg.setOrgWideEmailAddressId(owa[0].Id);
                    mailMsg.setTargetObjectId(cid);
                    mailMsg.setTemplateID(et[0].Id);
                    mailMsg.setSaveAsActivity(false);
                    mailMsgs.add(mailMsg);
                }

                if(!mailMsgs.isEmpty()){
                    try {
	                    sendEmailResults = Messaging.sendEmail(mailMsgs);
    	                for(Messaging.SendEmailResult ser: sendEmailResults) {
                        	if(!ser.isSuccess()) {
                            	System.debug('sendEmail errorMessage: ' + ser.getErrors()[0].getMessage() + ' - TargetObjectId:' + ser.getErrors()[0].getTargetObjectId());
                        	} else {
                        		errorMessage = false;
                        	}
                    	}
                	}
                	catch (Exception ex){
                    	System.debug('sendEmail error: ' + ex.getMessage());
                	}
                }

			}
			else if (owa.isEmpty()){
            	System.debug('sendEmail Couldn\'t find OrgWideEmailAddress \'IATA Noreply\'');
        	}
        	else if(et.isEmpty()){
            	System.debug('sendEmail Couldn\'t find EmailTemplate \'Currency_Center_Annual_Survey_Initial_Notification\'');
        	}
		}
		else{
            System.debug('sendEmail No contacts with access to Currency Center service');
        }
	}

	/*
		Purpose:  send email to countrys managers when survey is submitted                                                         
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public Set<Id> loadEmails() {
		Set<Id> countryManagerEmailList = new Set<Id>();

		for(IATA_ISO_Country__c country: [SELECT Id, Name, Country_Manager__c FROM IATA_ISO_Country__c WHERE Name IN :wccsObjectMap.keySet() LIMIT 999]) {
			if(country.Country_Manager__c != null) {

				countryManagerEmailList.add(country.Country_Manager__c);
			}
		}

		return countryManagerEmailList;
	}
	/*
		Purpose:  delete certain records from salesfore                                                        
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void deleteRecords() {
		List<Currency_Center_Survey__c> deleteCurrencyCenterList = new List<Currency_Center_Survey__c>(deleteCurrencyCenterSet);
		System.debug('deleteRecords ' + deleteCurrencyCenterList);
		
		delete deleteCurrencyCenterList;
	}

	/*
		Purpose:  add new row in the bank table                                                        
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void addRow() {
		String key = buildReportTypeMapKey(sectionReportKey, sectionCurrencyKey);

		if(sectionReportKey == 'Blocked Amount' && sectionCurrencyKey == countryCurrentCurrency()){
			key = '1' + key;
		}

		String emptyRequireFields = 'Default';
		for(Integer i = 0; i < wccsObject.bankMap.get(key).size(); i++) {
			if(wccsObject.bankMap.get(key).get(i).Bank__c != null && wccsObject.bankMap.get(key).get(i).Amount__c != null) {
				emptyRequireFields = 'Not Null';
			} else {
				emptyRequireFields = 'Null';
				break;
			}
		}

		if(emptyRequireFields.equals('Not Null') || emptyRequireFields.equals('Default')) {

			errorMessage = false;
			wccsObject.bankMap.get(key).add(new Currency_Center_Survey__c(Section__c = 'Bank Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlyBank, Currency__c = sectionCurrencyKey, Country_Name__c = selectedCountrySurvey));
			wccsObjectMap.put(selectedCountrySurvey,wccsObject);

		} else if(emptyRequireFields.equals('Null')){
			//message
			errorMessage = true;
			Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Empty Required Field', 'false', 'Banks Table'));
		}
	}

	/*
		Purpose:  delete row in the bank table                                                        
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void deleteRow() {
		System.debug('deleteRow');
		Integer indexVal = numRow;

		String key = buildReportTypeMapKey(sectionReportKey, sectionCurrencyKey);

		if(sectionReportKey == 'Blocked Amount' && sectionCurrencyKey == countryCurrentCurrency()){
			key = '1' + key;
		}

		Currency_Center_Survey__c bankDeleted = wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key)[indexVal];
		if(bankDeleted.id != null) {
			deleteCurrencyCenterSet.add(bankDeleted);
		}

		//delete row
		wccsObject.bankMap.get(key).remove(indexVal);
		wccsObjectMap.put(selectedCountrySurvey, wccsObject);

		//re-calculate
		calculate();

		closePopupDeleteBankRow();
	}

	/*
		Purpose:  add new section in the country                                                        
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void addSection() {

		//new reporting type with a reporting type and currency
		Currency_Center_Survey__c newRecordReportingType = new Currency_Center_Survey__c();
		newRecordReportingType.Reporting_Type__c = selectedReportingType;
		newRecordReportingType.Currency__c = selectedCurrency;

		List<Currency_Center_Survey__c> newRecordBankList = new List<Currency_Center_Survey__c>();

		//add a new bank to the list
		newRecordBankList.add(new Currency_Center_Survey__c(Section__c = 'Bank Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlyBank, Currency__c = selectedCurrency, Country_Name__c = selectedCountrySurvey));

		String tempCountryId = String.valueOf(wccsObject.country.id);

		if(tempCountryId != null){
			newRecordReportingType.Parent_Id__c = wccsObject.country.id;
		}

		//build key
		//the key for the reporting type map and bank map will be the same when add section
		//because we can track more easily
		String key = buildReportTypeMapKey(selectedReportingType, selectedCurrency);

		if(!wccsObject.typeReportMap.containsKey(key)){

			//default data that reporting type record has to have
			newRecordReportingType.Country_Name__c = selectedCountrySurvey;
			newRecordReportingType.Section__c = 'Report Type Record';
			newRecordReportingType.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlyReportType;

			//if country currency is USD the average exchange rate is equal 1
			if(!selectedCurrency.equals('USD')){

				for(String countryKeySet: countriesProfileMap.keySet()) {
					//if(iataIsoCountryMap.get(countryKeySet).CurrencyIsoCode.equals(selectedCurrency)) {
					if(countriesProfileMap.get(countryKeySet).Currency__c.equals(selectedCurrency)) {
						newRecordReportingType.Average_Exchange_Rate__c = countriesProfileMap.get(countryKeySet).Currency_Exchange_Rate__c;
						break;
					}
				}
			} else {

				newRecordReportingType.Average_Exchange_Rate__c = 1;
			}

			//add the new section report type into is map
			wccsObject.typeReportMap.put(key, newRecordReportingType);

			//add to the bank map a blank record for that recordType
			wccsObject.bankMap.put(key, new List<Currency_Center_Survey__c>());

			//update the object/country
			wccsObjectMap.put(selectedCountrySurvey, wccsObject);
		}

		//put keys in a map, so we can access the records in total tab
		if(countriesKeysMap.containsKey(selectedCountrySurvey)) {

			//get the country and add another key for that country
			countriesKeysMap.get(selectedCountrySurvey).add(key);
		} else {
			List<String> keysList = new List<String>();
			keysList.add(key);

			//save on the map the country and his key
			countriesKeysMap.put(selectedCountrySurvey, new List<String>());
			countriesKeysMap.get(selectedCountrySurvey).add(key);
		}
    }

    /*
		Purpose:  delete section in the country                                                        
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void deleteSection() {
		String countryCurrency = countryCurrentCurrency();

		String key = buildReportTypeMapKey(sectionReportKey, sectionCurrencyKey);
		System.debug('Luis Ferreira sectionReportKey' + sectionReportKey);
		System.debug('Luis Ferreira sectionCurrencyKey' + sectionCurrencyKey);
		if(!key.equals('Blocked Amount|'+countryCurrency)) {
			//add the section to the deleted records list
			deleteCurrencyCenterSet.add(wccsObjectMap.get(selectedCountrySurvey).typeReportMap.get(key));
			System.debug('Luis Ferreira wccsObjectMap.get(selectedCountrySurvey).bankMap' + wccsObjectMap.get(selectedCountrySurvey).bankMap);
			if(wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key).size() > 0) {
				deleteCurrencyCenterSet.addAll(wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key));
			}

			//remove from wrapper
			wccsObjectMap.get(selectedCountrySurvey).typeReportMap.remove(key);
			wccsObjectMap.get(selectedCountrySurvey).bankMap.remove(key);
		}
		closePopupDeleteSection();
    }
  	
  	/*
		Purpose:  Calculate the total amount of each section and each bank %.                                                        
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void calculate() {
		System.debug('calculate');
		Integer numberOfBanks = 0;
		Decimal totalAmount = 0;

		String key = buildReportTypeMapKey(sectionReportKey, sectionCurrencyKey);
		System.debug('calculate ' + key);

		if(sectionReportKey == 'Blocked Amount' && sectionCurrencyKey == countryCurrentCurrency()){
			key = '1' + key;
		}

		if(wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key).size() > 0) {
			for(Currency_Center_Survey__c bank: wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key)) {
				System.debug('calculate bank.Amount__c' + bank.Amount__c);
				if(bank.Amount__c != null) {
					numberOfBanks++;
					totalAmount += bank.Amount__c;
					System.debug('calculate bank.Amount__c' + bank.Amount__c);
				} else {
					System.debug('calculate totalAmount = 0; 1' + bank.Amount__c);
					totalAmount = 0;
				}
			}
		} else {
			System.debug('calculate totalAmount = 0; 2');
			totalAmount = 0;
		}
		

		if(totalAmount != null && totalAmount > 0) {

			if(numberOfBanks > 1) {
				for(Currency_Center_Survey__c bank: wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key)) {
						
						if(bank.Amount__c != null && wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c != null) {

							wccsObject.typeReportMap.get(key).Total_Currency__c = totalAmount;

							//total currency in USD
							wccsObject.typeReportMap.get(key).Total_Amount_USD__c = wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c * totalAmount;
							
							//Convert the amount of the bank to USD
							bank.Amount_USD__c = wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c * bank.Amount__c;

							//percentage of the total amount taht this bank have
							bank.Bank_Percentage__c = (100 * bank.Amount__c)/totalAmount;
						}
				}

			} else {
				for(Currency_Center_Survey__c bank: wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key)) {

					if(bank.Amount__c != null && wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c != null) {
						
						// total currency in the country currency
						wccsObject.typeReportMap.get(key).Total_Currency__c = bank.Amount__c;

						//total currency in USD
						wccsObject.typeReportMap.get(key).Total_Amount_USD__c = wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c *  bank.Amount__c;
					
						//Convert the amount of the bank to USD
						bank.Amount_USD__c = wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c * bank.Amount__c;

						//percentage of the total amount taht this bank have
						bank.Bank_Percentage__c = 100;
					}
				}
			}
		} else {

			if(wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key).size() > 0) {
				for(Currency_Center_Survey__c bank: wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key)) {
					
					// total currency in the country currency
					wccsObject.typeReportMap.get(key).Total_Currency__c = 0;

					//total currency in USD
					wccsObject.typeReportMap.get(key).Total_Amount_USD__c = 0;

					//Convert the amount of the bank to USD
					bank.Amount_USD__c = 0;

					//percentage of the total amount taht this bank have
					bank.Bank_Percentage__c = 0;
				}
			} else {
				// total currency in the country currency
				wccsObject.typeReportMap.get(key).Total_Currency__c = 0;

				//total currency in USD
				wccsObject.typeReportMap.get(key).Total_Amount_USD__c = 0;
			}
		}
	}

	/*
		Purpose:  Calculate the total amount USD of the last allocation Amount                                                       
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void calculateLastAllocationUSD() {

		String key = buildReportTypeMapKey(sectionReportKey, sectionCurrencyKey);

		if(wccsObject.typeReportMap.containsKey(key)) {
			wccsObject.typeReportMap.get(key).Last_Allocation_Total_Amount_USD__c = wccsObject.typeReportMap.get(key).Last_Allocation_Amount__c * wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c;
		}
	}

	/*
		Purpose:  Calculate the delay in days                                                       
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void calculateDelayInDays() {

		for(String reports: wccsObject.typeReportMap.keySet()) {

			if(wccsObject.country.Reporting_Date__c != null && wccsObject.typeReportMap.get(reports).Sales_Period_Start_Date__c != null) {
				Integer numberDaysDue = wccsObject.country.Reporting_Date__c.daysBetween(wccsObject.typeReportMap.get(reports).Sales_Period_Start_Date__c);
				/*
				DateTime dT = wccsObject.typeReportMap.get(reports).Sales_Period_Start_Date__c;
				String minSalesPeriodEnd = dT.format('yyyy-MM-dd');*/

				wccsObject.typeReportMap.get(reports).Delay_in_day__c = String.valueOf(numberDaysDue);
			}
		}
	}

	/*
		Purpose: to build the typeReportMap and bankMap keys                                                 
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public String buildReportTypeMapKey(String reportType, String currencyName) {
		return reportType+'|'+currencyName;
	}

	// Inner Classes 
	public class wrapperCurrencyCenterSurvey	{

		public Currency_Center_Survey__c 	  			 		parent 					{ get; set; }
		public Currency_Center_Survey__c 	   					country 				{ get; set; }
		public Map<String, Currency_Center_Survey__c> 			typeReportMap 			{ get; set; }
		public Map<String, List<Currency_Center_Survey__c>> 	bankMap 				{ get; set; }

		public wrapperCurrencyCenterSurvey(){
			parent = new Currency_Center_Survey__c();
			country = new Currency_Center_Survey__c();
			typeReportMap = new Map<String, Currency_Center_Survey__c>();
			bankMap = new Map<String, List<Currency_Center_Survey__c>>();

		}
	}
	
	public void loadAll() {
		countriesResult = new List<Currency_Center_Survey__c>();
		reportingTypesResult = new List<Currency_Center_Survey__c>();
		countryIds = new List<Id>();
		reportingTypesIds = new List<Id>();

		//build a map of countries profile, where the key is the country_profile ID
		//SEE countriesProfileIdMap (WE ALREADY HAVE THE COUNTRY NAME ON THIS RECORD) check
		buildCountriesProfileIdMap();

		if(parentQueryResult == null)  {

			//retrieve the parent record
			parentQueryResult = parentQuery();
		}

		if(parentQueryResult != null) {

			//retrieve all countries from survey
			countriesResult = countriesQuery();

			loadCountry();
		}

		if(!countryIds.isEmpty()) {

			reportingTypesResult = reportingTypeQuery();

			loadReportType();
		}

		if(!reportingTypesIds.isEmpty()) {

			bankResult = banksQuery();

			loadBanks();
		}
	}

	public void buildCountriesProfileIdMap() {

		//get all countries from country profile object
		countriesProfileList = [SELECT ID, Name, Currency__c, Currency_Exchange_Rate__c FROM Country_Profile__c ORDER BY Name ASC];

		//inicialize the map of countries
		countriesProfileIdMap = new Map<String, Country_Profile__c>();

		for(Country_Profile__c countryObj: countriesProfileList) {
			countriesProfileIdMap.put(countryObj.Id, countryObj);
		}

		//inicialize the map of countries
		iataIsoCountryMap = new Map<String, IATA_ISO_Country__c>();

		for(IATA_ISO_Country__c countryObj:  [SELECT ID, Name, CurrencyIsoCode FROM IATA_ISO_Country__c ORDER BY Name ASC]) {
			iataIsoCountryMap.put(countryObj.Name, countryObj);
		}
	}


	/*
		Purpose: load country records to the wrapper object                                                 
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void loadCountry() {

		countriesSurveyString = '';

		for(Currency_Center_Survey__c country: countriesResult) {

			if(countriesProfileIdMap.containsKey(country.country__c)) {

				//inicialize the country wrapper
				wccsObjectMap.put(countriesProfileIdMap.get(country.country__c).Name, new wrapperCurrencyCenterSurvey());

				//insert in the country wrapper is parent record
				wccsObjectMap.get(countriesProfileIdMap.get(country.country__c).Name).parent = parentQueryResult;

				//insert in the country wrapper is country record
				wccsObjectMap.get(countriesProfileIdMap.get(country.country__c).Name).country = country;
				
				//build a string that will have all countries loaded to send to javascript
				countriesSurveyString += countriesProfileIdMap.get(country.country__c).Name + '|';
				
			}
			//check if is needed because we have countryResult
			countryIds.add(country.Id);
		}
	}

	/*
		Purpose: load report types records to the wrapper object                                                 
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void loadReportType() {

		for(Currency_Center_Survey__c country: countriesResult) {
			String countryCurrency;

			if(countriesProfileMap.containsKey(country.Country_Name__c)) {
				countryCurrency = countriesProfileMap.get(country.Country_Name__c).Currency__c;
			}
			for(Currency_Center_Survey__c report: reportingTypesResult) {

				 if(report.Parent_Id__c.equals(country.Id)) {

				 	String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);

					 if(report.Reporting_Type__c == 'Blocked Amount' && report.Currency__c == countryCurrency){
						 key = '1' + key;
					 }

				 	wccsObjectMap.get(report.Country_Name__c).typeReportMap.put(key, report);

				 	reportingTypesIds.add(report.Id);

			 		//put keys in a map, so we can access the records in total tab
					if(countriesKeysMap.containsKey(report.Country_Name__c)) {

						//get the country and add another key for that country
						countriesKeysMap.get(report.Country_Name__c).add(key);
					} else {
						List<String> keysList = new List<String>();
						keysList.add(key);

						//save on the map the country and his key
						countriesKeysMap.put(report.Country_Name__c, new List<String>());
						countriesKeysMap.get(report.Country_Name__c).add(key);
					}
				}
			}
		}
	}

	/*
		Purpose: load bank records to the wrapper object                                                 
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void loadBanks() {

		for(Currency_Center_Survey__c report: reportingTypesResult) {

			String countryCurrency;

			if(countriesProfileMap.containsKey(report.Country_Name__c)) {
				countryCurrency = countriesProfileMap.get(report.Country_Name__c).Currency__c;
			}

			String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);

			System.debug('report.Reporting_Type__c: ' + report.Reporting_Type__c);
			System.debug('report.Currency__c: ' + report.Currency__c);
			System.debug('countryCurrency: ' + countryCurrency);

			if(report.Reporting_Type__c == 'Blocked Amount' && report.Currency__c == countryCurrency){
				key = '1' + key;
			}
			System.debug('key: ' + key);

			//inicialize the list o banks in that reporting type
			wccsObjectMap.get(report.Country_Name__c).bankMap.put(key, new List<Currency_Center_Survey__c>());

			for(Currency_Center_Survey__c bank: bankResult) {
				
				if(bank.Parent_Id__c.equals(report.Id) && bank.Country_Name__c.equals(report.Country_Name__c)) {
					System.debug('Add bank: ' + bank);
					wccsObjectMap.get(bank.Country_Name__c).bankMap.get(key).add(bank);
				}
			}

			//if the bank list is empty insert a empty bank
			/*if(wccsObjectMap.get(report.Country_Name__c).bankMap.get(key).isEmpty()) {

				wccsObjectMap.get(report.Country_Name__c).bankMap.get(key).add(new Currency_Center_Survey__c(Section__c = 'Bank Record', Currency__c = report.Currency__c, Country_Name__c = report.Country_Name__c));
			}*/
		}
	}

	/*
		Purpose: get the parent survey                                                 
		Parameters: none
		Returns: Currency_Center_Survey__c
		Throws: none                                                      
	*/
	public Currency_Center_Survey__c parentQuery() {
		Id surveyId = apexpages.currentpage().getparameters().get('id');
		List<Currency_Center_Survey__c> tempParent = [SELECT Id,
														LastModifiedDate,
														LastModifiedBy.Contact.Name,
														Year_Survey__c,
														Month_Survey__c,
														Status__c,
														Section__c,
														Airline__c,
														Survey__c
														FROM Currency_Center_Survey__c
														WHERE Id = :surveyId
														LIMIT 1];
														
		DateTime dT = tempParent.get(0).LastModifiedDate;
		lastSaveDate = dT.format('dd-MM-yyyy');												
		surveyStatus = tempParent.get(0).Status__c;
		if(surveyStatus.equals('Submitted')){
			surveyStatusBoolean = true;
		} else {
			surveyStatusBoolean = false;
		}
		monthSurvey = Integer.valueOf(tempParent.get(0).Month_Survey__c);
		yearSurvey = Integer.valueOf(tempParent.get(0).Year_Survey__c);								
		return tempParent.get(0);
	}

	/*
		Purpose: get all countries from a specific survey                                                
		Parameters: none
		Returns: List<Currency_Center_Survey__c>
		Throws: none                                                      
	*/
	public List<Currency_Center_Survey__c> countriesQuery() {
		return [SELECT Id,
					Country__c,
					Country_Name__c,
					Section__c,
					Parent_Id__c,
					Other_Currency_Business__c,
					Reporting_Date__c
				FROM Currency_Center_Survey__c 
				WHERE Parent_Id__c = :parentQueryResult.Id
				AND (Section__c = 'Country Record' OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlyCountry)];
	}

	/*
		Purpose: get all reporting types records                                            
		Parameters: none
		Returns: List<Currency_Center_Survey__c>
		Throws: none                                                      
	*/
	public List<Currency_Center_Survey__c> reportingTypeQuery() {
		return [SELECT Id,
					Country_Name__c,
					Reporting_Type__c,
					Currency__c,
					Section__c,
					Total_Currency__c,
					Sales_Period_Start_Date__c,
					Sales_Period_End_Date__c,
					Delay_in_day__c,
					Date__c,
					Comments__c,
					ICCS__c,
					Average_Exchange_Rate__c,
					Total_Amount_USD__c,
					Reporting_Date__c,
					Parent_Id__c,
					Last_Allocation_Date__c,
					Last_Allocation_Amount__c,
					Last_Allocation_Total_Amount_USD__c,
					Report_Type_Comments__c
				FROM Currency_Center_Survey__c 
				WHERE Parent_Id__c IN :countryIds
				AND (Section__c = 'Report Type Record' OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlyReportType)];
	}

	/*
		Purpose: get all banks records                                                
		Parameters: none
		Returns: List<Currency_Center_Survey__c>
		Throws: none                                                      
	*/
	public List<Currency_Center_Survey__c> banksQuery() {
		return [SELECT Id,
					Country_Name__c,
					Parent_Id__c,
					Sales_Period_Start_Date__c,
					Sales_Period_End_Date__c,
					Bank__c,
					Section__c,
					Amount__c,
					Currency__c,
					Amount_USD__c,
					Bank_Percentage__c
				FROM Currency_Center_Survey__c 
				WHERE Parent_Id__c IN :reportingTypesIds
				AND (Section__c = 'Bank Record' OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlyBank)];
	}

	public void none() {

	}
}