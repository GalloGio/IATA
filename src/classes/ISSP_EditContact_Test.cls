@isTest
private class ISSP_EditContact_Test {

	@isTest static void test_method_one() {
		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
		insert ISO_Country;
		account topacc = ISSP_ObjectFactory.createNewAccount();
		insert topacc;
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Top_Parent__c = topacc.Id;
		acc.Industry = 'Cargo Agent';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.sector__c = 'Airline';
		insert acc;

		//Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,3);
		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.Email = 'test2@test.test';
		con2.AccountId= acc.Id;
		con2.User_Portal_Status__c='Active';
		insert con2;

		 Test.startTest() ;
		 ApexPages.StandardController sc = new ApexPages.StandardController(con2);
		 ISSP_EditContact controller = new ISSP_EditContact(sc);
		 controller.SaveContact();
		 controller.CancelContact();

		Test.stopTest();
	}
}
