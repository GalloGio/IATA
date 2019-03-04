/**
 * Created by Samuel Anjos on 2019-03-01.
 */

@isTest
public class ISSP_AMC_CaseCleanUpBatchTest {

    @isTest
    static void testStaleCases() {

        String recordTypeName = 'Airline Coding Application';

        //create custom setting
        ISSP_AMC_ParticipationFactory.createcustomSetting(true);

        //create cases
        List<Case> testCaseList = new List<Case>();
        testCaseList = ISSP_AMC_ParticipationFactory.createAListOfCases(recordTypeName, 10);

        //create Participation_Online_Application__c
        List<Participation_Online_Application__c> participationOnlineApplicationsList= new List<Participation_Online_Application__c>();
        participationOnlineApplicationsList = ISSP_AMC_ParticipationFactory.createParticipationOnlineApplication(testCaseList, -90);

        //create Participation_Application_Requirement__c
        List<Participation_Application_Requirement__c> participationApplicationRequirementsList = new List<Participation_Application_Requirement__c>();
        participationApplicationRequirementsList = ISSP_AMC_ParticipationFactory.createParticipationApplicationRequirement(10);

        //create Participant_Online_App_Requirement__c
        List<Participant_Online_App_Requirement__c> participantOnlineAppRequirementsList = new List<Participant_Online_App_Requirement__c>();
        participantOnlineAppRequirementsList = ISSP_AMC_ParticipationFactory.createParticipantOnlineAppRequirement(participationOnlineApplicationsList,
                                                                    participationApplicationRequirementsList, 10);


        Test.startTest();

            ISSP_AMC_CaseCleanUpBatch cleanUpBatch = new ISSP_AMC_CaseCleanUpBatch();
            Database.executeBatch(cleanUpBatch);

        Test.stopTest();

            List<Case> batchedCaseList = [SELECT id FROM Case];
            List<Participation_Online_Application__c> batchedParticipationOnlineApplications = [SELECT Id FROM Participation_Online_Application__c ];
            List<Participant_Online_App_Requirement__c> batchedParticipantOnlineAppRequirements = [SELECT Id FROM Participant_Online_App_Requirement__c];

            System.assertEquals( 0 , batchedCaseList.size());
            System.assertEquals( 0 , batchedParticipantOnlineAppRequirements.size());
            System.assertEquals( 0 , batchedParticipationOnlineApplications.size());

    }

    @isTest
    static void testNonStaleCases() {

        String recordTypeName = 'Airline Coding Application';

        //create custom setting
        ISSP_AMC_ParticipationFactory.createcustomSetting(true);

        //create cases
        List<Case> testCaseList = new List<Case>();
        testCaseList = ISSP_AMC_ParticipationFactory.createAListOfCases(recordTypeName, 10);

        //create Participation_Online_Application__c
        List<Participation_Online_Application__c> participationOnlineApplicationsList= new List<Participation_Online_Application__c>();
        participationOnlineApplicationsList = ISSP_AMC_ParticipationFactory.createParticipationOnlineApplication(testCaseList, -10);

        //create Participation_Application_Requirement__c
        List<Participation_Application_Requirement__c> participationApplicationRequirementsList = new List<Participation_Application_Requirement__c>();
        participationApplicationRequirementsList = ISSP_AMC_ParticipationFactory.createParticipationApplicationRequirement(10);

        //create Participant_Online_App_Requirement__c
        List<Participant_Online_App_Requirement__c> participantOnlineAppRequirementsList = new List<Participant_Online_App_Requirement__c>();
        participantOnlineAppRequirementsList = ISSP_AMC_ParticipationFactory.createParticipantOnlineAppRequirement(participationOnlineApplicationsList,
                participationApplicationRequirementsList, 10);


        Test.startTest();

            ISSP_AMC_CaseCleanUpBatch cleanUpBatch = new ISSP_AMC_CaseCleanUpBatch();
            Database.executeBatch(cleanUpBatch);

        Test.stopTest();

        List<Case> batchedCaseList = [SELECT id FROM Case];
        List<Participation_Online_Application__c> batchedParticipationOnlineApplications = [SELECT Id FROM Participation_Online_Application__c ];
        List<Participant_Online_App_Requirement__c> batchedParticipantOnlineAppRequirements = [SELECT Id FROM Participant_Online_App_Requirement__c];

        System.assertEquals( 10 , batchedCaseList.size());
        System.assertEquals( 10 , batchedParticipantOnlineAppRequirements.size());
        System.assertEquals( 10 , batchedParticipationOnlineApplications.size());
    }

}