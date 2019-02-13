/*
    Class Name: ISSP_AMC_Application_And_Changes_Test
    Related Classes: ISSP_AMC_Application_And_Changes

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Application_And_Changes

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Application_And_Changes_Test {

	/*
		Purpose: Runs ISSP_AMC_Application_And_Changes as a portal user.
		Parameters: 
		Returns:
		Throws [Exceptions]: 
	*/
	public static testMethod void testApplicationAndChanges(){

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
					ISSP_AMC_Application_And_Changes controller = new ISSP_AMC_Application_And_Changes();
				}
			}
		Test.StopTest();
	}
}