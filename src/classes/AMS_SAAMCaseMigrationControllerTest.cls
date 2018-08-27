@isTest
private class AMS_SAAMCaseMigrationControllerTest {

	@testSetup static void setup(){

		Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.IATACode__c = '4242424';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account1.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO';
		saamCase.CaseArea__c = 'Accreditation Process';
		insert saamCase;


	}
	
	static testMethod void testAAMS_SAAMCaseMigrationControllerTest() {

		PageReference pageRef = Page.AMS_SAAMCaseMigration;
		pageRef.getParameters().put('retURL', URL.getSalesforceBaseUrl()+'');
        Test.setCurrentPageReference(pageRef);

		Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
		AMS_SAAMCaseMigrationController con = new AMS_SAAMCaseMigrationController();

		Test.startTest();

		System.assertEquals('No records found', con.getEmptyList()[0]);

		con.searchOption = 'Specific Cases';
		System.assert(con.showTextArea);

		con.caseNumbers = [SELECT CaseNumber FROM Case WHERE RecordTypeId = :SAAMcaseRecordTypeId LIMIT 1].CaseNumber;
		
		System.assert(con.searchOptions.size() > 0);

		con.search();

		System.assert(con.searched);

		con.first();
		con.previous();
		con.next();
		con.last();

		con.selectAll = true;
		con.doSelectAll();

		con.convert();
		con.migrateCases();
		con.migrateCases();


		con.searchOption = 'All SAAM Cases';
		con.search();

		con.cancel();

		Test.stopTest();

	}
	
}