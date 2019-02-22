/*
    Class Name: ISSP_AMC_Apply_New_Code_Test
    Related Classes: ISSP_AMC_Apply_New_Code

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Apply_New_Code

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    06-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Apply_New_Code_Test {

	/*
		Purpose: Requests a new participation form for the Baggage Tag Range Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testBaggageNoParticipation(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef);
					ISSP_AMC_Apply_New_Code controller = new ISSP_AMC_Apply_New_Code();
					controller.navigateBaggageTagRange();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Requests a used participation form for the Baggage Tag Range Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testBaggage(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Baggage_Tag_Range'));
					ISSP_AMC_Baggage_Tag_Range controller = new ISSP_AMC_Baggage_Tag_Range();
					controller.step = 'Submit';
					controller.saveParticipation();	
					controller.selectedOperationType  = 'Baggage Tag Range Test';

					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateBaggageTagRange();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Tries to request a Baggage Tag Range Code with a case already submitted.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testBaggageCaseSubmitted(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Baggage_Tag_Range'));
					ISSP_AMC_Baggage_Tag_Range controller = new ISSP_AMC_Baggage_Tag_Range();
					controller.step = 'Submit';
					controller.saveParticipation();	
					controller.selectedOperationType  = 'Baggage Tag Range Test';
					Case parCase = [SELECT Status From Case WHERE Id= :controller.participation.case__c];
					parCase.status = 'Submitted';
					upsert parCase;

					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateBaggageTagRange();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Requests a new participation form for the Location Identifier Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testLocationNoParticipation(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef);
					ISSP_AMC_Apply_New_Code controller = new ISSP_AMC_Apply_New_Code();
					controller.navigateLocationIdentifier();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Requests a used participation form for the Location Identifier Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testLocation(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Location_Identifier'));
					ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
					controller.step = 'Submit';
					controller.saveParticipation();	


					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateLocationIdentifier();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Tries to request a Location Identifier Code with a case already submitted.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testLocationCaseSubmitted(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Location_Identifier'));
					ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
					controller.step = 'Submit';
					controller.saveParticipation();	
					Case parCase = [SELECT Status From Case WHERE Id= :controller.participation.case__c];
					parCase.status = 'Submitted';
					upsert parCase;
					Test.StartTest();
					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateLocationIdentifier();
					Test.StopTest();
				}
			}
		
	}

	/*
		Purpose: Requests a new participation form for the Accouting or Prefix Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testAccountingPrefixNoParticipation(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef);
					ISSP_AMC_Apply_New_Code controller = new ISSP_AMC_Apply_New_Code();
					controller.navigateAccountingOrPrefixCode();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Requests a used participation form for the Accouting or Prefix Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testAccountingPrefix(){

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


					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateAccountingOrPrefixCode();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Tries to request a Accounting or Prefix Code with a case already submitted.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testAccountingPrefixCaseSubmitted(){

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
					Case parCase = [SELECT Status From Case WHERE Id= :controller.participation.case__c];
					parCase.status = 'Submitted';
					upsert parCase;

					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateAccountingOrPrefixCode();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Requests a new participation form for the Airline Designator Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testDesignatorsNoParticipation(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef);
					ISSP_AMC_Apply_New_Code controller = new ISSP_AMC_Apply_New_Code();
					controller.navigateAirlineDesignators();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Requests a used participation form for the Airline Designator Code
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testDesignators(){

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
					controller.step = 'Submit';
					controller.saveParticipation();	


					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateAirlineDesignators();
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Tries to request a Airline Designator Code with a case already submitted.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testDesignatorsCaseSubmitted(){

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
					controller.step = 'Submit';
					controller.saveParticipation();	
					Case parCase = [SELECT Status From Case WHERE Id= :controller.participation.case__c];
					parCase.status = 'Submitted';
					upsert parCase;

					PageReference pageRef1 = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef1);
					ISSP_AMC_Apply_New_Code ctrl = new ISSP_AMC_Apply_New_Code();
					ctrl.navigateAirlineDesignators();
				}
			}
		Test.StopTest();
	}
}