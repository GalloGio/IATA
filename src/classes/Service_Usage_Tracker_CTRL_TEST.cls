@IsTest
public class Service_Usage_Tracker_CTRL_TEST {

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

        insert accounts;

        Contact testContact = createContact('Neo', 'Smith', acc);

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        User testUser = createUser(testContact, profileId);

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

        insert contactRolesToInsert;


        Contact_Role_Service__c roleService = new Contact_Role_Service__c();
        roleService.Service__c = portalApplications.Id;
        roleService.Contact_Role__c = contactRoles.Id;
        contactRoleServicesToInsert.add(roleService);

        Contact_Role_Service__c roleService2 = new Contact_Role_Service__c();
        roleService2.Service__c = portalApplications.Id;
        roleService2.Contact_Role__c = contactRoles2.Id;
        contactRoleServicesToInsert.add(roleService2);

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

    private static void saveUsageTrackingTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];

        Boolean saved = false;

        Test.startTest();

        System.runAs(testUser) {
            saved = Service_Usage_Tracker_CTRL.saveUsageTracking(testUser.Id, 'HOME', 'GADM', 'Page');
        }

        Test.stopTest();

        System.assertEquals(true, saved);

        List<Service_Usage__c> savedUsages = [SELECT Id, User__c, Target__c, Service__c FROM Service_Usage__c];
        System.assertEquals(1, savedUsages.size(), 'Incorrect number of Service_Usage__c objects retrieved!');
        System.assertEquals(testUser.Id, savedUsages[0].User__c, 'User__c on Service_Usage__c object does not match!');
        System.assertEquals('HOME', savedUsages[0].Target__c, 'Target__c on Service_Usage__c object does not match!');
        System.assertEquals('GADM', savedUsages[0].Service__c, 'Service__c on Service_Usage__c object does not match!');
    }

    @IsTest
    private static void saveUsageTracking2Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];

        String dashboardId = '';
        List<Dashboard> dashboards = [SELECT Id FROM Dashboard LIMIT 10];
        if(! dashboards.isEmpty()) {
            dashboardId = dashboards[0].Id;
        }

        Boolean saved = false;

        Test.startTest();

        System.runAs(testUser) {
            saved = Service_Usage_Tracker_CTRL.saveUsageTracking(testUser.Id, 'HOME', 'GADM', 'Page', dashboardId);
        }

        Test.stopTest();

        System.assertEquals(true, saved);

        List<Service_Usage__c> savedUsages = [SELECT Id, User__c, Target__c, Service__c FROM Service_Usage__c];
        System.assertEquals(1, savedUsages.size(), 'Incorrect number of Service_Usage__c objects retrieved!');
        System.assertEquals(testUser.Id, savedUsages[0].User__c, 'User__c on Service_Usage__c object does not match!');
        System.assertEquals('HOME', savedUsages[0].Target__c, 'Target__c on Service_Usage__c object does not match!');
        System.assertEquals('GADM', savedUsages[0].Service__c, 'Service__c on Service_Usage__c object does not match!');
    }

    @IsTest
    private static void saveUsageTracking_falseTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];

        String loger255 = 'This string is very very very very very very very very very very very very very very very ' +
                'very very very very very very very very very very very very very very very very very very. This string' +
                'is very very very very very very very very very very very very very very vevy very very very very very' +
                ' very very very very very very very very very very very very very long.';


        Boolean saved = false;

        Test.startTest();

        System.runAs(testUser) {
            saved = Service_Usage_Tracker_CTRL.saveUsageTracking(null, loger255, 'GADM', 'Page');
        }

        Test.stopTest();

        System.assertEquals(false, saved);

        List<Service_Usage__c> savedUsages = [SELECT Id, User__c, Target__c, Service__c FROM Service_Usage__c];
        System.assertEquals(0, savedUsages.size(), 'Incorrect number of Service_Usage__c objects retrieved!');

    }

}