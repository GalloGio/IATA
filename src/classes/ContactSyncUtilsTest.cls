@IsTest
public with sharing class ContactSyncUtilsTest {

	private final static String ACCOUNT_RT_DEV_NAME_STANDARD_ACCOUNT = 'Standard_Account';
	private final static String BUSINESS_CONTEXT = 'E&F';
	private final static String FUNCTIONAL_ROLE_EF = 'E&F';

	@TestSetup
	public static void init() {
		User admin = TestUtilities.createAdminUser();
		System.runAs(admin){
			Id standardAccountRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', ACCOUNT_RT_DEV_NAME_STANDARD_ACCOUNT);

			List<Business_Context__c> businessContexts = new List<Business_Context__c>();
			businessContexts.add(new Business_Context__c(
				Name = 'businessContext1',
				Business_Context__c = BUSINESS_CONTEXT,
				Sub_Context__c = 'E&F Standard'

			));
			insert businessContexts;

			IATA_ISO_Country__c iataIsoCountry = new IATA_ISO_Country__c(
				Name = 'Country',
				ISO_Code__c = 'CT',
				ISO_Code_Numeric__c = 1
			);
			insert iataIsoCountry;

			List<Account> accounts = new List<Account>();
			accounts.add(new Account(
				Name = 'standardAccount',
				RecordTypeId = standardAccountRtId,
				Sector__c = 'Accommodation',
				IATA_ISO_Country__c = iataIsoCountry.Id
			));
			accounts.add(new Account(
				Name = 'airportAccount',
				RecordTypeId = CustomerSyncUtils.ACCOUNT_RECORDTYPEID_AIRPORT,
				Sector__c = 'Accommodation',
				IATACode__c = 'OX',
				IATA_ISO_Country__c = iataIsoCountry.Id,
				Business_State_Name__c = 'State',
				Business_City_Name__c = 'City',
				Business_Postal_Code__c = 'Postal',
				Business_Street__c = 'Street',
				Business_Po_Box__c = 'PoBox'
			));
			insert accounts;
			accounts.add(new Account(
				Name = 'branchAccount',
				RecordTypeId = standardAccountRtId,
				Hierarchy_Level__c = CustomerSyncUtils.ACCOUNT_HIERARCHY_LEVEL_BRANCH,
				ParentId = accounts.get(0).Id,
				Sector__c = 'Accommodation',
				IATA_ISO_Country__c = iataIsoCountry.Id
			));
			insert accounts.get(2);


			List<Account_Role__c> accountRoles = new List<Account_Role__c>();
			accountRoles.add(new Account_Role__c(
				Account__c = accounts.get(0).Id,
				Functional_Role__c = FUNCTIONAL_ROLE_EF
			));
			insert accountRoles;

			List<Address__c> addresses = new List<Address__c>();
			addresses.add(new Address__c(
				Account__c = accounts.get(0).Id,
				Street__c = 'Street1',
				Is_Business_Address__c = true,
				IATA_ISO_Country__c = iataIsoCountry.Id
			));
			addresses.add(new Address__c(
				Account__c = accounts.get(1).Id,
				Street__c = 'Street2',
				IATA_ISO_Country__c = iataIsoCountry.Id
			));
			insert addresses;

			List<Address_Role__c> addressRoles = new List<Address_Role__c>();
			addressRoles.add(new Address_Role__c(
				Address__c = addresses.get(0).Id,
				Role_Type__c = CustomerSyncUtils.ADDRESS_ROLE_ROLE_TYPE_BUSINESS
			));
			addressRoles.add(new Address_Role__c(
				Address__c = addresses.get(1).Id,
				Role_Type__c = 'Shipping'
			));
			insert addressRoles;

			List<Address_Role_Business_Context__c> addressRoleBusinessContexts = new List<Address_Role_Business_Context__c>();
			addressRoleBusinessContexts.add(new Address_Role_Business_Context__c(
				Address_Role__c = addressRoles.get(0).Id,
				Business_Context__c = businessContexts.get(0).Id
			));
			addressRoleBusinessContexts.add(new Address_Role_Business_Context__c(
				Address_Role__c = addressRoles.get(1).Id,
				Business_Context__c = businessContexts.get(0).Id
			));
			insert addressRoleBusinessContexts;

			List<Contact> contacts = new List<Contact>();
			contacts.add(new Contact(
				FirstName = 'contact1',
				LastName = 'contact1',
				AccountId = accounts.get(0).Id
			));
			insert contacts;
		}
	}

	private static testMethod void testDoSynchronizationOnStandardAccount(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContext = [
				SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__r.Id
				FROM Address_Role_Business_Context__c
				WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Contact contact = [SELECT Id FROM Contact WHERE FirstName = 'contact1'];


			List<Account_Contact_Role__c> accountContactRoles = new List<Account_Contact_Role__c>();
			accountContactRoles.add(new Account_Contact_Role__c(
				Account_Role__c = [SELECT Id FROM Account_Role__c WHERE Account__c = :addressRoleBusinessContext.Address_Role__r.Address__r.Account__r.Id].get(0).Id,
				Contact__c = contact.Id,
				Functional_Role__c = FUNCTIONAL_ROLE_EF,
				Service_Rendered__c = 'TIP'
			));
			insert accountContactRoles;

			Test.startTest();

			ContactSyncUtils.mapToSend = null;
			addressRoleBusinessContext.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContext;
			System.assertEquals(1, ContactSyncUtils.mapToSend.size());

			ContactSyncUtils.mapToSend = null;
			contact.Title = 'title1';
			update contact;
			System.assertEquals(1, ContactSyncUtils.mapToSend.size());

			
			Test.stopTest();
		}
	}
}