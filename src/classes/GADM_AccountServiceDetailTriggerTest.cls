@IsTest
public class GADM_AccountServiceDetailTriggerTest {

    @TestSetup
    private static void setup() {

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        List<Account> accToInsert = new List<Account>();

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
        accToInsert.add(acc);

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
        accToInsert.add(acc2);

        insert accToInsert;

        Contact testContact = createContact('Neo', 'Smith', acc);
        Contact testContact2 = createContact('Leo', 'Smith', acc2);


        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        User testUser = createUser(testContact, profileId);
        User testUser2 = createUser(testContact2, profileId);

        //GADM Participang Account Role
        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

        Date today = Date.today();

        List<Account_Role__c> accountRolesList = new List<Account_Role__c>();

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.RecordTypeId = defaultRecordTypeId;
        accountRole.Account__c = acc.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        accountRole.Status__c = 'Active';
        accountRole.Effective_From_Date__c = today.addDays(-2);
        accountRole.Effective_To_Date__c = today;
        accountRolesList.add(accountRole);

        Account_Role__c accountRole2 = new Account_Role__c();
        accountRole2.RecordTypeId = defaultRecordTypeId;
        accountRole2.Account__c = acc2.Id;
        accountRole2.Account_Roles__c = accountRoles.Id;
        accountRole2.Status__c = 'Active';
        accountRole2.Effective_From_Date__c = today.addDays(-2);
        accountRole2.Effective_To_Date__c = today;
        accountRolesList.add(accountRole2);

        insert accountRolesList;

        List<Contact_Roles__c> contactRolesList = new List<Contact_Roles__c>();

        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        contactRolesList.add(contactRoles);

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Service Power User';
        contactRolesList.add(contactRoles2);

        insert contactRolesList;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

        Account_Role_Service__c accountRoleService = new Account_Role_Service__c();
        accountRoleService.Account_Role__c = accountRole.Id;
        accountRoleService.Account_Role_Services__c = accountRoleServices.Id;
        insert accountRoleService;



        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        List<Account_Contact_Role__c> accountContactRoles = new List<Account_Contact_Role__c>();

        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
        accountContactRole.Contact__c = testContact.Id;
        accountContactRole.Contact_Roles__c = contactRoles.Id;
        accountContactRole.Account_Role__c = accountRole.Id;
        accountContactRole.Service_Rendered__c = 'GADM';
        accountContactRole.RecordTypeId = functionalRecordTypeId;
        accountContactRoles.add(accountContactRole);

        Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
        accountContactRole1.Contact__c = testContact.Id;
        accountContactRole1.Contact_Roles__c = contactRoles.Id;
        accountContactRole1.Account_Role__c = accountRole.Id;
        accountContactRole1.Service_Rendered__c = 'GADM';
        accountContactRole1.RecordTypeId = groupRecordTypeId;
        accountContactRoles.add(accountContactRole1);

        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact.Id;
        accountContactRole2.Contact_Roles__c = contactRoles2.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        accountContactRoles.add(accountContactRole2);

        Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
        accountContactRole3.Contact__c = testContact2.Id;
        accountContactRole3.Contact_Roles__c = contactRoles2.Id;
        accountContactRole3.Account_Role__c = accountRole2.Id;
        accountContactRole3.Service_Rendered__c = 'GADM';
        accountContactRole3.RecordTypeId = groupRecordTypeId;
        accountContactRoles.add(accountContactRole3);

        insert accountContactRoles;

        List<Contact_Role_Service_Access__c> contactRoleServiceAccesses = new List<Contact_Role_Service_Access__c>();

        Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
        serviceAccess.Contact_Role__c = accountContactRole.Id;
        serviceAccess.Service__c = portalApplications.Id;
        serviceAccess.Status__c = 'Granted';
        contactRoleServiceAccesses.add(serviceAccess);

        Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
        serviceAccess2.Contact_Role__c = accountContactRole2.Id;
        serviceAccess2.Service__c = portalApplications.Id;
        serviceAccess2.Status__c = 'Granted';
        contactRoleServiceAccesses.add(serviceAccess2);

        Contact_Role_Service_Access__c serviceAccess3 = new Contact_Role_Service_Access__c();
        serviceAccess3.Contact_Role__c = accountContactRole3.Id;
        serviceAccess3.Service__c = portalApplications.Id;
        serviceAccess3.Status__c = 'Granted';
        contactRoleServiceAccesses.add(serviceAccess3);

        insert contactRoleServiceAccesses;

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
    private static void insertTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId0001test';
            insert serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void insert_emptyTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = '';
            insert serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void deleteTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {

            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId0001test';
            insert serviceDetail;

            delete serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void updateTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = '';
            insert serviceDetail;

            serviceDetail.External_Actor_Id__c = 'ExtId002test';
            update serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void update2Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            insert serviceDetail;

            serviceDetail.External_Actor_Id__c = 'ExtId002test';
            update serviceDetail;

            serviceDetail.External_Actor_Id__c = 'ExtId003test';
            update serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void update3Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId002test';
            serviceDetail.Expected_amount_of_data_submissions__c = 5;
            insert serviceDetail;

            serviceDetail.External_Actor_Id__c = '';
            serviceDetail.Expected_amount_of_data_submissions__c = null;
            update serviceDetail;

            serviceDetail.Active_User_Count__c = 6;
            update serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void update3bTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId002test';
            serviceDetail.Expected_amount_of_data_submissions__c = 5;
            insert serviceDetail;

            serviceDetail.External_Actor_Id__c = '';
            serviceDetail.Expected_amount_of_data_submissions__c = null;
            update serviceDetail;

            serviceDetail.Expected_amount_of_data_submissions__c = 6;
            update serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void update4Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId002test';
            serviceDetail.Expected_amount_of_data_submissions__c = 5;
            insert serviceDetail;

            serviceDetail.External_Actor_Id__c = null;
            update serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void update5Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        //only one exists now
        Account_Role_Service__c accountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        System.runAs(testUser) {
            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId002test';
            serviceDetail.Expected_amount_of_data_submissions__c = 5;
            insert serviceDetail;

            update serviceDetail;

        }

        Test.stopTest();

    }

    @IsTest
    private static void checkGadmDuplicatesInsertTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];

        Account_Role_Service__c existingAccountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        String errorMessage = '';
        String existingServiceDetailId = '';

        System.runAs(testUser) {

            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = existingAccountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId0001test';
            insert serviceDetail;

            existingServiceDetailId = serviceDetail.Id;

            try{

                GADM_Account_Service_Detail__c serviceDetail2 = new GADM_Account_Service_Detail__c();
                serviceDetail2.Account_Role_Service__c = existingAccountRoleService.Id;
                serviceDetail2.Allowed_email_domain__c = 'somedomain.com';
                serviceDetail2.Active_User_Count__c = 5;
                serviceDetail2.External_Actor_Id__c = 'ExtId0001test';
                insert serviceDetail2;

            }catch(DmlException e) {
                errorMessage = e.getMessage();
            }

        }

        Test.stopTest();

        System.assertEquals(true, errorMessage.contains(existingServiceDetailId), 'Duplicates of GADM_Account_Service_Detail__c for GADM service are not allowed!');

    }

    @IsTest
    private static void checkGadmDuplicatesInsert2Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        Account_Role__c accountRole = [SELECT Id FROM Account_Role__c WHERE Account__c = :testAccount.Id];

        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'ISSP';
        insert portalApplications;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

        Account_Role_Service__c accountRoleService = new Account_Role_Service__c();
        accountRoleService.Account_Role__c = accountRole.Id;
        accountRoleService.Account_Role_Services__c = accountRoleServices.Id;
        insert accountRoleService;


        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId0001test';
            insert serviceDetail;

            try{

                GADM_Account_Service_Detail__c serviceDetail2 = new GADM_Account_Service_Detail__c();
                serviceDetail2.Account_Role_Service__c = accountRoleService.Id;
                serviceDetail2.Allowed_email_domain__c = 'somedomain.com';
                serviceDetail2.Active_User_Count__c = 5;
                serviceDetail2.External_Actor_Id__c = 'ExtId0002test';
                insert serviceDetail2;

            }catch(DmlException e) {
                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();

        System.assertEquals('', errorMessage, 'Duplicates of GADM_Account_Service_Detail__c for non GADM service should be allowed!');

    }

    @IsTest
    private static void checkGadmDuplicatesUpdateTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];

        Account_Role_Service__c existingAccountRoleService = [SELECT Id FROM Account_Role_Service__c];

        Test.startTest();

        String errorMessage = '';
        String existingServiceDetailId = '';

        System.runAs(testUser) {

            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = existingAccountRoleService.Id;
            serviceDetail.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail.Active_User_Count__c = 5;
            serviceDetail.External_Actor_Id__c = 'ExtId0001test';
            insert serviceDetail;

            existingServiceDetailId = serviceDetail.Id;

            try{

                serviceDetail.Allowed_email_domain__c += ';someotherdomain.com';
                update serviceDetail;

            }catch(DmlException e) {
                errorMessage = e.getMessage();
            }

        }

        Test.stopTest();

        System.assertEquals('', errorMessage, 'Update where Account_Role_Service__c nor Service_Name__c are not changed should be allowed!');

    }

    @IsTest
    private static void checkGadmDuplicatesUpdate2Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        Account_Role__c accountRole = [SELECT Id FROM Account_Role__c WHERE Account__c = :testAccount.Id];

        Account_Role_Service__c existingGadmAccountRoleService = [SELECT Id FROM Account_Role_Service__c];

        GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
        serviceDetail.Account_Role_Service__c = existingGadmAccountRoleService.Id;
        serviceDetail.Allowed_email_domain__c = 'somedomain.com';
        serviceDetail.Active_User_Count__c = 5;
        serviceDetail.External_Actor_Id__c = 'ExtId0001test';
        insert serviceDetail;

        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'ISSP';
        insert portalApplications;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

        Account_Role_Service__c accountRoleService = new Account_Role_Service__c();
        accountRoleService.Account_Role__c = accountRole.Id;
        accountRoleService.Account_Role_Services__c = accountRoleServices.Id;
        insert accountRoleService;


        Test.startTest();

        String errorMessage = '';
        String existingServiceDetailId = '';

        System.runAs(testUser) {

            GADM_Account_Service_Detail__c serviceDetail2 = new GADM_Account_Service_Detail__c();
            serviceDetail2.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail2.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail2.Active_User_Count__c = 5;
            serviceDetail2.External_Actor_Id__c = 'ExtId0002test';
            insert serviceDetail2;

            existingServiceDetailId = serviceDetail.Id;

            try{

                serviceDetail2.Account_Role_Service__c = existingGadmAccountRoleService.Id;
                update serviceDetail2;


            }catch(DmlException e) {
                errorMessage = e.getMessage();
            }

        }

        Test.stopTest();

        System.assertEquals(true, errorMessage.contains(serviceDetail.Id), 'Duplicates of GADM_Account_Service_Detail__c for GADM service are not allowed!');

    }

    @IsTest
    private static void checkGadmDuplicatesUpdate3Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];
        Account_Role__c accountRole = [SELECT Id FROM Account_Role__c WHERE Account__c = :testAccount.Id];

        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'ISSP';
        insert portalApplications;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

        Account_Role_Service__c accountRoleService = new Account_Role_Service__c();
        accountRoleService.Account_Role__c = accountRole.Id;
        accountRoleService.Account_Role_Services__c = accountRoleServices.Id;
        insert accountRoleService;


        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            GADM_Account_Service_Detail__c serviceDetail2 = new GADM_Account_Service_Detail__c();
            serviceDetail2.Account_Role_Service__c = accountRoleService.Id;
            serviceDetail2.Allowed_email_domain__c = 'somedomain.com';
            serviceDetail2.Active_User_Count__c = 5;
            serviceDetail2.External_Actor_Id__c = 'ExtId0002test';
            insert serviceDetail2;


            try{

                serviceDetail2.Allowed_email_domain__c += '; gmail.com';
                update serviceDetail2;


            }catch(DmlException e) {
                errorMessage = e.getMessage();
            }

        }

        Test.stopTest();

        System.assertEquals('', errorMessage, 'Duplicates of GADM_Account_Service_Detail__c for non GADM service should be allowed!');

    }

}