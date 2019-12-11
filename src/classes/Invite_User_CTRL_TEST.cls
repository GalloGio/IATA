@IsTest
public class Invite_User_CTRL_TEST {

	@TestSetup
	private static void setup() {

		List<ISSP_CS__c> settings = new List<ISSP_CS__c>();
		ISSP_CS__c setting = new ISSP_CS__c();
		setting.Name = 'IdentityPortal';
		setting.Value__c = 'gadm-customer-portal-iata.cs100.force.com/identity/s';
		settings.add(setting);

		ISSP_CS__c setting2 = new ISSP_CS__c();
		setting2.Name = 'Host';
		setting2.Value__c = 'portal.iata.org';
		settings.add(setting2);

		insert settings;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'Cs';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;

		Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		List<Account> accountsToInsert = new List<Account>();
		Account testAccount = createAccount('Test account 1', headquarters, country.Id);
		accountsToInsert.add(testAccount);

		Account testAccount2 = createAccount('Test account 2', headquarters, country.Id);
		accountsToInsert.add(testAccount2);

		insert accountsToInsert;

		List<Contact> contactsToInsert = new List<Contact>();
		Contact testContact = createContact('Petr', 'Novak', testAccount);
		Contact testContact2 = createContact('Martina', 'Vesela', testAccount);
		contactsToInsert.add(testContact);
		contactsToInsert.add(testContact2);

		insert contactsToInsert;

		Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

		List<User> usersToInsert = new List<User>();
		User testUser = createUser(testContact, profileId);
		usersToInsert.add(testUser);

		insert usersToInsert;


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
		accountRole.Account__c = testAccount.Id;
		accountRole.Account_Roles__c = accountRoles.Id;
		accountRole.Status__c = 'Active';
		accountRole.Effective_From_Date__c = today.addDays(-2);
		accountRole.Effective_To_Date__c = today.addDays(2);
		accountRolesToInsert.add(accountRole);

		Account_Role__c accountRole2 = new Account_Role__c();
		accountRole2.RecordTypeId = defaultRecordTypeId;
		accountRole2.Account__c = testAccount2.Id;
		accountRole2.Account_Roles__c = accountRoles.Id;
		accountRole2.Status__c = 'Active';
		accountRole2.Effective_From_Date__c = today.addDays(-2);
		accountRole2.Effective_To_Date__c = today.addDays(2);
		accountRolesToInsert.add(accountRole2);

		insert accountRolesToInsert;

		List<Account_Role_Service__c> roleServicesToInsert = new List<Account_Role_Service__c>();

		Account_Role_Service__c roleService = new Account_Role_Service__c();
		roleService.Account_Role__c = accountRole.Id;
		roleService.Account_Role_Services__c = accountRoleServices.Id;
		roleServicesToInsert.add(roleService);

		Account_Role_Service__c roleService2 = new Account_Role_Service__c();
		roleService2.Account_Role__c = accountRole2.Id;
		roleService2.Account_Role_Services__c = accountRoleServices.Id;
		roleServicesToInsert.add(roleService2);

		insert roleServicesToInsert;

		List<GADM_Account_Service_Detail__c> serviceDetailsToInsert = new List<GADM_Account_Service_Detail__c>();

		GADM_Account_Service_Detail__c accountServiceDetail = new GADM_Account_Service_Detail__c();
		accountServiceDetail.Account_Role_Service__c = roleService.Id;
		accountServiceDetail.External_Actor_Id__c = 'ExtIdTest0001';
		accountServiceDetail.Allowed_email_domain__c = 'email.cz;gmail.com;iata.org';
		serviceDetailsToInsert.add(accountServiceDetail);

		GADM_Account_Service_Detail__c accountServiceDetail2 = new GADM_Account_Service_Detail__c();
		accountServiceDetail2.Account_Role_Service__c = roleService2.Id;
		accountServiceDetail2.External_Actor_Id__c = 'ExtIdTest0002';
		accountServiceDetail2.Allowed_email_domain__c = 'email.cz';
		serviceDetailsToInsert.add(accountServiceDetail2);

		insert serviceDetailsToInsert;


		List<Contact_Roles__c> contactRolesToInsert = new List<Contact_Roles__c>();

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

		Contact_Roles__c contactRoles = new Contact_Roles__c();
		contactRoles.Name = 'GADM User';
		contactRoles.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles);

		Contact_Roles__c contactRoles2 = new Contact_Roles__c();
		contactRoles2.Name = 'Service Power User';
		contactRoles2.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles2);

		insert contactRolesToInsert;

		List<Contact_Role_Service__c> contactRoleServicesToInsert = new List<Contact_Role_Service__c>();

		Contact_Role_Service__c contactRoleService = new Contact_Role_Service__c();
		contactRoleService.Service__c = portalApplications.Id;
		contactRoleService.Contact_Role__c = contactRoles.Id;
		contactRoleServicesToInsert.add(contactRoleService);

		Contact_Role_Service__c contactRoleService2 = new Contact_Role_Service__c();
		contactRoleService2.Service__c = portalApplications.Id;
		contactRoleService2.Contact_Role__c = contactRoles2.Id;
		contactRoleServicesToInsert.add(contactRoleService2);

		insert contactRoleServicesToInsert;

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');
		One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'GADM',
				License_Upgrade_Required__c= true,
				Profile_Id__c='',
				Description__c='GADM',
				Is_Active__c = true, Portal_Visible__c = false,
				RecordTypeid = recTypeId, App_Picture_Url__c='oi',
				Customer_Type_Activation__c = 'OtherCompany');
		insert oi;

		One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'GADM', Is_Active__c = true, Portal_Visible__c = false, Service_Bundle__c=oi.id, Customer_Type_Activation__c = 'OtherCompany');
		insert rr;

		One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id, PermissionSet_SSO__c = 'GADM');
		insert r;

		One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Power User', One_Id_App_Config_Detail__c = r.id, Role_Description__c = '');
		insert role;
		One_Id_App_Role_Config__c role2 = new One_Id_App_Role_Config__c (Role_Name__c = 'User', One_Id_App_Config_Detail__c = r.id, Role_Description__c = '');
		insert role2;


		One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
		anUserApp.Application__c = r.id;
		anUserApp.One_Id_Service_Provider_Config__c = rr.id;
		anUserApp.One_Id_App_Bundle__c = oi.id;
		anUserApp.Identity_User__c = UserInfo.getUserId();
		anUserApp.Provisioning_Status__c = 'Started';
		//anUserApp.User_Provisioning_Request__c = uprov.id;
		anUserApp.action__c = 'Add';
		anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
		insert anUserApp;
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

		return testContact;
	}


	private static Account createAccount(String accountName, Id recordTypeId, Id countryId) {
		Account acc = new Account();
		acc.Name = accountName;
		acc.BillingCity = 'Montreal';
		acc.BillingCountry = 'Canada';
		acc.BillingStreet = 'some street';
		acc.IATA_ISO_Country__c = countryId;
		acc.Location_Type__c = 'HO';
		acc.IATACode__c = '1234567';
		acc.Type = 'IATA Cargo Agent';
		acc.Status__c = 'Approved';
		acc.RecordTypeId = recordTypeId;

		return acc;
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

		return testUser;
	}


	@IsTest
	private static void invitationWithContactTest() {

		Contact testContact = [SELECT Id, AccountId, FirstName, LastName, Salutation FROM Contact WHERE Email = 'petr.novak.test@somedomain.com'];
		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		List<Account_Role__c> accRoles = [SELECT Id FROM Account_Role__c WHERE Account__c =: testContact.AccountId];
		Integer count = 0;

		Test.startTest();

		System.runAs(testUser) {

			String contactString = JSON.serialize(testContact);

			Invite_User_CTRL.sendInvitation(contactString, null, false, testContact.AccountId);

			count = Limits.getEmailInvocations();

		}

		Test.stopTest();
		List<Account_Contact_Role__c> roles = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c =: testContact.Id];
		System.assertEquals(2, roles.size(), 'Two roles dhould be created for regular user');
		System.assertEquals(1, count, 'Invitation emails should be sent!');

	}

	@IsTest
	private static void invitationWithContact2Test() {

		Contact testContact = [SELECT Id, AccountId, FirstName, LastName, Salutation FROM Contact WHERE Email = 'martina.vesela.test@somedomain.com'];
		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		List<Account_Role__c> accRoles = [SELECT Id FROM Account_Role__c WHERE Account__c =: testContact.AccountId];

		Integer count = 0;

		Test.startTest();

		System.runAs(testUser) {

			String contactString = JSON.serialize(testContact);

			Invite_User_CTRL.sendInvitation(contactString, null, true, testContact.AccountId);

			count = Limits.getEmailInvocations();

		}

		Test.stopTest();
		List<Account_Contact_Role__c> roles = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c =: testContact.Id];
		System.assertEquals(3, roles.size(), 'Three roles dhould be created for power user');
		System.assertEquals(1, count, 'Invitation emails should be sent!');

	}


	@IsTest
	private static void invitationWithInvitationTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account 1'];

		Invitation__c invitation = new Invitation__c();
		invitation.AccountId__c = testAccount.Id;
		invitation.Email__c = 'some.name@some.domain.com';
		invitation.Last_Name__c = 'Nekonecny';

		Integer count = 0;

		Test.startTest();

		System.runAs(testUser) {

			String invitationString = JSON.serialize(invitation);

			Invite_User_CTRL.sendInvitation(null, invitationString, false, null);

			count = Limits.getEmailInvocations();

		}

		Test.stopTest();

		System.assertEquals(1, count, 'Invitation emails should be sent!');

	}

	@IsTest
	private static void invitationWithInvitation2Test() {

		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account 1'];

		Invitation__c invitation = new Invitation__c();
		invitation.AccountId__c = testAccount.Id;
		invitation.Email__c = 'some.name@some.domain.com';
		invitation.Last_Name__c = 'Dehausenknopf';
		invitation.First_Name__c = 'Frederik';

		Integer count = 0;

		Test.startTest();

		System.runAs(testUser) {

			String invitationString = JSON.serialize(invitation);

			Invite_User_CTRL.sendInvitation(null, invitationString, false, null);

			count = Limits.getEmailInvocations();

		}

		Test.stopTest();

		System.assertEquals(1, count, 'Invitation emails should be sent!');

	}



	@IsTest
	private static void labelsTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

		Test.startTest();

		List<OneId_RegistrationProcessController.PicklistEntry> jobValues = new List<OneId_RegistrationProcessController.PicklistEntry>();
		Map<String, String> contactValues = new Map<String, String>();

		System.runAs(testUser){

			jobValues = Invite_User_CTRL.getContactJobFunctionValues();
			contactValues = Invite_User_CTRL.getContactLabels();

		}

		Test.stopTest();

		System.assertEquals(false, jobValues.isEmpty(), 'Job Function field labels should be retrieved!');
		System.assertEquals(false, contactValues.isEmpty(), 'Contact field labels should be retrieved!');

	}

	@IsTest
	private static void getAccountsTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account 1'];
		Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'petr.novak.test@somedomain.com'];

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		Contact_Roles__c gadmUser = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];
		Account_Role__c accountRole = [SELECT Id FROM Account_Role__c WHERE Account__c =: testAccount.Id];
		List<Account_Contact_Role__c> accountContactRolesToInsert = new List<Account_Contact_Role__c>();

		Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
		accountContactRole.Contact__c = testContact.Id;
		accountContactRole.Contact_Roles__c = gadmUser.Id;
		accountContactRole.Account_Role__c = accountRole.Id;
		accountContactRole.Service_Rendered__c = 'GADM';
		accountContactRole.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole);

		Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
		accountContactRole1.Contact__c = testContact.Id;
		accountContactRole1.Contact_Roles__c = gadmUser.Id;
		accountContactRole1.Account_Role__c = accountRole.Id;
		accountContactRole1.Service_Rendered__c = 'GADM';
		accountContactRole1.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole1);

		insert accountContactRolesToInsert;

		List<Account> accounts = new List<Account>();

		Test.startTest();

		System.runAs(testUser) {
			accounts = Invite_User_CTRL.getUserAccounts();
		}


		System.assertEquals(1, accounts.size(), 'Incorrect number of accounts received!');
		System.assertEquals(testAccount.Id, accounts[0].Id, 'Incorrect account received!');

		Test.stopTest();
	}


	@IsTest
	private static void getgadmActorsTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

		List<Account> actors = new List<Account>();

		Test.startTest();

		System.runAs(testUser) {
			actors = Invite_User_CTRL.getGadmActors();
		}

		Test.stopTest();

		System.assertEquals(2, actors.size(), 'Incorrect number of actors received!');
	}

	@IsTest
	private static void getUserInformationTest() {

		User testUser = [SELECT Id, Email FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'martina.vesela.test@somedomain.com'];

		Invite_User_CTRL.UserInformationWrapper wrapper = null;

		Test.startTest();

		System.runAs(testUser) {
			wrapper = Invite_User_CTRL.getUserInformationFromEmail(testContact.Email, 'GADM');
		}

		Test.stopTest();

		System.assertEquals(testContact.Email, wrapper.invitation.Email__c, 'Incorrect Contact retrieved!');

	}

	@IsTest
	private static void getActorsAllowedDomainsTest() {

		User testUser = [SELECT Id, Email FROM User WHERE Email = 'petr.novak.test@somedomain.com'];
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account 1'];

		List<Account> actors = new List<Account>();
		actors.add(testAccount);
		String actorsString = JSON.serialize(actors);

		Map<Id, List<String>> allowedDomains = new Map<Id, List<String>>();

		Test.startTest();

		System.runAs(testUser) {
			allowedDomains = Invite_User_CTRL.getActorsAllowedDomains(actorsString);
		}

		Test.stopTest();

		System.assertEquals(1, allowedDomains.size(), 'Wrong number of accounts with allowed domains retrieved!');
		List<String> domains = allowedDomains.get(testAccount.Id);
		System.assertEquals(true, domains.contains('email.cz'), 'Email.cz domain should be present in allowed domains list!');
		System.assertEquals(true, domains.contains('gmail.com'), 'Gmail.cz domain should be present in allowed domains list!');
		System.assertEquals(true, domains.contains('iata.org'), 'Iata.org domain should be present in allowed domains list!');

	}

	@IsTest
	public static void getCurrenthUserInfoTest() {

		User testUser = [SELECT Id, Email FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

		User infoUser = null;

		Test.startTest();

		System.runAs(testUser) {

			infoUser = Invite_User_CTRL.getCurrenthUserInfo();

		}

		Test.stopTest();

		System.assertEquals(testUser.Id, infoUser.Id, 'Wrong user info returned!');

	}


	@isTest
	public static void testFindLocation() {

		// Prepare test data
		ISSP_CS__c setting = new ISSP_CS__c();
		setting.Name = 'ipinfo_token';
		setting.Value__c = '871e08ecd39325';
		insert setting;

		// Start the test
		Test.startTest();

		// Call linked method
		Test.setMock(HttpCalloutMock.class, new IpinfoioMockImpl());
		String returnedValue = Invite_User_CTRL.findLocation();

		// Stop the test
		Test.stopTest();

		// Check that we have data
		System.assertNotEquals(returnedValue, null);

	}



}