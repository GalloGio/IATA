@isTest
public with sharing class AccountDashboardCTIContactsTest {
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

		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c app1 = portalApplicationList.get(0);
		app1.Name = 'IATA Test1';
		Portal_Applications__c app2 = portalApplicationList.get(1);
		app2.Name = 'IATA Test2';

		insert portalApplicationList;

		List<Portal_Application_Right__c> portalAppRights = new List<Portal_Application_Right__c>();
		portalAppRights.add(new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = app1.Id, Access_Status_Reason__c = 'IATA Test1', Contact__c = contactList[0].Id ));
		portalAppRights.add(new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = app2.Id, Access_Status_Reason__c = 'IATA Test1', Contact__c = contactList[1].Id ));
		insert portalAppRights;
	}

	@isTest
	public static void searchPortalServicesForAccountAndContactsTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		List<Contact> contactList = [SELECT Id FROM Contact LIMIT 2];
		Set<Id> contactsIds = (new Map<Id,Contact>(contactList)).keySet();
		test.startTest();
		List<Portal_Application_Right__c> portalAR = AccountDashboardCTIContactsCtrl.searchPortalServicesForAccountAndContacts(accountList[0].Id, contactsIds);
		test.stopTest();
		System.assert(portalAR.size() > 0, 'No Portal Services found!');
	}

	@isTest
	public static void searchKeyContactsSelectedTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		List<Contact> contactList = [SELECT Id FROM Contact LIMIT 2];
		test.startTest();
		List<Contact> contacts = AccountDashboardCTIContactsCtrl.searchKeyContacts(accountList[0].Id, contactList[0].Id, 5);
		test.stopTest();
		System.assert(contacts.size() > 0, 'No Contacts (w/ selected) found!');
	}

	@isTest
	public static void searchKeyContactsAllTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		test.startTest();
		List<Contact> contacts = AccountDashboardCTIContactsCtrl.searchKeyContacts(accountList[0].Id, null, 5);
		test.stopTest();
		System.assert(contacts.size() > 0, 'No Contacts found!');
	}

	@isTest
	public static void getKeyContactsTest() {
		List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
		List<Contact> contactList = [SELECT Id FROM Contact LIMIT 2];
		test.startTest();
		List<AccountDashboardCTIContactsCtrl.KeyContact> contacts = AccountDashboardCTIContactsCtrl.getKeyContacts(accountList[0].Id, contactList[0].Id);
		test.stopTest();
		System.assert(contacts.size() > 0, 'No Contacts found!');
	}
}