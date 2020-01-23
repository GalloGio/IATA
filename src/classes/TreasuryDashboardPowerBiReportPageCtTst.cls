@IsTest
public with sharing class TreasuryDashboardPowerBiReportPageCtTst {

    @TestSetup
    private static void setup() {

        PowerBI_Cred__c cred = new PowerBI_Cred__c();
        cred.Name = 'TreasuryDashboardReport';
        cred.Dev_Configuration__c = 'TreasuryDashboardReport_PowerBI_Dev';
        cred.Prod_Configuration__c = 'TreasuryDashboardReport_PowerBI_Prod';
        insert cred;

        List<PowerBI_Config__c> configsToInsert = new List<PowerBI_Config__c>();

        PowerBI_Config__c configDev = new PowerBI_Config__c();
        configDev.Name = 'TreasuryDashboardReport_PowerBI_Dev';
        configDev.ClientId__c = 'some-client-id';
        configDev.Client_secret__c = 'some-client-secret';
        configDev.Tenant_Id__c = 'some-tennt-id';
        configDev.Username__c = 'some.username@iata.org';
        configDev.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configDev.Password__c = 'some-password';
        configDev.Application_Identifier__c = 'TDRepDev';
        configDev.Details_Resource__c = 'https://api.powerbi.com/v1.0/myorg';
        configDev.Report_Resource__c = 'https://app.powerbi.com';
        configsToInsert.add(configDev);

        PowerBI_Config__c configProd = new PowerBI_Config__c();
        configProd.Name = 'TreasuryDashboardReport_PowerBI_Prod';
        configProd.ClientId__c = 'some-client-id-prod';
        configProd.Client_secret__c = 'some-client-secret';
        configProd.Tenant_Id__c = 'some-tenant-id-prod';
        configProd.Username__c = 'some.username.prod@iata.org';
        configProd.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configProd.Password__c = 'some-password-prod';
        configProd.Application_Identifier__c = 'TDRepProd';
        configProd.Details_Resource__c = 'https://api.powerbi.com/v1.0/myorg';
        configProd.Report_Resource__c = 'https://app.powerbi.com';
        configsToInsert.add(configProd);

        insert configsToInsert;

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
    private static void getPageParams() {
        Test.startTest();
        PageReference pageRef = Page.TreasuryDashboardPowerBiReportPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('tokenType', 'tokenType');
        ApexPages.currentPage().getParameters().put('embedUrl', 'embedUrl');
        ApexPages.currentPage().getParameters().put('accessToken', 'accessToken');
        ApexPages.currentPage().getParameters().put('objectId', 'objectId');
        ApexPages.currentPage().getParameters().put('objectId', 'objectId');
        ApexPages.currentPage().getParameters().put('groupId', 'groupId');
        ApexPages.currentPage().getParameters().put('expiration', 'expiration');

        TreasuryDashboardPowerBiReportPageCtrl pageController = new TreasuryDashboardPowerBiReportPageCtrl();


        System.assertEquals(pageController.tokenType, 'tokenType');
        System.assertEquals(pageController.embedUrl, 'embedUrl');
        System.assertEquals(pageController.accessToken, 'accessToken');
        System.assertEquals(pageController.objectId, 'objectId');
        System.assertEquals(pageController.groupId, 'groupId');
        System.assertEquals(pageController.expiration, 'expiration');
        System.assertEquals(pageController.redirect(), null);
        Test.stopTest();
    }

    @IsTest
    private static void refreshEmbedTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        String refreshResultString = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            refreshResultString = TreasuryDashboardPowerBiReportPageCtrl.refreshEmbedToken('groupId', 'reportId');

        }

        Test.stopTest();

        System.assertEquals('someTokenexpiration=1561019567', refreshResultString, 'Wrong refresh token string received!');

    }

}