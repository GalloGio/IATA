@isTest
public with sharing class AccountDashboardCTICasesTest {
	public static final String DEFAULTNAME = 'TEST ACCOUNT';
	
	@TestSetup
	static void makeData() {
		List<IATA_ISO_Country__c> iataISOCountryList = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1);
		insert iataISOCountryList;
		//get standard record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'Others');
		//get iataISOCountry ID
		IATA_ISO_Country__c iataISOCountry = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = :TestDataFactory_IATAISOCountries.DEFAULTCOUNTRYNAME].get(0);
		Integer numberOfRecords = 1;
		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(Name = DEFAULTNAME + ' ' + x, RecordTypeId = recordTypeId, IATA_ISO_Country__c = iataISOCountry.Id);
			accountList.add(account);
		}
		insert accountList;

		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(accountList[0].id,2);
		insert contactList;

		Case testCase = ISSP_ObjectFactory.createNewCase();
		testCase.BSPCountry__c = 'Hong Kong (SAR), China';
		testCase.Reason1__c = 'Agency';
		testCase.Case_Language__c = 'English';
		testCase.Subject = 'Test 006';
		testCase.Reopened_case__c = 0.0;
		testCase.IFAP_Country_ISO__c = 'tq';
		testCase.AccountId = accountList[0].id;
		testCase.ContactId = contactList[0].id;
		testCase.Type = 'test';
		testCase.Origin = 'Phone';

		Case testCase2 = ISSP_ObjectFactory.createNewCase();
		testCase2.BSPCountry__c = 'Macau (SAR), China';
		testCase2.Reason1__c = 'Agency';
		testCase2.Case_Language__c = 'English';
		testCase2.Subject = 'Test 007';
		testCase2.Reopened_case__c = 0.0;
		testCase2.IFAP_Country_ISO__c = 'tq';
		testCase2.AccountId = accountList[0].id;
		testCase.ContactId = contactList[1].id;
		testCase.Type = 'test';
		testCase.Origin = 'Phone';

		Case testCase3 = ISSP_ObjectFactory.createNewCase();
		testCase3.BSPCountry__c = 'Singapure (SAR), China';
		testCase3.Reason1__c = 'Agency';
		testCase3.Case_Language__c = 'English';
		testCase3.Subject = 'Test 008';
		testCase3.Reopened_case__c = 0.0;
		testCase3.IFAP_Country_ISO__c = 'tq';
		testCase3.AccountId = accountList[0].id;
		testCase.ContactId = contactList[1].id;
		testCase.Type = 'test';
		testCase.Origin = 'Phone';

		list<Case> testCases = new list<Case>{testCase, testCase2, testCase3};
		insert testCases;
	}

	@isTest
	public static void getAccountCasesTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
		test.startTest();
		List<AccountDashboardCTICasesCtrl.CasesList> casesList = AccountDashboardCTICasesCtrl.getAccountCases(accountList[0].Id, contactList[0].Id);
		test.stopTest();
		System.assert(casesList.size() > 0, 'No Cases to wrapper found!');
	}

	@isTest
	public static void searchCasesTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		test.startTest();
		List<Case> casesList = AccountDashboardCTICasesCtrl.searchCases(accountList[0].Id, 5);
		test.stopTest();
		System.assert(casesList.size() > 0, 'No Cases found!');
	}
}