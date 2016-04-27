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
			ToContact__c = contact.Id,
			Case__c = cse.Id
		);

		SignaturitRest.TESTSTRING = testString;

		Test.startTest();
		SignaturitRest.MailResponse response = SignaturitRest.sendMail(trackedEmail);
		System.assert(response != null);
		list<String> certificates = response.getCertificateIds();
		System.assert(certificates != null);
		Test.stopTest();
	}

	static testMethod void testSendEmail_Error() {

		SignaturitRest.TESTSTRING = testString;

		Test.startTest();
		SignaturitRest.MailResponse response = SignaturitRest.sendMail(null);
		Test.stopTest();

		System.assert(response == null);
	}
}