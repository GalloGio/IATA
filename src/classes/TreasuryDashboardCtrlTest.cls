@IsTest
public class TreasuryDashboardCtrlTest {

    @TestSetup
    private static void setup() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        List<Account> accountsToInsert = new List<Account>();
        Account testAccount = createAccount('Test account 1', headquarters, country.Id);
        accountsToInsert.add(testAccount);

        Account testAccount2 = createAccount('Test account 2', headquarters, country.Id);
        accountsToInsert.add(testAccount2);

        insert accountsToInsert;

        List<Contact> contactsToInsert = new List<Contact>();
        Contact testContact = createContact('Petr', 'Novak', testAccount);
        contactsToInsert.add(testContact);

        insert contactsToInsert;

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

        List<User> usersToInsert = new List<User>();
        User testUser = createUser(testContact, profileId);
        testUser.TD_Team__c = true;
        usersToInsert.add(testUser);

        insert usersToInsert;

        Portal_Applications__c portalApplication = new Portal_Applications__c();
        portalApplication.Name = 'Treasury Dashboard';
        portalApplication.TD_Included_Dashboards__c = 'ISSP_TD_1;ISSP_TD_2;ISSP_TD_3;ISSP_TD_4';
        insert portalApplication;

        Portal_Applications__c portalApplications2 = new Portal_Applications__c();
        portalApplications2.Name = 'Treasury Dashboard - Premium';
        portalApplications2.TD_Included_Dashboards__c = 'ISSP_TD_1;ISSP_TD_2;ISSP_TD_3;ISSP_TD_4;ISSP_TD_5';
        insert portalApplications2;

        Portal_Application_Right__c right1 = new Portal_Application_Right__c();
        right1.Contact__c = testContact.Id;
        right1.Portal_Application__c = portalApplication.Id;
        right1.Right__c = '	Access Requested';

        insert right1;


    }

    private static Contact createContact(String firstName, String lastName, Account acc) {
        Contact testContact = new Contact();
        testContact.AccountId = acc.id;
        testContact.Firstname = firstName;
        testContact.Lastname= lastName;
        testContact.Phone = '911111113';
        testContact.MobilePhone = '911111113';
        testContact.Email = firstName + '.' + lastName + '.test.xyz@somedomain.xyz.com';
        testContact.BSP_CASS_Payment_contact__c = false;
        testContact.User_Portal_Status__c = 'Approved';

        return testContact;
    }


    private static Account createAccount(String accountName, Id recordTypeId, Id countryId) {
        Account acc = new Account();
        acc.Name = accountName;
        acc.BillingCity = 'Montreal';
        acc.BillingCountry = 'Canada';
        acc.BillingStreet = 'some street';
        acc.IATA_ISO_Country__c = countryId;
        acc.Location_Type__c = 'HO';
        acc.IATACode__c = '1234567';
        acc.Type = 'IATA Cargo Agent';
        acc.Status__c = 'Approved';
        acc.RecordTypeId = recordTypeId;

        return acc;
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

        return testUser;
    }



    @IsTest
    private static void getUserInformationTest() {

        User testUser = [SELECT Id, ContactId FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];
        Portal_Application_Right__c accessRight = [SELECT Id FROM Portal_Application_Right__c WHERE Contact__c = :testUser.ContactId LIMIT 1];

        Map<String, String> QR = new Map<String, String>();
        QR = Auth.SessionManagement.getQrCode();
        String secret = QR.get('secret');

        TwoFactorInfo tfInfo = new TwoFactorInfo();
        tfInfo.UserId = testUser.Id;
        tfInfo.SharedKey = secret;
        tfInfo.Type = 'TOTP';
        insert tfInfo;

        TreasuryDashboardCtrl.UserInformation info = null;

        Test.startTest();

        System.runAs(testUser) {

            accessRight.Right__c = 'Access Granted';
            update accessRight;

            info = TreasuryDashboardCtrl.getUserInformation();
        }

        Test.stopTest();

        System.assertEquals(true, info.hasTwoFactor, 'User should have Two Factor authorization!');
        System.assertEquals(true, info.isStandardUser, 'User should have granted access to Treasury Dashboard!');
        System.assertEquals(false, info.isPremiumUser, 'User should NOT have access to Treasury Dashboard Premium!');
        System.assertEquals(true, info.user.Id == testUser.Id, 'Wrong user retrieved!');

    }

    @IsTest
    private static void premiumAccessRequestTest() {

        User testUser = [SELECT Id, ContactId FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];
        Portal_Applications__c tdPremium = [SELECT Id FROM Portal_Applications__c WHERE Name = 'Treasury Dashboard - Premium'];

        String testResult = '';

        Test.startTest();

        System.runAs(testUser) {

            testResult = TreasuryDashboardCtrl.premiumAccessRequest(tdPremium.Id, testUser.ContactId);
        }


        Test.stopTest();

        System.assertEquals('ok', testResult, 'Unexpected test result! Should be "ok"!');

    }

}