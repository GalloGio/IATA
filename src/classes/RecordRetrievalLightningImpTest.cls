@isTest
public with sharing class RecordRetrievalLightningImpTest {
	public static final String DEFAULTNAME = 'TEST ACCOUNT';
	public static final String DEFAULTEMAIL = 'abc@def.com.invalid';
	public static final String DEFAULTLASTNAME = 'Contact Last Name';
	public static final String DEFAULTCONTACTPHONE = '91111111';
	public static final String DEFAULTACCOUNTPHONE = '81111111';
	public static final String DEFAULTIATACODE = '618';
	public static final String DEFAULTFOLDERID = 'Singapore#SIN#English#Airline_Differenciated#Singapore Airlines#618#618#Differentiated Service Model#';

	@TestSetup
	static void makeData() {
		List<IATA_ISO_Country__c> iataISOCountryList = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1);
		insert iataISOCountryList;
		//get standard record type
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'Others');
		//get iataISOCountry ID
		IATA_ISO_Country__c iataISOCountry = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = :TestDataFactory_IATAISOCountries.DEFAULTCOUNTRYNAME].get(0);
		Integer numberOfRecords = 2;
		//create and return Account List
		List<Account> accountList = new List<Account>();
		for (Integer x = 0; x < numberOfRecords; x ++){
			Account account = new Account(Name = DEFAULTNAME + ' ' + x, RecordTypeId = recordTypeId, IATA_ISO_Country__c = iataISOCountry.Id, IATACode__c = DEFAULTIATACODE, Phone=DEFAULTACCOUNTPHONE+x);
			accountList.add(account);
		}
		insert accountList;

		//create Contacts
		List<Contact> contactList = new List<Contact>();
		for(Integer x = 0; x < numberOfRecords; x++){
			Contact contact = new Contact(Email = DEFAULTEMAIL + x, AccountId = accountList.get(0).Id, LastName = DEFAULTLASTNAME, Phone = DEFAULTCONTACTPHONE+x);
			contactList.add(contact);
		}
		insert contactList;

		Case testCase1 = ISSP_ObjectFactory.createNewCase();
		testCase1.BSPCountry__c = 'Hong Kong (SAR), China';
		testCase1.Reason1__c = 'Agency';
		testCase1.Case_Language__c = 'English';
		testCase1.Subject = DEFAULTFOLDERID;
		testCase1.Reopened_case__c = 0.0;
		testCase1.IFAP_Country_ISO__c = 'tq';
		testCase1.AccountId = accountList[0].id;
		testCase1.ContactId = contactList[0].id;
		testCase1.Type = 'test';
		testCase1.Origin = 'Phone';

		Case testCase2 = ISSP_ObjectFactory.createNewCase();
		testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
		testCase2.Reason1__c = 'Agency';
		testCase2.Case_Language__c = 'English';
		testCase2.Subject = DEFAULTFOLDERID;
		testCase2.Reopened_case__c = 0.0;
		testCase2.IFAP_Country_ISO__c = 'tq';
		testCase2.AccountId = accountList[0].id;
		testCase2.ContactId = contactList[0].id;
		testCase2.Type = 'test';
		testCase2.Origin = 'Email';
		List<Case> lstCase = new List<Case>{testCase1, testCase2};
		insert lstCase;
	}

	@isTest
	public static void recordRetrivalImplementationNoPhoneFoundTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		String phoneNum = '999888777';
		String phoneIntNum = '+44999888777';
		String phoneLocalNum = '999888777';
		String folderId = DEFAULTFOLDERID;
		test.startTest();
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		test.stopTest();
		System.assert(result != null, 'Contact/Account found!');
	}

	@isTest
	public static void recordRetrivalImplementationContactsNoSearchDataTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Contact> contact = [SELECT Id, Phone FROM Contact];
		Set<Id> ctIds = (new Map<Id,SObject>(contact)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String partialPhone = ''; 
		String phoneNum = '';
		String phoneIntNum = '';
		String phoneLocalNum = '';
		String folderId = DEFAULTFOLDERID;
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Contacts found!');
	}

	@isTest
	public static void recordRetrivalImplementationNothingFoundTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		String phoneNum = '999888777';
		String phoneIntNum = '+44999888777';
		String phoneLocalNum = '999888777';
		String folderId = 'NO#NEED#FOLDERID';
		test.startTest();
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		test.stopTest();
		System.assert(result != null, 'Contact/Account found!');
	}

	@isTest
	public static void recordRetrivalImplementationContactPhoneFoundTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Contact> contact = [SELECT Id, Phone FROM Contact LIMIT 1];
		Set<Id> ctIds = (new Map<Id,SObject>(contact)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String phoneNum = contact[0].Phone;
		String phoneIntNum = '+44'+contact[0].Phone;
		String phoneLocalNum = contact[0].Phone;
		String folderId = DEFAULTFOLDERID;
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Contact found!');
	}

	@isTest
	public static void recordRetrivalImplementationContactsPhoneFoundTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Contact> contact = [SELECT Id, Phone FROM Contact];
		Set<Id> ctIds = (new Map<Id,SObject>(contact)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String partialPhone = contact[0].Phone; 
		String phoneNum = partialPhone.substring(0, 5);
		String phoneIntNum = '+44'+partialPhone.substring(0, 5);
		String phoneLocalNum = partialPhone.substring(0, 5);
		String folderId = DEFAULTFOLDERID;
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Contacts found!');
	}

	@isTest
	public static void recordRetrivalImplementationAccountPhoneFoundTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Account> accounts = [SELECT Id, Phone FROM Account LIMIT 1];
		Set<Id> ctIds = (new Map<Id,SObject>(accounts)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String phoneNum = accounts[0].Phone;
		String phoneIntNum = '+44'+accounts[0].Phone;
		String phoneLocalNum = accounts[0].Phone;
		String folderId = DEFAULTFOLDERID;
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Account found!');
	}

	@isTest
	public static void recordRetrivalImplementationAccountsPhoneFoundTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Account> accounts = [SELECT Id, Phone FROM Account];
		Set<Id> ctIds = (new Map<Id,SObject>(accounts)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String partialPhone = accounts[0].Phone; 
		String phoneNum = partialPhone.substring(0, 5);
		String phoneIntNum = '+44'+partialPhone.substring(0, 5);
		String phoneLocalNum = partialPhone.substring(0, 5);
		String folderId = DEFAULTFOLDERID;
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Accounts found!');
	}

	@isTest
	public static void recordRetrivalImplementationPhoneCallbackTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Case> cases = [SELECT Id, Subject FROM Case WHERE Origin='Phone'];
		Set<Id> ctIds = (new Map<Id,SObject>(cases)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String phoneNum = '91111111';
		String phoneIntNum = '+4491111111';
		String phoneLocalNum = '91111111';
		String folderId = '618';
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','callback','444');
		Test.stopTest();
		System.assert(result != null, 'No Cases found!');
	}

	@isTest
	public static void recordRetrivalImplementationPhoneCallback1Test() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Case> cases = [SELECT Id, Subject FROM Case];
		Set<Id> ctIds = (new Map<Id,SObject>(cases)).keySet();
		List<Id> fixedSearchResults = new List<Id>(ctIds);
		String phoneNum = '91111111';
		String phoneIntNum = '+4491111111';
		String phoneLocalNum = '91111111';
		String folderId = '618';
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','callback','444');
		Test.stopTest();
		System.assert(result != null, 'No Cases found!');
	}

	@isTest
	public static void recordRetrivalImplementationOneAccountTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Account> accounts = [SELECT Id, Phone FROM Account];
		List<Id> fixedSearchResults = new List<Id>();
		fixedSearchResults.add(accounts[0].Id);
		String newPhone = '71717171';
		accounts[0].Phone = newPhone;
		update accounts;
		String phoneNum = newPhone;
		String phoneIntNum = '+44'+newPhone;
		String phoneLocalNum = newPhone;
		String folderId = 'NO#NEED#FOLDERID';
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Accounts found!');
	}

	@isTest
	public static void recordRetrivalImplementationManyAccountsTest() {
		OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult result = new OdigoCti.RecordRetrievalLightningInterface_v3.SearchResult();
		RecordRetrievalLightningImplementation odigo_cs = new RecordRetrievalLightningImplementation();
		List<Account> accounts = [SELECT Id, Phone FROM Account];
		List<Id> fixedSearchResults = new List<Id>();
		Set<Id> ctIds = (new Map<Id,SObject>(accounts)).keySet();
		fixedSearchResults = new List<Id>(ctIds);
		String newPhone = '71717171';
		accounts[0].Phone = newPhone;
		accounts[1].Phone = newPhone;
		update accounts;
		String phoneNum = newPhone;
		String phoneIntNum = '+44'+newPhone;
		String phoneLocalNum = newPhone;
		String folderId = 'NO#NEED#FOLDERID';
		Test.startTest();
		Test.setFixedSearchResults(fixedSearchResults);
		result = odigo_cs.SearchRecords(phoneNum,phoneIntNum,phoneLocalNum,folderId,'111','222','call','444');
		Test.stopTest();
		System.assert(result != null, 'No Accounts found!');
	}
}