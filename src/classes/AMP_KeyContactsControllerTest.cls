@isTest
private class AMP_KeyContactsControllerTest
{
	@isTest
	static void testKeyContactsList()
	{
		// TODO: run this as a test User
		Account a = new Account(name='testAccount');
		insert a;

		Contact ceoContact = new Contact();
		ceoContact.LastName = 'testLast';
		ceoContact.Title = 'CEO';
		ceoContact.AccountId = a.Id;
		insert ceoContact;

		Contact notCEO = new Contact();
		notCEO.LastName = 'testLast';
		notCEO.Title = 'not-CEO';
		notCEO.AccountId = a.Id;
		insert notCEO;

		ApexPages.currentPage().getParameters().put('id',a.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(a);
		AMP_KeyContactsController keyContactsController  = new AMP_KeyContactsController(stdController);

		System.assertEquals((String)a.Id, keyContactsController.getRecordId(), 'The account Id should match');
		
	}
}