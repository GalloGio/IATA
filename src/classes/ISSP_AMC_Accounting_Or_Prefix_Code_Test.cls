/*
    Class Name: ISSP_AMC_Accounting_Or_Prefix_Code_Test
    Related Classes: ISSP_AMC_Accounting_Or_Prefix_Code

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Accounting_Or_Prefix_Code

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    06-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Accounting_Or_Prefix_Code_Test {
	
	/*
		Purpose: Submit an empty Participation with no Operation selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNoParticipationWithSubmit(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Accounting_Or_Prefix_Code'));
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Submit an empty Participation with Type of Operation SCHEDULED_PASSENGER selected
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testScheduledPassenger(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					System.assertNotEquals(testCountry ,null);
					System.assertNotEquals(testSalutation ,null);
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
					controller.showMessages();

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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller);
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller);
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();

					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code(); 
					controller.step = '1';
					controller.saveParticipation();
					//ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller); Too many SOQL Queries 101
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					//ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller); Too many SOQL Queries 101
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller);
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();

					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller);
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller);
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = 'Submit';
					controller.saveParticipation();
					
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
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Accounting_Or_Prefix_Code;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY).Id);
					ISSP_AMC_Accounting_Or_Prefix_Code controller = new ISSP_AMC_Accounting_Or_Prefix_Code();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testAccountingPrefixUploadFiles(controller);
					
				}
			}
		Test.StopTest();
	}

}