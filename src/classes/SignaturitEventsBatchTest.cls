@isTest
private class SignaturitEventsBatchTest {

    static Tracked_Email__c createTrackedEmail() {

        Sender_Tracked_Emails__c sender = new Sender_Tracked_Emails__c();
        sender.Name = 'name@mail.com';
        sender.email__c = 'name@mail.com';
        sender.Token__c = 'qwert';
        insert sender;

        Case cse = new Case();
        insert cse;

        Tracked_Email__c te = new Tracked_Email__c();
        te.Status__c = 'sent';
        te.Signaturit_Id__c = '123456';
        te.FromName__c = sender.email__c;
        te.Case__c = cse.id;

        return te;
    }

    static testMethod void testBatch() {
        Tracked_Email__c te = createTrackedEmail();
        insert te;

        Test.startTest();
        SignaturitEventsBatch batch = new SignaturitEventsBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();

    }

    static testMethod void testWSCall() {
        Tracked_Email__c te = createTrackedEmail();
        insert te;

        Test.startTest();
        WSJavascript.refreshSignaturitEvents(te.id);
        Test.stopTest();
    }
}