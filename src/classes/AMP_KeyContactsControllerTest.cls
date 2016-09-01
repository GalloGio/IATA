@isTest
private class AMP_KeyContactsControllerTest
{
	@isTest
	static void testKeyContactsList()
	{
		// TODO: run this as a test User
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(

			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);

		System.runAs(testUser) {
			Account a = new Account(name='testAccount');
			a.Field_Head_Office__c = 'Headquarter';
			insert a;

			Contact ceoContact = new Contact();
			ceoContact.FirstName = 'testFirst';
			ceoContact.LastName = 'testLast';
			ceoContact.Title = 'CEO';
			ceoContact.Email = 'CEO@testAccount.com';
			ceoContact.AccountId = a.Id;
			ceoContact.CEO_CFO__c = 'CEO';
			insert ceoContact;

			Contact notCEO = new Contact();
			notCEO.FirstName = 'testFirst';
			notCEO.LastName = 'testLast';
			notCEO.Title = 'not-CEO';
			notCEO.Email = 'notCEO@testAccount.com';
			notCEO.AccountId = a.Id;
			// notCEO.Function__c = 'testFunction';
			insert notCEO;

			ApexPages.currentPage().getParameters().put('id',a.id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(a);
			AMP_KeyContactsController keyContactsController  = new AMP_KeyContactsController(stdController);

			System.assertEquals((String)a.Id, keyContactsController.getRecordId(), 'The account Id should match');
			System.assertEquals(1, keyContactsController.getKeyContacs().size(), 'There should be 1 Key Contact');
		}
	}
}