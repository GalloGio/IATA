@IsTest
public class GADM_ExternalUserContactList_CTRL_TEST {

    @TestSetup
    private static void setup() {

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        List<Account> accountsToInsert = new List<Account>();

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
        accountsToInsert.add(acc);

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
        accountsToInsert.add(acc2);

        insert accountsToInsert;

        Contact testContact = createContact('Neo', 'Smith', acc);
        Contact testContact2 = createContact('Leo', 'Black', acc2);
        Contact testContact3 = createContact('Petr', 'Novy', acc);

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        User testUser = createUser(testContact, profileId);
        User testUser2 = createUser(testContact2, profileId);
        User testUser3 = createUser(testContact3, profileId);

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

        insert contactRolesToInsert;


        List<Contact_Role_Service__c> contactRoleServicesToInsert = new List<Contact_Role_Service__c>();

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

        insert contactRoleServicesToInsert;

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        List<Account_Contact_Role__c> accountContactRolesToInset = new List<Account_Contact_Role__c>();

        //Account contact role for user Neo and Test Account
        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
        accountContactRole.Contact__c = testContact.Id;
        accountContactRole.Contact_Roles__c = contactRoles.Id;
        accountContactRole.Account_Role__c = accountRole.Id;
        accountContactRole.Service_Rendered__c = 'GADM';
        accountContactRole.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInset.add(accountContactRole);

        Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
        accountContactRole1.Contact__c = testContact.Id;
        accountContactRole1.Contact_Roles__c = contactRoles.Id;
        accountContactRole1.Account_Role__c = accountRole.Id;
        accountContactRole1.Service_Rendered__c = 'GADM';
        accountContactRole1.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInset.add(accountContactRole1);

        //Account contact role for user Neo and Test Account
        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact.Id;
        accountContactRole2.Contact_Roles__c = contactRoles2.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInset.add(accountContactRole2);

        //Account contact role for user Neo and Test Account2
        Account_Contact_Role__c accountContactRole2b = new Account_Contact_Role__c();
        accountContactRole2b.Contact__c = testContact.Id;
        accountContactRole2b.Contact_Roles__c = contactRoles.Id;
        accountContactRole2b.Account_Role__c = accountRole2.Id;
        accountContactRole2b.Service_Rendered__c = 'GADM';
        accountContactRole2b.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInset.add(accountContactRole2b);

        Account_Contact_Role__c accountContactRole2c = new Account_Contact_Role__c();
        accountContactRole2c.Contact__c = testContact.Id;
        accountContactRole2c.Contact_Roles__c = contactRoles5.Id;
        accountContactRole2c.Account_Role__c = accountRole.Id;
        accountContactRole2c.Service_Rendered__c = 'GADM';
        accountContactRole2c.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInset.add(accountContactRole2c);

        //for testUser2
        //Account contact role for user Leo and Test Account2
        Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
        accountContactRole3.Contact__c = testContact2.Id;
        accountContactRole3.Contact_Roles__c = contactRoles.Id;
        accountContactRole3.Account_Role__c = accountRole2.Id;
        accountContactRole3.Service_Rendered__c = 'GADM';
        accountContactRole3.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInset.add(accountContactRole3);

        Account_Contact_Role__c accountContactRole3b = new Account_Contact_Role__c();
        accountContactRole3b.Contact__c = testContact2.Id;
        accountContactRole3b.Contact_Roles__c = contactRoles.Id;
        accountContactRole3b.Account_Role__c = accountRole2.Id;
        accountContactRole3b.Service_Rendered__c = 'GADM';
        accountContactRole3b.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInset.add(accountContactRole3b);

        Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
        accountContactRole4.Contact__c = testContact2.Id;
        accountContactRole4.Contact_Roles__c = contactRoles3.Id;
        accountContactRole4.Account_Role__c = accountRole2.Id;
        accountContactRole4.Service_Rendered__c = 'GADM';
        accountContactRole4.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInset.add(accountContactRole4);

        //for testUser2
        Account_Contact_Role__c accountContactRole5 = new Account_Contact_Role__c();
        accountContactRole5.Contact__c = testContact2.Id;
        accountContactRole5.Contact_Roles__c = contactRoles.Id;
        accountContactRole5.Account_Role__c = accountRole.Id;
        accountContactRole5.Service_Rendered__c = 'GADM';
        accountContactRole5.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInset.add(accountContactRole5);

        Account_Contact_Role__c accountContactRole5b = new Account_Contact_Role__c();
        accountContactRole5b.Contact__c = testContact2.Id;
        accountContactRole5b.Contact_Roles__c = contactRoles4.Id;
        accountContactRole5b.Account_Role__c = accountRole.Id;
        accountContactRole5b.Service_Rendered__c = 'GADM';
        accountContactRole5b.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInset.add(accountContactRole5b);

        Account_Contact_Role__c accountContactRole6 = new Account_Contact_Role__c();
        accountContactRole6.Contact__c = testContact3.Id;
        accountContactRole6.Contact_Roles__c = contactRoles.Id;
        accountContactRole6.Account_Role__c = accountRole.Id;
        accountContactRole6.Service_Rendered__c = 'GADM';
        accountContactRole6.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInset.add(accountContactRole6);

        insert accountContactRolesToInset;


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

        //grant access for user Leo, account Test account 2 and Service Super User role and GADM service
        Contact_Role_Service_Access__c serviceAccess4 = new Contact_Role_Service_Access__c();
        serviceAccess4.Contact_Role__c = accountContactRole5.Id;
        serviceAccess4.Service__c = portalApplications.Id;
        serviceAccess4.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess4);


        Contact_Role_Service_Access__c serviceAccess5 = new Contact_Role_Service_Access__c();
        serviceAccess5.Contact_Role__c = accountContactRole6.Id;
        serviceAccess5.Service__c = portalApplications.Id;
        serviceAccess5.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess5);

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
    private static void getCurrentUserInformationTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();

        GADM_ExternalUserContactList_CTRL.UserInformation info;

        System.runAs(testUser) {
            info = GADM_ExternalUserContactList_CTRL.getCurrentUserInformation(testUser.Id);
        }

        Test.stopTest();

        List<Contact_Roles__c> businessUnits = info.grantedBusinessUnits;
        List<Contact_Roles__c> roles = info.grantedRoles;
        List<Account> actors = info.visibleAccounts;

        System.assertEquals(1, businessUnits.size(), 'Incorrect number of business units retrieved!');
        System.assertEquals(2, roles.size(), 'Incorrect number of roles retrieved!');
        System.assertEquals(2, actors.size(), 'Incorrect number of visible accounts retrieved!');

        List<String> roleNames = new List<String>();
        List<String> actorsNames = new List<String>();

        for(Contact_Roles__c role : roles) {
            roleNames.add(role.Name);
        }

        for(Account actor : actors) {
            actorsNames.add(actor.Name);
        }

        System.assertEquals('Security', businessUnits[0].Name, 'Incorrect number of business units retrieved!');
        System.assertEquals(true, roleNames.contains('GADM User'), 'GADM User role should be granted!');
        System.assertEquals(true, roleNames.contains('Service Power User'), 'Service Power User role should be granted!');
        System.assertEquals(true, actorsNames.contains('Test account'), 'Test account should be visible!');
        System.assertEquals(true, actorsNames.contains('Test account 2'), 'Test account 2 should be visible!');

    }

    @IsTest
    private static void getContactsVisibleToUserTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Black.test@somedomain.com'];

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account'];
        Account testAccount2 = [SELECT Id FROM Account WHERE Name = 'Test account 2'];

        Contact_Roles__c gadmUserRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];
        Contact_Roles__c powerUserRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Service Power User'];
        Contact_Roles__c superUserRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Service Super User'];
        Contact_Roles__c dataSubmitterRole = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM Data Submitter'];

        Contact_Roles__c businessUnit = [SELECT Id FROM Contact_Roles__c WHERE Name = 'Security'];

        Map<Id, Contact_Roles__c> businessUnits = new Map<Id, Contact_Roles__c>([SELECT Id FROM Contact_Roles__c WHERE Category__c = 'Business Unit']);

        Test.startTest();

        List<Contact_Roles_Helper.AggregatedRecordWrapper> wrapper;

        System.runAs(testUser) {

            wrapper = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser2.Id, false, false, new List<Id>(businessUnits.keySet()), false);

        }

        Test.stopTest();

        System.assertEquals(3, wrapper.size(),'There should be exact 2 contacts visible!');

        Contact_Roles_Helper.AggregatedRecordWrapper userWrapper;
        Contact_Roles_Helper.AggregatedRecordWrapper user2Wrapper;

        for(Contact_Roles_Helper.AggregatedRecordWrapper uw: wrapper){
            if(uw.con.Email == 'Neo.Smith.test@somedomain.com') {
                userWrapper = uw;
            }
            if(uw.con.Email == 'Leo.Black.test@somedomain.com') {
                user2Wrapper = uw;
            }
        }

        Map<Id, Account_Contact_Role__c> actorsData1 = userWrapper.actorsData;
        Map<Id, Contact_Role_Service_Access__c> rolesData1 = userWrapper.rolesData;
        Map<Id, Contact_Role_Service_Access__c> businessUnitsData1 = userWrapper.buData;

        Map<Id, Account_Contact_Role__c> actorsData2 = user2Wrapper.actorsData;
        Map<Id, Contact_Role_Service_Access__c> rolesData2 = user2Wrapper.rolesData;
        Map<Id, Contact_Role_Service_Access__c> businessUnitsData2 = user2Wrapper.buData;

        System.assertEquals(2, actorsData1.size(), 'Incorrect number of actor retrieved!');
        System.assertEquals(true, actorsData1.containsKey(testAccount.Id), 'Test account should be visible!');
        System.assertEquals(true, actorsData1.containsKey(testAccount2.Id), 'Test account 2 should be visible!');
        System.assertEquals(1, businessUnitsData1.size(), 'Incorrect number of business units retrieved!');
        System.assertEquals(true, businessUnitsData1.containsKey(businessUnit.Id), 'Business unit does not match!');
        System.assertEquals(2, rolesData1.size(), 'Incorrect number of roles retrieved!');
        System.assertEquals(true, rolesData1.containsKey(gadmUserRole.Id), 'GADM User role should be visible!');
        System.assertEquals(true, rolesData1.containsKey(powerUserRole.Id), 'Power User role should be visible!');

        System.assertEquals(2, actorsData2.size(), 'Incorrect number of actor retrieved!');
        System.assertEquals(true, actorsData2.containsKey(testAccount.Id), 'Test account should be visible!');
        System.assertEquals(true, actorsData2.containsKey(testAccount2.Id), 'Test account 2 should be visible!');
        System.assertEquals(null, businessUnitsData2, 'Incorrect number of business units retrieved!');
        System.assertEquals(3, rolesData2.size(), 'Incorrect number of roles retrieved!');
        System.assertEquals(true, rolesData2.containsKey(gadmUserRole.Id), 'GADM User role should be visible!');
        System.assertEquals(true, rolesData2.containsKey(superUserRole.Id), 'Super User role should be visible!');
        System.assertEquals(true, rolesData2.containsKey(dataSubmitterRole.Id), 'GADM Data Submitter role should be visible!');

    }

    @IsTest
    private static void getContactsVisibleToUser2Test() {

        User testUser = [SELECT Id, Email FROM User WHERE Email = 'petr.novy.test@somedomain.com'];

        Test.startTest();

        List<Contact_Roles_Helper.AggregatedRecordWrapper> wrapper;

        System.runAs(testUser) {

            wrapper = GADM_ExternalUserContactList_CTRL.getContactsVisibleToUser(testUser.Id, false, false, new List<Id>(), false);
            System.debug('wrapper:: ' + wrapper);

        }

        Test.stopTest();

        System.assertEquals(1, wrapper.size(), 'Wrong number of records retrieved!');
        System.assertEquals(testUser.Email, wrapper[0].con.Email, 'Wrong record retrieved!');

    }


}