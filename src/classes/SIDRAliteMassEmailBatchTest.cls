@isTest
private class SIDRAliteMassEmailBatchTest {

    @isTest
    static void testProcessBatch() {
        Case cse = new Case();
        insert cse;
        List<Case> caseList = new list<Case>{cse};
        Boolean sendToParentCase = false;
        String sessionId = UserInfo.GetSessionId();
        String apiServerUrl = 'http://test.com';

        Test.startTest();
        SIDRAliteMassEmailBatch batch = new SIDRAliteMassEmailBatch(caseList, 'IRR', sendToParentCase, sessionId, apiServerUrl);
        batch.processCases(caseList);
        batch.processErrors();
        batch = new SIDRAliteMassEmailBatch(caseList, 'IRR Withdrawal', sendToParentCase, sessionId, apiServerUrl);
        batch.processCases(caseList);
        batch.processErrors();
        batch = new SIDRAliteMassEmailBatch(caseList, 'DEF', sendToParentCase, sessionId, apiServerUrl);
        batch.processCases(caseList);
        batch.processErrors();
        batch = new SIDRAliteMassEmailBatch(caseList, 'DEF Withdrawal', sendToParentCase, sessionId, apiServerUrl);
        batch.processCases(caseList);
        batch.processErrors();
        batch = new SIDRAliteMassEmailBatch(caseList, 'REI', sendToParentCase, sessionId, apiServerUrl);
        batch.processCases(caseList);
        batch.processErrors();
        batch = new SIDRAliteMassEmailBatch(caseList, 'TER', sendToParentCase, sessionId, apiServerUrl);
        batch.processCases(caseList);
        batch.processErrors();
        Test.StopTest();
    }

    @isTest
    static void testSendCongaMail() {
        Contact contact = new Contact(FirstName='firstName', LastName='lastName');
        insert contact;
        Case case1 = new Case(contactId=contact.Id);
        insert case1;
        Case case2 = new Case(contactId=contact.Id);
        insert case2;

        List<Case> caseList = new list<Case>{case1};
        String sessionId = UserInfo.GetSessionId();
        String apiServerUrl = 'http://test.com';

        Test.startTest();
        SIDRAliteMassEmailBatch batch = new SIDRAliteMassEmailBatch(caseList, 'IRR', true, sessionId, apiServerUrl);
        batch.sendCongaMail(case1, 'IRR');
        batch = new SIDRAliteMassEmailBatch(caseList, 'IRR', false, sessionId, apiServerUrl);
        batch.sendCongaMail(case1, 'IRR');
        batch.getTemplate(case1);
        Test.StopTest();
    }

}