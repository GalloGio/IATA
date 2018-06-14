@isTest
private class CongaManagerTest{

    @isTest
    static void TestSendMail_OK() {
        String sessionId = 'sessionId';
        String serverUrl = 'http://test.com';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id congaTemplate = '01H000000000000';
        Id emailTemplateId = '00X000000000000';

        CongaManager.TEST_RESPONSE = new System.HttpResponse();
        CongaManager.TEST_RESPONSE.setStatusCode(200);

        Test.StartTest();
        CongaManager.sendMail(sessionId, serverUrl, caseId, contactId, congaTemplate, emailTemplateId);
        Test.StopTest();
    }

    @isTest
    static void TestSendMail_BadResponse() {
        String sessionId = 'sessionId';
        String serverUrl = 'http://test.com';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id congaTemplate = '01H000000000000';
        Id emailTemplateId = '00X000000000000';

        CongaManager.TEST_RESPONSE = new System.HttpResponse();
        CongaManager.TEST_RESPONSE.setStatusCode(400);

        Test.StartTest();
        try {
            CongaManager.sendMail(sessionId, serverUrl, caseId, contactId, congaTemplate, emailTemplateId);
            System.assert(false, 'An exception was expected');
        } catch(Exception e) {
            System.assert(true);
        }
        Test.StopTest();
    }

    @isTest
    static void TestAttachFile() {
        String sessionId = 'sessionId';
        String serverUrl = 'http://test.com';
        Id caseId = '500000000000000';
        Id congaTemplate = '01H000000000000';

        CongaManager.TEST_RESPONSE = new System.HttpResponse();
        CongaManager.TEST_RESPONSE.setStatusCode(200);

        Test.StartTest();
        CongaManager.attachFile(sessionId, serverUrl, caseId, congaTemplate);
        Test.StopTest();
    }

    @isTest
    static void TestSendEmailURL() {
        String sessionId = 'sessionId';
        String serverUrl = 'http://test.com';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id congaTemplate = '01H000000000000';
        Id emailTemplateId = '00X000000000000';
        Id OrgWideDefaultsId = '0D2000000000000';

        Test.StartTest();
        String result = CongaManager.sendEmailURL(sessionId, serverUrl, caseId, caseId, contactId, congaTemplate, emailTemplateId, OrgWideDefaultsId, null);
        Test.StopTest();

        System.AssertEquals(true, result!=null);
    }

    @isTest
    static void TestGoToSendEmailConga() {
        String sessionId = 'sessionId';
        String serverUrl = 'http://test.com';
        Id caseId = '500000000000000';
        Id contactId = '003000000000000';
        Id OrgWideDefaultsId = '0D2000000000000';

        Test.StartTest();
        String result = CongaManager.goToSendEmailConga(sessionId, serverUrl, caseId, caseId, contactId, OrgWideDefaultsId, null);
        Test.StopTest();

        System.AssertEquals(true, result!=null);
    }

    @isTest
    static void TestgetValidSessionId() {
        Test.StartTest();
        String sessionId = CongaManager.getValidSessionId();
        Test.StopTest();

        System.AssertEquals(true, sessionId!=null);
    }

}
