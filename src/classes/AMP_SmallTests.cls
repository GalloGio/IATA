@isTest
private class AMP_SmallTests {

	@isTest
	static void testAMP() {

		Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Airline Headquarters'].Id;
		Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId, Sector__c='Airline', Category__c='Passenger and Cargo');
		insert a;

		ApexPages.currentPage().getParameters().put('id',a.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(a);

		AMP_AccountNewsFeedExtension controller = new AMP_AccountNewsFeedExtension(stdController);

		Service__c testService = new Service__c();
		testService.name = 'test';
		testService.Service_Publication__c = 'Services';
		insert testService;

		Account_Service__c ac = new Account_Service__c();
		ac.Account__c = a.Id;
		ac.Service__c = testService.Id;
		ac.Active__c = true;
		insert ac;

		AMP_ProductsController pcontroller = new AMP_ProductsController(stdController);
		Boolean canView = AMP_ProductsController.canViewSalesfigures();

		Account b = AMP_AccountManagementController.getAccount(a.Id);
		System.assertEquals(a.Name, b.Name, 'Accounts should be the same');

		Contact testContact = new Contact();
		testContact.FirstName = 'testFirstname';
		testContact.LastName = 'testLastname';
		testContact.Email = 'testLastname@test.ts';
		testContact.Title = 'test Title';
		testContact.AccountId = a.Id;
		testContact.Function__c = 'testFunction';
		testContact.Membership_Function__c = 'testFunction';
		insert testContact;
		
		testContact.Membership_Function__c = '';
		try {
			update testContact;

		} catch(Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Contact can only be Primary for values included in Job Functions') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		}
		testContact.Membership_Function__c = 'testFunction2';
		try {
			update testContact;
		} catch(Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Contact can only be Primary for values included in Job Functions') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);

		}

	}


}