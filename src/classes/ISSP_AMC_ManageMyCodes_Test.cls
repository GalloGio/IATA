/*
    Class Name: ISSP_AMC_ManageMyCodes_Test
    Related Classes: ISSP_AMC_ManageMyCodes

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_ManageMyCodes
 
    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    06-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_ManageMyCodes_Test {

	/*
        Purpose: Tries to request a Baggage Tag Range Code for the first time
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
					ISSP_AMC_ManageMyCodes controller = new ISSP_AMC_ManageMyCodes();
					controller.requestBaggageTagRange();
					controller.createCase();
					controller.clearMessage();
					controller.changeAnswer();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Submits a request for Baggage Tag Rage Code without a participation
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
					ISSP_AMC_ManageMyCodes ctrl = new ISSP_AMC_ManageMyCodes();
					ctrl.requestBaggageTagRange();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Tries to request a Baggage Tag Range code after a case for that has been submitted
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
					ISSP_AMC_ManageMyCodes ctrl = new ISSP_AMC_ManageMyCodes();
					ctrl.requestBaggageTagRange();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Tries to request a Accounting or Prefix Code for the first time
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
					ISSP_AMC_ManageMyCodes controller = new ISSP_AMC_ManageMyCodes();
					controller.requestAccountingOrPrefixCode();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Submits a request for Accouting or Prefix Code without a participation
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
					ISSP_AMC_ManageMyCodes ctrl = new ISSP_AMC_ManageMyCodes();
					ctrl.requestAccountingOrPrefixCode();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Tries to request a Accounting or Prefix Code after a case for that has been submitted
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
					ISSP_AMC_ManageMyCodes ctrl = new ISSP_AMC_ManageMyCodes();
					ctrl.requestAccountingOrPrefixCode();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Tries to request a Airline Designator Code for the first time
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
					ISSP_AMC_ManageMyCodes controller = new ISSP_AMC_ManageMyCodes();
					controller.requestAirlineDesignators();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Submits a request for Airline Designator Code without a participation
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
					ISSP_AMC_ManageMyCodes ctrl = new ISSP_AMC_ManageMyCodes();
					ctrl.requestAirlineDesignators();
				}
			}
		Test.StopTest();
	}

	/*
        Purpose: Tries to request a Airline Designator code after a case for that has been submitted
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
					ISSP_AMC_ManageMyCodes ctrl = new ISSP_AMC_ManageMyCodes();
					ctrl.requestAirlineDesignators();
				}
			}
		Test.StopTest();
	}
}