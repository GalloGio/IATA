@IsTest
public  class GADM_TabsContainerController_TEST {

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

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        User testUser = createUser(testContact, profileId);


        List<Data_Submission__c> listToInsert = new List<Data_Submission__c>();

        for(Integer i = 0; i < 20; i++) {
            Data_Submission__c submission = new Data_Submission__c();
            submission.User__c = testContact.Id;
            submission.Result__c = 'Test result ' + i;
            submission.Status__c = 'Submitted';
            submission.Type__c = 'Submission';
            submission.Submission_date__c = System.now();
            listToInsert.add(submission);
        }

        insert listToInsert;
        //GADM Participang Account Role
        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

        Date today = Date.today();

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.RecordTypeId = defaultRecordTypeId;
        accountRole.Account__c = acc.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        accountRole.Status__c = 'Active';
        accountRole.Effective_From_Date__c = today.addDays(-2);
        accountRole.Effective_To_Date__c = today;
        insert accountRole;


        //possible contact roles
        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        insert contactRoles;

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Service Power User';
        insert contactRoles2;

        Contact_Roles__c contactRoles3 = new Contact_Roles__c();
        contactRoles3.Name = 'Service Super User';
        insert contactRoles3;

        Contact_Roles__c contactRoles4 = new Contact_Roles__c();
        contactRoles4.Name = 'GADM Data Submitter';
        insert contactRoles4;

        Contact_Roles__c contactRoles5 = new Contact_Roles__c();
        contactRoles5.Name = 'GADM Data Consumer';
        insert contactRoles5;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        //Account contact role for user Neo and Test Account
        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
        accountContactRole.Contact__c = testContact.Id;
        accountContactRole.Contact_Roles__c = contactRoles.Id;
        accountContactRole.Account_Role__c = accountRole.Id;
        accountContactRole.Service_Rendered__c = 'GADM';
        accountContactRole.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole;

        Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
        accountContactRole1.Contact__c = testContact.Id;
        accountContactRole1.Contact_Roles__c = contactRoles.Id;
        accountContactRole1.Account_Role__c = accountRole.Id;
        accountContactRole1.Service_Rendered__c = 'GADM';
        accountContactRole1.RecordTypeId = groupRecordTypeId;
        insert accountContactRole1;

        //Account contact role for user Neo and Test Account
        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact.Id;
        accountContactRole2.Contact_Roles__c = contactRoles2.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole2;

        //grant access for user Neo, account Test account and GADM User role and GADM service
        Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
        serviceAccess.Contact_Role__c = accountContactRole.Id;
        serviceAccess.Service__c = portalApplications.Id;
        serviceAccess.Status__c = 'Granted';
        insert serviceAccess;

        //grant access for user Neo, account Test account and GADM User role and GADM service
        Contact_Role_Service_Access__c serviceAccess1 = new Contact_Role_Service_Access__c();
        serviceAccess1.Contact_Role__c = accountContactRole1.Id;
        serviceAccess1.Service__c = portalApplications.Id;
        serviceAccess1.Status__c = 'Granted';
        insert serviceAccess1;

        //grant access for user Neo, account Test account and Service Power User role and GADM service
        Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
        serviceAccess2.Contact_Role__c = accountContactRole2.Id;
        serviceAccess2.Service__c = portalApplications.Id;
        serviceAccess2.Status__c = 'Granted';
        insert serviceAccess2;


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
        testUser.Alias = 'dsfsdfds';
        testUser.Email = testContact.email;
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
    private static void getUserGrantedRolesTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        List<Contact_Roles__c> grantedRoles = new List<Contact_Roles__c>();

        Test.startTest();

            grantedRoles= GADM_TabsContainerController.getUserGrantedRoles(testUser.Id);

        Test.stopTest();

        System.assertEquals(2, grantedRoles.size(), 'Wrong number of granted roles retrieved!');

        List<String> roleNames = new List<String>();
        for(Contact_Roles__c grantedRole : grantedRoles) {
            roleNames.add(grantedRole.Name);
        }

        System.assertEquals(true, roleNames.contains('GADM User'), 'GADM User role should be granted!');
        System.assertEquals(true, roleNames.contains('Service Power User'), 'Service Power User role should be granted!');
    }

}