/*
    Class Name: ISSP_AMC_CaseTriggerHelper_Test
    Related Classes: ISSP_AMC_CaseTriggerHelper
    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_CaseTriggerHelper

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         TIAGO MENDES    				04-03-2018          INITIAL DEVELOPMENT
*/

@isTest
public class ISSP_AMC_CaseTriggerHelper_Test {
	

	public static testMethod void testCaseTriggerHelper(){

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		GlobalCaseTrigger__c gct = new GlobalCaseTrigger__c(Name = 'ISSP_AMC_CaseTriggerHelper', ON_OFF__c = true);
		IATA_Process_Orchestrator__c orchestrator = new IATA_Process_Orchestrator__c();
		orchestrator.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name='Orchestrator'][0].Id;
		
		User myOtherUser = [select Id from User WHERE Profile.Name = 'Developer' AND IsActive = true LIMIT 1];
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
		Test.StartTest();
			System.runAs(myOtherUser){
				Database.insert(orchestrator);
				Case testCase = new Case(
								RecordTypeId = [SELECT Id,Name FROM RecordType WHERE DeveloperName='Airline_Coding_Application'][0].Id,
								Region__c = 'China & North Asia',
								BSPCountry__c = 'China',
								Status = 'Open',
								Origin = 'asd',
								CaseArea__c = 'Accreditation',
								Reason1__c = '3 Digit Form',
								Coding_Application_ID__c = null,
								Coding_Application_Status__c = null,
								Coding_Application_Reception_Date__c = null,
								Subject = 'cs1',
								OwnerId = myOtherUser.id);
				Database.insert(testCase);
				orchestrator.Associated_Case__c = testCase.id;
				Database.update(orchestrator);
				testCase.OwnerId = myUser.Id;
				Database.update(testCase);
			}
		Test.StopTest();
	}
}