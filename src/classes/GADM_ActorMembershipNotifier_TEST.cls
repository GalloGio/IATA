@IsTest
public class GADM_ActorMembershipNotifier_TEST {

    @TestSetup
    private static void setup() {

        Date today = Date.today();

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

        insert accounts;

        Contact testContact = createContact('Neo', 'Smith', acc);
        Contact testContact2 = createContact('Leo', 'Black', acc2);
        Contact testContact3 = createContact('Kirk', 'Down', acc2);

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;
        Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;

        User testUser = createUser(testContact, profileId);
        User testUser2 = createUser(testContact2, profileId);
        User testUser5 = createUser(testContact3, profileId);
        //public group users
        User testUser3 = createUser('Petr', 'White', standardUserProfileId);
        User testUser4 = createUser('Milan', 'Green', standardUserProfileId);

        //GADM service
        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        //GADM Participang Account Role
        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

        GADM_Settings__mdt gadmSettings = [SELECT Id, Actor_Membership_Termination__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

        Integer daysToTerminate = 0;
        if(gadmSettings.Actor_Membership_Termination__c != null) {
            daysToTerminate = (Integer)gadmSettings.Actor_Membership_Termination__c;
        }

        List<Account_Role__c> accountRolesToInsert = new List<Account_Role__c>();

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.RecordTypeId = defaultRecordTypeId;
        accountRole.Account__c = acc.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        accountRole.Status__c = 'Active';
        accountRole.Effective_From_Date__c = today.addDays(-10);
        accountRole.Effective_To_Date__c = today.addDays(daysToTerminate);
        accountRolesToInsert.add(accountRole);

        Account_Role__c accountRole2 = new Account_Role__c();
        accountRole2.RecordTypeId = defaultRecordTypeId;
        accountRole2.Account__c = acc2.Id;
        accountRole2.Account_Roles__c = accountRoles.Id;
        accountRole2.Status__c = 'Inactive';
        accountRole2.Effective_From_Date__c = today.addDays(-10);
        accountRole2.Effective_To_Date__c = today.addDays(daysToTerminate);
        accountRolesToInsert.add(accountRole2);

        insert accountRolesToInsert;

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

        insert contactRolesToInsert;

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        List<Account_Contact_Role__c> accountContactRolesToInsert = new List<Account_Contact_Role__c>();

        ///test account 1

        //testContact - gadm user
        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
        accountContactRole.Contact__c = testContact.Id;
        accountContactRole.Contact_Roles__c = contactRoles.Id;
        accountContactRole.Account_Role__c = accountRole.Id;
        accountContactRole.Service_Rendered__c = 'GADM';
        accountContactRole.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole);

        //testContact - gadm user
        Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
        accountContactRole1.Contact__c = testContact.Id;
        accountContactRole1.Contact_Roles__c = contactRoles.Id;
        accountContactRole1.Account_Role__c = accountRole.Id;
        accountContactRole1.Service_Rendered__c = 'GADM';
        accountContactRole1.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole1);

        //testContact - power user
        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact.Id;
        accountContactRole2.Contact_Roles__c = contactRoles2.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole2);

        //testContact2 - gadm user
        Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
        accountContactRole3.Contact__c = testContact2.Id;
        accountContactRole3.Contact_Roles__c = contactRoles.Id;
        accountContactRole3.Account_Role__c = accountRole.Id;
        accountContactRole3.Service_Rendered__c = 'GADM';
        accountContactRole3.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole3);

        //testContact2 - gadm user
        Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
        accountContactRole4.Contact__c = testContact2.Id;
        accountContactRole4.Contact_Roles__c = contactRoles.Id;
        accountContactRole4.Account_Role__c = accountRole.Id;
        accountContactRole4.Service_Rendered__c = 'GADM';
        accountContactRole4.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole4);

        //testContact2 - power user
        Account_Contact_Role__c accountContactRole5 = new Account_Contact_Role__c();
        accountContactRole5.Contact__c = testContact2.Id;
        accountContactRole5.Contact_Roles__c = contactRoles2.Id;
        accountContactRole5.Account_Role__c = accountRole.Id;
        accountContactRole5.Service_Rendered__c = 'GADM';
        accountContactRole5.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole5);


        ///test account 2

        //testContact3- gadm user
        Account_Contact_Role__c accountContactRole6 = new Account_Contact_Role__c();
        accountContactRole6.Contact__c = testContact3.Id;
        accountContactRole6.Contact_Roles__c = contactRoles.Id;
        accountContactRole6.Account_Role__c = accountRole2.Id;
        accountContactRole6.Service_Rendered__c = 'GADM';
        accountContactRole6.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole6);

        //testContact3 - gadm user
        Account_Contact_Role__c accountContactRole7 = new Account_Contact_Role__c();
        accountContactRole7.Contact__c = testContact3.Id;
        accountContactRole7.Contact_Roles__c = contactRoles.Id;
        accountContactRole7.Account_Role__c = accountRole2.Id;
        accountContactRole7.Service_Rendered__c = 'GADM';
        accountContactRole7.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole7);

        //testContact3 - power user
        Account_Contact_Role__c accountContactRole8 = new Account_Contact_Role__c();
        accountContactRole8.Contact__c = testContact3.Id;
        accountContactRole8.Contact_Roles__c = contactRoles2.Id;
        accountContactRole8.Account_Role__c = accountRole2.Id;
        accountContactRole8.Service_Rendered__c = 'GADM';
        accountContactRole8.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole8);

        insert accountContactRolesToInsert;

        List<Contact_Role_Service_Access__c> contactRoleServiceAccessesToInsert = new List<Contact_Role_Service_Access__c>();

        Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
        serviceAccess.Contact_Role__c = accountContactRole.Id;
        serviceAccess.Service__c = portalApplications.Id;
        serviceAccess.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess);

        Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
        serviceAccess2.Contact_Role__c = accountContactRole2.Id;
        serviceAccess2.Service__c = portalApplications.Id;
        serviceAccess2.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess2);

        Contact_Role_Service_Access__c serviceAccess3 = new Contact_Role_Service_Access__c();
        serviceAccess3.Contact_Role__c = accountContactRole3.Id;
        serviceAccess3.Service__c = portalApplications.Id;
        serviceAccess3.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess3);

        Contact_Role_Service_Access__c serviceAccess4 = new Contact_Role_Service_Access__c();
        serviceAccess4.Contact_Role__c = accountContactRole5.Id;
        serviceAccess4.Service__c = portalApplications.Id;
        serviceAccess4.Status__c = 'Denied';
        contactRoleServiceAccessesToInsert.add(serviceAccess4);

        Contact_Role_Service_Access__c serviceAccess5 = new Contact_Role_Service_Access__c();
        serviceAccess5.Contact_Role__c = accountContactRole6.Id;
        serviceAccess5.Service__c = portalApplications.Id;
        serviceAccess5.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess5);

        Contact_Role_Service_Access__c serviceAccess6 = new Contact_Role_Service_Access__c();
        serviceAccess6.Contact_Role__c = accountContactRole8.Id;
        serviceAccess6.Service__c = portalApplications.Id;
        serviceAccess6.Status__c = 'Denied';
        contactRoleServiceAccessesToInsert.add(serviceAccess6);

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
        testUser.ProfileId = profileId;
        testUser.IsActive = true;
        insert testUser;
        return testUser;
    }

    private static User createUser(String firstName, String lastName, Id profileId) {
        User testUser = new User();
        testUser.alias = 'dsfsdfds';
        testUser.email = firstName+'.'+lastName+'@somedomain.org';
        testUser.emailencodingkey = 'UTF-8';
        testUser.firstname = firstName;
        testUser.lastname = lastname;
        testUser.languagelocalekey = 'en_US';
        testUser.localesidkey = 'en_US';
        testUser.timezonesidkey = 'Asia/Dubai';
        testUser.Username = firstName+'.'+lastName+'@somedomain.org';
        testUser.PortalRole = 'Manager';
        testUser.CommunityNickname = (firstName + lastName).substring(0,8);
        testUser.ProfileId = profileId;
        testUser.License_Cost_Center__c = 'ISF005CH01';
        testUser.IsActive = true;
        insert testUser;
        return testUser;
    }

    @IsTest
    private static void notifyUsersTest() {

        User testUser1 = [SELECT Id FROM User WHERE Email = 'petr.white@somedomain.org'];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'milan.green@somedomain.org'];

        Group group1 = new Group();
        group1.name = 'GADM Internal Users Notification Group';
        group1.Type = 'Regular';
        insert group1;

        GroupMember groupMember1 = new GroupMember();
        groupMember1.UserOrGroupId = testUser1.Id;
        groupMember1.GroupId = group1.Id;
        Insert groupMember1;

        GroupMember groupMember2 = new GroupMember();
        groupMember2.UserOrGroupId = testUser2.Id;
        groupMember2.GroupId = group1.Id;
        Insert groupMember2;

        Integer timesSent = 0;
        String result = '';

        Test.startTest();

        System.runAs(testUser1) {

            result = GADM_ActorMembershipNotifier.notifyUsers();
            timesSent = Limits.getEmailInvocations();
        }

        Test.stopTest();

        System.assertEquals(1, timesSent, 'Notification emails should be sent!');
        System.assertEquals('sent', result, 'Notification emails should be sent!');
    }

    @IsTest
    private static void getUsersToNotify() {

        User testUser1 = [SELECT Id FROM User WHERE Email = 'petr.white@somedomain.org'];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'milan.green@somedomain.org'];

        Contact testContact1 = [SELECT Id FROM Contact WHERE Email = 'neo.smith.test@somedomain.com'];

        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test account'];
        Account_Role__c accountRole = [SELECT Id, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE Account__c = :testAccount.Id LIMIT 1];

        Group group1 = new Group();
        group1.name = 'GADM Internal Users Notification Group';
        group1.Type = 'Regular';
        insert group1;

        GroupMember groupMember1 = new GroupMember();
        groupMember1.UserOrGroupId = testUser1.Id;
        groupMember1.GroupId = group1.Id;
        Insert groupMember1;

        GroupMember groupMember2 = new GroupMember();
        groupMember2.UserOrGroupId = testUser2.Id;
        groupMember2.GroupId = group1.Id;
        Insert groupMember2;

        List<GADM_ActorMembershipNotifier.NotifierWrapper> wrappers = new List<GADM_ActorMembershipNotifier.NotifierWrapper>();

        Test.startTest();

        System.runAs(testUser1) {

            wrappers = GADM_ActorMembershipNotifier.getUsersToNotify();

        }

        Test.stopTest();

        System.assertEquals(2, wrappers.size());

        GADM_ActorMembershipNotifier.NotifierWrapper wrapper1 = new GADM_ActorMembershipNotifier.NotifierWrapper();
        GADM_ActorMembershipNotifier.NotifierWrapper wrapper2 = new GADM_ActorMembershipNotifier.NotifierWrapper();

        if(wrappers[0].users.size() == 0) {
            wrapper1 = wrappers[0];
            wrapper2 = wrappers[1];

        }else if(wrappers[1].users.size() == 0){
            wrapper1 = wrappers[1];
            wrapper2 = wrappers[0];

        }

        GADM_Settings__mdt gadmSettings = [SELECT Id, Actor_Membership_Termination__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

        System.assertEquals(wrapper1.accountName, testAccount.Name, 'Account name does not match!');
        System.assertEquals(1, wrapper1.contacts.size(), 'There should be only 1 contact to notify!');
        System.assertEquals(0, wrapper1.users.size(), 'There should be no users to notify!');
        System.assertEquals(wrapper1.contacts[0].Id, testContact1.Id, 'Expected contact does not match!');
        System.assertEquals(wrapper1.effectiveFrom, accountRole.Effective_From_Date__c, 'Expected effective form date does not match!');
        System.assertEquals(wrapper1.effectiveTo, accountRole.Effective_To_Date__c, 'Expected effective to date does not match!');
        System.assertEquals(gadmSettings.Actor_Membership_Termination__c == null ? 0 : gadmSettings.Actor_Membership_Termination__c, wrapper1.priorDaysToNotify, 'Expected days prior does not match!');

        System.assertEquals(0, wrapper2.contacts.size(), 'There should be no contacts to notify!');
        System.assertEquals(true, wrapper2.users.size() >= 2, 'There should be at least two users to notify!');
        System.assertEquals(wrapper2.effectiveFrom, accountRole.Effective_From_Date__c, 'Expected effective form date does not match!');
        System.assertEquals(wrapper2.effectiveTo, accountRole.Effective_To_Date__c, 'Expected effective to date does not match!');
        System.assertEquals(gadmSettings.Actor_Membership_Termination__c == null ? 0 : gadmSettings.Actor_Membership_Termination__c, wrapper2.priorDaysToNotify, 'Expected days prior does not match!');

    }

}