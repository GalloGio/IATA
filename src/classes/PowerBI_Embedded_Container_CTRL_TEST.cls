@IsTest
public class PowerBI_Embedded_Container_CTRL_TEST {

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
		accountRole.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole);

		Account_Role__c accountRole2 = new Account_Role__c();
		accountRole2.RecordTypeId = defaultRecordTypeId;
		accountRole2.Account__c = testAccount2.Id;
		accountRole2.Account_Roles__c = accountRoles.Id;
		accountRole2.Status__c = 'Active';
		accountRole2.Effective_From_Date__c = today.addDays(-2);
		accountRole2.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole2);

		insert accountRolesToInsert;

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

		Contact_Roles__c contactRoles3 = new Contact_Roles__c();
		contactRoles3.Name = 'Security';
		contactRoles3.RecordTypeId = externalRecordTypeId;
		contactRoles3.Category__c = 'Business Unit';
		contactRolesToInsert.add(contactRoles3);

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

		Contact_Role_Service__c contactRoleService3 = new Contact_Role_Service__c();
		contactRoleService3.Contact_Role__c = contactRoles3.Id;
		contactRoleService3.Service__c = portalApplications.Id;
		contactRoleServicesToInsert.add(contactRoleService3);

		insert contactRoleServicesToInsert;


		List<Contact_Role_Service_Permission__c> permissionsToInsert = new List<Contact_Role_Service_Permission__c>();

		Contact_Role_Service_Permission__c permission = new Contact_Role_Service_Permission__c();
		permission.Contact_Role_Service__c = contactRoleService.Id;
		permission.Name = 'Ground test';
		permission.Category__c = 'Ground';
		permissionsToInsert.add(permission);

		Contact_Role_Service_Permission__c permission1 = new Contact_Role_Service_Permission__c();
		permission1.Contact_Role_Service__c = contactRoleService.Id;
		permission1.Name = 'Ground test 2';
		permission1.Category__c = 'Ground';
		permissionsToInsert.add(permission1);

		Contact_Role_Service_Permission__c permission2 = new Contact_Role_Service_Permission__c();
		permission2.Contact_Role_Service__c = contactRoleService3.Id;
		permission2.Name = 'Security';
		permissionsToInsert.add(permission2);

		Contact_Role_Service_Permission__c permission2b = new Contact_Role_Service_Permission__c();
		permission2b.Contact_Role_Service__c = contactRoleService3.Id;
		permission2b.Name = 'Security 2';
		permissionsToInsert.add(permission2b);

		Contact_Role_Service_Permission__c permission3 = new Contact_Role_Service_Permission__c();
		permission3.Contact_Role_Service__c = contactRoleService2.Id;
		permission3.Name = 'Administration';
		permissionsToInsert.add(permission3);

		Contact_Role_Service_Permission__c permission3b = new Contact_Role_Service_Permission__c();
		permission3b.Contact_Role_Service__c = contactRoleService2.Id;
		permission3b.Name = 'Administration 2';
		permissionsToInsert.add(permission3b);

		insert permissionsToInsert;


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

		Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
		accountContactRole1.Contact__c = testContact.Id;
		accountContactRole1.Contact_Roles__c = contactRoles.Id;
		accountContactRole1.Account_Role__c = accountRole.Id;
		accountContactRole1.Service_Rendered__c = 'GADM';
		accountContactRole1.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole1);

		Account_Contact_Role__c accountContactRole1b = new Account_Contact_Role__c();
		accountContactRole1b.Contact__c = testContact.Id;
		accountContactRole1b.Contact_Roles__c = contactRoles2.Id;
		accountContactRole1b.Account_Role__c = accountRole.Id;
		accountContactRole1b.Service_Rendered__c = 'GADM';
		accountContactRole1b.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole1b);

		Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
		accountContactRole2.Contact__c = testContact.Id;
		accountContactRole2.Contact_Roles__c = contactRoles3.Id;
		accountContactRole2.Account_Role__c = accountRole.Id;
		accountContactRole2.Service_Rendered__c = 'GADM';
		accountContactRole2.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2);

		insert accountContactRolesToInsert;


		List<Contact_Role_Service_Access__c> contactRoleServiceAccessesToInsert = new List<Contact_Role_Service_Access__c>();

		Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
		serviceAccess.Contact_Role__c = accountContactRole.Id;
		serviceAccess.Service__c = portalApplications.Id;
		serviceAccess.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess);

		Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
		serviceAccess2.Contact_Role__c = accountContactRole1.Id;
		serviceAccess2.Service__c = portalApplications.Id;
		serviceAccess2.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2);

		Contact_Role_Service_Access__c serviceAccess2b = new Contact_Role_Service_Access__c();
		serviceAccess2b.Contact_Role__c = accountContactRole1b.Id;
		serviceAccess2b.Service__c = portalApplications.Id;
		serviceAccess2b.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2b);

		Contact_Role_Service_Access__c serviceAccess3 = new Contact_Role_Service_Access__c();
		serviceAccess3.Contact_Role__c = accountContactRole2.Id;
		serviceAccess3.Service__c = portalApplications.Id;
		serviceAccess3.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess3);

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
	private static void getCategories_accessToWorkspaceTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

		List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];
		//List<ContentWorkspace> gadmWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];

		ContentVersion contentVersion1 = new ContentVersion();

		contentVersion1.Title = 'security';
		contentVersion1.PathOnClient = 'security.jpg';
		contentVersion1.VersionData = Blob.valueOf('Test Content Data');
		contentVersion1.IsMajorVersion = true;

		insert contentVersion1;

		contentVersion1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id];


		List<ContentWorkspacePermission> permissions = [SELECT Id FROM ContentWorkspacePermission WHERE Name = 'Viewer'];

		List<PowerBI_Embedded_Container_CTRL.CategoryWrapper> wrappers= new List<PowerBI_Embedded_Container_CTRL.CategoryWrapper>();
		User myOtherUser = [select Id from User WHERE UserRole.Name = 'IATA Information Technology Services' AND IsActive = true AND UserPermissionsSFContentUser=true LIMIT 1];
		Test.startTest();
		system.debug(myOtherUser);
		System.runAs(myOtherUser) {
			List<ContentWorkspace> existing = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c];
			if(existing.isEmpty()) {
				ContentWorkspace workspace = new ContentWorkspace();
				workspace.Name = gadmSettings[0].Files_Folder__c;
				insert workspace;
			}
		}
		System.runAs(myOtherUser) {
			List<ContentWorkspace> gadmWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
			ContentWorkspaceDoc doc = new ContentWorkspaceDoc();
			doc.ContentDocumentId = contentVersion1.ContentDocumentId;
			doc.ContentWorkspaceId = gadmWorkspace[0].Id;
			insert doc;

			ContentWorkspaceMember workspaceMember = new ContentWorkspaceMember();
			workspaceMember.ContentWorkspaceId = gadmWorkspace[0].Id;
			workspaceMember.MemberId = testUser.Id;
			workspaceMember.ContentWorkspacePermissionId = permissions[0].Id;
			insert workspaceMember;

			wrappers = PowerBI_Embedded_Container_CTRL.getCategories(testUser.Id);
		}

		Test.stopTest();

		for(PowerBI_Embedded_Container_CTRL.CategoryWrapper wrapper : wrappers) {
			if(wrapper.name == 'Security') {
				System.assertEquals(false, wrapper.pictureUrl == null, 'PictureUrl should not be null if user has access to ContentWorkspace and picture is there!');
			}
		}

	}

	@IsTest
	private static void checkSessionListCacheCoverageTest() {
		//can not be tested during deployment as session cache does not exist. Making coverage
		Boolean presentInCache;
		Test.startTest();
		presentInCache = PowerBI_Embedded_Dashboard_List_CTRL.checkSessionCache(UserInfo.getUserId(), 'checkSessionCacheCoverageTest');
		Test.stopTest();
		System.assertEquals(false, presentInCache, 'Key is not preset in cache');
	}

	@IsTest
	private static void checkSessionContainerCacheCoverageTest() {
		//can not be tested during deployment as session cache does not exist. Making coverage
		Boolean presentInCache;
		Test.startTest();
		presentInCache = PowerBI_Embedded_Container_CTRL.checkSessionCache(UserInfo.getUserId(), 'checkSessionCacheCoverageTest');
		Test.stopTest();
		System.assertEquals(false, presentInCache, 'Key is not preset in cache');
	}


	@IsTest
	private static void getCategories_noAccessToWorkspaceTest() {
		List<User> myOtherUser = [select Id from User WHERE UserRole.Name = 'IATA Information Technology Services' AND UserPermissionsSFContentUser=true AND IsActive = true LIMIT 2];
		List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

		ContentVersion contentVersion1 = new ContentVersion();

		contentVersion1.Title = 'security';
		contentVersion1.PathOnClient = 'security.jpg';
		contentVersion1.VersionData = Blob.valueOf('Test Content Data');
		contentVersion1.IsMajorVersion = true;

		insert contentVersion1;

		contentVersion1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id];
		List<PowerBI_Embedded_Container_CTRL.CategoryWrapper> wrappers= new List<PowerBI_Embedded_Container_CTRL.CategoryWrapper>();
		System.runAs(myOtherUser[0]) {
			List<ContentWorkspace> existing = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c];
			if(existing.isEmpty()) {
				ContentWorkspace workspace = new ContentWorkspace();
				workspace.Name = gadmSettings[0].Files_Folder__c;
				insert workspace;
			}
		}

		System.runAs(myOtherUser[0]) {
			List<ContentWorkspace> gadmWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
			ContentWorkspaceDoc doc = new ContentWorkspaceDoc();
			doc.ContentDocumentId = contentVersion1.ContentDocumentId;
			doc.ContentWorkspaceId = gadmWorkspace[0].Id;
			insert doc;
		}

		Test.startTest();
		System.runAs(myOtherUser[1]) {
			wrappers = PowerBI_Embedded_Container_CTRL.getCategories(myOtherUser[1].Id);
		}


		Test.stopTest();

		for(PowerBI_Embedded_Container_CTRL.CategoryWrapper wrapper : wrappers) {
			if(wrapper.name == 'Security') {
				System.assertEquals(true, wrapper.pictureUrl == null, 'PictureUrl should be null if user has no access to ContentWorkspace!');
			}
		}

	}

}
