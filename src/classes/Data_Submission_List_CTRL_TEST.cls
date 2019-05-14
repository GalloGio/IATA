@IsTest
public class Data_Submission_List_CTRL_TEST {

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
        insert acc2;

        Contact testContact = createContact('Neo', 'Smith', acc);
        Contact testContact2 = createContact('Leo', 'Smith', acc2);
        Contact testContact3 = createContact('Pedro', 'Smith', acc);

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        User testUser = createUser(testContact, profileId);
        User testUser2 = createUser(testContact2, profileId);
        User testUser3 = createUser(testContact3, profileId);

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

        Account_Role__c accountRole2 = new Account_Role__c();
        accountRole2.RecordTypeId = defaultRecordTypeId;
        accountRole2.Account__c = acc2.Id;
        accountRole2.Account_Roles__c = accountRoles.Id;
        accountRole2.Status__c = 'Active';
        accountRole2.Effective_From_Date__c = today.addDays(-2);
        accountRole2.Effective_To_Date__c = today;
        insert accountRole2;

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

        //Account contact role for user Neo and Test Account2
        Account_Contact_Role__c accountContactRole2b = new Account_Contact_Role__c();
        accountContactRole2b.Contact__c = testContact.Id;
        accountContactRole2b.Contact_Roles__c = contactRoles.Id;
        accountContactRole2b.Account_Role__c = accountRole2.Id;
        accountContactRole2b.Service_Rendered__c = 'GADM';
        accountContactRole2b.RecordTypeId = groupRecordTypeId;
        insert accountContactRole2b;

        //Account contact role for user Leo and Test Account2
        Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
        accountContactRole3.Contact__c = testContact2.Id;
        accountContactRole3.Contact_Roles__c = contactRoles.Id;
        accountContactRole3.Account_Role__c = accountRole2.Id;
        accountContactRole3.Service_Rendered__c = 'GADM';
        accountContactRole3.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole3;

        Account_Contact_Role__c accountContactRole3b = new Account_Contact_Role__c();
        accountContactRole3b.Contact__c = testContact2.Id;
        accountContactRole3b.Contact_Roles__c = contactRoles.Id;
        accountContactRole3b.Account_Role__c = accountRole2.Id;
        accountContactRole3b.Service_Rendered__c = 'GADM';
        accountContactRole3b.RecordTypeId = groupRecordTypeId;
        insert accountContactRole3b;

        Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
        accountContactRole4.Contact__c = testContact2.Id;
        accountContactRole4.Contact_Roles__c = contactRoles3.Id;
        accountContactRole4.Account_Role__c = accountRole2.Id;
        accountContactRole4.Service_Rendered__c = 'GADM';
        accountContactRole4.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole4;

        Account_Contact_Role__c accountContactRole5 = new Account_Contact_Role__c();
        accountContactRole5.Contact__c = testContact3.Id;
        accountContactRole5.Contact_Roles__c = contactRoles.Id;
        accountContactRole5.Account_Role__c = accountRole.Id;
        accountContactRole5.Service_Rendered__c = 'GADM';
        accountContactRole5.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole5;

        Account_Contact_Role__c accountContactRole6 = new Account_Contact_Role__c();
        accountContactRole6.Contact__c = testContact3.Id;
        accountContactRole6.Contact_Roles__c = contactRoles.Id;
        accountContactRole6.Account_Role__c = accountRole.Id;
        accountContactRole6.Service_Rendered__c = 'GADM';
        accountContactRole6.RecordTypeId = groupRecordTypeId;
        insert accountContactRole6;

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

        //grant access for user Neo, account Test account 2 and GADM User role and GADM service
        Contact_Role_Service_Access__c serviceAccess2b = new Contact_Role_Service_Access__c();
        serviceAccess2b.Contact_Role__c = accountContactRole2b.Id;
        serviceAccess2b.Service__c = portalApplications.Id;
        serviceAccess2b.Status__c = 'Granted';
        insert serviceAccess2b;

        //grant access for user Leo, account Test account 2 and GADM User role and GADM service
        Contact_Role_Service_Access__c serviceAccess3 = new Contact_Role_Service_Access__c();
        serviceAccess3.Contact_Role__c = accountContactRole3.Id;
        serviceAccess3.Service__c = portalApplications.Id;
        serviceAccess3.Status__c = 'Granted';
        insert serviceAccess3;

        //grant access for user Leo, account Test account 2 and Service Super User role and GADM service
        Contact_Role_Service_Access__c serviceAccess3b = new Contact_Role_Service_Access__c();
        serviceAccess3b.Contact_Role__c = accountContactRole4.Id;
        serviceAccess3b.Service__c = portalApplications.Id;
        serviceAccess3b.Status__c = 'Granted';
        insert serviceAccess3b;

        //grant access for user Leo, account Test account 2 and Service Super User role and GADM service
        Contact_Role_Service_Access__c serviceAccess4 = new Contact_Role_Service_Access__c();
        serviceAccess4.Contact_Role__c = accountContactRole5.Id;
        serviceAccess4.Service__c = portalApplications.Id;
        serviceAccess4.Status__c = 'Granted';
        insert serviceAccess4;

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
    private static void getTotalRecordsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();

        Integer totalRecordCount = 0;

        System.runAs(testUser) {
            totalRecordCount = Data_Submission_List_CTRL.getTotalRecords('Data_Submission__c', 'Status__c = \'Submitted\'');
        }

        Test.stopTest();

        System.assertEquals(20, totalRecordCount, 'Incorrect count fo existing Data_Submission__c objects retrieved!');

    }

    @IsTest
    private static void getRecordsTest() {

        User testUser = [SELECT Id, ContactId FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Data_Submission__c submission = new Data_Submission__c();
        submission.User__c = testUser.ContactId;
        submission.Result__c = 'Test result for status success';
        submission.Status__c = 'Success';
        submission.Type__c = 'Submission';
        submission.Submission_date__c = System.now();
        insert submission;


        Test.startTest();

        String records = '';

        System.runAs(testUser) {
            records = Data_Submission_List_CTRL.getRecords('Data_Submission__c', new List<String>{'Type__c', 'User__c', 'Result__c', 'Status__c'}, 'Status__c = \'Success\'', '', 'ASC');
        }

        Test.stopTest();

        //only one Id in string
        System.assertEquals(records.indexOf('Id'), records.lastIndexOf('Id'), 'Incorrect number of Data_Submission__c objects retrieved!');
        //correct object retrieved
        System.assertEquals(true, records.contains(submission.Id), 'Wrong Data_Submission__c object retrieved!');

    }

    @IsTest
    private static void getRecords2Test() {

        User testUser = [SELECT Id, ContactId FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Data_Submission__c submission = new Data_Submission__c();
        submission.User__c = testUser.ContactId;
        submission.Result__c = 'Test result for status success';
        submission.Status__c = 'Success';
        submission.Type__c = 'Submission';
        submission.Submission_date__c = System.now();
        insert submission;


        Test.startTest();

        String records = '';

        System.runAs(testUser) {
            records = Data_Submission_List_CTRL.getRecords('Data_Submission__c', new List<String>{'Type__c', 'User__c', 'Result__c', 'Status__c'}, 'Status__c = \'Success\'', 'User__c', '');
        }

        Test.stopTest();

        //only one Id in string
        System.assertEquals(records.indexOf('Id'), records.lastIndexOf('Id'), 'Incorrect number of Data_Submission__c objects retrieved!');
        //correct object retrieved
        System.assertEquals(true, records.contains(submission.Id), 'Wrong Data_Submission__c object retrieved!');

    }

    @IsTest
    private static void getColumnMetadataTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();

        String records = '';

        System.runAs(testUser) {
            records = Data_Submission_List_CTRL.getColumnMetadata('Data_Submission__c', new List<String>{'User__c', 'User__r.Name', 'Result__c', 'Status__c', 'OwnerId'}, new List<String>{'Status__c'}, new List<String>(), new List<String>{'User__c'}, new List<String>{'Status__c'});
        }

        Test.stopTest();

    }

    @IsTest
    private static void errorsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();

        String records = '';

        System.runAs(testUser) {
            records = Data_Submission_List_CTRL.getColumnMetadata('Data_Submission__c', new List<String>{'User__c', 'User__r.Name', 'Result__c', 'Status__c', 'OwnerId'}, new List<String>(), new List<String> {'Status__c'}, new List<String>{'User__r.Name'}, new List<String>{'Status'});
        }

        Test.stopTest();

        System.assertEquals(true, records.contains('Unknown field'));

    }

    @IsTest
    private static void getUserInformation_PowerUserTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();

        Data_Submission_List_CTRL.UserInformation info;

        System.runAs(testUser) {
            info = Data_Submission_List_CTRL.getUserInformation(testUser.Id);
        }

        Test.stopTest();


        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account'];

        System.assertEquals(false, info.isSuperUser, 'Bad user info retrieved!');
        System.assertEquals(false, info.isGadmUser, 'Bad user info retrieved!');
        System.assertEquals(true, info.isPowerUser, 'Bad user info retrieved!');
        System.assertEquals(2, info.visibleAccounts.size(), 'Incorrect number of visible accounts retrieved!');
    }

    @IsTest
    private static void getUserInformation_SuperUserTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'Leo.Smith.test@somedomain.com'];

        Test.startTest();

        Data_Submission_List_CTRL.UserInformation info;

        System.runAs(testUser) {
            info = Data_Submission_List_CTRL.getUserInformation(testUser2.Id);
        }

        Test.stopTest();

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account 2'];

        System.assertEquals(true, info.isSuperUser, 'Bad user info retrieved!');
        System.assertEquals(false, info.isGadmUser, 'Bad user info retrieved!');
        System.assertEquals(false, info.isPowerUser, 'Bad user info retrieved!');
        System.assertEquals(1, info.visibleAccounts.size(), 'Incorrect number of visible accounts retrieved!');
        System.assertEquals(testAccount.Id, info.visibleAccounts[0].Id, 'Retrieved accountId does not match!');
    }

    @IsTest
    private static void getUserInformation_GadmUserTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'Pedro.Smith.test@somedomain.com'];

        Test.startTest();

        Data_Submission_List_CTRL.UserInformation info;

        System.runAs(testUser) {
            info = Data_Submission_List_CTRL.getUserInformation(testUser2.Id);
        }

        Test.stopTest();

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account'];

        System.assertEquals(false, info.isSuperUser, 'Bad user info retrieved!');
        System.assertEquals(true, info.isGadmUser, 'Bad user info retrieved!');
        System.assertEquals(false, info.isPowerUser, 'Bad user info retrieved!');
        System.assertEquals(1, info.visibleAccounts.size(), 'Incorrect number of visible accounts retrieved!');
        System.assertEquals(testAccount.Id, info.visibleAccounts[0].Id, 'Retrieved accountId does not match!');
    }

}