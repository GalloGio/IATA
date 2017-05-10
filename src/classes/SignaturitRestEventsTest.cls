@isTest
private class SignaturitRestEventsTest {


    public static String TESTJSON = '{'
    +'   "certificate":{'
    +'      "certified_email":{'
    +'         "certificates":['
    +'         ],'
    +'         "created_at":"2015-11-23T15:45:16+0000",'
    +'         "id":"313bcf26-91f9-11e5-a4b9-0a0f5351f1ad",'
    +'         "source":"api",'
    +'         "subject":"Please, check this email",'
    +'         "type":"delivery"'
    +'      },'
    +'      "created_at":"2015-11-23T15:45:16+0000",'
    +'      "events":{'
    +'         "1":{'
    +'            "date":"2015-11-23T15:46:04+0000",'
    +'            "type":"delivered"'
    +'         }'
    +'      },'
    +'      "id":"f900ed26-91fd-11e5-a4b9-0a0f5351f1ad",'
    +'      "last_event":{'
    +'         "date":"2015-11-23T15:46:04+0000",'
    +'         "type":"delivered"'
    +'      },'
    +'      "recipient_email":"javier@signaturit.com",'
    +'      "recipient_name":"Javier"'
    +'   },'
    +'   "date":"2015-11-23T15:46:03+0000",'
    +'   "type":"processed"'
    +'}';

    static testMethod void testService() {
        Test.startTest();
        String result = SignaturitRestEvents.testService();
        Test.stopTest();

        System.assert(result == 'testService OK');
    }

    static testMethod void testSendEmail_ErrorRequest() {
        SignaturitRestEvents.testJson = null;

        Test.startTest();
        try {
            SignaturitRestEvents.receiveEvent();
            System.assert(false, 'Exception expected');
        } catch (Exception e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    static testMethod void testSendEmail_ErrorInJson() {
        SignaturitRestEvents.testJson = TESTJSON;

        Test.startTest();
        try {
            SignaturitRestEvents.receiveEvent();
            System.assert(false, 'Exception expected');
        } catch (Exception e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    static testMethod void testSendEmail_Ok() {
        SignaturitRestEvents.testJson = TESTJSON;

        Contact contact = new Contact();
        contact.email = 'recipient@test.com';
        contact.LastName = 'toto';
        insert contact;

        Case cse = new Case();
        insert cse;

        Tracked_Email__c trackedEmail = new Tracked_Email__c(
            Subject__c = 'subject',
            TextBody__c = 'body',
            ToContact__c = contact.Id,
            Case__c = cse.Id,
            Signaturit_Id__c = 'f900ed26-91fd-11e5-a4b9-0a0f5351f1ad',
            Status__c = 'email_processed'
        );
        insert trackedEmail;
        
        Tracked_Email_Certificate__c certificate = new Tracked_Email_Certificate__c();
        certificate.Name = '1234';
        certificate.Tracked_Email__c = trackedEmail.Id;
        insert certificate;

        list<Tracked_Email_Event__c> listEvents = [
            Select Id from Tracked_Email_Event__c
            where Parent__c = :trackedEmail.Id
        ];
        System.assert(listEvents.isEmpty());

        Test.startTest();
        
        RestRequest req = new RestRequest();

        req.params.put('certificate[id]', '1234');
        req.params.put('certificate[email]', 'recipient@test.com');
        req.params.put('certificate[name]', 'toto');
        req.params.put('certificate[file][name]', '');
        req.params.put('certificate[created_at]', '2017-03-02T17:42:45+0000');
        req.params.put('type', 'email_delivered');
        
        RestContext.request = req;
        
        SignaturitRestEvents.receiveEvent();
        Test.stopTest();

        listEvents = [
            Select Id from Tracked_Email_Event__c
            where Parent__c = :trackedEmail.Id
        ];
        System.assert(listEvents.size()==1);
    }

}