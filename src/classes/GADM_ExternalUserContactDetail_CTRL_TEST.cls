@IsTest
public class GADM_ExternalUserContactDetail_CTRL_TEST {

	@TestSetup
	private static void setup() {

		Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'Cs';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;

		List<Account> accounts = new List<Account>();

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
		accounts.add(acc);

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
		accounts.add(acc2);

		Account acc3 = new Account();
		acc3.Name = 'Test account 3';
		acc3.BillingCity = 'Montreal';
		acc3.BillingCountry = 'Canada';
		acc3.BillingStreet = 'some street';
		acc3.IATA_ISO_Country__c = country.Id;
		acc3.Location_Type__c = 'HO';
		acc3.IATACode__c = '1234567';
		acc3.Type = 'IATA Cargo Agent';
		acc3.Status__c = 'Approved';
		acc3.RecordTypeId = headquarters;
		accounts.add(acc3);

		Account acc4 = new Account();
		acc4.Name = 'Test account 4';
		acc4.BillingCity = 'Montreal';
		acc4.BillingCountry = 'Canada';
		acc4.BillingStreet = 'some street';
		acc4.IATA_ISO_Country__c = country.Id;
		acc4.Location_Type__c = 'HO';
		acc4.IATACode__c = '1234567';
		acc4.Type = 'IATA Cargo Agent';
		acc4.Status__c = 'Approved';
		acc4.RecordTypeId = headquarters;
		accounts.add(acc4);

		insert accounts;

		Contact testContact = createContact('Neo', 'Smith', acc);
		Contact testContact2 = createContact('Leo', 'Black', acc2);

		Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

		User testUser = createUser(testContact, profileId);
		User testUser2 = createUser(testContact2, profileId);

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

		Account_Role__c accountRole3 = new Account_Role__c();
		accountRole3.RecordTypeId = defaultRecordTypeId;
		accountRole3.Account__c = acc3.Id;
		accountRole3.Account_Roles__c = accountRoles.Id;
		accountRole3.Status__c = 'Active';
		accountRole3.Effective_From_Date__c = today.addDays(-2);
		accountRole3.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole3);

		Account_Role__c accountRole4 = new Account_Role__c();
		accountRole4.RecordTypeId = defaultRecordTypeId;
		accountRole4.Account__c = acc4.Id;
		accountRole4.Account_Roles__c = accountRoles.Id;
		accountRole4.Status__c = 'Active';
		accountRole4.Effective_From_Date__c = today.addDays(-2);
		accountRole4.Effective_To_Date__c = today;
		accountRolesToInsert.add(accountRole4);

		insert accountRolesToInsert;

		Account_Role_Service__c accountRoleService = new Account_Role_Service__c();
		accountRoleService.Account_Role__c = accountRole.Id;
		accountRoleService.Account_Role_Services__c = accountRoleServices.Id;
		insert accountRoleService;

		GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
		serviceDetail.Account_Role_Service__c = accountRoleService.Id;
		serviceDetail.Allowed_email_domain__c = 'somedomain.com';
		serviceDetail.Active_User_Count__c = 5;
		insert serviceDetail;

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

		List<Contact_Roles__c> contactRolesToInsert = new List<Contact_Roles__c>();
		List<Contact_Role_Service__c> contactRoleServicesToInsert = new List<Contact_Role_Service__c>();

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

		Contact_Roles__c contactRoles6 = new Contact_Roles__c();
		contactRoles6.Name = 'Ground';
		contactRoles6.Category__c = 'Business Unit';
		contactRoles6.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles6);

		Contact_Roles__c contactRoles7 = new Contact_Roles__c();
		contactRoles7.Name = 'Service';
		contactRoles7.Category__c = 'Business Unit';
		contactRoles7.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles7);

		Contact_Roles__c contactRoles8 = new Contact_Roles__c();
		contactRoles8.Name = 'Development';
		contactRoles8.Category__c = 'Business Unit';
		contactRoles8.RecordTypeId = externalRecordTypeId;
		contactRolesToInsert.add(contactRoles8);

		insert contactRolesToInsert;


		Contact_Role_Service__c roleService = new Contact_Role_Service__c();
		roleService.Service__c = portalApplications.Id;
		roleService.Contact_Role__c = contactRoles.Id;
		contactRoleServicesToInsert.add(roleService);

		Contact_Role_Service__c roleService2 = new Contact_Role_Service__c();
		roleService2.Service__c = portalApplications.Id;
		roleService2.Contact_Role__c = contactRoles2.Id;
		contactRoleServicesToInsert.add(roleService2);

		Contact_Role_Service__c roleService3 = new Contact_Role_Service__c();
		roleService3.Service__c = portalApplications.Id;
		roleService3.Contact_Role__c = contactRoles3.Id;
		contactRoleServicesToInsert.add(roleService3);

		Contact_Role_Service__c roleService4 = new Contact_Role_Service__c();
		roleService4.Service__c = portalApplications.Id;
		roleService4.Contact_Role__c = contactRoles4.Id;
		contactRoleServicesToInsert.add(roleService4);

		Contact_Role_Service__c roleService5 = new Contact_Role_Service__c();
		roleService5.Service__c = portalApplications.Id;
		roleService5.Contact_Role__c = contactRoles5.Id;
		contactRoleServicesToInsert.add(roleService5);

		Contact_Role_Service__c roleService6 = new Contact_Role_Service__c();
		roleService6.Service__c = portalApplications.Id;
		roleService6.Contact_Role__c = contactRoles6.Id;
		contactRoleServicesToInsert.add(roleService6);

		Contact_Role_Service__c roleService7 = new Contact_Role_Service__c();
		roleService7.Service__c = portalApplications.Id;
		roleService7.Contact_Role__c = contactRoles7.Id;
		contactRoleServicesToInsert.add(roleService7);

		Contact_Role_Service__c roleService8 = new Contact_Role_Service__c();
		roleService8.Service__c = portalApplications.Id;
		roleService8.Contact_Role__c = contactRoles7.Id;
		contactRoleServicesToInsert.add(roleService8);

		insert contactRoleServicesToInsert;


		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		List<Account_Contact_Role__c> accountContactRolesToInsert = new List<Account_Contact_Role__c>();

		//Account contact role for user Neo and Test Account
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

		//Account contact role for user Neo and Test Account
		Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
		accountContactRole2.Contact__c = testContact.Id;
		accountContactRole2.Contact_Roles__c = contactRoles2.Id;
		accountContactRole2.Account_Role__c = accountRole.Id;
		accountContactRole2.Service_Rendered__c = 'GADM';
		accountContactRole2.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2);

		//Account contact role for user Neo and Test Account2
		Account_Contact_Role__c accountContactRole2b = new Account_Contact_Role__c();
		accountContactRole2b.Contact__c = testContact.Id;
		accountContactRole2b.Contact_Roles__c = contactRoles.Id;
		accountContactRole2b.Account_Role__c = accountRole2.Id;
		accountContactRole2b.Service_Rendered__c = 'GADM';
		accountContactRole2b.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2b);

		Account_Contact_Role__c accountContactRole2c = new Account_Contact_Role__c();
		accountContactRole2c.Contact__c = testContact.Id;
		accountContactRole2c.Contact_Roles__c = contactRoles5.Id;
		accountContactRole2c.Account_Role__c = accountRole.Id;
		accountContactRole2c.Service_Rendered__c = 'GADM';
		accountContactRole2c.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2c);

		Account_Contact_Role__c accountContactRole2d = new Account_Contact_Role__c();
		accountContactRole2d.Contact__c = testContact.Id;
		accountContactRole2d.Contact_Roles__c = contactRoles.Id;
		accountContactRole2d.Account_Role__c = accountRole4.Id;
		accountContactRole2d.Service_Rendered__c = 'GADM';
		accountContactRole2d.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2d);

		Account_Contact_Role__c accountContactRole2e = new Account_Contact_Role__c();
		accountContactRole2e.Contact__c = testContact.Id;
		accountContactRole2e.Contact_Roles__c = contactRoles7.Id;
		accountContactRole2e.Account_Role__c = accountRole4.Id;
		accountContactRole2e.Service_Rendered__c = 'GADM';
		accountContactRole2e.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2e);

		//for testUser2
		//Account contact role for user Leo and Test Account2
		Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
		accountContactRole3.Contact__c = testContact2.Id;
		accountContactRole3.Contact_Roles__c = contactRoles.Id;
		accountContactRole3.Account_Role__c = accountRole2.Id;
		accountContactRole3.Service_Rendered__c = 'GADM';
		accountContactRole3.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole3);

		Account_Contact_Role__c accountContactRole3b = new Account_Contact_Role__c();
		accountContactRole3b.Contact__c = testContact2.Id;
		accountContactRole3b.Contact_Roles__c = contactRoles.Id;
		accountContactRole3b.Account_Role__c = accountRole2.Id;
		accountContactRole3b.Service_Rendered__c = 'GADM';
		accountContactRole3b.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole3b);

		Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
		accountContactRole4.Contact__c = testContact2.Id;
		accountContactRole4.Contact_Roles__c = contactRoles3.Id;
		accountContactRole4.Account_Role__c = accountRole2.Id;
		accountContactRole4.Service_Rendered__c = 'GADM';
		accountContactRole4.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole4);

		Account_Contact_Role__c accountContactRole5b = new Account_Contact_Role__c();
		accountContactRole5b.Contact__c = testContact2.Id;
		accountContactRole5b.Contact_Roles__c = contactRoles4.Id;
		accountContactRole5b.Account_Role__c = accountRole.Id;
		accountContactRole5b.Service_Rendered__c = 'GADM';
		accountContactRole5b.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole5b);

		Account_Contact_Role__c accountContactRole6 = new Account_Contact_Role__c();
		accountContactRole6.Contact__c = testContact2.Id;
		accountContactRole6.Contact_Roles__c = contactRoles.Id;
		accountContactRole6.Account_Role__c = accountRole.Id;
		accountContactRole6.Service_Rendered__c = 'GADM';
		accountContactRole6.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole6);

		Account_Contact_Role__c accountContactRole7 = new Account_Contact_Role__c();
		accountContactRole7.Contact__c = testContact2.Id;
		accountContactRole7.Contact_Roles__c = contactRoles5.Id;
		accountContactRole7.Account_Role__c = accountRole.Id;
		accountContactRole7.Service_Rendered__c = 'GADM';
		accountContactRole7.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole7);

		Account_Contact_Role__c accountContactRole8 = new Account_Contact_Role__c();
		accountContactRole8.Contact__c = testContact2.Id;
		accountContactRole8.Contact_Roles__c = contactRoles6.Id;
		accountContactRole8.Account_Role__c = accountRole.Id;
		accountContactRole8.Service_Rendered__c = 'GADM';
		accountContactRole8.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole8);

		Account_Contact_Role__c accountContactRole9 = new Account_Contact_Role__c();
		accountContactRole9.Contact__c = testContact2.Id;
		accountContactRole9.Contact_Roles__c = contactRoles.Id;
		accountContactRole9.Account_Role__c = accountRole3.Id;
		accountContactRole9.Service_Rendered__c = 'GADM';
		accountContactRole9.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole9);

		insert accountContactRolesToInsert;

		List<Contact_Role_Service_Access__c> contactRoleServiceAccessesToInsert = new List<Contact_Role_Service_Access__c>();

		//for testUser
		//grant access for user Neo, account Test account and GADM User role and GADM service
		Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
		serviceAccess.Contact_Role__c = accountContactRole.Id;
		serviceAccess.Service__c = portalApplications.Id;
		serviceAccess.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess);

		//grant access for user Neo, account Test account and Service Power User role and GADM service
		Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
		serviceAccess2.Contact_Role__c = accountContactRole2.Id;
		serviceAccess2.Service__c = portalApplications.Id;
		serviceAccess2.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2);

		//grant access for user Neo, account Test account 2 and GADM User role and GADM service
		Contact_Role_Service_Access__c serviceAccess2b = new Contact_Role_Service_Access__c();
		serviceAccess2b.Contact_Role__c = accountContactRole2b.Id;
		serviceAccess2b.Service__c = portalApplications.Id;
		serviceAccess2b.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2b);

		//grant access for user Neo, account Test account and Security role and GADM service
		Contact_Role_Service_Access__c serviceAccess2c = new Contact_Role_Service_Access__c();
		serviceAccess2c.Contact_Role__c = accountContactRole2c.Id;
		serviceAccess2c.Service__c = portalApplications.Id;
		serviceAccess2c.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2c);

		Contact_Role_Service_Access__c serviceAccess2d = new Contact_Role_Service_Access__c();
		serviceAccess2d.Contact_Role__c = accountContactRole2e.Id;
		serviceAccess2d.Service__c = portalApplications.Id;
		serviceAccess2d.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2d);

		//grant access for user Leo, account Test account 2 and GADM User role and GADM service
		Contact_Role_Service_Access__c serviceAccess3 = new Contact_Role_Service_Access__c();
		serviceAccess3.Contact_Role__c = accountContactRole3.Id;
		serviceAccess3.Service__c = portalApplications.Id;
		serviceAccess3.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess3);

		//grant access for user Leo, account Test account 2 and Service Super User role and GADM service
		Contact_Role_Service_Access__c serviceAccess3b = new Contact_Role_Service_Access__c();
		serviceAccess3b.Contact_Role__c = accountContactRole4.Id;
		serviceAccess3b.Service__c = portalApplications.Id;
		serviceAccess3b.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess3b);

		//grant access for user Leo, account Test account 2 and GADM Data Submitter role and GADM service
		Contact_Role_Service_Access__c serviceAccess3c = new Contact_Role_Service_Access__c();
		serviceAccess3c.Contact_Role__c = accountContactRole5b.Id;
		serviceAccess3c.Service__c = portalApplications.Id;
		serviceAccess3c.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess3c);

		Contact_Role_Service_Access__c serviceAccess7 = new Contact_Role_Service_Access__c();
		serviceAccess7.Contact_Role__c = accountContactRole7.Id;
		serviceAccess7.Service__c = portalApplications.Id;
		serviceAccess7.Status__c = 'Pending';
		contactRoleServiceAccessesToInsert.add(serviceAccess7);

		Contact_Role_Service_Access__c serviceAccess8 = new Contact_Role_Service_Access__c();
		serviceAccess8.Contact_Role__c = accountContactRole8.Id;
		serviceAccess8.Service__c = portalApplications.Id;
		serviceAccess8.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess8);

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
		testUser.ProfileId = profileId; //ISSP_Constant.TEST_User_ProfileID;
		testUser.IsActive = true;
		insert testUser;
		return testUser;
	}

	@IsTest
	private static void prepareManagementDataTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
		User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];

		GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData = new GADM_ExternalUserContactDetail_CTRL.UserManagementData();

		Test.startTest();

		System.runAs(testUser) {

			GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser2.Id, false, false, new List<Id>(), false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[1];
			}else{
				selectedUserInfo = allUsersInfo[0];
			}

			managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), false, true);
		}

		Test.stopTest();

		Map<Id, GADM_ExternalUserContactDetail_CTRL.Role> roleMap = managementData.roles;
		Map<Id, GADM_ExternalUserContactDetail_CTRL.BusinessUnit> businessUnitsMap = managementData.businessUnits;
		Map<Id, GADM_ExternalUserContactDetail_CTRL.Actor> actorsMap = managementData.actors;

		System.assertEquals(4, actorsMap.size(), 'There should be exactly 4 actors prepared!');
		System.assertEquals(3, businessUnitsMap.size(), 'There should be exactly 3 business units prepared!');
		System.assertEquals(4, roleMap.size(), 'There should be exactly 4 roles prepared!');
	}

	@IsTest
	private static void prepareManagementDataCurrentUserIsSelectedUserTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

		Contact_Roles__c businessRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Security'];

		GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData;

		Test.startTest();

		System.runAs(testUser) {

			GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser.Id, false, false, new List<Id>{businessRole.Id}, false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[0];
			}else{
				selectedUserInfo = allUsersInfo[1];
			}

			managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), false, true);

		}

		Test.stopTest();

		System.assertEquals(true, managementData.currentUserIsSelectedUser, 'Current user should be selected user!');

		Map<Id, GADM_ExternalUserContactDetail_CTRL.Role> roleMap = managementData.roles;
		Map<Id, GADM_ExternalUserContactDetail_CTRL.BusinessUnit> businessUnitsMap = managementData.businessUnits;
		Map<Id, GADM_ExternalUserContactDetail_CTRL.Actor> actorsMap = managementData.actors;

		for(GADM_ExternalUserContactDetail_CTRL.Role role : roleMap.values()) {
			System.assertEquals(false, role.isEditable, 'Role should not be editable!');
		}

		for(GADM_ExternalUserContactDetail_CTRL.BusinessUnit bu : businessUnitsMap.values()) {
			System.assertEquals(false, bu.isEditable, 'Business unit should not be editable!');
		}

		for(GADM_ExternalUserContactDetail_CTRL.Actor actor : actorsMap.values()) {
			System.assertEquals(false, actor.isEditable, 'Actor should not be editable!');
		}

	}

	@IsTest
	private static void saveManagementDataSuperUserTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
		User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];

		Account testAccount2 = [SELECT Id FROM Account WHERE Name = 'Test account 2'];
		Account testAccount4 = [SELECT Id FROM Account WHERE Name = 'Test account 4'];

		boolean saveResult = false;

		Test.startTest();

		System.runAs(testUser) {

			GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser2.Id, false, false, new List<Id>(), false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[1];
			}else{
				selectedUserInfo = allUsersInfo[0];
			}

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), true, false);
			String originalManagementData = JSON.serialize(managementData);

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData2 = (GADM_ExternalUserContactDetail_CTRL.UserManagementData)JSON.deserialize(originalManagementData, GADM_ExternalUserContactDetail_CTRL.UserManagementData.class);
			Map<Id, GADM_ExternalUserContactDetail_CTRL.Actor> actorsMap = managementData2.actors;

			actorsMap.get(testAccount2.Id).isChecked = false;
			actorsMap.get(testAccount4.Id).isChecked = true;

			saveResult = GADM_ExternalUserContactDetail_CTRL.saveManagementData(JSON.serialize(managementData), JSON.serialize(managementData2), JSON.serialize(selectedUserInfo));
		}


		Test.stopTest();

		Contact con = Contact_Roles_Helper.getContactFromUser(testUser2.Id);
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
		List<Account_Contact_Role__c> accountContactRoles = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND RecordTypeId = :groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User' AND Account_Role__r.Account__c =:testAccount2.Id];
		List<Account_Contact_Role__c> accountContactRoles2 = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND RecordTypeId = :groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User' AND Account_Role__r.Account__c =:testAccount4.Id];

		System.assertEquals(0, accountContactRoles.size(), 'These should not exists any Account_Contact_Role__c ro account \'testAccount 2\' and GADM User role!');
		System.assertEquals(1, accountContactRoles2.size(), 'These should exists one Account_Contact_Role__c ro account \'testAccount 4\' and GADM User role!');

	}


	@IsTest
	private static void saveManagementDataActorsTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
		User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];

		Account testAccount2 = [SELECT Id FROM Account WHERE Name = 'Test account 2'];
		Account testAccount4 = [SELECT Id FROM Account WHERE Name = 'Test account 4'];

		boolean saveResult = false;

		Test.startTest();

		System.runAs(testUser) {

			GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser2.Id, false, false, new List<Id>(),false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[1];
			}else{
				selectedUserInfo = allUsersInfo[0];
			}

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), false, true);
			String originalManagementData = JSON.serialize(managementData);

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData2 = (GADM_ExternalUserContactDetail_CTRL.UserManagementData)JSON.deserialize(originalManagementData, GADM_ExternalUserContactDetail_CTRL.UserManagementData.class);

			//change access
			Map<Id, GADM_ExternalUserContactDetail_CTRL.Actor> actorsMap = managementData2.actors;
			actorsMap.get(testAccount2.Id).isChecked = false;
			actorsMap.get(testAccount4.Id).isChecked = true;

			//save
			saveResult = GADM_ExternalUserContactDetail_CTRL.saveManagementData(JSON.serialize(managementData), JSON.serialize(managementData2), JSON.serialize(selectedUserInfo));
		}

		Test.stopTest();

		Contact con = Contact_Roles_Helper.getContactFromUser(testUser2.Id);
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
		List<Account_Contact_Role__c> accountContactRoles = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND RecordTypeId = :groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User' AND Account_Role__r.Account__c =:testAccount2.Id];
		List<Account_Contact_Role__c> accountContactRoles2 = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND RecordTypeId = :groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User' AND Account_Role__r.Account__c =:testAccount4.Id];

		System.assertEquals(0, accountContactRoles.size(), 'These should not exists any Account_Contact_Role__c ro account \'testAccount 2\' and GADM User role!');
		System.assertEquals(1, accountContactRoles2.size(), 'These should exists one Account_Contact_Role__c ro account \'testAccount 4\' and GADM User role!');

	}



	@IsTest
	private static void saveManagementDataBusinessUnitsTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
		User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];

		Contact_Roles__c security = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Security'];
		Contact_Roles__c ground = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Ground'];
		Contact_Roles__c service = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Service'];

		boolean saveResult = false;

		Test.startTest();

		System.runAs(testUser) {

			GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser2.Id, false, false, new List<Id>(), false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[1];
			}else{
				selectedUserInfo = allUsersInfo[0];
			}

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), false, true);
			String originalManagementData = JSON.serialize(managementData);

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData2 = (GADM_ExternalUserContactDetail_CTRL.UserManagementData)JSON.deserialize(originalManagementData, GADM_ExternalUserContactDetail_CTRL.UserManagementData.class);
			Map<Id, GADM_ExternalUserContactDetail_CTRL.BusinessUnit> businessUnitMap = managementData2.businessUnits;

			businessUnitMap.get(security.Id).isChecked = true;
			businessUnitMap.get(ground.Id).isChecked = false;
			businessUnitMap.get(service.Id).isChecked = true;

			saveResult = GADM_ExternalUserContactDetail_CTRL.saveManagementData(JSON.serialize(managementData), JSON.serialize(managementData2), JSON.serialize(selectedUserInfo));
		}

		Test.stopTest();

		System.assertEquals(true, saveResult, 'Save should be successful!');

		Contact con = Contact_Roles_Helper.getContactFromUser(testUser2.Id);
		List<Contact_Role_Service_Access__c> securityAccesses = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :con.Id AND Contact_Role__r.Contact_Roles__c = :security.Id ];
		List<Contact_Role_Service_Access__c> groundAccesses = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :con.Id AND Contact_Role__r.Contact_Roles__c = :ground.Id];
		List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :con.Id AND Contact_Role__r.Contact_Roles__c = :service.Id];

		System.assertEquals('Granted', securityAccesses[0].Status__c, 'Access to security business unit should be granted!');
		System.assertEquals('Denied', groundAccesses[0].Status__c, 'Access to ground business unit should be granted!');
		System.assertEquals('Granted', serviceAccesses[0].Status__c, 'Access to service business unit should be granted!');

	}


	@IsTest
	private static void saveManagementDataRolesTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
		User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];

		Contact_Roles__c gadmUser = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];
		Contact_Roles__c powerUser = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Service Power User'];

		Test.startTest();

		boolean saveResult = false;
		Set<Id> businessUnitsIds = new Set<Id>();
		GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo;

		System.runAs(testUser) {

			currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);

			//get business roles ids
			List<Contact_Roles__c> currentUserBusinessUnits = currentUserInfo.grantedBusinessUnits;
			for(Contact_Roles__c role : currentUserBusinessUnits) {
				businessUnitsIds.add(role.Id);
			}

			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser.Id, false, false, new List<Id>(businessUnitsIds), false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[1];
			}else{
				selectedUserInfo = allUsersInfo[0];
			}

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), false, true);
			String originalManagementData = JSON.serialize(managementData);

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData2 = (GADM_ExternalUserContactDetail_CTRL.UserManagementData)JSON.deserialize(originalManagementData, GADM_ExternalUserContactDetail_CTRL.UserManagementData.class);

			//change values (check/uncheck) for roles
			Map<Id, GADM_ExternalUserContactDetail_CTRL.Role> rolesMap = managementData2.roles;
			rolesMap.get(gadmUser.Id).isChecked = false;
			rolesMap.get(powerUser.Id).isChecked = true;

			//save changes
			saveResult = GADM_ExternalUserContactDetail_CTRL.saveManagementData(JSON.serialize(managementData), JSON.serialize(managementData2), JSON.serialize(selectedUserInfo));

		}

		Test.stopTest();

		System.assertEquals(true, saveResult, 'Save should be successful!');

		Contact con = Contact_Roles_Helper.getContactFromUser(testUser2.Id);
		List<Contact_Role_Service_Access__c> gadmUserAccesses = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :con.Id AND Contact_Role__r.Contact_Roles__c = :gadmUser.Id ];
		List<Contact_Role_Service_Access__c> powerUserAccesses = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :con.Id AND Contact_Role__r.Contact_Roles__c = :powerUser.Id];

		System.assertEquals('Denied', gadmUserAccesses[0].Status__c, 'Access for GADM User should be denied!');
		System.assertEquals('Granted', powerUserAccesses[0].Status__c, 'Access for Service Power User should be granted!');

	}

	@IsTest
	private static void saveManagementDataFailTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
		User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];


		boolean saveResult;

		Test.startTest();

		System.runAs(testUser) {

			GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
			List<Contact_Roles_Helper.AggregatedRecordWrapper> allUsersInfo = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser2.Id, false, false, new List<Id>(), false);

			Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = new Contact_Roles_Helper.AggregatedRecordWrapper();

			//we need to get the correct user form allUsersInfo
			if(allUsersInfo[0].con.Email == 'neo.smith.test@somedomain.com') {
				selectedUserInfo = allUsersInfo[1];
			}else{
				selectedUserInfo = allUsersInfo[0];
			}

			GADM_ExternalUserContactDetail_CTRL.UserManagementData managementData = GADM_ExternalUserContactDetail_CTRL.prepareManagementData(JSON.serialize(currentUserInfo), JSON.serialize(selectedUserInfo), false, true);

			Contact emptyContact = new Contact();

			saveResult = GADM_ExternalUserContactDetail_CTRL.saveManagementData(JSON.serialize(managementData), JSON.serialize(emptyContact), JSON.serialize(selectedUserInfo));
		}

		Test.stopTest();

		System.assertEquals(false, saveResult, 'Method should end with error!');

	}



}
