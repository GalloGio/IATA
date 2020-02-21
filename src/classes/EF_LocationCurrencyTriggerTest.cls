@isTest
private class EF_LocationCurrencyTriggerTest {

	@testSetup
	static void setup() {
		User u = EF_TestDataFactory.getEfProfileAndRole(0, 2);
		System.runAs(u){
		   EF_TestDataFactory.createBaseDataWithoutLocCurr();
		}


	}

	 @isTest static void addFirstLocationCurrency() {
		Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);

		Test.startTest();
			insert efl;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		System.assertEquals(ctAfter.EF_Billing_Currency__c, 'USD');
	}

	@isTest static void addSecondLocationCurrency() {

		 Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		List <EF_Location_Currency__c> lcList = new List <EF_Location_Currency__c> ();

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);
		lcList.add(efl);
		// Add one billing currency to the contract.
		EF_Location_Currency__c efl2 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'EUR',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '1' limit 1].Id
			);
		lcList.add(efl2);

		Test.startTest();
			insert lcList;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		System.assert(ctAfter.EF_Billing_Currency__c.contains('USD'));
		System.assert(ctAfter.EF_Billing_Currency__c.contains('EUR'));

	}

	 @isTest static void addRepeatedLocationCurrency() {

		  Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		List <EF_Location_Currency__c> lcList = new List <EF_Location_Currency__c> ();

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);
		lcList.add(efl);
		// Add one billing currency to the contract.
		EF_Location_Currency__c efl2 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '1' limit 1].Id
			);
		lcList.add(efl2);
		// Add one billing currency to the contract.
		EF_Location_Currency__c efl3 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'EUR',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '2' limit 1].Id
			);
		lcList.add(efl3);

		Test.startTest();
			insert lcList;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		System.assertEquals('EUR;USD', ctAfter.EF_Billing_Currency__c);


	 }

	 @isTest static void addRepeatedLocationCurrencyWhenThereIsOne() {

		  Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		List <EF_Location_Currency__c> lcList = new List <EF_Location_Currency__c> ();

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);
		insert efl;

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl2 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '1' limit 1].Id
			);
		lcList.add(efl2);
		// Add one billing currency to the contract.
		EF_Location_Currency__c efl3 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'EUR',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '2' limit 1].Id
			);
		lcList.add(efl3);

		Test.startTest();
			insert lcList;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		System.assertEquals('EUR;USD', ctAfter.EF_Billing_Currency__c);


	 }

	 @isTest static void deleteOneLocationCurrency() {

		Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		List <EF_Location_Currency__c> lcList = new List <EF_Location_Currency__c> ();

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);
		lcList.add(efl);
		// Add one billing currency to the contract.
		EF_Location_Currency__c efl2 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'EUR',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '1' limit 1].Id
			);
		lcList.add(efl2);
		insert lcList;

		Test.startTest();
		   delete efl2;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		//System.assertEquals('USD', ctAfter.EF_Billing_Currency__c);

	 }

	 @isTest static void deleteALLLocationCurrency() {

		 Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);

		insert efl;

		Test.startTest();
		   delete efl;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		System.assertEquals(null, ctAfter.EF_Billing_Currency__c);

	 }


	 @isTest static void updateLocationCurrencyWhenThereIsOne() {

		Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client2'];

		List <EF_Location_Currency__c> lcList = new List <EF_Location_Currency__c> ();

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
			);
		lcList.add(efl);

		// Add one billing currency to the contract.
		EF_Location_Currency__c efl2 = new EF_Location_Currency__c(
				EF_Billing_Currency__c = 'USD',
				Contract__c = contract.Id,
				Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = '1' limit 1].Id
			);
		lcList.add(efl2);

		insert lcList;

		Test.startTest();
			efl2.EF_Billing_Currency__c='GBP';
			update efl2;
		Test.stopTest();

		Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client2'];

		System.assert(ctAfter.EF_Billing_Currency__c.contains('USD'));
		System.assert(ctAfter.EF_Billing_Currency__c.contains('GBP'));


	 }


}
