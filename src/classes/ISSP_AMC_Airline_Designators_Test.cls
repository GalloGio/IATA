/*
    Class Name: ISSP_AMC_Airline_Designators_Test
    Related Classes: ISSP_AMC_Airline_Designators

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Airline_Designators

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    06-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Airline_Designators_Test {

	/*
		Purpose: Submit an empty Participation with no Operation selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNoParticipationWithSubmit(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Airline_Designators'));
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();

					ISSP_AMC_Upload_Files uploadFiles = new ISSP_AMC_Upload_Files();
					uploadFiles.getUploadedFileInfo();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Saves an Empty Participation with Account SIS_Status__c!= ACtive
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testNoParticipationNoSIS() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetupNoSIS();

			Account acc = [SELECT id, Name,
                                    Airline_Code__c, 
                                    Baggage_Tag_Range_Code__c,
                                    Airline_designator__c,
                                    Accounting_Code__c,
                                    Airline_Prefix__c,
                                    AOC_Expiry_Date__c,
                                    Legal_name__c,
                                    TradeName__c,
                                    Sector__c,
                                    Category__c,
                                    IATA_ISO_Country__r.Name,
                                    Region_formula__c,
                                    Phone,
                                    Email__c,
                                    Website,
                                    ShippingStreet,
                                    ShippingAddress,
                                    ShippingCity,
                                    ShippingState,
                                    ShippingPostalCode,
                                    ShippingCountry,
                                    IATA_ISO_Country__c,
                                    SIS_Status__c
                            FROM account
                            
                            LIMIT 1];
				acc.SIS_Status__c = 'Terminated';
				update acc;

			System.runAs(portalUser){

				System.debug('SIS_Status__c '+ISSP_AMC_DAO.getAccountInfo().SIS_Status__c);
				Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Airline_Designators'));
				ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
				controller.init();
				controller.Participation.AOC_Scheduled_Passenger__c = true;
				controller.CalculateWhichComponentsToShowWithCases();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = '1';
				controller.saveParticipation();


				//ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation SCHEDULED_PASSENGER selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testScheduledPassenger(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		//ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}
	
	
	/*
		Purpose: Save a Participation with Type of Operation SCHEDULED_PASSENGER selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testScheduledPassengerWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation SCHEDULED_CARGO selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testScheduledCargo(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		//ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation SCHEDULED_CARGO selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testScheduledCargoWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation Nom SCHEDULED_PASSENGER selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNonScheduledPassenger(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation Non SCHEDULED_PASSENGER selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNonScheduledPassengerWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation Non Scheduled Cargo selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNonScheduledCargo(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation Non Scheduled Cargo selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNonScheduledCargoWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation Ferry Company selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testFerry(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation Ferry Company selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testFerryWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation CRS selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testCRS(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation CRS selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testCRSWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation ULD selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testULD(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_ULD).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation ULD selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testULDWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_ULD).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation Bus Company selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testBus(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation Bus Company selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testBusWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation Railway Company selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testRailway(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Save a Participation with Type of Operation Railway Company selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testRailwayWithParticipationID(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY).Id);
					ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
					controller.step = '1';
					controller.saveParticipation();
					controller.init();
					ISSP_AMC_ParticipationFactory.testDesignatorUploadFiles(controller);
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

}