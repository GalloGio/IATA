@isTest
public class IfapToolManagerTest {

    /*

        to javier and lorenzo the test class for the trigger trgIFAPQualityIssue for the method IfapToolManager.submitCaseQualityIssuesToMFT(qualityIssueId);

    */

    public static void beforeTest() {
        insert new UtilityCS__c(name = 'ifapBatchSize', Value__c = '5');
    }


    static testMethod void UpdateCaseStatusToAssessmentCancelledNewTest() {
        beforeTest();
        CaseChildHelper.noValidationsOnTrgCAseIFAP = true;  //later I switch it to false to fully emulate production envinroment */

        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
        insert Amazon_Cred;

        list<AWSKey__c> AWS_KEYs = new list<AWSKey__c> {new AWSKey__c(name = 'aprodconf',
                    Key__c = 'asd',
                    Secret__c = 'asd',
                    IAS_configuration_name__c = 'asdas',
                    IAS_Access_Point__c = 'asd',
                    Bucket__c = 'asd',
                    AWS_ENDPOINT_URL__c = 'asd'),
                                        new AWSKey__c(name = 'adevconf' ,
                                                Key__c = 'asd',
                                                Secret__c = 'asd',
                                                IAS_configuration_name__c = 'asdas',
                                                IAS_Access_Point__c = 'asd',
                                                Bucket__c = 'asd',
                                                AWS_ENDPOINT_URL__c = 'asd')
        };

        insert AWS_KEYs;

        UtilityCS__c sup = new UtilityCS__c(name = 'Emails', value__c = 'arandomEmail@gmail.com');
        insert sup;
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse', ISO_Code__c = 'SS' );
        insert isoCountry;

        Account agent = New Account(name = 'The Agent',
                                    recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
                                    IATACode__c = '1234567' ,
                                    IATA_ISO_Country__c = isoCountry.id,
                                    Type = 'Passenger' ,
                                    Status__c = 'not in ths list'
                                                //Status__c = 'Not accreditated'
                                   );
        insert agent;

        Case testCase1 = new Case(  CaseArea__c = 'TTBS',
                                    //status = 'Agent Notified (Mail)',
                                    status = 'Quality Issue Requested',
                                    Financial_Review_Type__c = 'Annual',
                                    //Tax_Effective_Date__c = Date.valueOf('2011-08-29'),
                                    Origin = 'Other',
                                    SuppliedEmail = 'paia@iata.org',
                                    SuppliedPhone = '12456987456',
                                    Type = 'TFC update',
                                    Description = 'Testing...',
                                    Priority = '3',
                                    Subject = 'TTBS Test Case',
                                    accountId = agent.id);
        insert testCase1;

        String result;
        result = IfapToolManager.UpdateCaseStatusToAssessmentCancelledNew(testCase1.id);
        system.assertEquals('The case cannot be cancelled when the status is not Submitted', result);

        testCase1.status = 'Submitted';

        update testCase1;

        result = IfapToolManager.UpdateCaseStatusToAssessmentCancelledNew(testCase1.id);
        system.assertEquals('The case cannot be cancelled : valid agent', result);


        agent.status__c = 'Terminated';
        update agent;

        CaseChildHelper.noValidationsOnTrgCAseIFAP = false;

        result = IfapToolManager.UpdateCaseStatusToAssessmentCancelledNew(testCase1.id);
        system.assertEquals('Submitted documents by the agent: wrong filename case not submitted', result);

        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl());

        agent.status__c = 'No longer a customer';
        update agent;
        test.startTest();

        result = IfapToolManager.UpdateCaseStatusToAssessmentCancelledNew(testCase1.id);


        system.assert(result.startsWith('Error in the comunication to the financial institution:'));



        test.setMock(WebServiceMock.class, new YourWebServiceMockImpl2());

        result = IfapToolManager.UpdateCaseStatusToAssessmentCancelledNew(testCase1.id);
        test.stopTest();
        testCase1 = [select id, status from case where id = : testCase1.id];
        system.assertEquals('Submitted', testCase1.status);


    }


    //        Test.setMock(WebServiceMock.class, new ifapWebServiceMock2());

    public class YourWebServiceMockImpl implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            // Create response element from the autogenerated class.
            // Populate response element.
            // Add response element to the response parameter, as follows:

            //Map<String, WSToolmasterIfap.submitCaseCancellationToMFTResponse_element> response_map_x = new Map<String, WSToolmasterIfap.submitCaseCancellationToMFTResponse_element>();
            WSToolmasterIfap.submitCaseCancellationToMFTResponse_element respEl = new WSToolmasterIfap.submitCaseCancellationToMFTResponse_element();
            respEl.submitCaseCancellationToMFTReturn     = '{"success":false,"code":"CONF_FILE_NOT_FOUND","message":"Configuration file[fakeFile.ini] not found","response":"to what?"}';
            response.put('response_x', respEl);
        }
    }

    public class YourWebServiceMockImpl2 implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            // Create response element from the autogenerated class.
            // Populate response element.
            // Add response element to the response parameter, as follows:
            WSToolmasterIfap.submitCaseCancellationToMFTResponse_element respEl = new WSToolmasterIfap.submitCaseCancellationToMFTResponse_element();
            respEl.submitCaseCancellationToMFTReturn     = '{"success":true,"code":"CONF_FILE_NOT_FOUND","message":"Configuration file[fakeFile.ini] not found","response":"to what?"}';
            response.put('response_x', respEl);

        }
    }

    static testMethod void startMergeAllPDFForCaseTest() {
        beforeTest();
        Test.startTest();
        Test.stopTest();
    }

    static testMethod void AsyncCallsTest() {
        beforeTest();
        Test.startTest();
        IfapToolManager.startMergeAllPDFForCase( null, 'casenumber', 'outputFilename', 'xml');
        IfapToolManager.testJsonResults = '';
        IfapToolManager.mergeAndSubmitParameters( 'caseNumber', 'mergedFileName', 'xmlString');
        IfapToolManager.submitCaseQualityIssuesToMFT( 'caseNumber', 'mergedFileName', 'xmlString');
        IfapToolManager.submitCaseCancellationToMFT( 'caseNumber', 'mergedFileName', 'xmlString');
        IfapToolManager.submitPWCResultDeletions( 'json');
        IfapToolManager.submitPWCRejectionDeletions( 'json');
        Test.stopTest();
    }

    static testMethod void submitCaseCancellationToMFTTest() {
        beforeTest();
        Test.startTest();
        IfapToolManager.testJsonResults = '';
        Test.stopTest();
    }

    static testMethod void processPWCResultsTest_Error() {
        beforeTest();
        Test.startTest();
        //IfapToolManager.testJsonResults = '{"success":false,"ErrorMessage":"errorMessage", "responses": []}';
        IfapToolManager.testJsonResults = null;
        IfapToolManager.PWCResponses result = IfapToolManager.processPWCResults();
        System.assert( true, result.success == false );
        System.assert( true, result.ErrorMessage = 'errorMessage');
        Test.stopTest();
    }

    static testMethod void processPWCResultsTest_Ok() {
        beforeTest();
        Test.startTest();
        IfapToolManager.testJsonResults = '{"success":true,"ErrorMessage":"", "responses": [{"success":true,"caseNumber":"","originalFileName":"","xml":"","message":""}]}';
        IfapToolManager.PWCResponses result = IfapToolManager.processPWCResults();
        System.assert( true, result.success );
        System.assert( true, result.responses.size() == 1);
        Test.stopTest();
    }

    static testMethod void processPWCRejectionTest_Error() {
        beforeTest();
        Test.startTest();
        IfapToolManager.testJsonResults = null;
        IfapToolManager.PWCResponses result = IfapToolManager.processPWCRejections();
        System.assert( true, result.success == false );
        System.assert( true, result.ErrorMessage = 'errorMessage');
        Test.stopTest();
    }

    static testMethod void processPWCRejectionTest_Ok() {
        beforeTest();
        Test.startTest();
        IfapToolManager.testJsonResults = '{"success":true,"ErrorMessage":"", "responses": [{"success":true,"caseNumber":"","originalFileName":"","xml":"","message":""}]}';
        IfapToolManager.PWCResponses result = IfapToolManager.processPWCRejections();
        System.assert( true, result.success );
        Test.stopTest();
    }

    static testMethod void classResponseTest() {
        beforeTest();
        Test.startTest();
        String json = '{"success": true, "code": "CODE","response":"RESPONSE"}';
        System.assert(true, new IfapToolManager.Response(json).toString() == 'SUCCESS RESPONSE');
        String jsonError = '{"success": false, "code": "CODE","message":"MSG"}';
        System.assert(true, new IfapToolManager.Response(jsonError).toString() == '{"success": false, "code": "CODE","message":"MSG"}');
        Test.stopTest();
    }

    static testMethod void submitCaseQualityIssuesToMFTTest_TooMayIds() {
        beforeTest();
        list<id> qualityIssueId = new list<Id>();
        for (Integer i = 0; i < 10; i++) {
            qualityIssueId.add('50011000006kn5P');
        }
        Test.startTest();
        system.debug('aqui qualityIssueId ' + qualityIssueId.size());
        IfapToolManager.submitCaseQualityIssuesToMFT(qualityIssueId);
        Test.stopTest();
    }

    static testMethod void submitCaseQualityIssuesToMFTTest() {
        beforeTest();

        Id recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c = 'AA', Name = 'AA', AIMS_Area_ID__c = 'A');
        insert country;

        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<IFAP_Quality_Issue__c> qualityList = new List<IFAP_Quality_Issue__c>();
        List<IFAP_Reassessment_Accounting_Issue__c> reassList = new List<IFAP_Reassessment_Accounting_Issue__c>();


        Account account = new Account();
        account.Name = 'TestAccount';
        account.Type = 'IATA Passenger Sales Agent';
        account.Sector__c = 'Travel Agent';
        account.IATACode__c = '1234567';
        account.BillingCountry = country.Name;
        account.Location_Type__c = 'HO';
        accList.add(account);
        insert accList;

        Contact contact = new Contact();
        contact.FirstName = 'firstname';
        contact.LastName = 'lastName';
        contact.Financial_Assessment_Contact__c = true;
        contact.accountId = accList[0].Id;
        conList.add(contact);
        insert conList;

        Case caseObj = new Case();
        caseObj.ArchivedDate__c = Date.today();
        caseObj.RecordTypeId = recordtypeId;
        caseObj.status = 'Assessment Performed';
        caseObj.IFAP_Financial_Year__c = '2015';
        caseObj.AccountId = accList[0].Id;
        caseObj.contactId = conList[0].Id;
        caseList.add(caseObj);
        insert caseList;

        IFAP_Quality_Issue__c issue = new IFAP_Quality_Issue__c();

        issue.Status__c = 'Sent to GFA';
        issue.Assessment_using_wrong_template__c = true;
        issue.Wrong_figure_was_extracted__c = true;
        issue.Other_Issue_details__c = 'test details';
        issue.The_printout_of_the_result_is_unreadable__c = true;
        issue.Formatting_Issue_details__c = 'test details';
        issue.Related_Case__c = caseList[0].id;
        qualityList.add(issue);
        insert qualityList;


        list<id> qualityIssueId = new list<Id>();
        qualityIssueId.add(issue.id);

        IFAP_Reassessment_Accounting_Issue__c accIssue = new IFAP_Reassessment_Accounting_Issue__c(
            IFAP_Reassessment__c = issue.Id,
            Comment__c = 'comment',
            Field_Name__c = 'fieldname',
            Value_to_use__c = 'A',
            Wrong_value__c = 'B'
        );
        reassList.add(accIssue);
        insert reassList;

        Test.startTest();
        IfapToolManager.submitCaseQualityIssuesToMFT(qualityIssueId);
        Test.stopTest();
    }

}