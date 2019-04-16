/*
 * Created by Luís Ferreira on 07/12/2018.
 */
public without sharing class ISSP_CurrencyCenterAnnualSurveyCtrl {

	public String 										surveyStatus 								{ get; set; }					//survey status
	public Boolean 										surveyStatusBoolean							{ get; set; }
	public String 										lastSaveDate								{ get; set; }
	public Boolean 										displayPopupDeleteCountryConcernRow			{ get; set; }
	public Boolean 										displayPopupDeleteBankRow					{ get; set; }
	public Boolean 										displayPopupDeleteOperationRow				{ get; set; }
	public String 										saveSuccessful 								{ get; set; }
	public Boolean 										errorMessage								{ get; set; }
	public Boolean 										loadWrapperObject 							{ get; set; }
	public List<Country_Profile__c> 					countriesProfileList 						{ get; set; }
	public Map<String, wrapperCurrencyCenterSurvey> 	wccsObjectMap  								{ get; set; }
	public Map<String, Country_Profile__c>				countriesProfileMap							{ get; set; }
	public String 										countriesNamesString 						{ get; set; }
	/*public String 										countryProfileID							{ get; set; }*/
	public String 										selectedCountrySurvey 						{ get; set; }				//get paramters from url: country survey
	public wrapperCurrencyCenterSurvey 					wccsObject 									{ get; set; }
	public Set<Currency_Center_Survey__c> 				deleteCurrencyCenterSet 					{ get; set; }
	public List<Currency_Center_Survey__c> 				reportingTypeRecords 						{ get; set; }				//list sections to show in the table
/*	public Boolean 										isSectionVisible 							{ get; set; }				//section visibility*/
	public String 										sectionReportKey 							{ get; set; }				// get reporting type of the section
	public String 										sectionCurrencyKey 							{ get; set; }				// get currency of the section
	public Integer 										numRowBankPanel 							{ get; set; }
	public Integer 										numRowTypeOperationsPanel 					{ get; set; }
/*	public String 										selectedOperation 							{ get; set; }				//selected reporting type*/
	public Boolean 										loadSuccessful 								{ get; set; }
	public Integer 										numRowCountryCommentsPanel 					{ get; set; }
	public Map<String, String> 							countriesKeysMap 							{ get; set; }
	public list<Currency_Center_Survey__c> 				countryCommentsList 						{ get; set; }
	public String 										userFullName 								{ get; set; }
	public String 										userAirline 								{ get; set; }
	public String 										userPosition 								{ get; set; }
	public String 										userEmail 									{ get; set; }
	public String 										userTelephone 								{ get; set; }
	public String 										userId 										{ get; set; }
	public String 										airlineId									{ get; set; }
	public Integer 										yearSurvey 									{ get; set; }
	public Currency_Center_Survey__c 					parentQueryResult 							{ get; set; }
	public List<Currency_Center_Survey__c>				countryCommentsQueryResult 					{ get; set; }										
	/*
		Purpose:  retrieve the information of the user
		Parameters: none
		Returns: Decimal
		Throws: none
	*/
	public void userInformation() {

		//get the user Id
		userId = UserInfo.getUserId();

		//get the details of the user

		User[] contactUser = [SELECT id, 
								Contact.Name, 
								Contact.Email, 
								Contact.Phone,
								Contact.Title,
								Contact.Account.Name,
								Contact.Account.Id
								From User 
								where id = :userId 
								LIMIT 1];

		for(User cont: contactUser) {

			userAirline 	= cont.Contact.Account.Name;
			userFullName 	= cont.Contact.Name;
			userPosition 	= cont.Contact.Title;
			userEmail 		= cont.Contact.Email;
			userTelephone 	= cont.Contact.Phone;
			airlineId		= cont.Contact.Account.Id;
			
		}
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

				//get the type report key in the map of keys
				String typeReportKey = countriesKeysMap.get(mapKeySet);

				//only can sum if the value isn't null
				if(wccsObjectMap.get(mapKeySet).typeReportMap.get(typeReportKey).Total_Amount_USD__c != null) {

					//sum total amount usd of each country
					totalAmount += wccsObjectMap.get(mapKeySet).typeReportMap.get(typeReportKey).Total_Amount_USD__c;
				}

			}
		}
		return totalAmount;
	}

	public List<SelectOption> getCountriesList() {
		List<SelectOption> countriesList = new List<SelectOption>();
		countriesList.add(new SelectOption('Select Country', 'Select Country'));
		for(Country_Profile__c val : countriesProfileList) {
			countriesList.add(new SelectOption(val.Name, val.Name));
		}

		return countriesList;
	}

	public List<SelectOption> getSalesFundsAwaiting() {
		List<SelectOption> countriesList = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Currency_Center_Survey__c.SalesFundsAwaintingRepatriation__c.getDescribe();

		for(Schema.PicklistEntry val : fieldResult.getPicklistValues()) {
			countriesList.add(new SelectOption(val.getLabel(), val.getLabel()));
		}

		return countriesList;
	}
	/*END TOTAL VARIABLES*/

	/*
		Purpose:  get all reporting type
		Parameters: none
		Returns: reportingTypeList
		Throws: none
	*/
	public List<SelectOption> typeOperationsList { get; set; }
	public List<SelectOption> getTypeOperations() {
		typeOperationsList = new List<SelectOption>();
		typeOperationsList.add(new SelectOption('', 'Select Operation'));

		Schema.DescribeFieldResult fieldResult = Currency_Center_Survey__c.Type_of_Operations__c.getDescribe();

		for(Schema.PicklistEntry val : fieldResult.getPicklistValues()) {
			typeOperationsList.add(new SelectOption(val.getLabel(), val.getLabel()));
		}

		return typeOperationsList;
	}

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

	public ISSP_CurrencyCenterAnnualSurveyCtrl() {
		loadWrapperObject = true;
		loadSuccessful = false;
		errorMessage = false;

		/*surveyDate();*/
		buildCountriesMap();
		buildCountriesNameString();

		//Initialize list of country surveys
		wccsObjectMap = new Map<String, wrapperCurrencyCenterSurvey>();
		countriesKeysMap = new Map<String, String>();

		wccsObject = new wrapperCurrencyCenterSurvey();
		deleteCurrencyCenterSet = new Set<Currency_Center_Survey__c>();

		//add first reporting type record
		reportingTypeRecords = new List<Currency_Center_Survey__c>(); 
		Currency_Center_Survey__c newRecordReportingType = new Currency_Center_Survey__c();
		reportingTypeRecords.add(newRecordReportingType);

		init();
		userInformation();
		loadAll();
		
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

	public void init() {
		//inicialize list od country commets in the map
		countryCommentsList = new List<Currency_Center_Survey__c>();

		//load parent survey
		if(parentQueryResult == null){
			parentQueryResult = parentQuery();
		}

		if(parentQueryResult.Id != null) {
			countryCommentsQueryResult = queryCountryCommentSurvey(parentQueryResult.Id);

			if(!countryCommentsQueryResult.isEmpty()) {

				for(Currency_Center_Survey__c countryComment: countryCommentsQueryResult) {

					if(countryComment != null && countryComment.Parent_Id__c.equals(parentQueryResult.Id)) {

						//get the reporting type and add banks if exists
						countryCommentsList.add(countryComment);
					}
				}

			} /*else {
				//add empty countryComment if list of banks is empty
				countryCommentsList.add(new Currency_Center_Survey__c());
			}*/
		}
		System.debug('comments ' + countryCommentsQueryResult);
		
	}

	/*
		Purpose:  change the selected country when tab is clicked                                                       
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void countryObject() {

		this.selectedCountrySurvey = ApexPages.CurrentPage().getParameters().get('countryName');

		wccsObject = wccsObjectMap.get(selectedCountrySurvey);
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
		Purpose:  save the survey in the object Currency_Center_Survey__c                                                         
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public PageReference save() {
		List<Currency_Center_Survey__c> reportListToInsert = new List<Currency_Center_Survey__c>();

		System.debug('***** Save - wccsObjectMap: ' + wccsObjectMap);

		System.debug('Error message ' + errorMessage);
		if(errorMessage == false) {
			//add parent to salesforce if doesnt exist
			if(parentQueryResult.id == null) {
				insert parentQueryResult;
			} else {
				update parentQueryResult;
			}

			System.debug('Countries ' + wccsObjectMap.keySet());
			for(String countrySurvey: wccsObjectMap.keySet()){

				wccsObject = wccsObjectMap.get(countrySurvey);

				System.debug('***** Save - wccsObject: ' + wccsObject);

				//add country to salesforce
				if(wccsObject.country.id == null) {
					//associate parent id
					wccsObject.country.Parent_Id__c = parentQueryResult.id;
					insert wccsObject.country;
				}

				for(String reportKey: wccsObject.typeReportMap.keySet()) {
					
					if(wccsObject.typeReportMap.get(reportKey).Id == null) {

						//associate to the parent survey
						wccsObject.typeReportMap.get(reportKey).Parent_Id__c = wccsObject.country.id;
					}

					//add to a list for future insert
					reportListToInsert.add(wccsObject.typeReportMap.get(reportKey)); 
				}

				//add report type list to salesforce
				if(!reportListToInsert.isEmpty()) {
					System.debug('***** Save - reportKey: ' + reportListToInsert);
					upsert reportListToInsert;
				}

				// add banks list to salesforce
				List<Currency_Center_Survey__c> bankListToInsert = new List<Currency_Center_Survey__c>();

				for(Currency_Center_Survey__c report: reportListToInsert){

					//build key
					String key = buildReportTypeMapKey(report.Reporting_Type__c , report.Currency__c);

					//Example of empty bank record
					Currency_Center_Survey__c emptyBank = new Currency_Center_Survey__c(Section__c = 'Bank Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualBank,Currency__c = report.Reporting_Type__c, Country_Name__c = report.Country_Name__c);

					System.debug('BANKS KEY ' + key);
					System.debug('BANKS ' + wccsObject.bankMap);
					if(wccsObject.bankMap.containsKey(key)) {
						for(Currency_Center_Survey__c bank: wccsObject.bankMap.get(key)){

							if(bank.Parent_Id__c == null){

								bank.Parent_Id__c =  wccsObject.typeReportMap.get(key).Id;
							}

							if(bank != emptyBank && !bankListToInsert.contains(bank) && bank.Bank__c != null){
								bankListToInsert.add(bank);
								
							}
						}
					}
				}
				if(!bankListToInsert.isEmpty()){
					System.debug('***** Save - bankListToInsert: ' + bankListToInsert);
					upsert bankListToInsert;
				}

				// add type of Operations list to salesforce
				List<Currency_Center_Survey__c> typeOperationsListToInsert = new List<Currency_Center_Survey__c>();

				for(Currency_Center_Survey__c report: reportListToInsert){
		
					//build key
					String key = buildReportTypeMapKey(report.Reporting_Type__c , report.Currency__c);

					if(wccsObject.typeOfOperationsMap.containsKey(key)) {
						for(Currency_Center_Survey__c typeOper: wccsObject.typeOfOperationsMap.get(key)){

							if(typeOper.Parent_Id__c == null){

								typeOper.Parent_Id__c =  wccsObject.typeReportMap.get(key).Id;
							}
							//if dont have percentage can't be insert
							System.debug(typeOper.Type_of_Operations__c);
							if(typeOper.Type_Of_Operations_Percentage__c != null 
								&& typeOper.Type_of_Operations__c != null
								&& !typeOperationsListToInsert.contains(typeOper)  
								&& !typeOper.Type_of_Operations__c.equals('default')){
								typeOperationsListToInsert.add(typeOper);
							}
						}
					}
				}

					System.debug('***** Save - typeOperationsListToInsert: ' + typeOperationsListToInsert);
				if(!typeOperationsListToInsert.isEmpty()){

					System.debug('***** Save - typeOperationsListToInsert: ' + typeOperationsListToInsert);

					/*try {*/
						upsert typeOperationsListToInsert;
					/*} catch (DmlException ex) {
						ApexPages.addMessages(ex);
					}*/
				}
			}


			if(!countryCommentsList.isEmpty()) {

				List<Currency_Center_Survey__c> countryCommentsListToInsert = new List<Currency_Center_Survey__c>();

				for(Currency_Center_Survey__c comment: countryCommentsList) {
					if(comment.Country_Comments__c != null && !comment.Country_Comments__c.equals('') && !comment.Country_Name__c.equals('Select Country')) {

						comment.Parent_Id__c = parentQueryResult.id;

						countryCommentsListToInsert.add(comment);
					}
				}

				//insert into salesforce
				if(!countryCommentsListToInsert.isEmpty()) {

					upsert countryCommentsListToInsert;
				}
			}

			// clean-up removed report type and/or bank
			if(!deleteCurrencyCenterSet.isEmpty()) {
				System.debug('***** Save - deleteCurrencyCenterSet: ' + deleteCurrencyCenterSet);
				deleteRecords();
				
				System.debug('Before ' + deleteCurrencyCenterSet);
				deleteCurrencyCenterSet.clear();
				System.debug('After ' + deleteCurrencyCenterSet);
			}
			saveSuccessful = 'Saved';
			PageReference retURL = new PageReference('/ISSP_CurrencyCenterAnnualSurvey?id=' + parentQueryResult.id);
	      	retURL.setRedirect(true);
	      	return retURL;
		} else {
			saveSuccessful = 'unSaved';
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

		System.debug('Begin submit');
		//Change the parent status do submitted
		parentQueryResult.Status__c = 'Submitted';
		save();
		System.debug('IN SUBMITE');
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

		String emailReportTemplate = 'Currency_Center_Annual_Survey_Submitted';

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

		List<String> managerNameList = new List<String>();
		for(IATA_ISO_Country__c country: IATAIsoCountryDAO.getIsoCountryByCountriesName(wccsObjectMap.keySet())) {
			if(country.Country_Manager__c != null) {

				countryManagerEmailList.add(country.Country_Manager__c);
			}
		}

		return countryManagerEmailList;
	}

	/*
		Purpose:  delete the records from salesforce that were in the deleteCurrencyCenterList                                                  
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void deleteRecords() {
		List<Currency_Center_Survey__c> deleteCurrencyCenterList = new List<Currency_Center_Survey__c>(deleteCurrencyCenterSet);
		delete deleteCurrencyCenterList;
	}

	/*
		Purpose: when create the a new tab, we load the data from salesforce and put in the wrapper object                                                     
		Parameters: none
		Returns: wrapperCurrencyCenterSurvey
		Throws: none                                                      
	*/
	public void buildSurvey() {

		this.selectedCountrySurvey = ApexPages.CurrentPage().getParameters().get('countryName');

		System.debug('selectedCountrySurvey ' + selectedCountrySurvey);
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);

		/*START NEW*/
		if(!wccsObjectMap.containsKey(selectedCountrySurvey)) {
			wccsObjectMap.put(selectedCountrySurvey, new wrapperCurrencyCenterSurvey());

			//inicialize the list of bankMap
			wccsObjectMap.get(selectedCountrySurvey).bankMap.put(key, new List<Currency_Center_Survey__c>());

			//inicialize the list of typeOfOperationsMap
			wccsObjectMap.get(selectedCountrySurvey).typeOfOperationsMap.put(key, new List<Currency_Center_Survey__c>());

			wccsObjectMap.get(selectedCountrySurvey).parent = parentQueryResult;
			System.debug('countriesProfileMap ' +countriesProfileMap);
			wccsObjectMap.get(selectedCountrySurvey).country = new Currency_Center_Survey__c(Country__c = countriesProfileMap.get(selectedCountrySurvey).Id, Country_Name__c = selectedCountrySurvey, Section__c = 'Country Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualCountry);

			//add to the list of reporting type
			wccsObjectMap.get(selectedCountrySurvey).typeReportMap.put(key, new Currency_Center_Survey__c(Reporting_Type__c = 'Blocked Amount', Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey, Section__c = 'Report Type Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualReportType));

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
			/*wccsObjectMap.get(selectedCountrySurvey).bankMap.get(key).add(new Currency_Center_Survey__c(Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey, Section__c = 'Bank Record'));
			*/
			//add empty type of operations if list of operations is empty
			/*	wccsObjectMap.get(selectedCountrySurvey).typeOfOperationsMap.get(key).add(new Currency_Center_Survey__c( Country_Name__c = selectedCountrySurvey, Section__c = 'Type Of Operations Record'));
		*/} 
		
		wccsObject = wccsObjectMap.get(selectedCountrySurvey);
		//save on a map the key of each country
		countriesKeysMap.put(selectedCountrySurvey, key);
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

					/*if(!wccsObjectMap.get(countryToDelete).bankMap.get(key).isEmpty()) {*/

						for(Currency_Center_Survey__c bank: wccsObjectMap.get(countryToDelete).bankMap.get(key)){

							if(bank.id != null) {
								deleteCountrySurvey.add(bank);
							}
						}
					/*}*/

					//add type of operations to the delete list
					/*if(!wccsObjectMap.get(countryToDelete).typeOfOperationsMap.get(key).isEmpty()) {*/

						for(Currency_Center_Survey__c typeOfOperation: wccsObjectMap.get(countryToDelete).typeOfOperationsMap.get(key)){

							if(typeOfOperation.id != null) {
								deleteCountrySurvey.add(typeOfOperation);
							}
						}
					/*}*/
				}
			}

			if(wccsObjectMap.get(countryToDelete).country.Id != null){
				//add country to delete list
				deleteCountrySurvey.add(wccsObjectMap.get(countryToDelete).country);
			}
			wccsObjectMap.remove(countryToDelete);
			countriesKeysMap.remove(countryToDelete);
		}

		System.debug('**** DELETE SET ' + deleteCountrySurvey);
		//add country to delete list
		deleteCurrencyCenterSet.addAll(deleteCountrySurvey);
	}

	/*
		Purpose:  add new row in the bank table
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void addRowBankMap() {

		//get the current currency
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);

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
			wccsObject.bankMap.get(key).add(new Currency_Center_Survey__c(Section__c = 'Bank Record', RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualBank, Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey));
		} else if(emptyRequireFields.equals('Null')){
			//message
			errorMessage = true;
			Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Empty Required Field', 'false', 'Banks Table'));
		}
	}

	/*
		Purpose:  add new row in the type of operations table
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void addRowTypeOfOperationsMap() {

		//get the current currency
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);

		Boolean requiredFieldsMissing = false;
		Decimal totalPct = 0;
		for(Integer i = 0; i < wccsObject.typeOfOperationsMap.get(key).size(); i++){
			if(wccsObject.typeOfOperationsMap.get(key).get(i).Type_of_Operations__c == null || wccsObject.typeOfOperationsMap.get(key).get(i).Type_Of_Operations_Percentage__c == null){
				requiredFieldsMissing = true;
			}
			else{
				totalPct += wccsObject.typeOfOperationsMap.get(key).get(i).Type_Of_Operations_Percentage__c;
				if(wccsObject.typeOfOperationsMap.get(key).get(i).Type_Of_Operations_Percentage__c <= 0 || wccsObject.typeOfOperationsMap.get(key).get(i).Type_Of_Operations_Percentage__c >100 ||
					totalPct > 100){
					requiredFieldsMissing = true;
				}
			}
		}

		if(requiredFieldsMissing){
			//message
			errorMessage = true;
			Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Empty Required Field', 'false', 'Type Of Operations Table'));
		}
		else{
			if(wccsObject.typeOfOperationsMap.get(key).size() <= 4) {
				wccsObject.typeOfOperationsMap.get(key).add(new Currency_Center_Survey__c(Section__c = 'Type Of Operations Record', RecordTypeId =ISSP_CurrencyCenterUtil.rtIdAnnualTypeOfOperations, Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey));
			}
		}
	}

	/*
		Purpose:  add new row in the countries comments table
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void addRowCountryCommentsMap() {

		String emptyRequireFields = 'Default';
		String nome;
		for(Integer i = 0; i <countryCommentsList.size(); i++) {
		System.debug('countryCommentsList.get(i).Country_Comments__c ' + countryCommentsList.get(i).Country_Comments__c);
			if(countryCommentsList.get(i).Country_Name__c != null 
				&& countryCommentsList.get(i).Country_Name__c != 'Select Country' 
				&& countryCommentsList.get(i).Country_Comments__c != null
				&& !countryCommentsList.get(i).Country_Comments__c.isWhitespace()) {
				emptyRequireFields = 'Not Null';
			} else {
				emptyRequireFields = 'Null';
				break;
			}
		}
		if(emptyRequireFields.equals('Not Null') || emptyRequireFields.equals('Default')) {
			errorMessage = false;
			countryCommentsList.add(new Currency_Center_Survey__c(Section__c = 'Country Comment Record', RecordTypeId =ISSP_CurrencyCenterUtil.rtIdAnnualCountryComment, Country_Name__c = selectedCountrySurvey));
		} else if(emptyRequireFields.equals('Null')){
			errorMessage = true;
			Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Empty Required Field', 'false', 'Other Countries Of Concern'));
		}
	}

	/*
		Purpose:  delete row in the bank table
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void deleteRowBankMap() {
		Integer indexVal = numRowBankPanel;

		//get the current currency
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);
		System.debug('Luis Ferreira Key ' + key);
		System.debug('Luis Ferreira wccsObject.bankMap ' + wccsObject.bankMap);
		System.debug('Luis Ferreira wccsObject.bankMap.get(key)[indexVal - 1] ' + wccsObject.bankMap.get(key)[indexVal - 1]);
		Currency_Center_Survey__c bankDeleted = wccsObject.bankMap.get(key)[indexVal - 1];
		if(bankDeleted.id != null) {
			deleteCurrencyCenterSet.add(bankDeleted);
		}

		//delete row
		wccsObject.bankMap.get(key).remove(indexVal - 1);

		//update the object
		wccsObjectMap.put(selectedCountrySurvey, wccsObject);

		//re-calculate
		calculate();

		closePopupDeleteBankRow();
	}

	/*
		Purpose:  delete row in the type of operations table
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void deleteRowTypeOfOperationsMap() {
		Integer indexVal = numRowTypeOperationsPanel;

		//get the current currency
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);

		Currency_Center_Survey__c typeOperationsDeleted = wccsObject.typeOfOperationsMap.get(key)[indexVal - 1];

		if(typeOperationsDeleted.id != null) {
			deleteCurrencyCenterSet.add(typeOperationsDeleted);
		}

		//delete row
		wccsObject.typeOfOperationsMap.get(key).remove(indexVal - 1);

		/*if(wccsObject.typeOfOperationsMap.get(key).size() <= 1) {
			wccsObject.typeOfOperationsMap.get(key).add(new Currency_Center_Survey__c(Section__c = 'Type Of Operations Record', Currency__c = countryCurrency, Country_Name__c = selectedCountrySurvey));
		}*/

		//update the object
		wccsObjectMap.put(selectedCountrySurvey, wccsObject);

		closePopupDeleteTypeOperations();
	}

	/*
		Purpose:  delete row in the country comments table
		Parameters: none
		Returns: none
		Throws: none
	*/
	public void deleteRowCountryCommentsMap() {
		Integer indexVal = numRowCountryCommentsPanel;
		System.debug('Anydatatype_msg ' + countryCommentsList);
		Currency_Center_Survey__c countryCommentDeleted = countryCommentsList[indexVal - 1];
		if(countryCommentDeleted.id != null) {
			deleteCurrencyCenterSet.add(countryCommentDeleted);
		}

		//delete row
		countryCommentsList.remove(indexVal - 1);

		closePopupDeleteCountryConcernRow();
	}

	public void calculate() {
		Integer numberOfBanks = 0;
		Decimal totalAmount = 0;
		//get country we want to remove
		wccsObject = wccsObjectMap.get(selectedCountrySurvey);

		//get the current currency
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);
		for(Currency_Center_Survey__c bank: wccsObject.bankMap.get(key)) {
			if(bank.Amount__c != null) {
				numberOfBanks++;
				totalAmount += bank.Amount__c;
			}
		}

		if(totalAmount != null && totalAmount > 0) {

			//if number of banks is higher than one we have to calculate the percentage and the total amount
			if(numberOfBanks > 1) {

				for(Currency_Center_Survey__c bank: wccsObject.bankMap.get(key)) {

					if(bank.Amount__c != null && wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c != null) {

						// total currency in the country currency
						wccsObject.typeReportMap.get(key).Total_Currency__c = totalAmount;

						//total currency in USD
						wccsObject.typeReportMap.get(key).Total_Amount_USD__c = totalAmount / wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c;
						
						//Convert the amount of the bank to USD
						bank.Amount_USD__c = bank.Amount__c / wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c;

						//percentage of the total amount taht this bank have
						bank.Bank_Percentage__c = (100 * bank.Amount__c)/totalAmount;
					}
				}
			} else {
				for(Currency_Center_Survey__c bank: wccsObject.bankMap.get(key)) {

					if(bank.Amount__c != null && wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c != null) {

						// total currency in the country currency
						wccsObject.typeReportMap.get(key).Total_Currency__c = bank.Amount__c;

						//total currency in USD
						wccsObject.typeReportMap.get(key).Total_Amount_USD__c = bank.Amount__c / wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c;
					
						//Convert the amount of the bank to USD
						bank.Amount_USD__c = bank.Amount__c / wccsObject.typeReportMap.get(key).Average_Exchange_Rate__c;

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

	public Decimal percentageTypeOper { get; set; }

	public void iccsAutoComplete() {
		//get the current currency
		String countryCurrency = countryCurrentCurrency();

		//build map key
		String key = buildReportTypeMapKey('Blocked Amount', countryCurrency);

		Decimal tempPercentage = 0;
		
		for(Currency_Center_Survey__c typeOper: wccsObject.typeOfOperationsMap.get(key)) {

			//count the total percentage value
			System.debug('Test ' + typeOper.Type_Of_Operations_Percentage__c);
			if(typeOper.Type_Of_Operations_Percentage__c != null) {
				tempPercentage += typeOper.Type_Of_Operations_Percentage__c;
			}

			if(typeOper.Type_of_Operations__c != null && typeOper.Type_of_Operations__c.equals('ICCS') && typeOper.Type_Of_Operations_Percentage__c < 100 && typeOper.Type_Of_Operations_Percentage__c > 0) {
				System.debug(typeOper);
				wccsObject.typeReportMap.get(key).ICCS__c = String.valueOf(typeOper.Type_Of_Operations_Percentage__c);
				errorMessage = false;
				/*break;*/
			}

			//add message if the percentage is lower than 0 and higher than 100
			if(typeOper.Type_Of_Operations_Percentage__c > 100 || typeOper.Type_Of_Operations_Percentage__c < 0) {
				errorMessage = true;
			/*	Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, typeOper.Type_of_Operations__c + ' Type of Operations percentage must be between 0 and 100%.', 'false', 'Type Of Operations Percentage'));
			*/}

			//add message if the sum of percentage is higher than 100
			if(tempPercentage > 100) {
				errorMessage = true;
				/*Apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, typeOper.Country_Name__c + ' total percentage of the type operations must be between 0 and 100%.', 'false', 'Type Of Operations Percentage'));
				*/break;
			}
		}
		
		System.debug('object ***++++ ' + wccsObjectMap.get(selectedCountrySurvey).typeReportMap.get(key));
	}

	public void  closePopupDeleteTypeOperations() {

		displayPopupDeleteOperationRow = false;
	}

	public void showPopupDeleteTypeOperations() {
		numRowTypeOperationsPanel =	Integer.valueof(system.currentpagereference().getparameters().get('indexTypeOperationsPanel'));
		displayPopupDeleteOperationRow = true;
	}

	public void  closePopupDeleteBankRow() {

		displayPopupDeleteBankRow = false;
	}

	public void showPopupDeleteBankRow() {

		numRowBankPanel = Integer.valueof(system.currentpagereference().getparameters().get('indexBankPanel'));

		displayPopupDeleteBankRow = true;
	}

	public void closePopupDeleteCountryConcernRow() {

		displayPopupDeleteCountryConcernRow = false;
	}

	public void showPopupDeleteCountryConcernRow() {
		numRowCountryCommentsPanel = Integer.valueof(system.currentpagereference().getparameters().get('indexCountryCommentsPanel'));
		displayPopupDeleteCountryConcernRow = true;
	}

	public String buildReportTypeMapKey(String reportType, String currencyName) {
		return reportType+'|'+currencyName;
	}

	// Inner Classes
	public class wrapperCurrencyCenterSurvey	{

		public Currency_Center_Survey__c 	   						parent 					{ get; set; }
		public Currency_Center_Survey__c 	   						country 				{ get; set; }
		public Map<String, Currency_Center_Survey__c>				typeReportMap 			{ get; set; }
		public Map<String, List<Currency_Center_Survey__c>>			typeOfOperationsMap		{ get; set; }
		public Map<String, List<Currency_Center_Survey__c>> 		bankMap 				{ get; set; }

		public wrapperCurrencyCenterSurvey(){
			parent = new Currency_Center_Survey__c();
			country = new Currency_Center_Survey__c();
			typeReportMap = new Map<String, Currency_Center_Survey__c>();
			typeOfOperationsMap = new Map<String, List<Currency_Center_Survey__c>>();
			bankMap = new Map<String, List<Currency_Center_Survey__c>>();
		}
	}

	public List<Id> 						countryIds 											{ get; set; }
	public List<Id> 						reportingTypesIds 									{ get; set; }
	public List<Currency_Center_Survey__c> 	countriesResult 									{ get; set; }
	public List<Currency_Center_Survey__c> 	reportingTypesResult 								{ get; set; }
	public List<Currency_Center_Survey__c> 	bankResult 											{ get; set; }
	public List<Currency_Center_Survey__c> 	typeOfOperationsResult 								{ get; set; }
	public Map<String, Country_Profile__c>	countriesProfileIdMap								{ get; set; }
	public Map<String, IATA_ISO_Country__c>	iataIsoCountryMap									{ get; set; }
	public String 							countriesSurveyString 								{ get; set; }

	public void loadAll() {
		countriesResult = new List<Currency_Center_Survey__c>();
		reportingTypesResult = new List<Currency_Center_Survey__c>();
		typeOfOperationsResult = new List<Currency_Center_Survey__c>();
		countryIds = new List<Id>();
		reportingTypesIds = new List<Id>();

		//build a map of countries profile, and the key is the country_profile ID
		buildCountriesProfileIdMap();

		parentQueryResult = parentQuery();

		if(parentQueryResult != null) {
			countriesResult = countriesQuery();

			loadCountry();
		}

		if(!countryIds.isEmpty()) {

			reportingTypesResult = reportingTypeQuery();

			loadReportType();
		}

		if(!reportingTypesIds.isEmpty()) {

			bankResult = banksQuery();

			typeOfOperationsResult = typeOfOperationsQuery();

			loadBanks();

			loadTypeOperations();
		}
		system.debug('Luis Ferreira Object ' + wccsObjectMap);
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

		for(IATA_ISO_Country__c countryObj: IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')) {
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

				wccsObjectMap.put(countriesProfileIdMap.get(country.country__c).Name, new wrapperCurrencyCenterSurvey());

				wccsObjectMap.get(countriesProfileIdMap.get(country.country__c).Name).parent = parentQueryResult;

				wccsObjectMap.get(countriesProfileIdMap.get(country.country__c).Name).country = country;
				
				countriesSurveyString += countriesProfileIdMap.get(country.country__c).Name + '|';
				
			}
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

			for(Currency_Center_Survey__c report: reportingTypesResult) {

				 if(report.Parent_Id__c.equals(country.Id)) {

				 	String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);

				 	wccsObjectMap.get(countriesProfileIdMap.get(country.country__c).Name).typeReportMap.put(key, report);

				 	reportingTypesIds.add(report.Id);

				 	//save on a map the key of each country
					countriesKeysMap.put(countriesProfileIdMap.get(country.country__c).Name, key);
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
		System.debug('loadBanks IN');
		for(Currency_Center_Survey__c report: reportingTypesResult) {

			String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);
			System.debug('loadBanks KEY ' + key);

			System.debug(report.Currency__c);
			//inicialize the list o banks in that reporting type
			wccsObjectMap.get(report.Country_Name__c).bankMap.put(key, new List<Currency_Center_Survey__c>());


			for(Currency_Center_Survey__c bank: bankResult) {

				if(bank.Parent_Id__c.equals(report.Id) && bank.Country_Name__c.equals(report.Country_Name__c)) {

					wccsObjectMap.get(bank.Country_Name__c).bankMap.get(key).add(bank);
				}
			}

			//if the bank list is empty insert a empty bank
			/*if(wccsObjectMap.get(report.Country_Name__c).bankMap.get(key).isEmpty()) {

				wccsObjectMap.get(report.Country_Name__c).bankMap.get(key).add(new Currency_Center_Survey__c(Currency__c = report.Currency__c, Country_Name__c = report.Country_Name__c, Section__c = 'Bank Record'));
			}*/
		}
	}

	/*
		Purpose: load type operations records to the wrapper object                                                 
		Parameters: none
		Returns: none
		Throws: none                                                      
	*/
	public void loadTypeOperations() {
		System.debug('loadTypeOperations IN');
		for(Currency_Center_Survey__c report: reportingTypesResult) {

			String key = buildReportTypeMapKey(report.Reporting_Type__c, report.Currency__c);
			System.debug('loadTypeOperations KEY ' + key);

			//inicialize the list o banks in that reporting type
			wccsObjectMap.get(report.Country_Name__c).typeOfOperationsMap.put(key, new List<Currency_Center_Survey__c>());

			for(Currency_Center_Survey__c operation: typeOfOperationsResult) {

				if(operation.Parent_Id__c.equals(report.Id) && operation.Country_Name__c.equals(report.Country_Name__c)) {

					wccsObjectMap.get(operation.Country_Name__c).typeOfOperationsMap.get(key).add(operation);
				}
			}

			//if the type of operations list is empty insert a empty record
			/*if(wccsObjectMap.get(report.Country_Name__c).typeOfOperationsMap.get(key).isEmpty()) {

				wccsObjectMap.get(report.Country_Name__c).typeOfOperationsMap.get(key).add(new Currency_Center_Survey__c(Country_Name__c = report.Country_Name__c, Section__c = 'Type Of Operations Record'));
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
														Status__c,
														Section__c,
														SalesFundsAwaintingRepatriation__c,
														Survey__c,
														Airline__c
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
					Parent_Id__c,
					Country_Name__c,
					Section__c
				FROM Currency_Center_Survey__c 
				WHERE Parent_Id__c = :parentQueryResult.Id
				AND (Section__c = 'Country Record' OR RecordTypeId =:ISSP_CurrencyCenterUtil.rtIdAnnualCountry)];
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
					Report_Type_Comments__c,
					ICCS__c,
					Average_Exchange_Rate__c,
					Total_Amount_USD__c,
					Reporting_Date__c,
					Parent_Id__c
				FROM Currency_Center_Survey__c 
				WHERE Parent_Id__c IN :countryIds
				AND (Section__c = 'Report Type Record' OR RecordTypeId =:ISSP_CurrencyCenterUtil.rtIdAnnualReportType)];
	}

	/*
		Purpose: get all banks records                                                
		Parameters: none
		Returns: List<Currency_Center_Survey__c>
		Throws: none                                                      
	*/
	public List<Currency_Center_Survey__c> banksQuery() {
		return [SELECT Id,
					Country_Name__c ,
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
				AND (Section__c = 'Bank Record' OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualBank)];
	}

	/*
		Purpose: get all banks type of operations                                                
		Parameters: none
		Returns: List<Currency_Center_Survey__c>
		Throws: none                                                      
	*/
	public List<Currency_Center_Survey__c> typeOfOperationsQuery() {
		return [SELECT Id,
					Type_of_Operations__c,
					Country_Name__c ,
					Type_Of_Operations_Percentage__c,
					Parent_Id__c,
					Section__c,
					Currency__c
				FROM Currency_Center_Survey__c 
				WHERE Parent_Id__c IN :reportingTypesIds
				AND (Section__c = 'Type Of Operations Record' OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualTypeOfOperations)];
	}

	/*
		Purpose: get the countries comments records                                                      
		Parameters: String
		Returns: List<Currency_Center_Survey__c>
		Throws: none                                                      
	*/
	public List<Currency_Center_Survey__c> queryCountryCommentSurvey(String parentID) {
		Currency_Center_Survey__c[] resultList = [SELECT Id,
														Section__c,
														Parent_Id__c,
														Country_Comments__c,
														Country_Name__c
													FROM Currency_Center_Survey__c 
													WHERE Parent_Id__c = :parentID
													AND (Section__c = 'Country Comment Record' OR RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualCountryComment)];
		return resultList;
	}

	public void none() {
	}
}