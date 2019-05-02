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

        insert new AMC_Configuration__c(SetupOwnerId = UserInfo.getOrganizationId(),
                                        endpoint__c = 'https://apisbx.iata.org/acli-coding/requests',
                                        username__c = '9b5e2abd65ee4c8e9bff0e97bd8c4e16',
                                        password__c = '8ac07dac22564502AB51BfBF6f24D217');

        acli.isSuccess = false;
        /*acli.errorCode = '';
        acli.errorDescription = '';
        acli.status = '';
        acli.requestId = null;
        acli.OscarCase = null;
        acli.errors = null;*/

        String resp = JSON.serialize(acli);

        ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(200,
                                                 'Complete',
                                                 resp,
                                                 null);

        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Participation_Online_Application__c apllicationTest = createApplication();

        Test.startTest();
        
        HttpResponse response = ISSP_AMC_Integration.sendRequest(resp,apllicationTest.case__c);
        //HttpResponse responseWithHeaderAutho = restWithHeaderAutho.sendHttpRequest();
        Test.stopTest();

        //System.assert(response.getStatusCode()==200);
        //System.assert(response.getBody().equals(resp));
        //System.assert(responseWithHeaderAutho.getStatusCode()==200);

    }


    @IsTest
    static void TestPostRequest() {
        ISSP_AMC_Integration.ACLIResponse acli = new ISSP_AMC_Integration.ACLIResponse();

        insert new AMC_Configuration__c(SetupOwnerId = UserInfo.getOrganizationId(),
                endpoint__c = 'https://apisbx.iata.org/acli-coding/requests',
                username__c = '9b5e2abd65ee4c8e9bff0e97bd8c4e16',
                password__c = '8ac07dac22564502AB51BfBF6f24D217');

        acli.isSuccess = false;
        /*acli.errorCode = '';
        acli.errorDescription = '';
        acli.status = '';
        acli.requestId = null;
        acli.OscarCase = null;
        acli.errors = null;*/

        String resp = JSON.serialize(acli);

        ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(200,
                'Complete',
                resp,
                null);

        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Participation_Online_Application__c apllicationTest = createApplication();

        Test.startTest();

        HttpResponse response = ISSP_AMC_Integration.doPost(apllicationTest.case__c);
        //HttpResponse responseWithHeaderAutho = restWithHeaderAutho.sendHttpRequest();
        Test.stopTest();

        //System.assert(response.getStatusCode()==200);
        //System.assert(response.getBody().equals(resp));
        //System.assert(responseWithHeaderAutho.getStatusCode()==200);

    }


    @IsTest
    static void applicationInfoMapping_Test(){
        Participation_Online_Application__c apllicationTest = createApplication();

        Test.startTest();
        ISSP_AMC_Integration.applicationInfoMapping(apllicationTest.case__c);
        Test.stopTest();

        Participation_Online_Application__c app = [select id, Case__c, Billing_City__c
                FROM Participation_Online_Application__c WHERE Case__c =: apllicationTest.case__c];

        System.assertEquals(app.Billing_City__c, 'Madrid');
    }

    @IsTest
    static Participation_Online_Application__c createApplication() {
        Participation_Online_Application__c pApply = new Participation_Online_Application__c();
        Id devRecordTypeId = Schema.SObjectType.Participation_Online_Application__c.getRecordTypeInfosByName().get('Designator Code').getRecordTypeId();
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

        insert tCase;
        return tCase;
    }


    //@IsTest
    //static void integrationMethods() {

        //Test.StartTest(); 
        //Test.startTest();
            /*List<Case> caseTesList = new List<Case>();
            Participation_Online_Application__c apllicationTest = createApplication();
            Case caseTest = new Case();
            //insert caseTesList;
            apllicationTest.Case__c = caseTest.Id;
            caseTest.RecordType.DeveloperName = 'Designator_Code';
            caseTest.Status = ISSP_AMC_Constants.AMC_CASE_STATUS_SUBMITTED;
            insert caseTest;*/

        /*Participation_Online_Application__c apllicationTest = createApplication();

        insert new AMC_Configuration__c(SetupOwnerId = UserInfo.getOrganizationId(),
                endpoint__c = 'https://apisbx.iata.org/acli-coding/requests',
                username__c = '9b5e2abd65ee4c8e9bff0e97bd8c4e16',
                password__c = '8ac07dac22564502AB51BfBF6f24D217');

        ISSP_AMC_Integration.doPost(apllicationTest.case__c);
            ISSP_AMC_Integration.ACLIForm acliform = new ISSP_AMC_Integration.ACLIForm();
            Boolean testIntegrationClass = acliform.AOC_Non_Scheduled_Passenger;
        Test.stopTest();
                

        //Test.stopTest();

    }*/
}