@IsTest
public class File_Upload_Lookup_CTRL_TEST {

	public static final ID headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

	@TestSetup
	private static void setup(){
		IATA_ISO_Country__c canada = createIataCountry('Canada', 'CA', 'Canada');
		Account testAccount = createTestAccount('Test Account', canada);
		Contact testContact = createTestContact(testAccount);
		User testUser = createTestUser(testContact);


		Account_Role__c accountRole = new Account_Role__c();
		accountRole.Account__c = testAccount.Id;
		insert accountRole;

		Contact_Roles__c contactRoles = new Contact_Roles__c();
		contactRoles.Name = 'GADM User';
		insert contactRoles;

		Contact_Roles__c contactRoles2 = new Contact_Roles__c();
		contactRoles2.Name = 'GADM Data Submitter';
		insert contactRoles2;

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		Account_Contact_Role__c contactRole1 = new Account_Contact_Role__c();
		contactRole1.RecordTypeId = functionalRecordTypeId;
		contactRole1.Account_Role__c = accountRole.Id;
		contactRole1.Contact__c = testContact.Id;
		contactRole1.Contact_Roles__c = contactRoles.Id;
		contactRole1.Service_Rendered__c = 'GADM';
		insert contactRole1;


		Account_Contact_Role__c contactRole = new Account_Contact_Role__c();
		contactRole.RecordTypeId = groupRecordTypeId;
		contactRole.Account_Role__c = accountRole.Id;
		contactRole.Contact__c = testContact.Id;
		contactRole.Contact_Roles__c = contactRoles.Id;
		contactRole.Service_Rendered__c = 'GADM';
		insert contactRole;

		Account_Contact_Role__c contactRole2 = new Account_Contact_Role__c();
		contactRole2.RecordTypeId = functionalRecordTypeId;
		contactRole2.Account_Role__c = accountRole.Id;
		contactRole2.Contact__c = testContact.Id;
		contactRole2.Contact_Roles__c = contactRoles2.Id;
		contactRole2.Service_Rendered__c = 'GADM';
		insert contactRole2;

		Portal_Applications__c portalApplications = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		portalApplications.Name = 'GADM';
		insert portalApplications;

		Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
		access.Contact__c = testContact.Id;
		access.Status__c = 'Granted';
		access.Contact_Role__c = contactRole.Id;
		access.Service__c = portalApplications.Id;
		insert access;

		Contact_Role_Service_Access__c access1 = new Contact_Role_Service_Access__c();
		access1.Contact__c = testContact.Id;
		access1.Status__c = 'Granted';
		access1.Contact_Role__c = contactRole1.Id;
		access1.Service__c = portalApplications.Id;
		insert access1;

		Contact_Role_Service_Access__c access2 = new Contact_Role_Service_Access__c();
		access2.Contact__c = testContact.Id;
		access2.Status__c = 'Granted';
		access2.Contact_Role__c = contactRole2.Id;
		access2.Service__c = portalApplications.Id;
		insert access2;

	}

	private static IATA_ISO_Country__c createIataCountry(String name, String isoCode, string areaName) {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = name;
		country.ISO_Code__c = isoCode;
		country.AIMS_Area_Name__c = areaName;
		country.AIMS_Area_ID__c = '1';

		insert country;
		return country;
	}


	private static Account createTestAccount(String accountName, IATA_ISO_Country__c country) {
		Account acc = new Account();
		acc.Name = accountName;
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
		return acc;
	}

	private static Contact createTestContact(Account account) {
		Contact testContact = new Contact();
		testContact.AccountId = account.id;
		testContact.Firstname = 'Luisa';
		testContact.Lastname='Sanchez';
		testContact.Phone = '911111113';
		testContact.MobilePhone = '911111113';
		testContact.Email = 'testFileUploadLookup@test.com';
		testContact.BSP_CASS_Payment_contact__c = false;
		testContact.User_Portal_Status__c = 'Approved';

		insert testContact;
		return testContact;

	}

	private static User createTestUser(Contact contact) {

		User newUser = new User();
		newUser.alias = 'dsfsdfds';
		newUser.email = contact.email;
		newUser.emailencodingkey = 'UTF-8';
		newUser.firstname = contact.firstName;
		newUser.lastname = contact.lastname;
		newUser.languagelocalekey = 'en_US';
		newUser.localesidkey = 'en_US';
		newUser.contactId = contact.Id;
		newUser.FederationIdentifier = contact.Id;
		newUser.timezonesidkey = 'Asia/Dubai';
		newUser.Username = contact.Email;
		newUser.PortalRole = 'Manager';
		newUser.CommunityNickname = (contact.FirstName + contact.LastName).substring(0,8);
		newUser.ProfileId = ISSP_Constant.TEST_User_ProfileID;
		newUser.IsActive = true;

		insert newUser;
		return newUser;

	}



	@IsTest
	private static void lookupTest() {

		User testUser = [SELECT Id FROM User WHERE Email = 'testFileUploadLookup@test.com'];
		Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'testFileUploadLookup@test.com'];

		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = testContact.Id;
		Test.setFixedSearchResults(fixedSearchResults);

		List<File_Upload_Lookup_CTRL.Result> result = new List<File_Upload_Lookup_CTRL.Result>();

		Test.startTest();

		System.runAs(testUser) {

			result = File_Upload_Lookup_CTRL.lookup('Luisa', 'Contact', '');

		}


		Test.stopTest();

		System.assertEquals(result[0].SObjectId, testContact.Id, 'Incorrect contact id retrieved!');

	}

}
