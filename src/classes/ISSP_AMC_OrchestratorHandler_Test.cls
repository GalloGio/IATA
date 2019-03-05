@isTest
public class ISSP_AMC_OrchestratorHandler_Test {

	@isTest static void testOrchestrator() {

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
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				//orchestrator.Process_Step_Name__c = 'TESTE 1';
				insert orchestrator;

				IATA_Process_Orchestrator__c orchestratorSon = createOrchSon(controller, orchestrator);

				IATA_Process_Orchestrator_Step_Action__c action = createActionpOrch(orchestratorSon,'Completed');


				List<IATA_Process_Orchestrator__c> oneOrchestratorList = [SELECT Status__c, IATA_Orchestrator_Process__r.Overall_Status__c, IATA_Orchestrator_Process__c
																		  FROM IATA_Process_Orchestrator__c 
																		  WHERE id =: orchestrator.Id];


				Test.stopTest();

				/*Test.startTest();
				action2.Status__c = 'Fail';
				update action2;
				Test.stopTest();

				System.assertEquals(oneOrchestrator.IATA_Orchestrator_Process__r.Overall_Status__c, 'Fail');*/
			}
		}
	}

	@isTest static void testOrchestratorSec() {

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
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				//orchestrator.Process_Step_Name__c = 'TESTE 1';
				insert orchestrator;

				IATA_Process_Orchestrator__c orchestratorSon = createOrchSon(controller, orchestrator);

				//IATA_Process_Orchestrator_Step_Action__c action = createActionpOrch(orchestratorSon,'Completed');
				//actionList.add(action);

				//IATA_Process_Orchestrator_Step_Action__c action2 = createActionpOrch(orchestratorSon,'Pending Customer');

				//IATA_Process_Orchestrator_Step_Action__c action3 = createActionpOrch(orchestratorSon,'Fail');

				IATA_Process_Orchestrator_Step_Action__c action4 = createActionpOrch(orchestratorSon,'Progressing');

				//IATA_Process_Orchestrator_Step_Action__c action5 = createActionpOrch(orchestratorSon,'Not Applicable');


				List<IATA_Process_Orchestrator__c> oneOrchestratorList = [SELECT Status__c, IATA_Orchestrator_Process__r.Overall_Status__c, IATA_Orchestrator_Process__c
						FROM IATA_Process_Orchestrator__c
						WHERE id =: orchestrator.Id];


				Test.stopTest();

				/*Test.startTest();
				action2.Status__c = 'Fail';
				update action2;
				Test.stopTest();

				System.assertEquals(oneOrchestrator.IATA_Orchestrator_Process__r.Overall_Status__c, 'Fail');*/
			}
		}
	}

	@isTest static void testOrchestratorT() {

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
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				//orchestrator.Process_Step_Name__c = 'TESTE 1';
				insert orchestrator;

				IATA_Process_Orchestrator__c orchestratorSon = createOrchSon(controller, orchestrator);

				//IATA_Process_Orchestrator_Step_Action__c action = createActionpOrch(orchestratorSon,'Completed');
				//actionList.add(action);

				//IATA_Process_Orchestrator_Step_Action__c action2 = createActionpOrch(orchestratorSon,'Pending Customer');

				//IATA_Process_Orchestrator_Step_Action__c action3 = createActionpOrch(orchestratorSon,'Fail');

				IATA_Process_Orchestrator_Step_Action__c action4 = createActionpOrch(orchestratorSon,'Pending Customer');

				//IATA_Process_Orchestrator_Step_Action__c action5 = createActionpOrch(orchestratorSon,'Not Applicable');


				List<IATA_Process_Orchestrator__c> oneOrchestratorList = [SELECT Status__c, IATA_Orchestrator_Process__r.Overall_Status__c, IATA_Orchestrator_Process__c
						FROM IATA_Process_Orchestrator__c
						WHERE id =: orchestrator.Id];


				Test.stopTest();

				/*Test.startTest();
				action2.Status__c = 'Fail';
				update action2;
				Test.stopTest();

				System.assertEquals(oneOrchestrator.IATA_Orchestrator_Process__r.Overall_Status__c, 'Fail');*/
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
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				//orchestrator.Process_Step_Name__c = 'TESTE 1';
				insert orchestrator;

				IATA_Process_Orchestrator__c orchestratorSon = createOrchSon(controller, orchestrator);

				IATA_Process_Orchestrator_Step_Action__c action3 = createActionpOrch(orchestratorSon,'Fail');

				List<IATA_Process_Orchestrator__c> oneOrchestratorList = [SELECT Status__c, IATA_Orchestrator_Process__r.Overall_Status__c, IATA_Orchestrator_Process__c
						FROM IATA_Process_Orchestrator__c
						WHERE id =: orchestrator.Id];


				Test.stopTest();

				/*Test.startTest();
				action2.Status__c = 'Fail';
				update action2;
				Test.stopTest();

				System.assertEquals(oneOrchestrator.IATA_Orchestrator_Process__r.Overall_Status__c, 'Fail');*/
			}
		}
	}

	@isTest static void testOrchestratorFF() {

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
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				//orchestrator.Process_Step_Name__c = 'TESTE 1';
				insert orchestrator;

				IATA_Process_Orchestrator__c orchestratorSon = createOrchSon(controller, orchestrator);

				IATA_Process_Orchestrator_Step_Action__c action5 = createActionpOrch(orchestratorSon,'Not Applicable');


				List<IATA_Process_Orchestrator__c> oneOrchestratorList = [SELECT Status__c, IATA_Orchestrator_Process__r.Overall_Status__c, IATA_Orchestrator_Process__c
						FROM IATA_Process_Orchestrator__c
						WHERE id =: orchestrator.Id];


				Test.stopTest();

				/*Test.startTest();
				action2.Status__c = 'Fail';
				update action2;
				Test.stopTest();

				System.assertEquals(oneOrchestrator.IATA_Orchestrator_Process__r.Overall_Status__c, 'Fail');*/
			}
		}
	}

	@isTest static void testOrchestratorSS() {

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
				pageRef.getParameters().put('participationId',
						ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true,
								'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = 'Submit';
				controller.saveParticipation();

				IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
				orchestrator.associated_case__c = controller.participation.case__c;
				orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
				//orchestrator.Process_Step_Name__c = 'TESTE 1';
				insert orchestrator;

				IATA_Process_Orchestrator__c orchestratorSon = createOrchSon(controller, orchestrator);

				IATA_Process_Orchestrator_Step_Action__c action5 = createActionpOrch(orchestratorSon,'Not Started');


				List<IATA_Process_Orchestrator__c> oneOrchestratorList = [SELECT Status__c, IATA_Orchestrator_Process__r.Overall_Status__c, IATA_Orchestrator_Process__c
						FROM IATA_Process_Orchestrator__c
						WHERE id =: orchestrator.Id];


				Test.stopTest();

				/*Test.startTest();
				action2.Status__c = 'Fail';
				update action2;
				Test.stopTest();

				System.assertEquals(oneOrchestrator.IATA_Orchestrator_Process__r.Overall_Status__c, 'Fail');*/
			}
		}
	}

	public static IATA_Process_Orchestrator_Step_Action__c createActionpOrch(IATA_Process_Orchestrator__c orch, String status) {
		IATA_Process_Orchestrator_Step_Action__c orchStepAction = new IATA_Process_Orchestrator_Step_Action__c();
		orchStepAction.Status__c = status;
		orchStepAction.IATA_Process_Orchestrator__c = orch.Id;
		orchStepAction.Action_name__c = 'Scheduled Airlines';
		insert orchStepAction;
		return orchStepAction;
	}

	public static IATA_Process_Orchestrator__c createOrchSon(ISSP_AMC_Location_Identifier controller,IATA_Process_Orchestrator__c orchestrator) {
		IATA_Process_Orchestrator__c orchestratorSon = new IATA_Process_Orchestrator__c();
		orchestratorSon.associated_case__c = controller.participation.case__c;
		orchestratorSon.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='IATA Process Step'][0].Id;
		orchestratorSon.IATA_Orchestrator_Process__c = orchestrator.Id;
		orchestratorSon.Process_Step_Name__c = 'TESTE Son 1';
		insert orchestratorSon;
		return orchestratorSon;
	}
}