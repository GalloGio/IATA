/*
	Class Name: ISSP_AMC_Integration_Test
	Related Classes:

	Copyright @Right IT Services

	Purpose: Class with logic to handle Integration Layer with ACLI (SAP) via Mulesoft

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Manuel Conde		09-01-2019   	INITIAL DEVELOPMENT
*/
@isTest
private class ISSP_AMC_Integration_Test {


    //@isTest static void test_method_PositiveSimple() {

        /*List<ISSP_AMC_Integration.ACLIForm> myList = new List<ISSP_AMC_Integration.ACLIForm>();
        List<Case> caseList = new List<Case>();*/

        /*for(Integer i = 0; i<10; i++) {
            ISSP_AMC_Integration.ACLIForm aForm = new ISSP_AMC_Integration.ACLIForm();

            aForm.RecordType = 'Accounting_or_Prefix_Code';
            aForm.Accounting_Code_Airline_Prefix_Purpose = 'Accounting Code & Airline Prefix Code';
            //aForm.Baggage_Reason_For_Use_1 = '';
            aForm.Authorized_areas_of_operations = '';
            //aForm.Baggage_Reason_For_Use_2 = '';
            //aForm.Baggage_Reason_For_Use_3 = '';
            //aForm.Baggage_Reason_For_Use_4 = '';
            //aForm.Baggage_Reason_For_Use_5 = '';
            aForm.Billing_City = 'Madrid';
            aForm.Billing_Country = 'Spain';
            aForm.Billing_Postal_Zip_code = 'ADSA1';
            aForm.Billing_State_Province = 'Madrid';
            aForm.Billing_Street_address_1 = 'Paseo de la castellana';
            aForm.Billing_VAT = '3232323';
            aForm.City_Name = '';
            aForm.Date_when_airport_has_been_operational = '';
            aForm.Does_Metropolitan_area_currently_exists = '';
            aForm.Does_the_airline_presently_hold_a_three = '';
            aForm.GPS_Coordinates = '';
            aForm.HQ_City = '';
            aForm.HQ_Country = '';
            aForm.HQ_Postal_Zip_code = '';
            aForm.HQ_State_Province = '';
            aForm.HQ_Street_address_1 = '';
            aForm.HQ_VAT = '';
            aForm.Has_airline_assigned_two_char_code = '';
            aForm.Has_company_assigned_numeric_code = '';
            aForm.Has_the_company_published_their_schedule = '';
            aForm.IATA_ISO_Country = '';
            aForm.ICAO_Code = '';
            aForm.Is_ULD_participation_IATA_program = '';
            aForm.Legal_Name = '';
            aForm.Location_Code_1 = '';
            aForm.Location_Code_2 = '';
            aForm.Location_Code = '';
            aForm.Location_Name = '';
            aForm.Name_of_Organization = '';
            aForm.Off_Line_Point_Purpose = '';
            aForm.Preference_of_Code_1 = '';
            aForm.Preference_of_Code_2 = '';
            aForm.Preference_of_Code_3 = '';
            aForm.Previously_assigned_IATA_code = '';
            aForm.Previously_assigned_numeric_code = '';
            aForm.Recommended_Loc_Identifier = '';
            aForm.State = '';
            aForm.Time_Zone = '';
            aForm.X1_other_airlines_in_the_airport = '';
            aForm.X2_other_airlines_in_the_airport = '';
            aForm.X3_other_airlines_in_the_airport = '';

            myList.add(aForm);
        }*/
        //ISSP_AMC_Integration.doPost(myList);

        /*case receivedCase = createCase();

        caseList.add(receivedCase);

        ISSP_AMC_Integration.doPost(caseList);*/
    //}

    @IsTest
    static void TestSendHttpRequest(){
        ISSP_AMC_Integration.ACLIResponse acli = new ISSP_AMC_Integration.ACLIResponse();

        acli.isSuccess = false;
        acli.errorCode = '';
        acli.errorDescription = '';
        acli.status = '';
        acli.requestId = '';
        acli.caseNumber = '';
        String resp = JSON.serializePretty(acli);

        ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(200,
                                                 'Complete',
                                                 resp,
                                                 null);

        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        
        HttpResponse response = ISSP_AMC_Integration.sendRequest(resp);
        //HttpResponse responseWithHeaderAutho = restWithHeaderAutho.sendHttpRequest();
        Test.stopTest();

        //System.assert(response.getStatusCode()==200);
        //System.assert(response.getBody().equals(resp));
        //System.assert(responseWithHeaderAutho.getStatusCode()==200);

    }


    @IsTest
    static void applicationInfoMapping_Test(){
        List<Case> caseTesList = new List<Case>();
        Participation_Online_Application__c apllicationTest = createApplication();
        Case caseTest = new Case();
        insert caseTesList;
        apllicationTest.Case__c = caseTest.Id;
        caseTesList.add(caseTest);

        Test.startTest();
        ISSP_AMC_Integration.applicationInfoMapping(caseTesList);
        Test.stopTest();

        Participation_Online_Application__c app = [select id, Case__c, Billing_City__c
                FROM Participation_Online_Application__c WHERE Case__c =: caseTest.Id];

        System.assertEquals(app.Billing_City__c, 'Madrid');
    }

    @IsTest
    static Participation_Online_Application__c createApplication() {
        Participation_Online_Application__c pApply = new Participation_Online_Application__c();
        pApply.Billing_City__c = 'Madrid';
        pApply.Billing_Country__c = 'Spain';
        pApply.Billing_Postal_Zip_code__c = 'ADSA1';
        pApply.Billing_State_Province__c = 'Madrid';
        pApply.Billing_Street_address_1__c = 'Paseo de la castellana';
        pApply.Billing_VAT__c = '3232323';

        insert pApply;
        return pApply;
    }

    @IsTest
    static Case createCase() {
        Case tCase = new Case();
        //tCase.IATA_Code__c = 'TP PT';
        tCase.BSPCountry__c = 'Portugal';
        tCase.Case_Creator_Email__c = 'test@gmail.com';

        insert tCase;
        return tCase;
    }


    @IsTest
    static void testWithParticipationSaveAirport() {

        ISSP_AMC_ParticipationFactory.createcustomSetting(true);
        ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
        
        //ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false);
        
        
        User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        Test.StartTest(); 
            System.runAs(myUser){

            User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

            System.runAs(portalUser){



                PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
                Test.setCurrentPageReference(pageRef);
                pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false).Id);
                ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
                controller.init();
                controller.step = '1';

                controller.saveParticipation();

                Case caseACLI = [SELECT Id FROM Case WHERE Id=:controller.participation.case__c];

                List<Case> caseList = new List<Case>();
                caseList.add(caseACLI);
                ISSP_AMC_Integration.doPost(caseList);
                ISSP_AMC_Integration.ACLIForm acliform = new ISSP_AMC_Integration.ACLIForm();
                Boolean test = acliform.AOC_Non_Scheduled_Passenger;

            }

            Test.stopTest();

        }
    }
}