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
					Sector__c = 'Accommodation'
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
					Sector__c = 'Accommodation'
			));
			insert accounts.get(2);

			List<Address__c> addresses = new List<Address__c>();
			addresses.add(new Address__c(
					Account__c = accounts.get(0).Id,
					Street__c = 'Street1',
					Is_Business_Address__c = true
			));
			addresses.add(new Address__c(
					Account__c = accounts.get(1).Id,
					Street__c = 'Street2'
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
		}
	}

	private static testMethod void testDoSynchronizationOnStandardAccountNotSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContext = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__r.Id
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Test.startTest();

			update addressRoleBusinessContext;
			update addressRoleBusinessContext.Address_Role__r;
			update addressRoleBusinessContext.Address_Role__r.Address__r;
			update addressRoleBusinessContext.Address_Role__r.Address__r.Account__r;

			Test.stopTest();

			System.assertEquals(0, [SELECT Id FROM ISSP_Web_Service_Log__c].size());
		}
	}

	private static testMethod void testDoSynchronizationOnStandardAccountSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContext = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__r.Id
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Test.startTest();

			addressRoleBusinessContext.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContext;

			addressRoleBusinessContext.Address_Role__r.SIS_Location_ID__c = 'Main';
			update addressRoleBusinessContext.Address_Role__r;

			addressRoleBusinessContext.Address_Role__r.Address__r.Po_Box__c = '1';
			update addressRoleBusinessContext.Address_Role__r.Address__r;

			addressRoleBusinessContext.Address_Role__r.Address__r.Account__r.Business_City_Name__c = 'City1';
			update addressRoleBusinessContext.Address_Role__r.Address__r.Account__r;

			delete addressRoleBusinessContext;

			Test.stopTest();

			System.assertEquals(0, [SELECT Id FROM ISSP_Web_Service_Log__c].size());
		}
	}

	private static testMethod void testDoSynchronizationOnBranchSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContextParentAccount = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__r.Id
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Test.startTest();

			addressRoleBusinessContextParentAccount.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContextParentAccount;

			List<Address__c> addresses = new List<Address__c>();
			addresses.add(new Address__c(
					Account__c = [SELECT Id FROM Account WHERE Name = 'branchAccount'].get(0).Id,
					Street__c = 'Street',
					Is_Business_Address__c = true
			));
			insert addresses;

			List<Address_Role__c> addressRoles = new List<Address_Role__c>();
			addressRoles.add(new Address_Role__c(
					Address__c = addresses.get(0).Id,
					Role_Type__c = 'Shipping'
			));
			insert addressRoles;

			List<Address_Role_Business_Context__c> addressRoleBusinessContexts = new List<Address_Role_Business_Context__c>();
			addressRoleBusinessContexts.add(new Address_Role_Business_Context__c(
					Address_Role__c = addressRoles.get(0).Id,
					Business_Context__c = [SELECT Id FROM Business_Context__c WHERE Business_Context__c = :BUSINESS_CONTEXT].get(0).Id
			));
			insert addressRoleBusinessContexts;

			Test.stopTest();

			System.assertEquals(0, [SELECT Id FROM ISSP_Web_Service_Log__c].size());
		}
	}

	private static testMethod void testDoSynchronizationOnAirportSynchronized(){
		User admin = [SELECT Id FROM User WHERE Username LIKE 'test-%@weitclick.de.test' LIMIT 1];
		System.runAs(admin) {
			Address_Role_Business_Context__c addressRoleBusinessContextAirportAuthority = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__r.Id
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'standardAccount'
			];

			Address_Role_Business_Context__c addressRoleBusinessContext = [
					SELECT Id, Address_Role__c, Address_Role__r.Address__c, Address_Role__r.Address__r.Account__r.Id
					FROM Address_Role_Business_Context__c
					WHERE Address_Role__r.Address__r.Account__r.Name = 'airportAccount'
			];

			Test.startTest();

			addressRoleBusinessContextAirportAuthority.Account_Activation_Context_Status__c = CustomerSyncUtils.ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK;
			update addressRoleBusinessContextAirportAuthority;

			List<Account_Relationship__c> accountRelationships = new List<Account_Relationship__c>();
			accountRelationships.add(new Account_Relationship__c(
					Parent_Account__c = [SELECT Id FROM Account WHERE Name = 'standardAccount'].get(0).Id,
					Child_Account__c = addressRoleBusinessContext.Address_Role__r.Address__r.Account__r.Id
			));
			insert accountRelationships;

			update accountRelationships;

			delete accountRelationships;

			Test.stopTest();

			System.assertEquals(0, [SELECT Id FROM ISSP_Web_Service_Log__c].size());
		}
	}
}