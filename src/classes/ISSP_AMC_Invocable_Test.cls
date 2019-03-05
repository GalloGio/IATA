@isTest
public with sharing class ISSP_AMC_Invocable_Test {
	
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
				
				Test.StartTest(); 
					ISSP_AMC_Invocable.invokeACLICustomImpl(orchestratorList);
					ISSP_AMC_FlowDAO.getStageWithStatusMap(orchestrator.Id);
					ISSP_AMC_FlowDAO.getPicklistsFromProcessOrchestrator(orchestrator.Id,'STAGE_A');
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