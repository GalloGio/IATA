/*
    Class Name: ISSP_AMC_Baggage_Tag_Range_Test
    Related Classes: ISSP_AMC_Baggage_Tag_Range

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Baggage_Tag_Range

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    06-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Baggage_Tag_Range_Test {

	/*
		Purpose: New participation form for the Baggage Tag Range Code request with a save and no submit.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testWithParticipationNoSubmit(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
		ISSP_AMC_ParticipationFactory.createBaggageParticipation('testName', true, true, true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Baggage_Tag_Range;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createEmptyBaggageParticipation('testName', true, true, true).Id);
					ISSP_AMC_Baggage_Tag_Range controller = new ISSP_AMC_Baggage_Tag_Range();
					controller.step = '1';
					controller.saveParticipation();
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.selectedOperationType  = 'Baggage Tag Range Test';
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Empty participation form for the Baggage Tag Range Code request with a submit.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testNoParticipationNoSubmit(){

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
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.selectedOperationType  = 'Baggage Tag Range Test';
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}

	/*
		Purpose: Filled participation form for the Baggage Tag Range Code request with a submit.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testWithParticipationAndSubmit(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Baggage_Tag_Range;
					Test.setCurrentPageReference(pageRef);
					pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createBaggageParticipation('testName', true, true, true).Id);
					ISSP_AMC_Baggage_Tag_Range controller = new ISSP_AMC_Baggage_Tag_Range();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testBaggageUploadFiles(controller);
					controller.init();
					String testLanguage = controller.displayLanguage;
					String testComName = controller.communityName;
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.selectedOperationType  = 'Baggage Tag Range Test';
					controller.operationTypes = new List<SelectOption>();
					controller.isSaved = true;
				}
			}
		Test.StopTest();
	}
}