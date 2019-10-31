/*
    Class Name: ISSP_AMC_ParticipationFactory_Test.cls
    Related Classes: ISSP_AMC_ParticipationFactory.cls

    Copyright @Right IT Services

    Purpose: Test class for Participation Factory

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    31-12-2018              INITIAL DEVELOPMENT
*/
@isTest
private class ISSP_AMC_ParticipationFactory_Test {


    @isTest static void createPortalSetup() {

        ISSP_AMC_ParticipationFactory.createcustomSetting(true);
        
        User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        Test.StartTest(); 
            System.runAs(myUser){

            User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();
        }
    }


    @isTest static void testDesignatorRequirementsParticipations() {

        Test.StartTest(); 
            ISSP_AMC_ParticipationFactory.createDesignatorRequirements(true);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_ULD);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY);
            ISSP_AMC_ParticipationFactory.createDesignatorParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY);

        Test.stopTest();

        
    }

    @isTest static void testAccountingPrefixRequirementsParticipations() {

        Test.StartTest(); 
            ISSP_AMC_ParticipationFactory.createAccountingPrefixRequirements(true);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY);
            ISSP_AMC_ParticipationFactory.createAccountingPrefixParticipation('testName', true, ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY);

        Test.stopTest();
    }



    @isTest static void testLocationRequirementsParticipations() {

        Test.StartTest(); 
            ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Heliport', false);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Railway Station', false);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Bus Station', false);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Ferry Port', false);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Metropolitan Area', true);
            ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Metropolitan Area', false);
            
        Test.stopTest();
        
    }
    @isTest static void testBaggageRequirementsParticipations() {

        Test.StartTest(); 
            ISSP_AMC_ParticipationFactory.createBaggageRequirements(true);
            ISSP_AMC_ParticipationFactory.createBaggageParticipation('testName', true, true, true);
            ISSP_AMC_ParticipationFactory.createBaggageParticipation('testName', true, false, false);

        Test.stopTest();
    }

    @isTest
    static void testCaseCreationAndParticipationOnlineAppData(){
        Test.StartTest();
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

        Test.stopTest();

    }



}