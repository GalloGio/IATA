@IsTest
public class GADM_RelatedFilesCategorizedLists_TEST {
	@TestSetup
	private static void setup() {

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
		insert accountsToInsert;

		List<Contact> contactsToInsert = new List<Contact>();
		Contact testContact = createContact('Petr', 'Novak', testAccount);
		contactsToInsert.add(testContact);
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


		Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

		Date today = Date.today();

		List<Account_Role__c> accountRolesToInsert = new List<Account_Role__c>();

		Account_Role__c accountRole = new Account_Role__c();
		accountRole.RecordTypeId = defaultRecordTypeId;
		accountRole.Account__c = testAccount.Id;
		accountRole.Account_Roles__c = accountRoles.Id;
		accountRole.Status__c = 'Active';
		accountRole.Effective_From_Date__c = today.addDays(-2);
		accountRole.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole);
		insert accountRolesToInsert;

		List<Contact_Roles__c> contactRolesToInsert = new List<Contact_Roles__c>();

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

		Contact_Roles__c contactRoles = new Contact_Roles__c();
		contactRoles.Name = 'GADM User';
		contactRoles.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles);

		Contact_Roles__c contactRoles2 = new Contact_Roles__c();
		contactRoles2.Name = 'Power User';
		contactRoles2.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles2);
		insert contactRolesToInsert;

		List<Contact_Role_Service__c> contactRoleServicesToInsert = new List<Contact_Role_Service__c>();

		Contact_Role_Service__c contactRoleService = new Contact_Role_Service__c();
		contactRoleService.Contact_Role__c = contactRoles.Id;
		contactRoleService.Service__c = portalApplications.Id;
		contactRoleServicesToInsert.add(contactRoleService);

		Contact_Role_Service__c contactRoleService2 = new Contact_Role_Service__c();
		contactRoleService2.Contact_Role__c = contactRoles2.Id;
		contactRoleService2.Service__c = portalApplications.Id;
		contactRoleServicesToInsert.add(contactRoleService2);

		insert contactRoleServicesToInsert;

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		List<Account_Contact_Role__c> accountContactRolesToInsert = new List<Account_Contact_Role__c>();

		Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
		accountContactRole.Contact__c = testContact.Id;
		accountContactRole.Contact_Roles__c = contactRoles.Id;
		accountContactRole.Account_Role__c = accountRole.Id;
		accountContactRole.Service_Rendered__c = 'GADM';
		accountContactRole.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole);

		Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
		accountContactRole2.Contact__c = testContact.Id;
		accountContactRole2.Contact_Roles__c = contactRoles2.Id;
		accountContactRole2.Account_Role__c = accountRole.Id;
		accountContactRole2.Service_Rendered__c = 'GADM';
		accountContactRole2.RecordTypeId = functionalRecordTypeId;
		//accountContactRolesToInsert.add(accountContactRole2);

		insert accountContactRolesToInsert;

		List<Contact_Role_Service_Permission__c> permissionsToInsert = new List<Contact_Role_Service_Permission__c>();

		Contact_Role_Service_Permission__c permission = new Contact_Role_Service_Permission__c();
		permission.Contact_Role_Service__c = contactRoleService.Id;
		permission.Name = 'Ground test';
		permission.Category__c = 'Ground';
		permissionsToInsert.add(permission);
		insert permissionsToInsert;

		List<Contact_Role_Service_Access__c> contactRoleServiceAccessesToInsert = new List<Contact_Role_Service_Access__c>();

		Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
		serviceAccess.Contact_Role__c = accountContactRole.Id;
		serviceAccess.Service__c = portalApplications.Id;
		serviceAccess.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess);
		insert contactRoleServiceAccessesToInsert;
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
	private static void shareServiceNotification() {
		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

		Portal_Applications__c pa = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM' LIMIT 1];

		Service_Notification__c message = new Service_Notification__c();
		message.Header__c = 'header';
		message.Body__c = 'head';
		message.Valid_From__c = Date.Today();
		message.Valid_To__c = Date.Today();
		message.Service__c = pa.Id;
		insert message;

		Id gadmRT = RecordTypeSingleton.getInstance().getRecordTypeId('ContentVersion', 'GADM');
		ContentVersion contentVersion = new ContentVersion(
			Title = 'testFile',
			PathOnClient = 'testFile.jpg',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true,
			RecordTypeId = gadmRT,
			Valid_From__c = Date.today().addDays(-2),
			Valid_To__c = Date.today().addDays(2)
		);
		insert contentVersion;
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = message.id;
		cdl.ContentDocumentId = documents[0].Id;
		cdl.shareType = 'V';
		insert cdl;

		List<Contact_Roles__c> roles = [SELECT Id FROM Contact_Roles__c];
		Test.startTest();

		Service_Notification_Role__c role = new Service_Notification_Role__c();
		role.Contact_Roles__c = roles[0].Id;
		role.Service_Notification__c = message.Id;
		insert role;

		System.runAs(testUser){
			List<Id> objIds = GADM_HomePageContainer_CTRL.getObjects();
			System.assertEquals(true, objIds.size() == 1, 'One shared file should be present.');
			System.assertEquals(true, GADM_RelatedFilesCategorizedLists_CTRL.getFiles(objIds).size() == 1, 'One shared file should be present.');
		}
		Test.stopTest();

	}

}
