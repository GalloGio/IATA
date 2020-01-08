/**
 * Created by ppop on 6/26/2019.
 */

@IsTest
private class DataSubmissionTriggerHandlerTest {
	static testMethod void testEmailNotification() {
		Data_Submission__c submission = [SELECT Id, Status__c FROM  Data_Submission__c LIMIT 1];
		submission.Status__c = 'Rejected';
		update submission;
	}

	static testMethod void getNotifiedUsers() {
		Contact submitter = [SELECT id FROM Contact WHERE Email = 'Neo.Smith.test@somedomain.com' LIMIT 1];
		Contact superUser = [SELECT id FROM Contact WHERE Email = 'Leo.Smith.test@somedomain.com' LIMIT 1];

		Data_Submission__c subm = [SELECT Id, Submitter__c FROM Data_Submission__c LIMIT 1];
		Account a = [SELECT Id FROM Account WHERE Name = 'Test account' LIMIT 1];
		Map<Id, Set<Id>> result = DataSubmissionTriggerHandler.getAllDataSubmittersAndSuperUsers(new List<Id>{a.Id}, new List<Data_Submission__c>{subm});

		system.assertEquals(result.get(subm.Id).size(), 2);
	}

	static testMethod void getNotifiedUsers2() {
		Contact submitter = [SELECT id FROM Contact WHERE Email = 'Neo.Smith.test@somedomain.com' LIMIT 1];
		Contact superUser = [SELECT id FROM Contact WHERE Email = 'Leo.Smith.test@somedomain.com' LIMIT 1];

		Contact_Role_Service_Access__c buAccess = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact__c =: submitter.Id AND Contact_Role__r.Contact_Roles__r.Name = 'BU' LIMIT 1];
		buAccess.Status__c = 'Denied';
		delete buAccess;

		Data_Submission__c subm = [SELECT Id, Submitter__c FROM Data_Submission__c LIMIT 1];
		Account a = [SELECT Id FROM Account WHERE Name = 'Test account' LIMIT 1];
		Map<Id, Set<Id>> result = DataSubmissionTriggerHandler.getAllDataSubmittersAndSuperUsers(new List<Id>{a.Id}, new List<Data_Submission__c>{subm});
		Set<id> users = result.get(subm.Id);
		system.assertEquals(result.get(subm.Id).size(), 1);
		system.assertEquals(new list<Id>(users)[0], submitter.Id);
	}

	static testMethod void getNotifiedUsers3() {
		Contact submitter = [SELECT id FROM Contact WHERE Email = 'Neo.Smith.test@somedomain.com' LIMIT 1];
		Contact superUser = [SELECT id FROM Contact WHERE Email = 'Leo.Smith.test@somedomain.com' LIMIT 1];

		Contact_Role_Service_Access__c buAccess = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact__c =: submitter.Id AND Contact_Role__r.Contact_Roles__r.Name = 'GADM Data Submitter' LIMIT 1];

		delete buAccess;

		Data_Submission__c subm = [SELECT Id, Submitter__c,Account__c FROM Data_Submission__c LIMIT 1];
		Account a = [SELECT Id FROM Account WHERE Name = 'Test account' LIMIT 1];
		Map<Id, Set<Id>> result = DataSubmissionTriggerHandler.getAllDataSubmittersAndSuperUsers(new List<Id>{a.Id}, new List<Data_Submission__c>{subm});
		Set<id> users = result.get(subm.Id);
		system.assertEquals(result.get(subm.Id).size(), 1);
		system.assertEquals(new list<Id>(users)[0], superUser.Id);
	}



	@TestSetup
	private static void setup() {

		Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'Cs';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;

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
		insert acc;

		Contact testContact = createContact('Neo', 'Smith', acc);
		Contact testContact2 = createContact('Leo', 'Smith', acc);

		Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

		User testUser = createUser(testContact, profileId);
		User testUser2 = createUser(testContact2, profileId);

		//GADM Participang Account Role
		Account_Roles__c accountRoles = new Account_Roles__c();
		accountRoles.Name = 'GADM Participant';
		insert accountRoles;

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
		insert accountRolesToInsert;

		List<Contact_Roles__c> contactRolesToInsert = new List<Contact_Roles__c>();

//possible contact roles
		Contact_Roles__c gadmUser = new Contact_Roles__c();
		gadmUser.Name = 'GADM User';
		contactRolesToInsert.add(gadmUser);

		Contact_Roles__c superUser = new Contact_Roles__c();
		superUser.Name = 'Service Super User';
		contactRolesToInsert.add(superUser);

		Contact_Roles__c dataSubmitter = new Contact_Roles__c();
		dataSubmitter.Name = 'GADM Data Submitter';
		contactRolesToInsert.add(dataSubmitter);

		Contact_Roles__c businessUnit = new Contact_Roles__c();
		businessUnit.Name = 'BU';
		businessUnit.Category__c = 'Business Unit';
		contactRolesToInsert.add(businessUnit);


		insert contactRolesToInsert;

		Portal_Applications__c portalApplications = new Portal_Applications__c();
		portalApplications.Name = 'GADM';
		insert portalApplications;

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		List<Account_Contact_Role__c> accountContactRolesToInsert = new List<Account_Contact_Role__c>();

//Account contact role for user Neo and Test Account
		Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
		accountContactRole.Contact__c = testContact.Id;
		accountContactRole.Contact_Roles__c = gadmUser.Id;
		accountContactRole.Account_Role__c = accountRole.Id;
		accountContactRole.Service_Rendered__c = 'GADM';
		accountContactRole.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole);

		Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
		accountContactRole1.Contact__c = testContact.Id;
		accountContactRole1.Contact_Roles__c = dataSubmitter.Id;
		accountContactRole1.Account_Role__c = accountRole.Id;
		accountContactRole1.Service_Rendered__c = 'GADM';
		accountContactRole1.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole1);

		Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
		accountContactRole2.Contact__c = testContact.Id;
		accountContactRole2.Contact_Roles__c = gadmUser.Id;
		accountContactRole2.Account_Role__c = accountRole.Id;
		accountContactRole2.Service_Rendered__c = 'GADM';
		accountContactRole2.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole2);

		Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
		accountContactRole4.Contact__c = testContact2.Id;
		accountContactRole4.Contact_Roles__c = gadmUser.Id;
		accountContactRole4.Account_Role__c = accountRole.Id;
		accountContactRole4.Service_Rendered__c = 'GADM';
		accountContactRole4.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole4);

		Account_Contact_Role__c accountContactRole5 = new Account_Contact_Role__c();
		accountContactRole5.Contact__c = testContact2.Id;
		accountContactRole5.Contact_Roles__c = dataSubmitter.Id;
		accountContactRole5.Account_Role__c = accountRole.Id;
		accountContactRole5.Service_Rendered__c = 'GADM';
		accountContactRole5.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole5);

		Account_Contact_Role__c accountContactRole6 = new Account_Contact_Role__c();
		accountContactRole6.Contact__c = testContact2.Id;
		accountContactRole6.Contact_Roles__c = superUser.Id;
		accountContactRole6.Account_Role__c = accountRole.Id;
		accountContactRole6.Service_Rendered__c = 'GADM';
		accountContactRole6.RecordTypeId = functionalRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole6);

		Account_Contact_Role__c accountContactRole7 = new Account_Contact_Role__c();
		accountContactRole7.Contact__c = testContact2.Id;
		accountContactRole7.Contact_Roles__c = gadmUser.Id;
		accountContactRole7.Account_Role__c = accountRole.Id;
		accountContactRole7.Service_Rendered__c = 'GADM';
		accountContactRole7.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole7);

		Account_Contact_Role__c accountContactRole8 = new Account_Contact_Role__c();
		accountContactRole8.Contact__c = testContact.Id;
		accountContactRole8.Contact_Roles__c = businessUnit.Id;
		accountContactRole8.Account_Role__c = accountRole.Id;
		accountContactRole8.Service_Rendered__c = 'GADM';
		accountContactRole8.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole8);

		Account_Contact_Role__c accountContactRole9 = new Account_Contact_Role__c();
		accountContactRole9.Contact__c = testContact2.Id;
		accountContactRole9.Contact_Roles__c = businessUnit.Id;
		accountContactRole9.Account_Role__c = accountRole.Id;
		accountContactRole9.Service_Rendered__c = 'GADM';
		accountContactRole9.RecordTypeId = groupRecordTypeId;
		accountContactRolesToInsert.add(accountContactRole9);


		insert accountContactRolesToInsert;


		List<Contact_Role_Service_Access__c> contactRoleServiceAccessesToInsert = new List<Contact_Role_Service_Access__c>();


		Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
		serviceAccess.Contact_Role__c = accountContactRole.Id;
		serviceAccess.Service__c = portalApplications.Id;
		serviceAccess.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess);

		Contact_Role_Service_Access__c serviceAccess1 = new Contact_Role_Service_Access__c();
		serviceAccess1.Contact_Role__c = accountContactRole1.Id;
		serviceAccess1.Service__c = portalApplications.Id;
		serviceAccess1.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess1);

		Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
		serviceAccess2.Contact_Role__c = accountContactRole2.Id;
		serviceAccess2.Service__c = portalApplications.Id;
		serviceAccess2.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess2);

		Contact_Role_Service_Access__c serviceAccess4 = new Contact_Role_Service_Access__c();
		serviceAccess4.Contact_Role__c = accountContactRole4.Id;
		serviceAccess4.Service__c = portalApplications.Id;
		serviceAccess4.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess4);

		Contact_Role_Service_Access__c serviceAccess5 = new Contact_Role_Service_Access__c();
		serviceAccess5.Contact_Role__c = accountContactRole5.Id;
		serviceAccess5.Service__c = portalApplications.Id;
		serviceAccess5.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess5);

		Contact_Role_Service_Access__c serviceAccess6 = new Contact_Role_Service_Access__c();
		serviceAccess6.Contact_Role__c = accountContactRole6.Id;
		serviceAccess6.Service__c = portalApplications.Id;
		serviceAccess6.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess6);

		Contact_Role_Service_Access__c serviceAccess7 = new Contact_Role_Service_Access__c();
		serviceAccess7.Contact_Role__c = accountContactRole7.Id;
		serviceAccess7.Service__c = portalApplications.Id;
		serviceAccess7.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess7);

		Contact_Role_Service_Access__c serviceAccess8 = new Contact_Role_Service_Access__c();
		serviceAccess8.Contact_Role__c = accountContactRole8.Id;
		serviceAccess8.Service__c = portalApplications.Id;
		serviceAccess8.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess8);

		Contact_Role_Service_Access__c serviceAccess9 = new Contact_Role_Service_Access__c();
		serviceAccess9.Contact_Role__c = accountContactRole9.Id;
		serviceAccess9.Service__c = portalApplications.Id;
		serviceAccess9.Status__c = 'Granted';
		contactRoleServiceAccessesToInsert.add(serviceAccess9);

		insert contactRoleServiceAccessesToInsert;

		Data_Submission__c submission = new Data_Submission__c();
		submission.User__c = testContact.Id;
		submission.Result__c = 'Test result' ;
		submission.Status__c = 'Submitted';
		submission.Type__c = 'Submission';
		submission.File_Name__c = 'file.xml';
		submission.Submitter__c = testUser.Id;
		submission.Account__c = acc.Id;
		submission.Submission_date__c = System.now();
		insert submission;
	}


	private static Contact createContact(String firstName, String lastName, Account acc) {
		Contact testContact = new Contact();
		testContact.AccountId = acc.id;
		testContact.Firstname = firstName;
		testContact.Lastname = lastName;
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
		testUser.CommunityNickname = (testContact.FirstName + testContact.LastName).substring(0, 8);
		testUser.ProfileId = profileId; //ISSP_Constant.TEST_User_ProfileID;
		testUser.IsActive = true;
		insert testUser;
		return testUser;
	}
}
