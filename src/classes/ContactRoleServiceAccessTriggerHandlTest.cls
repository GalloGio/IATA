@IsTest
public class ContactRoleServiceAccessTriggerHandlTest {

    @TestSetup
    private static void setup() {
        IATA_ISO_Country__c canada = createIataCountry('Canada', 'CA', 'Canada');
        Account testAccount = createTestAccount('Test Account', canada);
        Contact testContact = createTestContact(testAccount, 'testContactRoleServiceAccessTrigger@test.com', 'John', 'Rambo');
        Contact testContact2 = createTestContact(testAccount, 'testContactRoleServiceAccessTrigger2@test.com', 'Frank' , 'Herbert');
        User testUser = createTestUser(testContact);
        User testUser2 = createTestUser(testContact2);

        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.RecordTypeId = defaultRecordTypeId;
        accountRole.Account__c = testAccount.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        insert accountRole;

        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        insert contactRoles;

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Power User';
        insert contactRoles2;

        Contact_Roles__c contactRoles3 = new Contact_Roles__c();
        contactRoles3.Name = 'Account Sharing';
        insert contactRoles3;

        Contact_Roles__c contactRoles4 = new Contact_Roles__c();
        contactRoles4.Name = 'GADM Data Consumer';
        insert contactRoles4;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
        accountContactRole.Contact__c = testContact.Id;
        accountContactRole.Contact_Roles__c = contactRoles.Id;
        accountContactRole.Account_Role__c = accountRole.Id;
        accountContactRole.Service_Rendered__c = 'GADM';
        accountContactRole.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole;

        //role GADM User is pending
        Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
        serviceAccess.Contact_Role__c = accountContactRole.Id;
        serviceAccess.Service__c = portalApplications.Id;
        serviceAccess.Status__c = 'Pending';
        insert serviceAccess;

        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact2.Id;
        accountContactRole2.Contact_Roles__c = contactRoles.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole2;

        //role GADM User is pending
        Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
        serviceAccess2.Contact_Role__c = accountContactRole2.Id;
        serviceAccess2.Service__c = portalApplications.Id;
        serviceAccess2.Status__c = 'Pending';
        insert serviceAccess2;

        Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
        accountContactRole3.Contact__c = testContact2.Id;
        accountContactRole3.Contact_Roles__c = contactRoles4.Id;
        accountContactRole3.Account_Role__c = accountRole.Id;
        accountContactRole3.Service_Rendered__c = 'GADM';
        accountContactRole3.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole3;
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

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

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

    private static Contact createTestContact(Account account, String email, String firstName, String lastName) {
        Contact testContact = new Contact();
        testContact.AccountId = account.id;
        testContact.Firstname = firstName;
        testContact.Lastname = lastName;
        testContact.Phone = '911111113';
        testContact.MobilePhone = '911111113';
        testContact.Email = email;
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
        newUser.FirstName = contact.FirstName;
        newUser.LastName = contact.LastName;
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
    private static void uniqueKeyInsertNegativeTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger@test.com'];

        List<Account_Contact_Role__c> accountContactRole = [SELECT Id, Name FROM Account_Contact_Role__c];

        Portal_Applications__c portalApplications = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'GADM'];

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            try{
                Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
                serviceAccess.Contact_Role__c = accountContactRole[0].Id;
                serviceAccess.Service__c = portalApplications.Id;
                serviceAccess.Status__c = 'Pending';
                insert serviceAccess;
            }catch(Exception e) {
                errorMessage = e.getMessage();
            }
        }

        Test.stopTest();

        System.assertEquals(true, errorMessage.contains('DUPLICATE_VALUE'), 'Updating duplicates should not be allowed!');

    }

    @IsTest
    private static void uniqueKeyInsertPositiveTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger@test.com'];

        List<Account_Contact_Role__c> accountContactRole = [SELECT Id, Name FROM Account_Contact_Role__c];

        Portal_Applications__c portalApplication = new Portal_Applications__c();
        portalApplication.Name = 'ISSP';
        insert portalApplication;

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            try{
                Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
                serviceAccess.Contact_Role__c = accountContactRole[0].Id;
                serviceAccess.Service__c = portalApplication.Id;
                serviceAccess.Status__c = 'Pending';
                insert serviceAccess;
            }catch(Exception e) {
                errorMessage = e.getMessage();
            }
        }

        Test.stopTest();

        System.assertEquals(true, errorMessage == '', 'No error should occur!');

    }

    @IsTest
    private static void uniqueKeyUpdatePositiveTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger@test.com'];

        Portal_Applications__c portalApplication = new Portal_Applications__c();
        portalApplication.Name = 'ISSP';
        insert portalApplication;

        Test.startTest();

        String errorMessage = '';
        //setup inserts only one Contact_Role_Service_Access__c object
        List<Contact_Role_Service_Access__c> serviceAccessesOrig = new List<Contact_Role_Service_Access__c>();


        try {
            serviceAccessesOrig = [SELECT Id, Status__c, Service__c, UniqueKey__c FROM Contact_Role_Service_Access__c];
            serviceAccessesOrig[0].Service__c = portalApplication.Id;

            update serviceAccessesOrig;

        } catch (Exception e) {
            errorMessage = e.getMessage();
        }

        Test.stopTest();

        System.assertEquals(true, errorMessage == '', 'No error should occur!');

        List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Status__c, Service__c, UniqueKey__c FROM Contact_Role_Service_Access__c WHERE Service__c = :portalApplication.Id];

        System.assertEquals(1, serviceAccesses.size(), 'Only one Contact_Role_Service_Access__c should exists with Service__c = ' + portalApplication.Id);
        System.assertEquals(true, serviceAccesses[0].UniqueKey__c != serviceAccessesOrig[0].UniqueKey__c, 'UniqueKey should be changed!');

    }

    @IsTest
    private static void uniqueKeyUpdateNegativeTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger@test.com'];

        Portal_Applications__c portalApplication = new Portal_Applications__c();
        portalApplication.Name = 'ISSP';
        insert portalApplication;

        Test.startTest();

        String errorMessage = '';
        //setup inserts only one Contact_Role_Service_Access__c object
        Contact_Role_Service_Access__c serviceAccessesOrig = [SELECT Id, Status__c, Service__c, Contact_Role__c, UniqueKey__c FROM Contact_Role_Service_Access__c LIMIT 1];

        //create new Contact_Role_Service_Access__c with different Service__c -> allowed
        Contact_Role_Service_Access__c contactRoleServiceAccess = new Contact_Role_Service_Access__c();
        contactRoleServiceAccess.Status__c = serviceAccessesOrig.Status__c;
        contactRoleServiceAccess.Service__c = portalApplication.Id;
        contactRoleServiceAccess.Contact_Role__c = serviceAccessesOrig.Contact_Role__c;
        insert contactRoleServiceAccess;

        try {
            //try to update new Contact_Role_Service_Access__c with Service__c so two records witch identical Service__c and Contact_Role__c would exist -> duplicates
            Contact_Role_Service_Access__c serviceAccess = [SELECT Id, Service__c FROM Contact_Role_Service_Access__c WHERE Id = :contactRoleServiceAccess.Id];
            serviceAccess.Service__c = serviceAccessesOrig.Service__c;
            update serviceAccess;

        } catch (Exception e) {
            errorMessage = e.getMessage();
        }


        Test.stopTest();

        System.assertEquals(true, errorMessage.contains('DUPLICATE_VALUE'), 'Updating duplicates should not be allowed!');
    }


    @IsTest
    private static void fillAccountAndContactInsertTest() {

        List<Contact> contacts = [SELECT Id FROM Contact];//testContact
        List<Account> accounts = [SELECT Id FROM Account];//testAccount

        Test.startTest();

        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Account__c, Contact__c FROM Contact_Role_Service_Access__c];

        Test.stopTest();

        System.assertEquals(false, accesses[0].Account__c == null, 'Field Account__c should be filled in trigger!');
        System.assertEquals(false, accesses[0].Contact__c == null, 'Field Contact__c should be filled in trigger!');
        System.assertEquals(true, accesses[0].Account__c == accounts[0].Id, 'Field Account__c filled incorrectly!');
        System.assertEquals(true, accesses[0].Contact__c == contacts[0].Id, 'Field Contact__c filled incorrectly!');
    }


    @IsTest
    private static void fillAccountAndContactUpdateTest() {

        List<Contact> contacts = [SELECT Id FROM Contact];//testContact
        List<Account> accounts = [SELECT Id FROM Account];//testAccount

        Test.startTest();

        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Account__c, Contact__c, Status__c FROM Contact_Role_Service_Access__c];
        accesses[0].Status__c = 'Granted';
        update  accesses[0];

        Test.stopTest();

        System.assertEquals(false, accesses[0].Account__c == null, 'Field Account__c should be filled in trigger!');
        System.assertEquals(false, accesses[0].Contact__c == null, 'Field Contact__c should be filled in trigger!');
        System.assertEquals(true, accesses[0].Account__c == accounts[0].Id, 'Field Account__c filled incorrectly!');
        System.assertEquals(true, accesses[0].Contact__c == contacts[0].Id, 'Field Contact__c filled incorrectly!');


    }

    @IsTest
    private static void sendNotificationOnStatusChange() {

        List<Contact> contacts = [SELECT Id FROM Contact];//testContact
        List<Account> accounts = [SELECT Id FROM Account];//testAccount

        Test.startTest();

        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Account__c, Contact__c, Status__c FROM Contact_Role_Service_Access__c];
        accesses[0].Status__c = 'Granted';
        update  accesses[0];

        Test.stopTest();
    }

    @IsTest
    private static void usersNotifiedOnStatusChange() {

        List<Contact> contacts = [SELECT Id FROM Contact];//testContact
        List<Account> accounts = [SELECT Id FROM Account];//testAccount

        Test.startTest();

        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Contact_Roles_Name__c, Account__c, Contact__c, Status__c FROM Contact_Role_Service_Access__c];
        accesses[0].Status__c = 'Granted';
        accesses[1].Status__c = 'Granted';
        List<ContactRoleServiceAccessTriggerHandler.NotificationWrapper> wrappers = ContactRoleServiceAccessTriggerHandler.notifyUserAboutStatusChange(accesses);
        system.assertEquals(wrappers.size(), 2);
        Test.stopTest();
    }

    @IsTest
    private static void grandAccessToGadmCategoryFilesTest() {

        Portal_Applications__c gadmApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
        Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c WHERE Contact_Roles__r.Name = 'GADM Data Consumer'];
        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger2@test.com'];

        List<ContentWorkspace> existing = [SELECT Id FROM ContentWorkspace WHERE Name = 'GADM Public' LIMIT 1];
        if(existing.isEmpty()) {
            ContentWorkspace workspace = new ContentWorkspace();
            workspace.Name = 'GADM Public';
            insert workspace;

            existing.add(workspace);
        }

        Test.startTest();

        System.runAs(testUser) {
            Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
            access.Contact_Role__c = accountContactRole.Id;
            access.Service__c = gadmApp.Id;
            access.Status__c = 'Granted';
            insert access;

        }

        Test.stopTest();

        List<ContentWorkspaceMember> members = [SELECT Id, MemberId FROM ContentWorkspaceMember WHERE ContentWorkspaceId = :existing[0].Id];
        Set<Id> membersIds = new Set<Id>();
        for(ContentWorkspaceMember member : members) {
            membersIds.add(member.MemberId);
        }

        System.assertEquals(true, membersIds.contains(testUser.Id), 'User should have access to ContentWorkspace!');

    }

    @IsTest
    private static void grandAccessToGadmCategoryFilesTest2() {

        Portal_Applications__c gadmApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
        Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c WHERE Contact_Roles__r.Name = 'GADM Data Consumer'];
        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger2@test.com'];

        List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

        List<ContentWorkspace> existing = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c];
        if(existing.isEmpty()) {
            ContentWorkspace workspace = new ContentWorkspace();
            workspace.Name = 'GADM Public';
            insert workspace;

            existing.add(workspace);
        }

        Test.startTest();

        System.runAs(testUser) {
            Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
            access.Contact_Role__c = accountContactRole.Id;
            access.Service__c = gadmApp.Id;
            access.Status__c = 'Pending';
            insert access;

        }

        Test.stopTest();

        List<ContentWorkspaceMember> members = [SELECT Id, MemberId FROM ContentWorkspaceMember WHERE ContentWorkspaceId = :existing[0].Id];
        Set<Id> membersIds = new Set<Id>();
        for(ContentWorkspaceMember member : members) {
            membersIds.add(member.MemberId);
        }

        System.assertEquals(false, membersIds.contains(testUser.Id), 'User should NOT have access to ContentWorkspace!');

    }

    @IsTest
    private static void removeAccessToGadmCategoryFilesTest() {

        Portal_Applications__c gadmApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
        Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c WHERE Contact_Roles__r.Name = 'GADM Data Consumer'];
        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger2@test.com'];

        List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

        List<ContentWorkspace> existing = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
        if(existing.isEmpty()) {
            ContentWorkspace workspace = new ContentWorkspace();
            workspace.Name = 'GADM Public';
            insert workspace;
        }

        Test.startTest();

        System.runAs(testUser) {

            Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
            access.Contact_Role__c = accountContactRole.Id;
            access.Service__c = gadmApp.Id;
            access.Status__c = 'Granted';
            insert access;

            delete access;
        }

        Test.stopTest();

    }

    @IsTest
    private static void removeAccessToGadmCategoryFilesTest2() {

        Portal_Applications__c gadmApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
        Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c WHERE Contact_Roles__r.Name = 'GADM Data Consumer'];
        User testUser = [SELECT Id FROM User WHERE Email = 'testContactRoleServiceAccessTrigger2@test.com'];

        List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

        List<ContentWorkspace> existing = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
        if(existing.isEmpty()) {
            ContentWorkspace workspace = new ContentWorkspace();
            workspace.Name = 'GADM Public';
            insert workspace;
        }

        Test.startTest();

        System.runAs(testUser) {

            Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
            access.Contact_Role__c = accountContactRole.Id;
            access.Service__c = gadmApp.Id;
            access.Status__c = 'Granted';
            insert access;

            access.Status__c = 'Pending';
            update access;

        }

        Test.stopTest();


    }


}