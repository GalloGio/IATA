@isTest
private class CongaManagerTest{

    @isTest
    static void TestSendMail_OK() {
        String sessionId = 'sessionId';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id congaTemplate = '01H000000000000';
        Id emailTemplateId = '00X000000000000';

        CongaManager.TEST_RESPONSE = new System.HttpResponse();
        CongaManager.TEST_RESPONSE.setStatusCode(200);

        Test.StartTest();
        CongaManager.sendMail(sessionId, caseId, contactId, congaTemplate, emailTemplateId);
        Test.StopTest();
    }

    @isTest
    static void TestSendMail_BadResponse() {
        String sessionId = 'sessionId';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id congaTemplate = '01H000000000000';
        Id emailTemplateId = '00X000000000000';

        CongaManager.TEST_RESPONSE = new System.HttpResponse();
        CongaManager.TEST_RESPONSE.setStatusCode(400);

        Test.StartTest();
        try {
            CongaManager.sendMail(sessionId, caseId, contactId, congaTemplate, emailTemplateId);
            System.assert(false, 'An exception was expected');
        } catch(Exception e) {
            System.assert(true);
        }
        Test.StopTest();
    }

    @isTest
    static void TestAttachFile() {
        String sessionId = 'sessionId';
        Id caseId = '500000000000000';
        Id congaTemplate = '01H000000000000';

        CongaManager.TEST_RESPONSE = new System.HttpResponse();
        CongaManager.TEST_RESPONSE.setStatusCode(200);

        Test.StartTest();
        CongaManager.attachFile(sessionId, caseId, congaTemplate);
        Test.StopTest();
    }

    @isTest
    static void TestSendEmailURL() {
        String sessionId = 'sessionId';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id congaTemplate = '01H000000000000';
        Id emailTemplateId = '00X000000000000';
        Id OrgWideDefaultsId = '0D2000000000000';

        Test.StartTest();
        String result = CongaManager.sendEmailURL(sessionId, caseId, contactId, congaTemplate, emailTemplateId, OrgWideDefaultsId);
        Test.StopTest();

        System.AssertEquals(true, result!=null);
    }

    @isTest
    static void TestGoToSendEmailConga() {
        String sessionId = 'sessionId';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id OrgWideDefaultsId = '0D2000000000000';

        Test.StartTest();
        String result = CongaManager.goToSendEmailConga(sessionId, caseId, contactId, OrgWideDefaultsId);
        Test.StopTest();

        System.AssertEquals(true, result!=null);
    }
}