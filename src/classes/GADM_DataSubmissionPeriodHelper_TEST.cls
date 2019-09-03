@IsTest
public with sharing class GADM_DataSubmissionPeriodHelper_TEST {

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
        Contact testContact3 = createContact('Jack', 'Lincoln', acc2);

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

        Account_Role_Service__c accountRoleService2 = new Account_Role_Service__c();
        accountRoleService2.Account_Role__c = accountRole2.Id;
        accountRoleService2.Account_Role_Services__c = accountRoleServices.Id;
        insert accountRoleService2;

        Date startDate = Date.newInstance(Date.today().year(), 1, 1);
        Date testDate = Date.today();

        GADM_Data_Submission_Period__c submissionPeriod = new GADM_Data_Submission_Period__c();
        submissionPeriod.Name = 'Test';
        submissionPeriod.Period_Length__c = 3;
        submissionPeriod.Submission_Cycle_Start_Month__c = 1;
        submissionPeriod.Submission_Cycle_Start_Day__c = 1;
        submissionPeriod.Submission_Cycle_End_Month__c = 1;
        submissionPeriod.Submission_Cycle_End_Day__c = 10;
        submissionPeriod.Upcoming_Notification__c = 3;
        submissionPeriod.In_Due_Notification__c = 2;
        submissionPeriod.Start_Date__c = startDate;
        insert submissionPeriod;

        GADM_Data_Submission_Period__c submissionPeriod2 = new GADM_Data_Submission_Period__c();
        submissionPeriod2.Name = 'Test2';
        submissionPeriod2.Period_Length__c = 12;
        submissionPeriod2.Submission_Cycle_Start_Day__c = 1;
        submissionPeriod2.Submission_Cycle_End_Day__c = 10;
        submissionPeriod2.Submission_Cycle_Start_Month__c = 1;
        submissionPeriod2.Submission_Cycle_End_Month__c = 1;
        submissionPeriod2.Upcoming_Notification__c = 3;
        submissionPeriod2.In_Due_Notification__c = 0;
        submissionPeriod2.Start_Date__c = startDate;
        insert submissionPeriod2;

        GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
        serviceDetail.Account_Role_Service__c = accountRoleService.Id;
        serviceDetail.Allowed_email_domain__c = 'somedomain.com';
        serviceDetail.Active_User_Count__c = 5;
        serviceDetail.External_Actor_Id__c = 'ExtTestId001';
        serviceDetail.Data_Submission_Period__c = submissionPeriod.Id;
        serviceDetail.Submission_Period_Extension__c = 5;
        serviceDetail.Periods_without_data_submission_notify__c = 2;
        insert serviceDetail;

        GADM_Account_Service_Detail__c serviceDetail2 = new GADM_Account_Service_Detail__c();
        serviceDetail2.Account_Role_Service__c = accountRoleService2.Id;
        serviceDetail2.Allowed_email_domain__c = 'somedomain.com';
        serviceDetail2.Active_User_Count__c = 10;
        serviceDetail2.External_Actor_Id__c = 'ExtTestId002';
        serviceDetail2.Data_Submission_Period__c = submissionPeriod.Id;
        serviceDetail2.Periods_without_data_submission_notify__c = 2;
        insert serviceDetail2;

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
        contactRoles5.RecordTypeId = externalRecordTypeId;
        contactRoles5.Category__c = 'Business Unit';
        contactRolesToInsert.add(contactRoles5);

        Contact_Roles__c contactRoles6 = new Contact_Roles__c();
        contactRoles6.Name = 'Ground';
        contactRoles6.RecordTypeId = externalRecordTypeId;
        contactRoles6.Category__c = 'Business Unit';
        contactRolesToInsert.add(contactRoles6);

        insert contactRolesToInsert;


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

        insert contactRoleServicesToInsert;

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        List<Account_Contact_Role__c> accountContactRolesToInsert = new List<Account_Contact_Role__c>();

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

        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact.Id;
        accountContactRole2.Contact_Roles__c = contactRoles3.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole2);

        Account_Contact_Role__c accountContactRole2b = new Account_Contact_Role__c();
        accountContactRole2b.Contact__c = testContact.Id;
        accountContactRole2b.Contact_Roles__c = contactRoles.Id;
        accountContactRole2b.Account_Role__c = accountRole2.Id;
        accountContactRole2b.Service_Rendered__c = 'GADM';
        accountContactRole2b.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole2b);

        //for testUser2
        Account_Contact_Role__c accountContactRole5b = new Account_Contact_Role__c();
        accountContactRole5b.Contact__c = testContact2.Id;
        accountContactRole5b.Contact_Roles__c = contactRoles4.Id;
        accountContactRole5b.Account_Role__c = accountRole.Id;
        accountContactRole5b.Service_Rendered__c = 'GADM';
        accountContactRole5b.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole5b);

        Account_Contact_Role__c accountContactRole6 = new Account_Contact_Role__c();
        accountContactRole6.Contact__c = testContact2.Id;
        accountContactRole6.Contact_Roles__c = contactRoles.Id;
        accountContactRole6.Account_Role__c = accountRole.Id;
        accountContactRole6.Service_Rendered__c = 'GADM';
        accountContactRole6.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole6);

        Account_Contact_Role__c accountContactRole7 = new Account_Contact_Role__c();
        accountContactRole7.Contact__c = testContact2.Id;
        accountContactRole7.Contact_Roles__c = contactRoles5.Id;
        accountContactRole7.Account_Role__c = accountRole.Id;
        accountContactRole7.Service_Rendered__c = 'GADM';
        accountContactRole7.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole7);

        //for testUser3
        Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
        accountContactRole3.Contact__c = testContact3.Id;
        accountContactRole3.Contact_Roles__c = contactRoles.Id;
        accountContactRole3.Account_Role__c = accountRole2.Id;
        accountContactRole3.Service_Rendered__c = 'GADM';
        accountContactRole3.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole3);

        Account_Contact_Role__c accountContactRole3b = new Account_Contact_Role__c();
        accountContactRole3b.Contact__c = testContact3.Id;
        accountContactRole3b.Contact_Roles__c = contactRoles.Id;
        accountContactRole3b.Account_Role__c = accountRole2.Id;
        accountContactRole3b.Service_Rendered__c = 'GADM';
        accountContactRole3b.RecordTypeId = groupRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole3b);

        Account_Contact_Role__c accountContactRole4 = new Account_Contact_Role__c();
        accountContactRole4.Contact__c = testContact3.Id;
        accountContactRole4.Contact_Roles__c = contactRoles3.Id;
        accountContactRole4.Account_Role__c = accountRole2.Id;
        accountContactRole4.Service_Rendered__c = 'GADM';
        accountContactRole4.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole4);

        Account_Contact_Role__c accountContactRole5 = new Account_Contact_Role__c();
        accountContactRole5.Contact__c = testContact3.Id;
        accountContactRole5.Contact_Roles__c = contactRoles4.Id;
        accountContactRole5.Account_Role__c = accountRole2.Id;
        accountContactRole5.Service_Rendered__c = 'GADM';
        accountContactRole5.RecordTypeId = functionalRecordTypeId;
        accountContactRolesToInsert.add(accountContactRole5);


        insert accountContactRolesToInsert;

        List<Contact_Role_Service_Access__c> contactRoleServiceAccessesToInsert = new List<Contact_Role_Service_Access__c>();

        //for testUser
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

        Contact_Role_Service_Access__c serviceAccess2b = new Contact_Role_Service_Access__c();
        serviceAccess2b.Contact_Role__c = accountContactRole2b.Id;
        serviceAccess2b.Service__c = portalApplications.Id;
        serviceAccess2b.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess2b);


        Contact_Role_Service_Access__c serviceAccess3 = new Contact_Role_Service_Access__c();
        serviceAccess3.Contact_Role__c = accountContactRole3.Id;
        serviceAccess3.Service__c = portalApplications.Id;
        serviceAccess3.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess3);

        Contact_Role_Service_Access__c serviceAccess3b = new Contact_Role_Service_Access__c();
        serviceAccess3b.Contact_Role__c = accountContactRole4.Id;
        serviceAccess3b.Service__c = portalApplications.Id;
        serviceAccess3b.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess3b);

        Contact_Role_Service_Access__c serviceAccess3c = new Contact_Role_Service_Access__c();
        serviceAccess3c.Contact_Role__c = accountContactRole5b.Id;
        serviceAccess3c.Service__c = portalApplications.Id;
        serviceAccess3c.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess3c);

        Contact_Role_Service_Access__c serviceAccess4 = new Contact_Role_Service_Access__c();
        serviceAccess4.Contact_Role__c = accountContactRole7.Id;
        serviceAccess4.Service__c = portalApplications.Id;
        serviceAccess4.Status__c = 'Granted';
        contactRoleServiceAccessesToInsert.add(serviceAccess4);

        Contact_Role_Service_Access__c serviceAccess5 = new Contact_Role_Service_Access__c();
        serviceAccess5.Contact_Role__c = accountContactRole5.Id;
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
        testUser.ProfileId = profileId;
        testUser.IsActive = true;
        insert testUser;
        return testUser;
    }

    private static List<String> getPicklistValues(String ObjectApi_name,String Field_name) {

        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.add(a.getValue());
        }

        return lstPickvals;
    }



    @IsTest
    private static void isSubmissionOnTime_positiveTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        GADM_Data_Submission_Period__c testPeriod = [SELECT Id FROM GADM_Data_Submission_Period__c WHERE Name = 'Test'];

        Date today = Date.today();
        Date testDate = Date.newInstance(today.year(), 1, 8);

        boolean isOnTime = false;

        Test.startTest();

        System.runAs(testUser) {

            isOnTime = GADM_DataSubmissionPeriodHelper.isSubmissionOnTime(testPeriod.Id, testDate, 'ExtTestId001');

        }

        Test.stopTest();

        System.assertEquals(true, isOnTime, 'Submission should be in time!');
    }

    @IsTest
    private static void isSubmissionOnTime_negativeTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];
        GADM_Data_Submission_Period__c testPeriod = [SELECT Id FROM GADM_Data_Submission_Period__c WHERE Name = 'Test'];

        Date today = Date.today();
        Date testDate = Date.newInstance(today.year(), 1, 21);

        boolean isOnTime = false;

        Test.startTest();

        System.runAs(testUser) {

            isOnTime = GADM_DataSubmissionPeriodHelper.isSubmissionOnTime(testPeriod.Id, testDate, 'ExtTestId001');

        }

        Test.stopTest();

        System.assertEquals(false, isOnTime, 'Submission should not be in time!');
    }

    @IsTest
    private static void notifyContacts_InDueTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];


        Date today = Date.today();
        Date testDate = Date.newInstance(today.year(), 4, 8);


        String result = '';
        Integer timesSent = 0;

        Test.startTest();

        System.runAs(testUser) {

            result = GADM_DataSubmissionPeriodHelper.notifyContacts(testDate);
            timesSent = Limits.getEmailInvocations();

        }

        Test.stopTest();

        System.assertEquals('sent', result, 'Notification emails should be correctly sent!');
        System.assertEquals(1, timesSent, 'Email should be sent!');

    }

    @IsTest
    private static void notifyContacts_UpcomingTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'neo.smith.test@somedomain.com'];


        Date today = Date.today();
        Date testDate = Date.newInstance(today.year(), 3, 29);


        String result = '';
        Integer timesSent = 0;

        Test.startTest();

        System.runAs(testUser) {

            result = GADM_DataSubmissionPeriodHelper.notifyContacts(testDate);
            timesSent = Limits.getEmailInvocations();

        }

        Test.stopTest();

        System.assertEquals('sent', result, 'Notification emails should be correctly sent!');
        System.assertEquals(1, timesSent, 'Email should be sent!');

    }


    @IsTest
    private static void notifyContacts_withDataSubmissionsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'leo.black.test@somedomain.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account 2'];

        List<String> statusValues = new List<String>{'File processed'};
        List<String> typeValues = getPicklistValues('Data_Submission__c', 'Type__c');

        Date today = Date.today();
        Date submissionDate = Date.newInstance(today.year(), 4, 5);

        Data_Submission__c dataSubmission = new Data_Submission__c();
        dataSubmission.Account__c = testAccount.Id;
        dataSubmission.Submission_date__c = submissionDate;
        dataSubmission.External_Actor_Id__c = 'ExtTestId002';
        dataSubmission.Original_User__c = testUser.Id;
        dataSubmission.Submitter__c = testUser.Id;
        dataSubmission.Status__c = statusValues[0];
        dataSubmission.Type__c = typeValues[0];

        insert dataSubmission;

        Test.setCreatedDate(dataSubmission.Id, submissionDate);

        Date testDate = Date.newInstance(today.year(), 4, 8);

        String result = '';
        Integer timesSent = 0;

        Test.startTest();

        System.runAs(testUser) {

            result = GADM_DataSubmissionPeriodHelper.notifyContacts(testDate);
            timesSent = Limits.getEmailInvocations();

        }

        Test.stopTest();

        System.assertEquals('sent', result, 'Notification emails should be correctly sent!');
        System.assertEquals(1, timesSent, 'Email should be sent!');

    }

    @IsTest
    private static void notifyContacts_notSubmittingTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'leo.black.test@somedomain.com'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account'];

        Contact testContact1 =[SELECT Id FROM Contact WHERE FirstName = 'Neo' AND LastName = 'Smith'];
        Contact testContact2 =[SELECT Id FROM Contact WHERE FirstName = 'Jack' AND LastName = 'Lincoln'];

        List<String> statusValues = new List<String>{'File processed'};
        List<String> typeValues = getPicklistValues('Data_Submission__c', 'Type__c');

        Date today = Date.today();
        Date submissionDate = Date.newInstance(today.year(), 4, 5);

        Data_Submission__c dataSubmission = new Data_Submission__c();
        dataSubmission.Account__c = testAccount.Id;
        dataSubmission.Submission_date__c = submissionDate;
        dataSubmission.External_Actor_Id__c = 'ExtTestId002';
        dataSubmission.Original_User__c = testUser.Id;
        dataSubmission.Submitter__c = testUser.Id;
        dataSubmission.Status__c = statusValues[0];
        dataSubmission.Type__c = typeValues[0];

        insert dataSubmission;

        Data_Submission__c dataSubmission2 = new Data_Submission__c();
        dataSubmission2.Account__c = testAccount.Id;
        dataSubmission2.Submission_date__c = submissionDate.addDays(1);
        dataSubmission2.External_Actor_Id__c = 'ExtTestId002';
        dataSubmission2.Original_User__c = testUser.Id;
        dataSubmission2.Submitter__c = testUser.Id;
        dataSubmission2.Status__c = statusValues[0];
        dataSubmission2.Type__c = typeValues[0];

        insert dataSubmission2;


        Date testDate = Date.newInstance(today.year(), 4, 8);

        Map<String, List<GADM_DataSubmissionPeriodHelper.NotificationWrapper>> result = new Map<String, List<GADM_DataSubmissionPeriodHelper.NotificationWrapper>>();

        Test.startTest();

        System.runAs(testUser) {

            result = GADM_DataSubmissionPeriodHelper.notifyContactsBySubmissionPeriods(testDate);

        }

        Test.stopTest();

        List<GADM_DataSubmissionPeriodHelper.NotificationWrapper> notSubmitting = result.get('NotSubmitting');
        System.assertEquals(1, notSubmitting.size());

        List<Id> contacts = notSubmitting[0].contactsNotSubmitting;
        System.assertEquals(true, notSubmitting[0].accountName == 'Test account 2', 'Data for wrong account retrieved!');
        System.assertEquals(true, contacts.contains(testContact1.Id), 'Contact id missing among notified contacts!');
        System.assertEquals(false, contacts.contains(testContact2.Id), 'Contact id missing among notified contacts!');


    }

}