@isTest
public with sharing class AccountDashboardCTITest {
	public static final String DEFAULTNAME = 'TEST ACCOUNT';

	@TestSetup
	static void makeData() {
		List<IATA_ISO_Country__c> iataISOCountryList = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1);
		insert iataISOCountryList;
		//get standard record type
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
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

		// Create a new Contact for the Account
		Id contactStdRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test_AccountCTIController@test.com', AccountId = accountList.get(0).Id, RecordTypeId = contactStdRTId);
		insert c;
	}

	@isTest
	public static void accountDashboardCTIOkTest(){
		//init();
		Account acc = [SELECT Id, Name FROM Account LIMIT 1];
		Contact con = [SELECT Id, Name FROM contact LIMIT 1];
		test.startTest();
			ApexPages.currentPage().getParameters().put('contactId',con.Id);
			AccountDashboardCTI adCTI = new AccountDashboardCTI(new ApexPages.StandardController(acc));
		test.stopTest();
		System.assert(adCTI.accountId!=null, 'Must have an AccountId!');
	}
	@isTest
	public static void accountDashboardCTINOkTest(){
		//init();
		Account acc = new Account();
		test.startTest();
			AccountDashboardCTI adCTI = new AccountDashboardCTI(new ApexPages.StandardController(acc));
		test.stopTest();
		System.assert(adCTI.accountId==null, 'Must have an empty Account!');
	}
	@isTest
	public static void accountDashboardCTIErrorTest(){
		//init();
		test.startTest();
			AccountDashboardCTI adCTI = new AccountDashboardCTI(null);
		test.stopTest();
		System.assert(adCTI.accountId==null, 'Must trigger an error!');
	}

	@isTest
	public static void accountDashboardCTICheckAndRedirectTest(){
		Contact con = [SELECT Id, Name FROM contact LIMIT 1];
		Test.startTest();
			ApexPages.currentPage().getParameters().put('id',con.Id);
			ApexPages.StandardController stdCtrl = new ApexPages.StandardController(con);
			AccountDashboardCTI cdCTI = new AccountDashboardCTI(stdCtrl);
			cdCTI.checkandredirect();
			System.assert(cdCTI.accountId!=null, 'Must trigger an error!');
		Test.stopTest();
	}

	@isTest
	public static void accountDashboardCTIErrorCheckAndRedirectTest(){
		Test.startTest();
			ApexPages.currentPage().getParameters().put('id','');
			AccountDashboardCTI cdCTI = new AccountDashboardCTI(null);
			cdCTI.checkandredirect();
			System.assert(cdCTI.accountId==null, 'Must trigger an error!');
		Test.stopTest();
	}
}