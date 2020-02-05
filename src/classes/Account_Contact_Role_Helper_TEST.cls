@IsTest
public with sharing class Account_Contact_Role_Helper_TEST {

	@TestSetup
	private static void setup() {

		Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'Cs';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;

		List<Account> accountsToInsert = new List<Account>();

		Account acc = new Account();
		acc.Name = 'Test account';
		acc.BillingCity = 'Montreal';
		acc.BillingCountry = 'Canada';
		acc.BillingStreet = 'some street';
		acc.IATA_ISO_Country__c = country.Id;
		acc.Location_Type__c = 'HO';
		acc.IATACode__c = '1234567';
		acc.Type = 'IATA Cargo Agent';
		acc.Status__c = 'Approved';
		acc.RecordTypeId = headquarters;
		accountsToInsert.add(acc);

		Account acc2 = new Account();
		acc2.Name = 'Test account 2';
		acc2.BillingCity = 'Montreal';
		acc2.BillingCountry = 'Canada';
		acc2.BillingStreet = 'some street';
		acc2.IATA_ISO_Country__c = country.Id;
		acc2.Location_Type__c = 'HO';
		acc2.IATACode__c = '1234567';
		acc2.Type = 'IATA Cargo Agent';
		acc2.Status__c = 'Approved';
		acc2.RecordTypeId = headquarters;
		accountsToInsert.add(acc2);

		insert accountsToInsert;

		Contact testContact = createContact('Neo', 'Smith', acc);
		Contact testContact2 = createContact('Leo', 'Black', acc2);
		Contact testContact3 = createContact('Joseph', 'White', acc2);

		Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

		User testUser = createUser(testContact, profileId);
		User testUser2 = createUser(testContact2, profileId);
		User testUser3 = createUser(testContact3, profileId);

		//GADM service
		Portal_Applications__c portalApplications = new Portal_Applications__c();
		portalApplications.Name = 'GADM';
		insert portalApplications;

		//GADM Participang Account Role
		Account_Roles__c accountRoles = new Account_Roles__c();
		accountRoles.Name = 'GADM Participant';
		insert accountRoles;

		Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
		accountRoleServices.Portal_Service__c = portalApplications.Id;
		accountRoleServices.Account_Roles__c = accountRoles.Id;
		insert accountRoleServices;

		Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

		Date today = Date.today();

		List<Account_Role__c> accountRolesToInsert = new List<Account_Role__c>();

		Account_Role__c accountRole = new Account_Role__c();
		accountRole.RecordTypeId = defaultRecordTypeId;
		accountRole.Account__c = acc.Id;
		accountRole.Account_Roles__c = accountRoles.Id;
		accountRole.Status__c = 'Active';
		accountRole.Effective_From_Date__c = today.addDays(-2);
		accountRole.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole);

		Account_Role__c accountRole2 = new Account_Role__c();
		accountRole2.RecordTypeId = defaultRecordTypeId;
		accountRole2.Account__c = acc2.Id;
		accountRole2.Account_Roles__c = accountRoles.Id;
		accountRole2.Status__c = 'Active';
		accountRole2.Effective_From_Date__c = today.addDays(-2);
		accountRole2.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole2);

		insert accountRolesToInsert;

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

		List<Contact_Roles__c> contactRolesToInsert = new List<Contact_Roles__c>();

		//possible contact roles
		Contact_Roles__c contactRoles = new Contact_Roles__c();
		contactRoles.Name = 'GADM User';
		contactRoles.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles);

		Contact_Roles__c contactRoles2 = new Contact_Roles__c();
		contactRoles2.Name = 'Service Power User';
		contactRoles2.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles2);

		Contact_Roles__c contactRoles3 = new Contact_Roles__c();
		contactRoles3.Name = 'Service Super User';
		contactRoles3.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles3);

		Contact_Roles__c contactRoles4 = new Contact_Roles__c();
		contactRoles4.Name = 'GADM Data Submitter';
		contactRoles4.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles4);

		Contact_Roles__c contactRoles5 = new Contact_Roles__c();
		contactRoles5.Name = 'Security';
		contactRoles5.Category__c = 'Business Unit';
		contactRoles5.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles5);

		insert contactRolesToInsert;

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		List<Account_Contact_Role__c> accountContactRolesToInset = new List<Account_Contact_Role__c>();

		//Account contact role for test user and gadm role
		Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
		accountContactRole.Contact__c = testContact.Id;
		accountContactRole.Contact_Roles__c = contactRoles.Id;
		accountContactRole.Account_Role__c = accountRole.Id;
		accountContactRole.Service_Rendered__c = 'GADM';
		accountContactRole.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInset.add(accountContactRole);

		Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
		accountContactRole3.Contact__c = testContact.Id;
		accountContactRole3.Contact_Roles__c = contactRoles.Id;
		accountContactRole3.Account_Role__c = accountRole2.Id;
		accountContactRole3.Service_Rendered__c = 'GADM';
		accountContactRole3.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInset.add(accountContactRole3);


		//for test user 2 and gadm user role
		Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
		accountContactRole4.Contact__c = testContact2.Id;
		accountContactRole4.Contact_Roles__c = contactRoles.Id;
		accountContactRole4.Account_Role__c = accountRole2.Id;
		accountContactRole4.Service_Rendered__c = 'GADM';
		accountContactRole4.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInset.add(accountContactRole4);

		Account_Contact_Role__c accountContactRole5 = new Account_Contact_Role__c();
		accountContactRole5.Contact__c = testContact2.Id;
		accountContactRole5.Contact_Roles__c = contactRoles.Id;
		accountContactRole5.Account_Role__c = accountRole2.Id;
		accountContactRole5.Service_Rendered__c = 'GADM';
		accountContactRole5.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInset.add(accountContactRole5);

		insert accountContactRolesToInset;

	}

	private static Contact createContact(String firstName, String lastName, Account acc) {
		Contact testContact = new Contact();
		testContact.AccountId = acc.id;
		testContact.Firstname = firstName;
		testContact.Lastname= lastName;
		testContact.Phone = '911111113';
		testContact.MobilePhone = '911111113';
		testContact.Email = firstName + '.' + lastName + '.test@somedomain.com';
		testContact.BSP_CASS_Payment_contact__c = false;
		testContact.User_Portal_Status__c = 'Approved';
		insert testContact;
		return testContact;
	}

	private static User createUser(Contact testContact, Id profileId) {
		User testUser = new User();
		testUser.alias = 'dsfsdfds';
		testUser.email = testContact.email;
		testUser.emailencodingkey = 'UTF-8';
		testUser.firstname = testContact.firstName;
		testUser.lastname = testContact.lastname;
		testUser.languagelocalekey = 'en_US';
		testUser.localesidkey = 'en_US';
		testUser.contactId = testContact.Id;
		testUser.FederationIdentifier = testContact.Id;
		testUser.timezonesidkey = 'Asia/Dubai';
		testUser.Username = testContact.Email;
		testUser.PortalRole = 'Manager';
		testUser.CommunityNickname = (testContact.FirstName + testContact.LastName).substring(0,8);
		testUser.ProfileId = profileId;
		testUser.IsActive = true;
		insert testUser;
		return testUser;
	}

	@IsTest
	private static void insertDuplicateGadmRoleTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
		Contact_Roles__c gadmRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];


		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Account_Contact_Role__c> existing = [SELECT Id, RecordTypeId, Contact_Roles__r.Name, Contact__c, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact_Roles__c = :gadmRole.Id];

		Test.startTest();

		String errorMessage = '';

		System.runAs(testUser) {


			try{
				Account_Contact_Role__c newAccountContactRole = new Account_Contact_Role__c();
				newAccountContactRole.Contact__c = existing[0].Contact__c;
				newAccountContactRole.Account_Role__c = existing[0].Account_Role__c;
				newAccountContactRole.Service_Rendered__c = 'GADM';
				newAccountContactRole.RecordTypeId = existing[0].RecordTypeId;
				newAccountContactRole.Contact_Roles__c = existing[0].Contact_Roles__c;

				insert newAccountContactRole;

			}catch(Exception e) {
				errorMessage = e.getMessage();
				System.debug('error message:: ' + errorMessage);
			}
		}

		Test.stopTest();

		System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');

	}

	@IsTest
	private static void insertDuplicateGadmRole_differentRecordTypeTest() {

		List<User> admins = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];
		Contact_Roles__c gadmRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];


		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Account_Contact_Role__c> existing = [SELECT Id, RecordTypeId, Contact_Roles__r.Name, Contact__c, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact_Roles__c = :gadmRole.Id];

		Test.startTest();

		String errorMessage = '';

		System.runAs(admins[0]) {


			try{

				Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

				Account_Contact_Role__c newAccountContactRole = new Account_Contact_Role__c();
				newAccountContactRole.Contact__c = existing[0].Contact__c;
				newAccountContactRole.Account_Role__c = existing[0].Account_Role__c;
				newAccountContactRole.Service_Rendered__c = 'GADM';
				newAccountContactRole.RecordTypeId = groupRecordTypeId;
				newAccountContactRole.Contact_Roles__c = existing[0].Contact_Roles__c;

				insert newAccountContactRole;

			}catch(Exception e) {
				errorMessage = e.getMessage();
			}
		}

		Test.stopTest();

		System.assertEquals(true, errorMessage == '', 'Inserting account contact role with group record type should be allowed!');

	}

	@IsTest
	private static void updateGadmRoleTest() {

		Contact  testContact = [SELECT Id FROM Contact WHERE Email = 'joseph.white.test@somedomain.com'];

		List<User> admins = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];
		Contact_Roles__c gadmRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];


		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Account_Contact_Role__c> existingGadmRoles = [SELECT Id, RecordTypeId, Contact_Roles__r.Name, Contact__c, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact_Roles__c = :gadmRole.Id];


		Test.startTest();

		String errorMessage = '';

		System.runAs(admins[0]) {


			try{

				Account_Contact_Role__c newAccountContactRole = new Account_Contact_Role__c();
				newAccountContactRole.Contact__c = testContact.Id;
				newAccountContactRole.Account_Role__c = existingGadmRoles[0].Account_Role__c;
				newAccountContactRole.Service_Rendered__c = 'GADM';
				newAccountContactRole.RecordTypeId = functionalRecordTypeId;
				newAccountContactRole.Contact_Roles__c = existingGadmRoles[0].Contact_Roles__c;

				insert newAccountContactRole;

				update newAccountContactRole;

			}catch(Exception e) {
				errorMessage = e.getMessage();
			}
		}

		Test.stopTest();

		System.assertEquals(true, errorMessage == '', 'Updating existing account contact role should be allowed!');

	}

	@IsTest
	private static void insertTwoSameGadmRoleTest() {

		Contact  testContact = [SELECT Id FROM Contact WHERE Email = 'joseph.white.test@somedomain.com'];

		List<User> admins = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];
		Contact_Roles__c gadmRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];


		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Account_Contact_Role__c> existingGadmRoles = [SELECT Id, RecordTypeId, Contact_Roles__r.Name, Contact__c, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact_Roles__c = :gadmRole.Id];


		Test.startTest();

		String errorMessage = '';

		System.runAs(admins[0]) {


			try{

				List<Account_Contact_Role__c> toInsert = new List<Account_Contact_Role__c>();

				Account_Contact_Role__c newAccountContactRole = new Account_Contact_Role__c();
				newAccountContactRole.Contact__c = testContact.Id;
				newAccountContactRole.Account_Role__c = existingGadmRoles[0].Account_Role__c;
				newAccountContactRole.Service_Rendered__c = 'GADM';
				newAccountContactRole.RecordTypeId = functionalRecordTypeId;
				newAccountContactRole.Contact_Roles__c = existingGadmRoles[0].Contact_Roles__c;
				toInsert.add(newAccountContactRole);

				Account_Contact_Role__c newAccountContactRole2 = new Account_Contact_Role__c();
				newAccountContactRole2.Contact__c = testContact.Id;
				newAccountContactRole2.Account_Role__c = existingGadmRoles[0].Account_Role__c;
				newAccountContactRole2.Service_Rendered__c = 'GADM';
				newAccountContactRole2.RecordTypeId = functionalRecordTypeId;
				newAccountContactRole2.Contact_Roles__c = existingGadmRoles[0].Contact_Roles__c;
				toInsert.add(newAccountContactRole2);

				insert toInsert;


			}catch(Exception e) {
				errorMessage = e.getMessage();
			}
		}

		Test.stopTest();

		System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting two same account contact roles should not be allowed!');

	}


	@IsTest
	public static void generateGadmUniqueKeyTest() {


		Contact_Roles__c gadmRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];
		List<User> admins = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		List<Account_Contact_Role__c> existing = [SELECT Id, RecordTypeId, Contact_Roles__c, Contact__c, Account_Role__c, Service_Rendered__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact_Roles__c = :gadmRole.Id AND Service_Rendered__c = 'GADM'];

		String errorMessage = '';

		Test.startTest();

		System.runAs(admins[0]) {

			Account_Contact_Role__c newAccountContactRole = new Account_Contact_Role__c();
			newAccountContactRole.RecordTypeId = existing[0].RecordTypeId;
			newAccountContactRole.Service_Rendered__c = existing[0].Service_Rendered__c;
			newAccountContactRole.Contact__c = existing[0].Contact__c;
			newAccountContactRole.Contact_Roles__c = existing[0].Contact_Roles__c;
			newAccountContactRole.Account_Role__c = existing[0].Account_Role__c;

			try{
				insert newAccountContactRole;
			}catch(DmlException e) {
				errorMessage = e.getMessage();
			}

		}


		Test.stopTest();

		System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'User can have only one Account Contact Role for GADM User role and Reco');

	}

}
