@IsTest
public class File_Upload_CTRL_TEST {

    public static final ID headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

    @TestSetup
    private static void setup() {

        IATA_ISO_Country__c canada = createIataCountry('Canada', 'CA', 'Canada');
        Account testAccount = createTestAccount('Test Account', canada);
        Contact testContact = createTestContact(testAccount, 'testFileUpload@test.com', 'John', 'Fortest');
        User testUser = createTestUser(testContact);

        Account testAccount2 = createTestAccount('Test Account 2', canada);
        Contact testContact2 = createTestContact(testAccount2, 'test2FileUpload@test.com', 'Petr', 'Martinez');
        User testUser2 = createTestUser(testContact2);

        Data_Submission__c dataSubmission = createDataSubmission(testContact, testAccount.Id);
        createCredentials('GenericAttach');
        createCredentials('RecycleBin');

        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Date today = System.today();
        Id masterRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
        Account_Role__c accountRole = new Account_Role__c();
        accountRole.Account__c = testAccount.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        accountRole.Effective_From_Date__c = today.addDays(-10);
        accountRole.Effective_To_Date__c = today.addDays(10);
        accountRole.Status__c = 'Active';
        accountRole.RecordTypeId = masterRecordType;
        insert accountRole;

        Account_Role__c accountRole2 = new Account_Role__c();
        accountRole2.Account__c = testAccount2.Id;
        accountRole2.Account_Roles__c = accountRoles.Id;
        accountRole2.Effective_From_Date__c = today.addDays(-10);
        accountRole2.Effective_To_Date__c = today.addDays(10);
        accountRole2.Status__c = 'Active';
        accountRole2.RecordTypeId = masterRecordType;
        insert accountRole2;

        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        insert contactRoles;

        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
        Account_Contact_Role__c contactRole = new Account_Contact_Role__c();
        contactRole.RecordTypeId = groupRecordTypeId;
        contactRole.Account_Role__c = accountRole.Id;
        contactRole.Contact__c = testContact.Id;
        contactRole.Contact_Roles__c = contactRoles.Id;
        contactRole.Service_Rendered__c = 'GADM';
        insert contactRole;

        //for Test Account
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

        GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
        serviceDetail.Account_Role_Service__c = accountRoleService.Id;
        serviceDetail.Allowed_email_domain__c = 'somedomain.com';
        serviceDetail.Active_User_Count__c = 5;
        serviceDetail.External_Actor_Id__c = 'ExtId0001';
        serviceDetail.Submission_Period_Extension__c = 30;
        insert serviceDetail;

        //for Test Account 2
        Account_Role_Service__c accountRoleService2 = new Account_Role_Service__c();
        accountRoleService2.Account_Role__c = accountRole2.Id;
        accountRoleService2.Account_Role_Services__c = accountRoleServices.Id;
        insert accountRoleService2;

        GADM_Data_Submission_Period__c submissionPeriod = new GADM_Data_Submission_Period__c();
        submissionPeriod.Name = 'Test';
        submissionPeriod.Period_Length__c = 12;
        submissionPeriod.Submission_Cycle_Start_Day__c = 1;
        submissionPeriod.Submission_Cycle_End_Day__c = 10;
        submissionPeriod.Submission_Cycle_Start_Month__c = 1;
        submissionPeriod.Submission_Cycle_End_Month__c = 1;
        submissionPeriod.Upcoming_Notification__c = 3;
        submissionPeriod.In_Due_Notification__c = 0;
        submissionPeriod.Start_Date__c = Date.newInstance(Date.today().year(), 1 , 1);
        submissionPeriod.TestDate__c = Date.newInstance(Date.today().year(), 1 , 1).addDays(30);
        insert submissionPeriod;

        GADM_Account_Service_Detail__c serviceDetail2 = new GADM_Account_Service_Detail__c();
        serviceDetail2.Account_Role_Service__c = accountRoleService2.Id;
        serviceDetail2.Allowed_email_domain__c = 'somedomain.com';
        serviceDetail2.Active_User_Count__c = 5;
        serviceDetail2.External_Actor_Id__c = 'SomeExtTestId002';
        serviceDetail2.Submission_Period_Extension__c = 30;
        serviceDetail2.Data_Submission_Period__c = submissionPeriod.Id;
        insert serviceDetail2;

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

    private static Contact createTestContact(Account account, String email, String firstName, String lastName) {
        Contact testContact = new Contact();
        testContact.AccountId = account.id;
        testContact.Firstname = firstName;
        testContact.Lastname= lastName;
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

    private static Data_Submission__c createDataSubmission(Contact contact, Id actorId) {
        Data_Submission__c dataSubmission = new Data_Submission__c();
        dataSubmission.Account__c = actorId;
        dataSubmission.User__c = Contact.Id;
        dataSubmission.Type__c = 'Submission';
        dataSubmission.Status__c = 'Data Submission Error';
        dataSubmission.Submission_date__c = System.now();

        insert dataSubmission;
        return dataSubmission;
    }

    private static void createCredentials(String credentialName){
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = credentialName, Prod_Configuration__c = credentialName+'aprodconf' , Dev_Configuration__c = credentialName+'adevconf');
        insert Amazon_Cred;

        List<AWSKey__c> AWS_KEYs = new List<AWSKey__c>{new AWSKey__c(name = credentialName+'aprodconf',
                Key__c = 'asd',
                Secret__c = 'asd',
                IAS_configuration_name__c = 'asdas',
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd'),
                new AWSKey__c(name = credentialName+'adevconf' ,
                        Key__c = 'asd',
                        Secret__c = 'asd',
                        IAS_configuration_name__c = 'asdas',
                        IAS_Access_Point__c = 'asd',
                        Bucket__c = 'asd',
                        AWS_ENDPOINT_URL__c = 'asd')
        };

        insert AWS_KEYs;
    }


    @IsTest
    private static void createDataSubmissionTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];

        Test.startTest();

        System.runAs(testUser) {
            File_Upload_CTRL.createDataSubmission(testUser.Id, testAccount.Id, 'testFile.xml');
        }

        Test.stopTest();

        List<Data_Submission__c> submissions = [SELECT Id FROM Data_Submission__c];

        System.assertEquals(2, submissions.size(), 'Data submission was not created!');

    }

    @IsTest
    private static void updateDataSubmissionTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];

        Data_Submission__c dataSubmission = [SELECT Id FROM Data_Submission__c];

        File_Upload_CTRL.DataSubmissionWrapper wrapper = new File_Upload_CTRL.DataSubmissionWrapper();
        wrapper.dataSubmissionId = dataSubmission.Id;
        wrapper.fileName = 'testFile.csv';

        Test.startTest();

        System.runAs(testUser) {
            File_Upload_CTRL.updateDataSubmission(new List<File_Upload_CTRL.DataSubmissionWrapper>{wrapper});
        }

        Test.stopTest();

        List<Data_Submission__c> submissions = [SELECT Id, Status__c, Result__c FROM Data_Submission__c];
        System.assertEquals('Submitted', submissions[0].Status__c, 'Status__c was not correctly changed!');

    }

    @IsTest
    private static void updateDataSubmissionNullTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];

        Data_Submission__c dataSubmission = new Data_Submission__c();

        File_Upload_CTRL.DataSubmissionWrapper wrapper = new File_Upload_CTRL.DataSubmissionWrapper();
        wrapper.dataSubmissionId = dataSubmission.Id;
        wrapper.fileName = 'testFile.csv';

        Boolean result = false;

        Test.startTest();

        System.runAs(testUser) {
            result = File_Upload_CTRL.updateDataSubmission(new List<File_Upload_CTRL.DataSubmissionWrapper>{wrapper});
        }

        Test.stopTest();

        System.assertEquals(false, result, 'Bad result returned!');

    }


    @IsTest
    private static void getUserInformationTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];
        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'testFileUpload@test.com'];

        Test.startTest();

        File_Upload_CTRL.UserInformation userInformation = new File_Upload_CTRL.UserInformation();

        System.runAs(testUser) {
            userInformation = File_Upload_CTRL.getUserInformation(testUser.Id);
        }

        Test.stopTest();
        
        System.assertEquals(testUser.Id, userInformation.userId, 'Wrong userId retrieved!');
        System.assertEquals(false, userInformation.isInternalUser, 'Wrong user type retrieved!');
        System.assertEquals(true, userInformation.isExternalUser, 'Wrong user type retrieved!');
        System.assertEquals(testContact.AccountId, userInformation.actors[0].Id, 'Wrong actors retrieved!');

    }

    @IsTest
    private static void createUploadFileTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];
        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'testFileUpload@test.com'];

        Data_Submission__c submission = [SELECT Id FROM Data_Submission__c];

        File_Upload_CTRL.UploadFile uploadFile;

        Test.startTest();

        System.runAs(testUser) {
            uploadFile = File_Upload_CTRL.createUploadFile(submission.Id,'testFile.csv', 'application/vnd.ms-excel', 'GenericAttach', testUser.Id, testContact.AccountId, true, 'Input/Test_Folder/');
        }

        Test.stopTest();

        System.assertEquals(testContact.AccountId, uploadFile.actorId, 'ActorId on UploadFile is not as expected!');
        System.assertEquals('asd', uploadFile.bucketName, 'BucketName on UploadFile is not as expected!');
        System.assertEquals(submission.Id, uploadFile.dataSubmissionId, 'DataSubmissionId on UploadFile is not as expected!');
        System.assertEquals('Input/Test_Folder/'+submission.Id + '.csv', uploadFile.fullFileNameEncoded, 'FullFileNameEncoded on UploadFile is not as expected!');


    }

    @IsTest
    private static void getUserFromContactTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];
        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'testFileUpload@test.com'];

        Id resultUserId;

        Test.startTest();

        System.runAs(testUser) {
            resultUserId =  File_Upload_CTRL.getUserFromContact(testContact.Id);
        }

        Test.stopTest();

        System.assertEquals(resultUserId, testUser.Id, 'Wrong user retrieved!');
    }

    @IsTest
    private static void getGadmSettingsTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];

        GADM_Settings__mdt settings;

        Test.startTest();

        System.runAs(testUser) {
            settings =  File_Upload_CTRL.getGadmSettings();
        }

        Test.stopTest();

        System.assertEquals(false, settings == null, 'GADM Custom metadata not retrieved!');
    }

    @IsTest
    private static void checkForInternalUserPermissionSetTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];

        Profile programManagerProfile = [SELECT Id FROM Profile WHERE Name = 'GADM Program Manager'];

        User managerUser = new User();
        managerUser.alias = 'dsfsdfds';
        managerUser.email = 'iammanager@test.test.org';
        managerUser.emailencodingkey = 'UTF-8';
        managerUser.firstname = 'Pedro';
        managerUser.lastname ='Sanches';
        managerUser.languagelocalekey = 'en_US';
        managerUser.localesidkey = 'en_US';
        managerUser.timezonesidkey = 'Asia/Dubai';
        managerUser.Username = 'pedro.sanchez@iata.com';
        managerUser.PortalRole = 'Manager';
        managerUser.ProfileId = programManagerProfile.Id;
        managerUser.License_Cost_Center__c = 'ISF005CH01';
        managerUser.IsActive = true;

        insert managerUser;

        PermissionSet gadmPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'GADM_Data_Submissions'];
        PermissionSetAssignment assignment = new PermissionSetAssignment();
        assignment.AssigneeId = managerUser.Id;
        assignment.PermissionSetId = gadmPermissionSet.Id;
        insert assignment;

        Boolean hasPermissionSet = false;
        File_Upload_CTRL.UserInformation userInformation = new File_Upload_CTRL.UserInformation();

        Test.startTest();

        System.runAs(testUser) {
            hasPermissionSet =  File_Upload_CTRL.checkForInternalUserPermissionSet(managerUser.Id);
            userInformation = File_Upload_CTRL.getUserInformation(managerUser.Id);
        }

        Test.stopTest();

        System.assertEquals(true, hasPermissionSet, 'Correct permission set was not detected!');
        System.assertEquals(true, userInformation.isInternalUser, 'User information retrieved incorrectly!');
        System.assertEquals(false, userInformation.isExternalUser, 'User information retrieved incorrectly!');
    }

    @IsTest
    private static void isSubmissionOnTimeTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];

        Boolean isOnTime = false;

        Test.startTest();

        System.runAs(testUser) {
            isOnTime =  File_Upload_CTRL.isSubmissionOnTime(testAccount.Id);
        }

        Test.stopTest();

        System.assertEquals(false, isOnTime, 'Data submission should be sent with delay!');
    }

    @IsTest
    private static void isSubmissionOnTime_emptySubmissionIdTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testFileUpload@test.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];

        Boolean isOnTime = false;

        Test.startTest();

        System.runAs(testUser) {
            isOnTime =  File_Upload_CTRL.isSubmissionOnTime(testAccount.Id);
        }

        Test.stopTest();

        System.assertEquals(true, isOnTime, 'Missing submission period indicated submission on time!');
    }

}