@IsTest
public class OneId_RegistrationHelper_GADM_TEST {

    @TestSetup
    private static void setup() {

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        Account parentAcc = new Account();
        parentAcc.Name='parentAccount1';
        parentAcc.Type='IATA Passenger Sales Agent';
        parentAcc.Location_Type__c = 'AO';
        insert parentAcc;

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
        acc.ParentId = parentAcc.Id;
        acc.Top_Parent__c = parentAcc.Id;
        insert acc;

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
        acc2.ParentId = parentAcc.Id;
        acc2.Top_Parent__c = parentAcc.Id;
        insert acc2;

        Contact testContact = createContact('Neo', 'Smith', acc);
        Contact testContact2 = createContact('Pedro', 'Smith', acc);

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        //User testUser = createUser(testContact, profileId);

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

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.RecordTypeId = defaultRecordTypeId;
        accountRole.Account__c = acc.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        accountRole.Status__c = 'Active';
        accountRole.Effective_From_Date__c = today.addDays(-2);
        accountRole.Effective_To_Date__c = today;
        insert accountRole;

        Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

        //possible contact roles
        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        contactRoles.RecordTypeId = externalRecordTypeId;
        insert contactRoles;

        Contact_Role_Service__c roleService = new Contact_Role_Service__c();
        roleService.Service__c = portalApplications.Id;
        roleService.Contact_Role__c = contactRoles.Id;
        insert roleService;

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Service Power User';
        contactRoles2.RecordTypeId = externalRecordTypeId;
        insert contactRoles2;

        Contact_Role_Service__c roleService2 = new Contact_Role_Service__c();
        roleService2.Service__c = portalApplications.Id;
        roleService2.Contact_Role__c = contactRoles2.Id;
        insert roleService2;

        Contact_Roles__c contactRoles3 = new Contact_Roles__c();
        contactRoles3.Name = 'Service Super User';
        contactRoles3.RecordTypeId = externalRecordTypeId;
        insert contactRoles3;

        Contact_Role_Service__c roleService3 = new Contact_Role_Service__c();
        roleService3.Service__c = portalApplications.Id;
        roleService3.Contact_Role__c = contactRoles3.Id;
        insert roleService3;

        Contact_Roles__c contactRoles4 = new Contact_Roles__c();
        contactRoles4.Name = 'GADM Data Submitter';
        contactRoles4.RecordTypeId = externalRecordTypeId;
        insert contactRoles4;

        Contact_Role_Service__c roleService4 = new Contact_Role_Service__c();
        roleService4.Service__c = portalApplications.Id;
        roleService4.Contact_Role__c = contactRoles4.Id;
        insert roleService4;

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
    private static void gadmRegistrationTest() {

        Account acc1 = [SELECT Id, Name, Type, Sector__c, ParentId, Top_Parent__c FROM Account WHERE Name = 'Test account'];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'Pedro.Smith.test@somedomain.com'];

        String serviceName = 'GADM';

        Test.startTest();


        OneId_RegistrationProcessController.registration(acc1, testContact, serviceName, new Map<String, String>{'isPowerUser' =>'true'});

        Test.stopTest();

    }

    @IsTest
    private static void gadmRegistration2Test() {

        Account acc1 = [SELECT Id, Name, Type, Sector__c, ParentId, Top_Parent__c FROM Account WHERE Name = 'Test account 2'];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'Pedro.Smith.test@somedomain.com'];

        String serviceName = 'GADM';

        Test.startTest();


        OneId_RegistrationProcessController.registration(acc1, testContact, serviceName, new Map<String, String>{'isPowerUser' =>'true'});

        Test.stopTest();

    }

}