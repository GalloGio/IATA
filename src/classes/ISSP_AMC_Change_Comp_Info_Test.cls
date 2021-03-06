/*
	Class Name: ISSP_AMC_Change_Comp_Info_Test
	Related Classes: ISSP_AMC_Change_Comp_Info

	Copyright @Right IT Services

	Purpose:

	VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
	1.0         DAVID BENTO & TIAGO MENDES    07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Change_Comp_Info_Test {

	public static testMethod void testAccountNoInfo(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();
				System.runAs(user1){
					ISSP_AMC_Change_Comp_Info controller = new ISSP_AMC_Change_Comp_Info();
					controller.getAccountInfo();
					controller.createCase();
					controller.clearMessage();
				}
			}
		Test.StopTest();
	}
}
