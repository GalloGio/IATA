/*
    Class Name: ISSP_AMC_Home_Test
    Related Classes: ISSP_AMC_Home

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Home

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    06-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Home_Test {

	/*
        Purpose: Runs the home page and gets 2 strings.
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	public static testMethod void testHomeStep1(){
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					PageReference pageRef = Page.ISSP_AMC_Home;
					Test.setCurrentPageReference(pageRef);
					ISSP_AMC_Home controller = new ISSP_AMC_Home();
					String cname = controller.communityName;
					String ulanguage = controller.UserLanguage;
				}
			}
		Test.StopTest();
	}
}