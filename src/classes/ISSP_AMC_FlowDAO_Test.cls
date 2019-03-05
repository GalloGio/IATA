/*
    Class Name: ISSP_AMC_FlowDAO_Test.cls
    Related Classes: ISSP_AMC_FlowDAO.cls

    Copyright @Right IT Services

    Purpose: Test class for FlowDAO

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         Filipa Martins				    31-12-2018          INITIAL DEVELOPMENT
*/

@isTest
public with sharing class ISSP_AMC_FlowDAO_Test {

	@IsTest
	static Participation_Online_Application__c createApplication() {
		Participation_Online_Application__c pApply = new Participation_Online_Application__c();
		Id devRecordTypeId = Schema.SObjectType.Participation_Online_Application__c.getRecordTypeInfosByName().get('Baggage Code').getRecordTypeId();
		pApply.Billing_City__c = 'Madrid';
		pApply.Billing_Country__c = 'Spain';
		pApply.Billing_Postal_Zip_code__c = 'ADSA1';
		pApply.Billing_State_Province__c = 'Madrid';
		pApply.Billing_Street_address_1__c = 'Paseo de la castellana';
		pApply.Billing_VAT__c = '3232323';
		pApply.RecordTypeId = devRecordTypeId;

		Case testCase = createCase();
		pApply.case__c = testCase.Id;

		insert pApply;
		return pApply;
	}

	@IsTest
	static Case createCase() {
		Case tCase = new Case();
		//tCase.IATA_Code__c = 'TP PT';
		tCase.BSPCountry__c = 'Portugal';
		tCase.Case_Creator_Email__c = 'test@gmail.com';
		tCase.Status = ISSP_AMC_Constants.AMC_CASE_STATUS_SUBMITTED;
		tCase.Coding_Application_ID__c = 'Not Applicable';

		insert tCase;
		return tCase;
	}

	/*
	 Purpose: Disable the sync button according to a value
	 Parameters:
	 Returns:
	 Throws [Exceptions]:
	*/
	@isTest public static void disableButtonTest() {

		Participation_Online_Application__c apllicationTest = createApplication();

		Test.startTest();
		ISSP_AMC_FlowDAO.disableButton(apllicationTest.case__c);
		Test.stopTest();

		Case c = [SELECT id, Coding_Application_ID__c,
						(SELECT Id, RecordType.DeveloperName FROM Participation_Online_Applications__r)
		FROM Case];

		System.assertEquals(c.Coding_Application_ID__c, 'Not Applicable');
	}

	/*
	Purpose: Sync case to ACLI
	Parameters:
	Returns:
	Throws [Exceptions]:
	*/
	/*@isTest public static void sendCaseCtrTest() {
		ISSP_AMC_Integration.ACLIResponse acli = new ISSP_AMC_Integration.ACLIResponse();

		insert new AMC_Configuration__c(SetupOwnerId = UserInfo.getOrganizationId(),
				endpoint__c = 'https://apisbx.iata.org/acli-coding/requests',
				username__c = '9b5e2abd65ee4c8e9bff0e97bd8c4e16',
				password__c = '8ac07dac22564502AB51BfBF6f24D217');

		acli.isSuccess = false;
		acli.errorCode = '';
		acli.errorDescription = '';
		acli.status = null;
		acli.requestId = null;
		acli.OscarCase = null;
		//acli.errors = null;
		System.debug('FILIPA TESTTT ' + acli);
		String resp = JSON.serialize(acli);

		ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(400,
				'Complete',
				resp,
				null);

		Test.setMock(HttpCalloutMock.class, fakeResponse);


		Test.startTest();
		ISSP_AMC_FlowDAO.sendCaseCtr(resp);
		Test.stopTest();

		//System.assertEquals(resp, 'Error validating JSON. Error: -Invalid type Null, expected String for Prefix_Code');
	}*/

	@isTest static void testOrchestrator() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		
		System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				insert orchestrator;
				List <ID> orchestratorList = new List<ID>();
				orchestratorList.add(orchestrator.Id);
				Test.StartTest();

				ISSP_AMC_Invocable.invokeACLICustomImpl(orchestratorList);
				ISSP_AMC_FlowDAO.getStageWithStatusMap(orchestrator.Id);
				ISSP_AMC_FlowDAO.getPicklistsFromProcessOrchestrator(orchestrator.Id, 'STAGE_A');
				ISSP_AMC_FlowDAO.sendCaseCtr(controller.participation.case__c);

				//ISSP_AMC_FlowDAO.requestForApproval(controller.participation.case__c);
				ISSP_AMC_FlowDAO.createRelatedCases(controller.participation.case__c, 'STAGE_A');
				//ISSP_AMC_FlowDAO.updateStepAction(Id stepActionId, String stepStatus);


				Test.stopTest();

			}
		}
	}

	@isTest static void testOrchestratorB() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
		System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				insert orchestrator;
				List <ID> orchestratorList = new List<ID>();
				orchestratorList.add(orchestrator.Id);

				ISSP_AMC_Invocable.invokeACLICustomImpl(orchestratorList);

				//ISSP_AMC_FlowDAO.requestForApproval(controller.participation.case__c);
				ISSP_AMC_FlowDAO.createRelatedCases(controller.participation.case__c, 'STAGE B');

				ISSP_AMC_FlowDAO.loadURL();
				//ISSP_AMC_FlowDAO.apiCall();
				//ISSP_AMC_FlowDAO.updateStepAction(Id stepActionId, String stepStatus);


				Test.stopTest();

			}
		}
	}

	@isTest static void testOrchestratorC() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
		System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				insert orchestrator;
				List <ID> orchestratorList = new List<ID>();
				orchestratorList.add(orchestrator.Id);

				ISSP_AMC_Invocable.invokeACLICustomImpl(orchestratorList);

				//ISSP_AMC_FlowDAO.requestForApproval(controller.participation.case__c);
				ISSP_AMC_FlowDAO.createRelatedCases(controller.participation.case__c, 'STAGE C');



				Test.stopTest();

			}
		}
	}

	@isTest static void testOrchestratorD() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);

		User myUser = [select Id,Name from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		
		System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';

				

				controller.saveParticipation();
				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				
				insert orchestrator;
				/*orchestrator.IATA_Orchestrator_Process__c = orchestrator.Id;
				update orchestrator;*/
				List <ID> orchestratorList = new List<ID>();
				orchestratorList.add(orchestrator.Id);

				ISSP_AMC_Invocable.invokeACLICustomImpl(orchestratorList);

				
				
				/*User approvalUser = new User(
				     ProfileId = [SELECT Id FROM Profile WHERE Name = 'IDFS Distribution'].Id,
				     LastName = 'last',
				     Email = 'approvalUser@approvalUser.com',
				     Username = 'approvalUser@approvalUser.com' + System.currentTimeMillis(),
				     Alias = 'alias',
				     TimeZoneSidKey = 'America/Los_Angeles',
				     EmailEncodingKey = 'UTF-8',
				     LanguageLocaleKey = 'en_US',
				     LocaleSidKey = 'en_US',
				     License_Cost_Center__c= 'ISF005CH01'
				);
				insert approvalUser;*/

				IATA_Process_Orchestrator_Step_Action__c stepaction = new IATA_Process_Orchestrator_Step_Action__c();
				stepaction.Approvel_Process_User__c = myUser.name;
				stepaction.Action_name__c = 'STAGE D';
				stepaction.IATA_Process_Orchestrator__c = orchestrator.Id;
				insert stepaction;


				
				//ISSP_AMC_FlowDAO.getUsersCustomSettingList = new List<String>();


				Test.StartTest();

				ISSP_AMC_FlowDAO.updateStepAction(stepaction.Id, 'Completed');
				ISSP_AMC_FlowDAO.updateStepActionApprovelProcessUser(stepaction.Id, 'Cesar Gonzalez');
				ISSP_AMC_FlowDAO.createRelatedCases(controller.participation.case__c, 'STAGE D');
				//ISSP_AMC_FlowDAO.requestForApproval(orchestrator.Id, 'STAGE D');


				Test.stopTest();

			}
		}
	}

	@isTest static void testOrchestratorF() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
		System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				insert orchestrator;
				List <ID> orchestratorList = new List<ID>();
				orchestratorList.add(orchestrator.Id);

				ISSP_AMC_Invocable.invokeACLICustomImpl(orchestratorList);

				//ISSP_AMC_FlowDAO.requestForApproval(controller.participation.case__c);
				ISSP_AMC_FlowDAO.createRelatedCases(controller.participation.case__c, 'STAGE F');



				Test.stopTest();

			}
		}
	}
}