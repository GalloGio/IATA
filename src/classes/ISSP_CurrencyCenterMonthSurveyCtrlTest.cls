@isTest
public class ISSP_CurrencyCenterMonthSurveyCtrlTest {
	public ISSP_CurrencyCenterMonthSurveyCtrlTest() {
		
	}
	public static User portalSetup(){
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + Math.random() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            License_Cost_Center__c = 'ISF005CH01'
        );
        Database.insert(portalAccountOwner1);

        //Create account
        Account portalAccount1 = new Account(
            Name = 'TestAirline',
            OwnerId = portalAccountOwner1.Id,
            RecordType = RecordTypeSingleton.getInstance().getRecordType('Account', 'IATA_Airline')
        );
        Database.insert(portalAccount1);
                
        //Create contact
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com',
            RecordType = RecordTypeSingleton.getInstance().getRecordType('Account', 'Standard_Contact')
        );
        Database.insert(contact1);
                
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline Delegated Admin User' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + Math.random() + 'test12345@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);

        return user1;
    }

  	/*
		Purpose:  create the annual survey (parent record)                                                         
		Parameters: none 
		Returns:  Currency_Center_Survey__C
		Throws: none                                                        
	*/
    public static Currency_Center_Survey__C createParentSurvey(String idAccount) {

    	Currency_Center_Survey__C parent = new Currency_Center_Survey__C(Section__c = 'Survey Record', 
    																		Survey__c = 'Monthly', 
    																		Year_Survey__c = '2019',
    																		Month_Survey__c = '1',
    																		Status__c = 'Draft',
    																		Airline__c = idAccount);
    	return parent;
    }

    public static Currency_Center_Survey__C createCountry(String parentId) {
    	IATA_ISO_Country__c iataISOCountry = new IATA_ISO_Country__c(Name='Portugal', 
    																	ISO_Code__c = 'PT', 
    																	AIMS_Area_Name__c = 'PORTUGAL', 
    																	Region__C = 'Europe', 
    																	IEC_Zip_Postal_Code_required__c = true);
		insert iataISOCountry;

		Country_Profile__c countryProfile = new Country_Profile__c(Name = iataISOCountry.Name,
																	Send_Notifications__C = 'No', 
																	IATA_ISO_Country__c = iataISOCountry.Id,
																	Currency_Exchange_Rate__c = 2,
																	CurrencyIsoCode = 'EUR');
		insert countryProfile;

		Currency_Center_Survey__C countryRecord = new Currency_Center_Survey__C(Section__c = 'Country Record', 
    																				Country__c = countryProfile.Id, 
    																				Country_Name__c = countryProfile.Name,
    																				Parent_Id__c = parentId);
    	return countryRecord;
    }

    public static Currency_Center_Survey__C createReportType(String countryId, String countryName, String countryCurrency) {

		Currency_Center_Survey__C reportTypeRecord = new Currency_Center_Survey__C(Section__c = 'Report Type Record', 
    																				Reporting_Type__c = 'Blocked Amount', 
    																				Country_Name__c = countryName,
    																				Currency__c = countryCurrency,
    																				Parent_Id__c = countryId);
    	return reportTypeRecord;
    }

    public static Currency_Center_Survey__C createBank(String reportTypeId, String countryName, String countryCurrency) {

		Currency_Center_Survey__C bankRecord = new Currency_Center_Survey__C(Section__c = 'Bank Record', 
    																			Reporting_Type__c = 'Blocked Amount', 
    																			Country_Name__c = countryName,
    																			Currency__c = countryCurrency,
    																			Parent_Id__c = reportTypeId);
    	return bankRecord;
    }

    	/*
		Purpose:  load all records from the survey                                                         
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void loadAllSurvey(){

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the bank survey
					Currency_Center_Survey__C bank = createBank(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert bank;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();

					//verify if the values are correct or loaded
					System.assertEquals(country.Country_Name__c, monthlySurvey.countriesResult[0].Country_Name__c);
					System.assertEquals(country.Section__c, monthlySurvey.countriesResult[0].Section__c);
					System.assertEquals(country.Country__c, monthlySurvey.countriesResult[0].Country__c);
					System.assertEquals(country.Parent_Id__c, monthlySurvey.countriesResult[0].Parent_Id__c);
					
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  save all changes                                                        
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void saveSurvey() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the bank survey
					Currency_Center_Survey__C bank = createBank(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert bank;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					List<Currency_Center_Survey__C> ccs = [SELECT Name FROM Currency_Center_Survey__C];
					System.assertEquals(4, ccs.size());
					
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  save all changes                                                        
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void buildCountrySurvey() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					IATA_ISO_Country__c iataISOCountry = new IATA_ISO_Country__c(Name='France', 
    																	ISO_Code__c = 'FR', 
    																	AIMS_Area_Name__c = 'FRANCE', 
    																	Region__C = 'Europe', 
    																	IEC_Zip_Postal_Code_required__c = true);
					insert iataISOCountry;

					Country_Profile__c countryProfile = new Country_Profile__c(Name = iataISOCountry.Name,
																				Send_Notifications__C = 'No', 
																				IATA_ISO_Country__c = iataISOCountry.Id,
																				Currency_Exchange_Rate__c = 2,
																				CurrencyIsoCode = 'EUR');
					insert countryProfile;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'countryName=France'));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.buildSurvey();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					//the '2' is the parent result and the other country of concern
					System.assertEquals('France', monthlySurvey.wccsObjectMap.get('France').country.Country_Name__c);
					System.assertEquals('Country Record', monthlySurvey.wccsObjectMap.get('France').country.Section__c);
					System.assertEquals(2, monthlySurvey.wccsObjectMap.keyset().size());
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  add bank                                                        
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void addBank() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					Financial_Institution__c bank = new Financial_Institution__c(Name = 'Novo Banco', 
																					Region__c = 'Europe', 
																					Country__c = reportType.Country_Name__c, 
																					Institution_Type__c = 'Bank');
					insert bank;


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'EUR';
					monthlySurvey.addRow();
					monthlySurvey.wccsObject.bankMap.get('1Blocked Amount|EUR')[0].Bank__c = bank.id;
					monthlySurvey.wccsObject.bankMap.get('1Blocked Amount|EUR')[0].Amount__c = 100;
					monthlySurvey.addRow();
					monthlySurvey.addRow();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(2, monthlySurvey.wccsObject.bankMap.get('1Blocked Amount|EUR').size());
					System.assertEquals(true, monthlySurvey.errorMessage);
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  calculate amounts                                                       
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void calculateTest() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					IATA_ISO_Country__c iataISOCountry = new IATA_ISO_Country__c(Name='Portugal', 
    																	ISO_Code__c = 'PT', 
    																	AIMS_Area_Name__c = 'PORTUGAL', 
    																	Region__C = 'Europe', 
    																	IEC_Zip_Postal_Code_required__c = true);
					insert iataISOCountry;

					Country_Profile__c countryProfile = new Country_Profile__c(Name = iataISOCountry.Name,
																				Send_Notifications__C = 'No', 
																				IATA_ISO_Country__c = iataISOCountry.Id,
																				Currency_Exchange_Rate__c = 2,
																				CurrencyIsoCode = 'EUR');
					insert countryProfile;

					Currency_Center_Survey__C countryRecord = new Currency_Center_Survey__C(Section__c = 'Country Record', 
			    																				Country__c = countryProfile.Id, 
			    																				Country_Name__c = countryProfile.Name,
			    																				Parent_Id__c = parent.Id);
					insert countryRecord;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :countryRecord.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportTypeRecord = new Currency_Center_Survey__C(Section__c = 'Report Type Record', 
			    																				Reporting_Type__c = 'Blocked Amount', 
			    																				Country_Name__c = countryRecord.Country_Name__c,
			    																				Currency__c = countryProfileSF.Currency__c,
			    																				Parent_Id__c = countryRecord.Id,
			    																				Average_Exchange_Rate__c = countryProfile.Currency_Exchange_Rate__c);
					insert reportTypeRecord;

					Financial_Institution__c bank = new Financial_Institution__c(Name = 'Novo Banco', 
																					Region__c = 'Europe', 
																					Country__c = reportTypeRecord.Country_Name__c, 
																					Institution_Type__c = 'Bank');
					insert bank;

					Financial_Institution__c bank2 = new Financial_Institution__c(Name = 'Mau Banco', 
																					Region__c = 'Europe', 
																					Country__c = reportTypeRecord.Country_Name__c, 
																					Institution_Type__c = 'Bank');
					insert bank2;


					Currency_Center_Survey__C bankRecord = new Currency_Center_Survey__C(Section__c = 'Bank Record', 
			    																			Reporting_Type__c = 'Blocked Amount', 
			    																			Country_Name__c = reportTypeRecord.Country_Name__c,
			    																			Currency__c = countryProfileSF.Currency__c,
			    																			Parent_Id__c = reportTypeRecord.Id,
			    																			Amount__c = 10,
			    																			Bank__c = bank.Id);
					insert bankRecord;


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'countryName='+countryRecord.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'EUR';
					monthlySurvey.calculate();
					System.assertEquals(10, monthlySurvey.wccsObject.typeReportMap.get('1Blocked Amount|EUR').Total_Currency__c);
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'EUR';
					monthlySurvey.addRow();
					monthlySurvey.wccsObject.bankMap.get('1Blocked Amount|EUR')[1].Amount__c = 10;
					monthlySurvey.wccsObject.bankMap.get('1Blocked Amount|EUR')[1].Bank__c = bank2.Id;
					monthlySurvey.calculate();
					monthlySurvey.getGrandTotal();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(20, monthlySurvey.wccsObject.typeReportMap.get('1Blocked Amount|EUR').Total_Currency__c);
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  delete bank                                                       
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void deleteBank() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the bank survey
					Currency_Center_Survey__C bank = createBank(reportType.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert bank;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'index='+0+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.showPopupDeleteBankRow();
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'EUR';
					monthlySurvey.deleteRow();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(0, monthlySurvey.wccsObject.bankMap.get('1Blocked Amount|EUR').size());
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  delete country                                                       
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void deleteCountrySurvey() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the bank survey
					Currency_Center_Survey__C bank = createBank(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert bank;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.deleteCountry();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(0, monthlySurvey.wccsObjectMap.keyset().size());
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  reload All Seclect lists                                                     
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
    public static testMethod void reloadSelectListTest() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.AccountId);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					Financial_Institution__c bank = new Financial_Institution__c(Name = 'Novo Banco', 
																					Region__c = 'Europe', 
																					Country__c = reportType.Country_Name__c, 
																					Institution_Type__c = 'Bank');
					insert bank;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.getCountriesList();
					monthlySurvey.getCurrencyType();
					monthlySurvey.getReportingType();
					monthlySurvey.getBankOptions();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(1, monthlySurvey.getCountriesList().size());
					System.assertEquals(4, monthlySurvey.getReportingType().size());
					System.assertEquals(2, monthlySurvey.getBankOptions().size());
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  submit the survey                                                     
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void submitSurveyTest() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					IATA_ISO_Country__c iataISOCountry = new IATA_ISO_Country__c(Name='Portugal', 
    																	ISO_Code__c = 'PT', 
    																	AIMS_Area_Name__c = 'PORTUGAL', 
    																	Region__C = 'Europe', 
    																	IEC_Zip_Postal_Code_required__c = true,
    																	Country_Manager__c = user1.Id);
					insert iataISOCountry;

					Country_Profile__c countryProfile = new Country_Profile__c(Name = iataISOCountry.Name,
																				Send_Notifications__C = 'No', 
																				IATA_ISO_Country__c = iataISOCountry.Id,
																				Currency_Exchange_Rate__c = 2,
																				CurrencyIsoCode = 'EUR');
					insert countryProfile;

					Currency_Center_Survey__C countryRecord = new Currency_Center_Survey__C(Section__c = 'Country Record', 
			    																				Country__c = countryProfile.Id, 
			    																				Country_Name__c = countryProfile.Name,
			    																				Parent_Id__c = parent.Id);
					insert countryRecord;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :countryRecord.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(countryRecord.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					System.debug('Anydatatype_msg reportType ' + reportType);
					insert reportType;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'countryName='+countryRecord.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.submit();
					//verify if the values are correct or loaded
					System.assertEquals(false, monthlySurvey.errorMessage);
					System.assertEquals('Submitted', monthlySurvey.parentQueryResult.Status__c);
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  add section                                                       
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void addSection() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'index='+1+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.selectedCurrency = 'EUR';
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'EUR';
					monthlySurvey.addSection();
					monthlySurvey.selectedCurrency = 'USD';
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'USD';
					monthlySurvey.addSection();
					System.debug('DEBUG Luis F ' + monthlySurvey.wccsObject.typeReportMap.keyset());
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(2, monthlySurvey.wccsObject.typeReportMap.keyset().size());
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  delete section                                                       
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void deleteSection() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'index='+1+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();/*
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'EUR';
					monthlySurvey.showPopupDeleteSection();
					monthlySurvey.deleteSection();*/
					monthlySurvey.selectedCurrency = 'USD';
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'USD';
					monthlySurvey.addSection();
					System.debug('DEUBG Luis Ferreira ' + monthlySurvey.wccsObject.typeReportMap.keyset());
					System.assertEquals(2, monthlySurvey.wccsObject.typeReportMap.keyset().size());
					monthlySurvey.showPopupDeleteSection();
					monthlySurvey.sectionReportKey = 'Blocked Amount';
					monthlySurvey.sectionCurrencyKey = 'USD';
					monthlySurvey.deleteSection();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(1, monthlySurvey.wccsObject.typeReportMap.keyset().size());
				}
			}
		Test.StopTest();
	}

	/*
		Purpose:  calculate delay in days                                                      
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
	public static testMethod void calculateDelayInDays() {
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.Account.Id);
					insert parent;

					//insert the country survey
					Currency_Center_Survey__C country = createCountry(parent.Id);
					insert country;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterReportingActionsMonth?id='+parent.Id+'&&'+'index='+1+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterMonthSurveyCtrl monthlySurvey = new ISSP_CurrencyCenterMonthSurveyCtrl();
					monthlySurvey.loadAll();
					monthlySurvey.countryObject();
					monthlySurvey.wccsObject.country.Reporting_Date__c = Date.newInstance(2020, 1, 1);
					monthlySurvey.wccsObject.typeReportMap.get('1Blocked Amount|EUR').Sales_Period_Start_Date__c = Date.newInstance(2020, 1, 11);
					monthlySurvey.calculateDelayInDays();
					monthlySurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals('10', monthlySurvey.wccsObject.typeReportMap.get('1Blocked Amount|EUR').Delay_in_day__c);
				}
			}
		Test.StopTest();
	}
}