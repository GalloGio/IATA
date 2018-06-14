@isTest
public class SignaturitRestTest {

    public static String testString = '{'
        +'  "body": "testbody",'
        +'  "certificates": ['
        +'    {'
        +'      "created_at": "2015-12-04T14:09:05+0000",'
        +'      "events": [],'
        +'      "id": "94472f2c-9a90-11e5-a4b9-0a0f5351f1ad",'
        +'      "recipient_email": "testmail@test.com",'
        +'      "recipient_name": "testname"'
        +'    }'
        +'  ],'
        +'  "created_at": "2015-12-04T14:09:05+0000",'
        +'  "id": "9415bd83-9a90-11e5-a4b9-0a0f5351f1ad",'
        +'  "source": "api",'
        +'  "subject": "test subject",'
        +'  "type": "delivery"'
        +'}';

    public static String testMailInfo = '{'
        +'  "certificates": ['
        +'    {'
        +'      "created_at": "2015-12-03T07:50:24+0000",'
        +'      "events": ['
        +'        {'
        +'          "created_at": "2015-12-03T07:51:02+0000",'
        +'          "type": "email_processed"'
        +'        },'
        +'        {'
        +'          "created_at": "2015-12-03T07:51:05+0000",'
        +'          "type": "email_delivered"'
        +'        }'
        +'      ],'
        +'      "id": "94472f2c-9a90-11e5-a4b9-0a0f5351f1ad",'
        +'      "email": "tenaj2@iata.org",'
        +'      "name": "tenaj2@iata.org",'
        +'      "status": "sent"'
        +'    }'
        +'  ],'
        +'  "created_at": "2015-12-03T07:50:23+0000",'
        +'  "data": [],'
        +'  "id": "94472f2c-9a90-11e5-a4b9-0a0f5351f1af"'
        +'}';

    static testMethod void testSendEmail_OK() {
        Contact contact = new Contact (
            FirstName = 'test contact',
            LastName = 'last name',
            email = 'test@email.com'
        );
        insert contact;

        Case cse = new Case();
        insert cse;

        Tracked_Email__c trackedEmail = new Tracked_Email__c(
            Subject__c = 'subject',
            TextBody__c = 'body',
            Html_Body__c = 'body',
            ToContact__c = contact.Id,
            Case__c = cse.Id
        );

		Signaturit_Events_WS__c ws = new Signaturit_Events_WS__c(name = 'test', events_url__c = 'http://test.com', oauth_url__c = '');
		insert ws;

        SignaturitRest.TESTSTRING = testString;

        Test.startTest();
        SignaturitRest.MailInfoResponse response = SignaturitRest.sendMail(trackedEmail);
        System.assert(response != null);
        list<String> certificates = response.getCertificateIds();
        System.assert(certificates != null);
        Test.stopTest();
    }

    static testMethod void testSendEmail_Error() {

        SignaturitRest.TESTSTRING = testString;

        Test.startTest();
        SignaturitRest.MailInfoResponse response = SignaturitRest.sendMail(null);
        Test.stopTest();

    }

    static testMethod void testGetMailInfo_Error() {

        SignaturitRest.TESTSTRING = 'jsonerror';

        Test.startTest();
        SignaturitRest.MailInfoResponse response = SignaturitRest.getMailInfo(null);
        Test.stopTest();

        System.assert(response == null);
    }

    static testMethod void testGetMailInfo_OK() {
        Contact contact = new Contact (
            FirstName = 'test contact',
            LastName = 'last name',
            email = 'test@email.com'
        );
        insert contact;

        Case cse = new Case();
        insert cse;

        Tracked_Email__c trackedEmail = new Tracked_Email__c(
            Subject__c = 'subject',
            TextBody__c = 'body',
            ToContact__c = contact.Id,
            Case__c = cse.Id
        );

        SignaturitRest.TESTSTRING = testMailInfo;

        Test.startTest();
        SignaturitRest.MailInfoResponse response = SignaturitRest.getMailInfo(trackedEmail);
        Test.stopTest();

        System.assert(response != null);
        System.assert(response.certificates != null);
        System.assert(response.certificates.size() == 1);
        System.assert(response.certificates[0].events != null);
        System.assert(response.certificates[0].events.size() == 2);
    }

    static testMethod void testUpdateEventList_OK() {
        Contact contact = new Contact (
            FirstName = 'test contact',
            LastName = 'last name',
            email = 'test@email.com'
        );
        insert contact;

        Case cse = new Case();
        insert cse;

        Tracked_Email__c trackedEmail = new Tracked_Email__c(
            Subject__c = 'subject',
            TextBody__c = 'body',
            ToContact__c = contact.Id,
            Case__c = cse.Id
        );
        insert trackedEmail;

        SignaturitRest.TESTSTRING = testMailInfo;

        Test.startTest();
        SignaturitRest.updateEventList(trackedEmail);
        Test.stopTest();
    }
}