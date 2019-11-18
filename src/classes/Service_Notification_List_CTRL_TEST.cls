@IsTest
public class Service_Notification_List_CTRL_TEST {


    public static final ID headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

    @TestSetup
    private static void setup() {

        IATA_ISO_Country__c canada = createIataCountry('Canada', 'CA', 'Canada');
        Account testAccount = createTestAccount('Test Account', canada);
        Contact testContact = createTestContact(testAccount);
        User testUser = createTestUser(testContact);


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

        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = testContact.Id;
        accountContactRole2.Contact_Roles__c = contactRoles2.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole2;

        //role GADM User is pending
        Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
        serviceAccess.Contact_Role__c = accountContactRole.Id;
        serviceAccess.Service__c = portalApplications.Id;
        serviceAccess.Status__c = 'Pending';
        insert serviceAccess;

        //role Power User is granted
        Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
        serviceAccess2.Contact_Role__c = accountContactRole2.Id;
        serviceAccess2.Service__c = portalApplications.Id;
        serviceAccess2.Status__c = 'Granted';
        insert serviceAccess2;


        Service_Notification__c message1 = createMessage('Test header1', 'Test body1 <a href="https://iata--gadm.lightning.force.com/lightning/r/ContentVersion/0681x000000Fi1I/view" target="_blank">file</a>', Date.today(), Date.today());
        Service_Notification__c message2 = createMessage('Test header2', 'Test body2', Date.today().addDays(-5), Date.today().addDays(5));
        Service_Notification__c message3 = createMessage('Test header3', 'Test body3', Date.today().addDays(-10), Date.today().addDays(-1));
        Service_Notification__c message4 = createMessage('Test header4', 'Test body4', Date.today().addDays(1), Date.today().addDays(5));

        Service_Notification_Role__c notificationRole = new Service_Notification_Role__c();
        notificationRole.Service_Notification__c = message1.Id;//Message1
        notificationRole.Contact_Roles__c = contactRoles.Id; //GADM User
        insert notificationRole;

        Service_Notification_Role__c notificationRole2 = new Service_Notification_Role__c();
        notificationRole2.Service_Notification__c = message2.Id;//Message2
        notificationRole2.Contact_Roles__c = contactRoles.Id; //GADM User
        insert notificationRole2;

        Service_Notification_Role__c notificationRole3 = new Service_Notification_Role__c();
        notificationRole3.Service_Notification__c = message1.Id;//Message1
        notificationRole3.Contact_Roles__c = contactRoles2.Id; //Power User
        insert notificationRole3;

        Service_Notification_Role__c notificationRole4 = new Service_Notification_Role__c();
        notificationRole4.Service_Notification__c = message3.Id;//Message3
        notificationRole4.Contact_Roles__c = contactRoles2.Id; //Power User
        insert notificationRole4;

        Service_Notification_Role__c notificationRole5 = new Service_Notification_Role__c();
        notificationRole5.Service_Notification__c = message4.Id;//Message4
        notificationRole5.Contact_Roles__c = contactRoles3.Id; //Account Sharing
        insert notificationRole5;


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

    private static Contact createTestContact(Account account) {
        Contact testContact = new Contact();
        testContact.AccountId = account.id;
        testContact.Firstname = 'teste3_4';
        testContact.Lastname='test3';
        testContact.Phone = '911111113';
        testContact.MobilePhone = '911111113';
        testContact.Email = 'testServiceNotification@test.com';
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

    private static Service_Notification__c createMessage(String header, String body, Date validFrom, Date validTo) {
        Service_Notification__c message = new Service_Notification__c();
        message.Header__c = header;
        message.Body__c = body;
        message.Valid_From__c = validFrom;
        message.Valid_To__c = validTo;

        insert message;
        return message;
    }


    @IsTest
    private static void getMessages_validMessagesTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testServiceNotification@test.com'];

        Test.startTest();

        List<Service_Notification__c> testMessages;

        System.runAs(testUser) {
            testMessages  = Service_Notification_List_CTRL.getMessages();
        }

        Test.stopTest();

        System.assertEquals(1, testMessages.size(), 'Incorrect number of valid messages retrieved!');
        System.assertEquals(testMessages[0].Header__c, 'Test header1', 'Incorrect message retrieved!');

    }

    @IsTest
    private static void getMessages_noMessagesTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'testServiceNotification@test.com'];

        List<Contact_Role_Service_Access__c> serviceAccess = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Status__c = 'Granted'];
        serviceAccess[0].Status__c = 'Pending';
        update serviceAccess;


        Test.startTest();

        List<Service_Notification__c> testMessages;

        System.runAs(testUser) {
            testMessages  = Service_Notification_List_CTRL.getMessages();
        }

        Test.stopTest();

        System.assertEquals(0, testMessages.size(), 'Incorrect number of valid messages retrieved!');

    }



}