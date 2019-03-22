/*
    Class Name: ISSP_CurrencyCenterAnnualSurveyCtrlTest
    Related Classes: 

    Copyright @Right IT Services

    Purpose: 

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         Luis Ferreira    				07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_CurrencyCenterAnnualSurveyCtrlTest {
	public ISSP_CurrencyCenterAnnualSurveyCtrlTest() {
		
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
    																		Survey__c = 'Annual', 
    																		Year_Survey__c = '2019', 
    																		Status__c = 'Draft',
    																		Airline__c = idAccount);
    	return parent;
    }
    public static Currency_Center_Survey__C createOtherCountryConcern(String idAccount, String countryName) {

		Currency_Center_Survey__C otherCountryConcerRecord = new Currency_Center_Survey__C(Section__c = 'Country Comment Record', 
    																						Reporting_Type__c = 'Blocked Amount', 
    																						Country_Name__c = countryName,
    																						Parent_Id__c = idAccount);
    	return otherCountryConcerRecord;
    }

    /*public static Currency_Center_Survey__C createCountries() {
    	List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c>();

		countryList.add(new IATA_ISO_Country__c(Name='Canada', ISO_Code__c = 'CA', Case_BSP_Country__c = 'Canada', AIMS_Area_Name__c = 'CANADA', Region__C = 'Americas'));
		countryList.add(new IATA_ISO_Country__c(Name='Chile', ISO_Code__c = 'CL', Case_BSP_Country__c = 'Chile', AIMS_Area_Name__c = 'CHILE', Region__C = 'Americas', VAT_Validation_Required__c = true));
        countryList.add(new IATA_ISO_Country__c(Name='Mexico', ISO_Code__c = 'MX', Case_BSP_Country__c = '', AIMS_Area_Name__c = 'MEXICO', Region__C = 'Americas'));
        countryList.add(new IATA_ISO_Country__c(Name='United States', ISO_Code__c = 'US', AIMS_Area_Name__c = 'UNITED STATES', Region__C = 'Americas', VAT_Validation_Required__c = true));
        countryList.add(new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c = 'PT', AIMS_Area_Name__c = 'PORTUGAL', Region__C = 'Europe', IEC_Zip_Postal_Code_required__c = true));

		insert countryList;
    }*/

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

    public static Currency_Center_Survey__C createTypeOperation(String reportTypeId, String countryName, String countryCurrency) {

		Currency_Center_Survey__C typeOperationRecord = new Currency_Center_Survey__C(Section__c = 'Type Of Operations Record', 
    																					Country_Name__c = countryName,
    																					Currency__c = countryCurrency,
    																					Parent_Id__c = reportTypeId);
    	return typeOperationRecord;
    }

    /*
		Purpose:  test survey load                                                         
		Parameters: none 
		Returns:  none
		Throws: none                                                      
	*/
    public static testMethod void testSurvey(){

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = portalSetup();		
				System.runAs(user1){

					//insert the annual survey
					Currency_Center_Survey__C parent = createParentSurvey(user1.Contact.AccountId);
					insert parent;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					System.assertEquals(parent.Section__c, annualSurvey.parentQueryResult.Section__c);
					System.assertEquals(parent.Survey__c, annualSurvey.parentQueryResult.Survey__c);
					System.assertEquals(parent.Year_Survey__c, annualSurvey.parentQueryResult.Year_Survey__c);
					System.assertEquals(parent.Airline__c, annualSurvey.parentQueryResult.Airline__c);
					
				}
			}
		Test.StopTest();
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

					//insert the other country of concern survey
					Currency_Center_Survey__C otherCountryConcern = createOtherCountryConcern(parent.Id, country.Country_Name__c);
					insert otherCountryConcern;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the bank survey
					Currency_Center_Survey__C bank = createBank(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert bank;

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();

					//verify if the values are correct or loaded
					System.assertEquals(country.Country_Name__c, annualSurvey.countriesResult[0].Country_Name__c);
					System.assertEquals(country.Section__c, annualSurvey.countriesResult[0].Section__c);
					System.assertEquals(country.Country__c, annualSurvey.countriesResult[0].Country__c);
					System.assertEquals(country.Parent_Id__c, annualSurvey.countriesResult[0].Parent_Id__c);
					
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

					//insert the other country of concern survey
					Currency_Center_Survey__C otherCountryConcern = createOtherCountryConcern(parent.Id, country.Country_Name__c);
					insert otherCountryConcern;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the bank survey
					Currency_Center_Survey__C bank = createBank(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert bank;

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(country.Country_Name__c, annualSurvey.countriesResult[0].Country_Name__c);
					System.assertEquals(country.Section__c, annualSurvey.countriesResult[0].Section__c);
					System.assertEquals(country.Country__c, annualSurvey.countriesResult[0].Country__c);
					System.assertEquals(country.Parent_Id__c, annualSurvey.countriesResult[0].Parent_Id__c);
					
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

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName=France'));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.buildSurvey();
					annualSurvey.save();
					//verify if the values are correct or loaded
					//the '2' is the parent result and the other country of concern
					System.assertEquals('France', annualSurvey.wccsObjectMap.get('France').country.Country_Name__c);
					System.assertEquals('Country Record', annualSurvey.wccsObjectMap.get('France').country.Section__c);
					System.assertEquals(2, annualSurvey.wccsObjectMap.keyset().size());
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

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.deleteCountry();
					annualSurvey.save();
					//verify if the values are correct or loaded
					//the '2' is the parent result and the other country of concern
					System.assertEquals(0, annualSurvey.wccsObjectMap.keyset().size());
				}
			}
		Test.StopTest();
	}

	public static testMethod void deleteBankSurvey() {
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

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'indexBankPanel='+1+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.showPopupDeleteBankRow();
					annualSurvey.deleteRowBankMap();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(0, annualSurvey.wccsObject.bankMap.get('Blocked Amount|EUR').size());
				}
			}
		Test.StopTest();
	}

	public static testMethod void deleteTypeOperationSurvey() {
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

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(reportType.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'indexTypeOperationsPanel='+1+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.showPopupDeleteTypeOperations();
					annualSurvey.deleteRowTypeOfOperationsMap();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.debug('Luis Ferreira type ' + annualSurvey.wccsObject.typeOfOperationsMap);
					System.assertEquals(0, annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR').size());
				}
			}
		Test.StopTest();
	}

	public static testMethod void deleteOtherCountryConcernSurvey() {
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

					//insert the other country of concern survey
					Currency_Center_Survey__C otherCountryConcern = createOtherCountryConcern(parent.Id, country.Country_Name__c);
					insert otherCountryConcern;

					Country_Profile__c countryProfileSF = [SELECT Name, Currency__c FROM Country_Profile__c WHERE Name = :country.Country_Name__c LIMIT 1];

					//insert the report type survey
					Currency_Center_Survey__C reportType = createReportType(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert reportType;

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(country.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'indexCountryCommentsPanel='+1+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.showPopupDeleteCountryConcernRow();
					annualSurvey.deleteRowCountryCommentsMap();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(0, annualSurvey.countryCommentsList.size());
				}
			}
		Test.StopTest();
	}

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


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.addRowBankMap();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(1, annualSurvey.wccsObject.bankMap.get('Blocked Amount|EUR').size());
				}
			}
		Test.StopTest();
	}

	public static testMethod void addTypeOperations() {
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


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.addRowTypeOfOperationsMap();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(1, annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR').size());
				}
			}
		Test.StopTest();
	}

	public static testMethod void addOtherCountryConcern() {
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


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c+'&&'+'indexCountryCommentsPanel='+2));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.addRowCountryCommentsMap();
					annualSurvey.countryCommentsList[0].Country_Name__c = 'Portugal';
					annualSurvey.countryCommentsList[0].Country_Comments__c = 'Portugal';
					annualSurvey.addRowCountryCommentsMap();
					annualSurvey.addRowCountryCommentsMap();
					annualSurvey.showPopupDeleteCountryConcernRow();
					annualSurvey.deleteRowCountryCommentsMap();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(1, annualSurvey.countryCommentsList.size());
					System.assertEquals(true, annualSurvey.errorMessage);
					System.assertEquals('Portugal', annualSurvey.countryCommentsList[0].Country_Name__c);
				}
			}
		Test.StopTest();
	}

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


					Currency_Center_Survey__C bankRecord = new Currency_Center_Survey__C(Section__c = 'Bank Record', 
			    																			Reporting_Type__c = 'Blocked Amount', 
			    																			Country_Name__c = reportTypeRecord.Country_Name__c,
			    																			Currency__c = countryProfileSF.Currency__c,
			    																			Parent_Id__c = reportTypeRecord.Id,
			    																			Amount__c = 10,
			    																			Bank__c = bank.Id);
					insert bankRecord;


					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+countryRecord.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.calculate();
					annualSurvey.getGrandTotal();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(10, annualSurvey.wccsObject.typeReportMap.get('Blocked Amount|EUR').Total_Currency__c);
				}
			}
		Test.StopTest();
	}

	public static testMethod void IccsCalculationTest() {
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
					System.debug('Anydatatype_msg reportType ' + reportType);
					insert reportType;

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(reportType.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[0].Type_of_Operations__c = 'CASS';
					annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[0].Type_Of_Operations_Percentage__c = 50;
					annualSurvey.addRowTypeOfOperationsMap();
					annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[1].Type_of_Operations__c = 'ICCS';
					annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[1].Type_Of_Operations_Percentage__c = 50;
					annualSurvey.iccsAutoComplete();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals('CASS', annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[0].Type_of_Operations__c);
					System.assertEquals(50, annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[0].Type_Of_Operations_Percentage__c);
					System.assertEquals('ICCS', annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[1].Type_of_Operations__c);
					System.assertEquals(50, annualSurvey.wccsObject.typeOfOperationsMap.get('Blocked Amount|EUR')[1].Type_Of_Operations_Percentage__c);
					System.assertEquals('50', annualSurvey.wccsObject.typeReportMap.get('Blocked Amount|EUR').ICCS__c);
				}
			}
		Test.StopTest();
	}

	public static testMethod void reloadSelectListTest() {
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
					System.debug('Anydatatype_msg reportType ' + reportType);
					insert reportType;

					Financial_Institution__c bank = new Financial_Institution__c(Name = 'Novo Banco', 
																					Region__c = 'Europe', 
																					Country__c = reportType.Country_Name__c, 
																					Institution_Type__c = 'Bank');
					insert bank;

					//insert the type of Operation survey
					Currency_Center_Survey__C typeOperation = createTypeOperation(reportType.Id, countryProfileSF.Name, countryProfileSF.Currency__c);
					insert typeOperation;

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+country.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.getCountriesList();
					annualSurvey.getSalesFundsAwaiting();
					annualSurvey.getTypeOperations();
					annualSurvey.getBankOptions();
					annualSurvey.save();
					//verify if the values are correct or loaded
					System.assertEquals(2, annualSurvey.getCountriesList().size());
					System.assertEquals(2, annualSurvey.getSalesFundsAwaiting().size());
					System.assertEquals(5, annualSurvey.getTypeOperations().size());
					System.assertEquals(2, annualSurvey.getBankOptions().size());
				}
			}
		Test.StopTest();
	}

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

					Test.setCurrentPageReference(new PageReference('https://ccf2-customer-portal-iata.cs106.force.com/ISSP_CurrencyCenterAnnualSurvey?id='+parent.Id+'&&'+'countryName='+countryRecord.Country_Name__c));
					ISSP_CurrencyCenterAnnualSurveyCtrl annualSurvey = new ISSP_CurrencyCenterAnnualSurveyCtrl();
					annualSurvey.loadAll();
					annualSurvey.countryObject();
					annualSurvey.submit();
					//verify if the values are correct or loaded
					System.assertEquals(false, annualSurvey.errorMessage);
					System.assertEquals('Submitted', annualSurvey.parentQueryResult.Status__c);
				}
			}
		Test.StopTest();
	}
}