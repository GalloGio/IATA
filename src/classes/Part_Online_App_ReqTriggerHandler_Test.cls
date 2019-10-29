/*
	Class Name: Part_Online_App_ReqTriggerHandler_Test
	Related Trigger: Part_Online_App_ReqTriggerHandler

	Copyright @Right IT Services

	Purpose: Trigger handler for the Participant_Online_App_Requirement__c object 

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	João Ferreira		2019-01-14   	INITIAL DEVELOPMENT
 	2.0		  	Tiago Mendes		2019-03-05   	INITIAL DEVELOPMENT
*/
@isTest
private class Part_Online_App_ReqTriggerHandler_Test{


	@isTest
	static void testMethod1()
	{	
		
		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		List <Participation_Application_Requirement__c> testPar = ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
		Participation_Online_Application__c testPoa = ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
		List<Participant_Online_App_Requirement__c> junctionToDelete = new List<Participant_Online_App_Requirement__c>();
		Case case1 = new Case(
                              Region__c = 'China & North Asia',
                              BSPCountry__c = 'China',
                              Status = 'Open',
                              Origin = 'asd',
                              CaseArea__c = 'Accreditation',
                              Reason1__c = '3 Digit Form',
                              Coding_Application_ID__c = null,
                              Coding_Application_Status__c = null,
                              Coding_Application_Reception_Date__c = null,
                              Subject = 'case1');
        insert case1;

        WrapperAttachTest.loadTestCredentials();
        AmazonFile__C AmzFile = new AmazonFile__C(name ='file',Full_Name_Unique__c = 'test name', case__c = case1.id, Category__c = 'Contractual', Subcategory__c = 'Signatory Authority');
        insert AmzFile;

		System.runAs(myUser)
		{
			User user1 = ISSP_AMC_ParticipationFactory.portalSetup();

			AmzFile.OwnerId = user1.Id;
			update AmzFile;

			System.runAs(user1){
				
				PageReference pageRef = Page.ISSP_AMC_Airline_Designators;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER).Id);
				ISSP_AMC_Airline_Designators controller = new ISSP_AMC_Airline_Designators();
				controller.step = '1';
				controller.saveParticipation();
				
				Participant_Online_App_Requirement__c formToDelete1 = new Participant_Online_App_Requirement__c (
					Participation_Application_Requirement__c = testPar[0].Id,
					Participation_Online_Application__c = controller.participation.Id,
					AmazonFile__c = AmzFile.id
					);
				Participant_Online_App_Requirement__c formToDelete2= new Participant_Online_App_Requirement__c (
					Participation_Application_Requirement__c = testPar[1].Id,
					Participation_Online_Application__c = controller.participation.Id
					);
				Participant_Online_App_Requirement__c formToDelete3 = new Participant_Online_App_Requirement__c (
					Participation_Application_Requirement__c = testPar[6].Id,
					Participation_Online_Application__c = controller.participation.Id
					);
				
				junctionToDelete.add(formToDelete1);
				junctionToDelete.add(formToDelete2);
				junctionToDelete.add(formToDelete3);
				
				Test.StartTest();
				
				controller.participation.AOC_Non_Scheduled_Passenger__c = true;
				controller.participation.AOC_Scheduled_Passenger__c = false;

				controller.step = '1';
				controller.saveParticipation();

				controller.step = 'Submit';
				controller.saveParticipation();
				Part_Online_App_ReqTriggerHandler.handleBeforeDelete(junctionToDelete);
				Part_Online_App_ReqTriggerHandler.handleAfterDelete(junctionToDelete);
				
				Test.StopTest();
			}
		}

	}
}