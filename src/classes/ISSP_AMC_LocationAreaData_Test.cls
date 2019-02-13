/*
    Class Name: ISSP_AMC_LocationAreaData_Test
    Related Classes: ISSP_AMC_LocationAreaData

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_LocationAreaData

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_LocationAreaData_Test {

	/*
        Purpose: Gets the participation for the ISSP_AMC_LocationAreaData and then changes it. Also gets various strings.
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	public static testMethod void ISSP_AMC_LocationAreaData_Test(){
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					ISSP_AMC_LocationAreaData controller = new ISSP_AMC_LocationAreaData();
					controller.controllerParticipation = new Participation_Online_Application__c();
					controller.controllerParticipation.HOC_Email__c = 't@t.pt';
					controller.controllerParticipation.HOC_First_Name__c = 'Test';
					controller.controllerParticipation.HOC_Last_Name__c = 'McTest';
					controller.controllerParticipation.HOC_Phone__c = '123456789';
					controller.controllerParticipation.HOC_Salutation__c = 'Mr';
					controller.controllerParticipation.HOC_Title__c = 'Manager';

					ISSP_CS__c testCustomSetting = new ISSP_CS__c(
						Name = 'googleMapsKey',
						Value__c = 'googleMapsKey'
						);
					insert testCustomSetting;

					String cityName = controller.cityName;
					String locationName = controller.locationName;
					String stateName = controller.stateName;
					String locationIdentifier = controller.locationIdentifier;
					String gpsCoordinates = controller.gpsCoordinates;
					String mapkey = controller.mapkey;
				}
			}
		Test.StopTest();
	}

}