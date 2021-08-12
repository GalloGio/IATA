@isTest
public with sharing class AccountDashboardCTIHeaderTest {
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
	}


	@isTest
	public static void getAccountHeaderTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		test.startTest();
		Account acc = AccountDashboardCTIHeaderCtrl.getAccountHeader(accountList[0].Id);
		test.stopTest();
		System.assert(acc != null, 'No Account found!');
	}
}