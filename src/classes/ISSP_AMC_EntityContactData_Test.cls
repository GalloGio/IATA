/*
    Class Name: ISSP_AMC_EntityContactData_Test
    Related Classes: ISSP_AMC_EntityContactData

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_EntityContactData

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_EntityContactData_Test {

	/*
        Purpose: Runs ISSP_AMC_EntityContactData as a portal user and gets and changes its participation.
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	public static testMethod void testEntityContactData(){
		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		//ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser)
			{
				User user1 = ISSP_AMC_ParticipationFactory.portalSetup();		
				System.runAs(user1){
					Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Airline_Designators'));
					ISSP_AMC_Airline_Designators ctrl = new ISSP_AMC_Airline_Designators();
					ctrl.saveParticipation();
					ISSP_AMC_EntityContactData controller = new ISSP_AMC_EntityContactData();
					List <SelectOption> testCountry = controller.countryList;
					List <SelectOption> testSalutation = controller.salutationList;
					controller.controllerParticipation = new Participation_Online_Application__c();
					controller.controllerParticipation.HOC_Email__c = 't@t.pt';
					controller.controllerParticipation.HOC_First_Name__c = 'Test';
					controller.controllerParticipation.HOC_Last_Name__c = 'McTest';
					controller.controllerParticipation.HOC_Phone__c = '123456789';
					controller.controllerParticipation.HOC_Salutation__c = 'Mr';
					controller.controllerParticipation.HOC_Title__c = 'Manager';
					upsert controller.controllerParticipation;
					controller.contactList = [SELECT 
												id, Name, FirstName, LastName, Email, Fax, Phone, Salutation, Title
								        	FROM 
								        		Contact
								            WHERE 
								            	Id = :user1.contactId
											];
					controller.currentContactId = String.valueOf(controller.contactList[0].Id);
					
					controller.selectHocContact();
					controller.selectHobContact();
					controller.addMeToHeadOfficeContact();
					controller.searchBillingContact();
					controller.searchHeadOfficeContact();
					controller.addMeToBillingContact();
					//controller.fillDefaultParticipationData();
				}
			}
		Test.StopTest();
	}
}