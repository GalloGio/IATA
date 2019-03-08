@isTest
private class EmailUtilsTest {
	
	@isTest static void createEmailsTest() {	
		Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
		insert con;

		Case c = new Case();
		c.contactId = con.Id;
		insert c;

		List<Messaging.SingleEmailMessage> emailsToSend = new list<Messaging.SingleEmailMessage>();

		emailsToSend = EmailUtils.createEmails(new List<Contact> { con } , 'Portal_Case_Comment_Autoreply', 'noreply@iata.org', c.Id);
	
		System.debug('----------> emailsToSend: ' + emailsToSend);

		System.assertEquals(1, emailsToSend.size());
	}
}