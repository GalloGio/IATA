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
			ceoContact.Membership_Function__c = 'General Management';
			insert ceoContact;

			Contact mainContact = new Contact();
			mainContact.FirstName = 'testFirst';
			mainContact.LastName = 'testLast';
			mainContact.Title = 'main';
			mainContact.Email = 'main@testAccount.com';
			mainContact.AccountId = a.Id;
			mainContact.Membership_Main_Contact__c = true;
			mainContact.Membership_Function__c = 'General Management';
			insert mainContact;

			Contact primaryContact = new Contact();
			primaryContact.FirstName = 'testFirst';
			primaryContact.LastName = 'testLast';
			primaryContact.Title = 'primary';
			primaryContact.Email = 'primary@testAccount.com';
			primaryContact.AccountId = a.Id;
			primaryContact.Membership_Function__c = 'Cargo';
			primaryContact.Function__c = 'Cargo';
			insert primaryContact;

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
			System.assertEquals(3, keyContactsController.lsKeyContactsWrapped.size(), 'There should be 3 Key Contacts');
			
			// Test the printable page part
			ApexPages.currentPage().getParameters().put('accountId',a.id);
			keyContactsController  = new AMP_KeyContactsController();

			System.assertEquals(a.Name, keyContactsController.accountName);

			String reportId = AMP_KeyContactsController.getReportId();
		}
	}
}