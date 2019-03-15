@isTest
private class WSJavascriptTest {

    @isTest static void test_updateCase() {
        Case cse = new Case();
        insert cse;

        Test.StartTest();
        cse.Subject = 'test';
        WSJavascript.updateCase(cse,true);
        Test.StopTest();
    }
}