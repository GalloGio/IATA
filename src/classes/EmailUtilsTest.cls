@isTest
private class EmailUtilsTest {
	
	@isTest static void sendEmailAlert() {	
		Contact con = new Contact(LastName = 'test', Email = 'test@test.com');
		insert con;

		Case c = new Case();
		c.contactId = con.Id;
		insert c;

		EmailUtils.sendEmailAlert(new List<Contact> { con } , 'Portal_Case_Comment_Autoreply', 'noreply@iata.org', c.Id);
	}
}