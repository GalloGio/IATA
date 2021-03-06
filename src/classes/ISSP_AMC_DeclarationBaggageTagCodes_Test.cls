/*
	Class Name: ISSP_AMC_DeclarationBaggageTagCodes_Test
	Related Classes: ISSP_AMC_DeclarationBaggageTagCodes

	Copyright @Right IT Services

	Purpose: Test Class for ISSP_AMC_DeclarationBaggageTagCodes

	VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
	1.0         DAVID BENTO & TIAGO MENDES    07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_DeclarationBaggageTagCodes_Test {

	/*
		Purpose: Runs ISSP_AMC_DeclarationBaggageTagCodes as a portal user and gets its participation.
		Parameters:
		Returns:
		Throws [Exceptions]:
	*/
	public static testMethod void testDeclarationBaggageTagCodes(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
		ISSP_AMC_ParticipationFactory.createBaggageParticipation('testName', true, true, true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];



		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();
				System.runAs(user1){
					ISSP_AMC_DeclarationBaggageTagCodes controller = new ISSP_AMC_DeclarationBaggageTagCodes();
					Participation_Online_Application__c testParticipation = controller.controllerParticipation;
				}
			}
		Test.StopTest();
	}
}
