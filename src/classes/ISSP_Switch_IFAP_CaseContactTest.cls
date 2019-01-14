@isTest
private class ISSP_Switch_IFAP_CaseContactTest {

	@isTest static void testGetSetPermissionSet() {

		IATA_ISO_Country__c isoCountryCA = new  IATA_ISO_Country__c();
		isoCountryCA.name = 'Canada';
		isoCountryCA.ISO_Code__c = 'CA';
		isoCountryCA.ISO_Code_Numeric__c = 123; //not real code
		isoCountryCA.CurrencyIsoCode = 'CAD';
		isoCountryCA.AIMS_Area_ID__c = '1'; //not real code
		insert isoCountryCA;

		Account acc = new Account();
		acc.IATACode__c = '1234560'; //7digits
		acc.Name = 'Test account 1';
		acc.BillingCity = 'Montreal';
		acc.BillingCountry = 'Canada';
		acc.BillingStreet = 'some street';
		acc.Type = 'IATA Passenger Sales Agent';
		acc.Location_Type__c = 'HO';
		insert acc;

		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(FirstName = 'firstName', Financial_Assessment_Contact__c = true, LastName = 'LastName 1', Email = 'test1@test.com', phone='(514) 111 2222', AccountId=acc.Id));
		insert contacts;

		Id rtid = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
		Case caseObj = new Case(RecordTypeId = rtid, AccountID = acc.id, Subject = 'Test Case 1', IFAP_Financial_Year__c = '2016', Financial_Review_Type__c = 'New applications', Description = 'Test Case 1');
		insert caseObj;

		Test.startTest();

		caseObj = [SELECT Id, RecordTypeId, IsClosed, AccountId, ContactId FROM Case WHERE Id=:caseObj.Id LIMIT 1][0];

		//assert contact related to case is null
		System.assertEquals(caseObj.contactId, null);

		//method receives a list of contacts but only sets the first element the index
		ISSP_Switch_IFAP_CaseContact.getSetPermissionSet(contacts);

		caseObj = [SELECT Id, RecordTypeId, IsClosed, AccountId, ContactId FROM Case WHERE Id=:caseObj.Id LIMIT 1][0];

		//assert that contactID related to case's account is equal to case's contactID
		System.assertEquals(caseObj.contactId, contacts[0].Id);

		Test.stopTest();
	}


}