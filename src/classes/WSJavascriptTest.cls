@isTest
private class WSJavascriptTest {

    @isTest static void test_sendEmail() {
        Contact contact = new Contact(
            FirstName='first',
            LastName='last',
            Email = 'test0230890@mail.com'
        );
        insert contact;

        Case cse = new Case(ContactId = contact.Id);
        insert cse;

        EmailTemplate template = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];

        Test.StartTest();
        cse.Subject = 'test';
        WSJavascript.sendEmail(cse.Id,template.DeveloperName);
        Test.StopTest();
    }
}