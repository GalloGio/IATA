@IsTest
public with sharing class CustomerSyncUtilsTest {

	private final static String ACCOUNT_RT_DEV_NAME_STANDARD_ACCOUNT = 'Standard_Account';
	private final static String BUSINESS_CONTEXT = 'E&F';

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
			accounts.add(new Account(
				Name = 'airportAccount2',
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
			insert accounts.get(3);

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
			addresses.add(new Address__c(
				Account__c = accounts.get(2).Id,
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
			addressRoles.add(new Address_Role__c(
				Address__c = addresses.get(2).Id,
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
			addressRoleBusinessContexts.add(new Address_Role_Business_Context__c(
				Address_Role__c = addressRoles.get(2).Id,
				Business_Context__c = businessContexts.get(0).Id
			));
			insert addressRoleBusinessContexts;
		}
	}

	private static testMethod void testDoSynchronizationOnStandardAccountNotSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContext = [
				SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__c
				FROM Address_Role_Business_Context__c
				WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];


			addressRoleBusinessContext.Account_Activation_Context_Status__c = null;
			update addressRoleBusinessContext;

			Test.startTest();

			CustomerSyncUtils.mapToSend = null;
			update new Address_Role_Business_Context__c(
				Id = addressRoleBusinessContext.Id,
				Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK
			);
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			update new Address_Role__c(
				Id = addressRoleBusinessContext.Address_Role__c,
				SIS_Location_ID__c = '003'
			);
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			update new Account(
				Id = addressRoleBusinessContext.Address_Role__r.Address__r.Account__c,
				Business_Postal_Code__c = '33000'
			);
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());
			
			CustomerSyncUtils.mapToSend = null;
			update new Account(
				Id = addressRoleBusinessContext.Address_Role__r.Address__r.Account__c,
				EF_SIS_Code__c = '002'
			);
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			Test.stopTest();
		}
	}

	private static testMethod void testDoSynchronizationOnStandardAccountSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContext = [
				SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__c, Address_Role__r.Address__r.Account__r.Business_City_Name__c
				FROM Address_Role_Business_Context__c
				WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Test.startTest();
			
			CustomerSyncUtils.mapToSend = null;
			addressRoleBusinessContext.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContext;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			addressRoleBusinessContext.Address_Role__r.SIS_Location_ID__c = '001';
			update addressRoleBusinessContext.Address_Role__r;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			addressRoleBusinessContext.Address_Role__r.Address__r.PO_Box_Address__c = '1';
			update addressRoleBusinessContext.Address_Role__r.Address__r;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			addressRoleBusinessContext.Address_Role__r.Address__r.Account__r.Business_City_Name__c = 'City1';
			update addressRoleBusinessContext.Address_Role__r.Address__r.Account__r;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			delete addressRoleBusinessContext;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			Test.stopTest();
		}
	}

	private static testMethod void testDoSynchronizationOnBranchSynchronized(){
		IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = 'Country' LIMIT 1];
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContextParentAccount = [
				SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__c
				FROM Address_Role_Business_Context__c
				WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Test.startTest();

			addressRoleBusinessContextParentAccount.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContextParentAccount;

			update new Account(
				Id = addressRoleBusinessContextParentAccount.Address_Role__r.Address__r.Account__c, 
				Sold_To_Completed__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK
			);

			List<Address__c> addresses = new List<Address__c>();
			addresses.add(new Address__c(
				Account__c = [SELECT Id FROM Account WHERE Name = 'branchAccount'].get(0).Id,
				Street__c = 'Street',
				Is_Business_Address__c = true,
				IATA_ISO_Country__c = country.Id
			));
			insert addresses;

			List<Address_Role__c> addressRoles = new List<Address_Role__c>();
			addressRoles.add(new Address_Role__c(
				Address__c = addresses.get(0).Id,
				Role_Type__c = 'Shipping'
			));
			insert addressRoles;

			CustomerSyncUtils.mapToSend = null;
			List<Address_Role_Business_Context__c> addressRoleBusinessContexts = new List<Address_Role_Business_Context__c>();
			addressRoleBusinessContexts.add(new Address_Role_Business_Context__c(
				Address_Role__c = addressRoles.get(0).Id,
				Business_Context__c = [SELECT Id FROM Business_Context__c WHERE Business_Context__c = :BUSINESS_CONTEXT].get(0).Id
			));
			insert addressRoleBusinessContexts;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			Test.stopTest();
		}
	}

	private static testMethod void testDoSynchronizationOnAirportSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContextAirportAuthority = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__c
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Address_Role_Business_Context__c addressRoleBusinessContext = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__c
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'airportAccount'
			];

			Address_Role_Business_Context__c addressRoleBusinessContext2 = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__c
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'airportAccount2'
			];

			Id parentAccountId = [SELECT Id FROM Account WHERE Name = 'standardAccount'].get(0).Id;

			Test.startTest();

			addressRoleBusinessContextAirportAuthority.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContextAirportAuthority;

			CustomerSyncUtils.mapToSend = null;
			List<Account_Relationship__c> accountRelationships = new List<Account_Relationship__c>();
			accountRelationships.add(new Account_Relationship__c(
				Parent_Account__c = parentAccountId,
				Child_Account__c = addressRoleBusinessContext.Address_Role__r.Address__r.Account__c
			));
			insert accountRelationships;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			CustomerSyncUtils.mapToSend = null;
			delete accountRelationships;
			System.assertEquals(1, CustomerSyncUtils.mapToSend.size());

			Test.stopTest();
		}
	}
}