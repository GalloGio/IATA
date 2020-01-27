@IsTest
public class TreasuryDashboardReportCtrlTest {

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
        testContact.Email = firstName + '.' + lastName + '.xyz.abc.test@somedomain.com';
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
    private static void getPowerBICredentialsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c config = null;

        Test.startTest();
        System.runAs(testUser) {
            config = TreasuryDashboardReportCtrl.getPowerBICredentials('TreasuryDashboardReport');
        }
        Test.stopTest();

        System.assertEquals(false, config == null, 'PowerBI config should not be null!');

    }


    @IsTest
    private static void getReportConfigDetailsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBiCtrl.ReportDetails result = null;

        Test.startTest();

        System.runAs(testUser) {
            result = TreasuryDashboardReportCtrl.getReportConfigDetails('Treasury_Dashboard_Premium');
        }

        Test.stopTest();

        System.assertEquals(true, result.reportId != null, 'ReportId should not be null!');
        System.assertEquals(true, result.groupId != null, 'GroupId should not be null!');

    }



    @IsTest
    private static void getServicePrincipalAccessToken_newTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = TreasuryDashboardReportCtrl.getServicePrincipalAccessToken(conf);
        }

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires_on retrieved!');

    }

    @IsTest
    private static void getServicePrincipalAccessToken_newTokenNullTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = null;
        PowerBiCtrl.ServicePrincipalAccessTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = TreasuryDashboardReportCtrl.getServicePrincipalAccessToken(conf);
        }

        Test.stopTest();

        System.assertEquals(null, result, 'Null should be retrieved!');

    }

    @IsTest
    private static void getServicePrincipalAccessToken_tokenFromCacheTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = null;

        //current time + one hour
        Long expTime = (System.currentTimeMillis()/1000) + 3600;

        Cache.OrgPartition  orgPartition = Cache.Org.getPartition('local.PowerBI');
        if(orgPartition != null) {
            orgPartition.put(TreasuryDashboardReportCtrl.SERVICE_PRINCIPAL_ACCESS_TOKEN+conf.Application_Identifier__c, 'servicePrincipalSomeKey');
            orgPartition.put(TreasuryDashboardReportCtrl.SERVICE_PRINCIPAL_EXPIERS_ON+conf.Application_Identifier__c, expTime);
        }

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = TreasuryDashboardReportCtrl.getServicePrincipalAccessToken(conf);
        }

        Test.stopTest();


        System.assertEquals('servicePrincipalSomeKey', result.access_token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals(expTime, result.expires_on, 'Wrong expires_on retrieved!');

    }

    @IsTest
    private static void getServicePrincipalAccessToken_tokenFromCacheExpiredTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = null;

        //current time - 30 minutes
        Long expTime = (System.currentTimeMillis()/1000) - 1800;

        Cache.OrgPartition  orgPartition = Cache.Org.getPartition('local.PowerBI');
        if(orgPartition != null) {
            orgPartition.put(TreasuryDashboardReportCtrl.SERVICE_PRINCIPAL_ACCESS_TOKEN+conf.Application_Identifier__c, 'servicePrincipalSomeKey');
            orgPartition.put(TreasuryDashboardReportCtrl.SERVICE_PRINCIPAL_EXPIERS_ON+conf.Application_Identifier__c, expTime);
        }

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = TreasuryDashboardReportCtrl.getServicePrincipalAccessToken(conf);
        }

        Test.stopTest();


        System.assertEquals('testTokenString', result.access_token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires_on retrieved!');

    }


    @IsTest
    private static void getServicePrincipalAccessToken_newTokenErrorTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = null;
        Exception testException = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider.PowerBIServicePrincipalAccessErrorMock());
            try{
                result = TreasuryDashboardReportCtrl.getServicePrincipalAccessToken(conf);
            }catch(Exception e) {
                testException = e;
            }

        }

        Test.stopTest();

        System.assertEquals(true, testException.getMessage().contains('No HTTP resource was found that matches the request URI.'), 'Wrong token retrieved!');


    }

    @IsTest
    private static void getServicePrincipalEmbedTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {
            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken('access_token', 'user_id', 'groupid', 'reportid', conf);
        }

        Test.stopTest();


        System.assertEquals('someToken', result.token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals('1561019567', result.expiration, 'Wrong token retrieved!');

    }

    @IsTest
    private static void getServicePrincipalEmbedToken_tokenFromCacheTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        //current time + one hour
        Datetime now = Datetime.now().addMinutes(60);
        String expTime = now.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            Cache.SessionPartition  sessionPartition = Cache.Session.getPartition('local.PowerBiSession');
            if(sessionPartition != null) {
                sessionPartition.put(conf.Application_Identifier__c + 'reportid', 'servicePrincipalSomeKey');
                sessionPartition.put(conf.Application_Identifier__c + 'reportidexpireson',expTime);
            }

            result = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken('access_token', 'user_id', 'groupid', 'reportid', conf);
        }

        Test.stopTest();


        System.assertEquals('servicePrincipalSomeKey', result.token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals(expTime, result.expiration, 'Wrong expires_on retrieved!');

    }


    @IsTest
    private static void getServicePrincipalEmbedToken_expiresOnMissingFromCacheTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            Cache.SessionPartition  sessionPartition = Cache.Session.getPartition('local.PowerBiSession');
            if(sessionPartition != null) {
                sessionPartition.put('reportid', 'servicePrincipalSomeKey');
            }

            result = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken('access_token', 'user_id', 'groupid', 'reportid', conf);
        }

        Test.stopTest();


        System.assertEquals('someToken', result.token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals('1561019567', result.expiration, 'Wrong expires_on retrieved!');

    }

    @IsTest
    private static void getServicePrincipalEmbedToken_tokenFromCacheExpiredTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        //current time + one hour
        Datetime now = Datetime.now().addMinutes(-30);
        String expTime = now.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            Cache.SessionPartition  sessionPartition = Cache.Session.getPartition('local.PowerBiSession');
            if(sessionPartition != null) {
                sessionPartition.put('reportid', 'servicePrincipalSomeKey');
                sessionPartition.put('reportidexpireson',expTime);
            }

            result = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken('access_token', 'user_id', 'groupid', 'reportid', conf);
        }

        Test.stopTest();


        System.assertEquals('someToken', result.token, 'Wrong token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error retrieving token!');
        System.assertEquals('1561019567', result.expiration, 'Wrong expires_on retrieved!');

    }

    @IsTest
    private static void getServicePrincipalEmbedToken_newTokenNullTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = null;
        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken('access_token', 'user_id', 'groupid', 'reportid', conf);

        }

        Test.stopTest();

        System.assertEquals(null, result, 'Null should be retrieved!');

    }



    @IsTest
    private static void getServicePrincipalEmbedToken_newTokenErrorTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.xyz.abc.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;
        Exception testException = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider.PowerBIServicePrincipalEmbedTokenErrorMock());
            try{
                result = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken('access_token', 'user_id', 'groupid', 'reportid', conf);
            }catch(Exception e) {
                testException = e;
            }

        }

        Test.stopTest();

        System.assertEquals(true ,testException.getMessage().contains('No HTTP resource was found that matches the request URI.'), 'There should be an error!');

    }



}