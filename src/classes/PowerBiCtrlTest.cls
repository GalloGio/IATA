@IsTest
public class PowerBiCtrlTest {

    @TestSetup
    private static void setup() {

        List<PowerBI_Cred__c> credsToInsert = new List<PowerBI_Cred__c>();

        PowerBI_Cred__c cred = new PowerBI_Cred__c();
        cred.Name = 'TreasuryDashboard';
        cred.Dev_Configuration__c = 'TreasuryDashboard_PowerBI_Dev';
        cred.Prod_Configuration__c = 'TreasuryDashboard_PowerBI_Production';
        credsToInsert.add(cred);

        PowerBI_Cred__c cred2 = new PowerBI_Cred__c();
        cred2.Name = 'TreasuryDashboardReport';
        cred2.Dev_Configuration__c = 'TreasuryDashboardReport_PowerBI_Dev';
        cred2.Prod_Configuration__c = 'TreasuryDashboardReport_PowerBI_Prod';
        credsToInsert.add(cred2);

        insert credsToInsert;

        List<PowerBI_Config__c> configsToInsert = new List<PowerBI_Config__c>();

        PowerBI_Config__c configDev = new PowerBI_Config__c();
        configDev.Name = 'TreasuryDashboard_PowerBI_Dev';
        configDev.ClientId__c = 'some-client-id';
        configDev.Tenant_Id__c = 'some-tennt-id';
        configDev.Username__c = 'some.username@iata.org';
        configDev.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configDev.Password__c = 'some-password';
        configDev.Application_Identifier__c = 'TDdev';
        configDev.Details_Resource__c = 'https://api.powerbi.com/v1.0/myorg';
        configDev.Report_Resource__c = 'https://app.powerbi.com';
        configsToInsert.add(configDev);

        PowerBI_Config__c configProd = new PowerBI_Config__c();
        configProd.Name = 'TreasuryDashboard_PowerBI_Production';
        configProd.ClientId__c = 'some-client-id-prod';
        configProd.Tenant_Id__c = 'some-tenant-id-prod';
        configProd.Username__c = 'some.username.prod@iata.org';
        configProd.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configProd.Password__c = 'some-password-prod';
        configProd.Application_Identifier__c = 'TDprod';
        configProd.Details_Resource__c = 'https://api.powerbi.com/v1.0/myorg';
        configProd.Report_Resource__c = 'https://app.powerbi.com';
        configsToInsert.add(configProd);

        PowerBI_Config__c configDev2 = new PowerBI_Config__c();
        configDev2.Name = 'TreasuryDashboardReport_PowerBI_Dev';
        configDev2.ClientId__c = 'some-client-id';
        configDev2.Client_secret__c = 'some-client-secret';
        configDev2.Tenant_Id__c = 'some-tennt-id';
        configDev2.Username__c = 'some.username@iata.org';
        configDev2.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configDev2.Password__c = 'some-password';
        configDev2.Application_Identifier__c = 'TDRepDev';
        configDev2.Details_Resource__c = 'https://api.powerbi.com/v1.0/myorg';
        configDev2.Report_Resource__c = 'https://app.powerbi.com';
        configsToInsert.add(configDev2);

        PowerBI_Config__c configProd2 = new PowerBI_Config__c();
        configProd2.Name = 'TreasuryDashboardReport_PowerBI_Prod';
        configProd2.ClientId__c = 'some-client-id-prod';
        configProd2.Client_secret__c = 'some-client-secret';
        configProd2.Tenant_Id__c = 'some-tenant-id-prod';
        configProd2.Username__c = 'some.username.prod@iata.org';
        configProd2.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configProd2.Password__c = 'some-password-prod';
        configProd2.Application_Identifier__c = 'TDRepProd';
        configProd2.Details_Resource__c = 'https://api.powerbi.com/v1.0/myorg';
        configProd2.Report_Resource__c = 'https://app.powerbi.com';
        configsToInsert.add(configProd2);

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
        testContact.Email = firstName + '.' + lastName + '.test@somedomain.com';
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

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBI_Config__c config = null;

        Test.startTest();
            System.runAs(testUser) {
                config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            }
        Test.stopTest();

        System.assertEquals(false, config == null, 'PowerBI config should not be null!');

    }


    @IsTest
    private static void getAccessTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];


        PowerBiCtrl.OAuthResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = PowerBiCtrl.getNewAccessToken(config);

        }

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('refreshTokenString', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');
    }


    @IsTest
    private static void refreshTokenTest() {

        Boolean isProd = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF';
        String configName = '';
        if(isProd) {
            configName = 'TreasuryDashboard_PowerBI_Production';
        }else{
            configName = 'TreasuryDashboard_PowerBI_Dev';
        }

        PowerBI_Config__c conf = PowerBI_Config__c.getValues(configName);


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

        PowerBiCtrl.OAuthResult result = PowerBiCtrl.refreshToken(null, conf);

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('refreshTokenString', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');
    }


    @IsTest
    private static void getDatasetTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBiCtrl.DatasetDetailResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = PowerBiCtrl.getDataset('access_token', 'datasetId', config);
        }

        Test.stopTest();

        System.assertEquals('datasetid', result.id, 'Wrong datasetId retrieved!');
        System.assertEquals('datasetname', result.name, 'Wrong dataset name retrieved!');
        System.assertEquals('true', result.isRefreshable, 'Wrong isRefreshable value retrieved!');
        System.assertEquals('true', result.isEffectiveIdentityRequired, 'Wrong isEffectiveIdentityRequired value retrieved!');
        System.assertEquals('true', result.isEffectiveIdentityRolesRequired, 'Wrong isEffectiveIdentityRolesRequired value retrieved!');

    }

    @IsTest
    private static void getReportsDetailsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBiCtrl.ReportDetailResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = PowerBiCtrl.getReportsDetails('access_token', 'reportId',config);
        }

        Test.stopTest();

        System.assertEquals('reportid', result.id, 'Wrong reportid retrieved!');
        System.assertEquals('reportname', result.name, 'Wrong reportname retrieved!');
        System.assertEquals('someDatasetId', result.datasetId, 'Wrong datasetId name retrieved!');
        System.assertEquals('www.weburl.org', result.webUrl, 'Wrong webUrl value retrieved!');
        System.assertEquals('embed/url', result.embedUrl, 'Wrong embedUrl value retrieved!');

    }

    @IsTest
    private static void getEmbedTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBiCtrl.EmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = PowerBiCtrl.getEmbedToken('access_token', 'federationId', 'groupId', 'reportId', 'datasetId',config);
        }

        Test.stopTest();

        System.assertEquals('someToken', result.token, 'Wrong reportid retrieved!');
        System.assertEquals('someTokenId', result.tokenId, 'Wrong reportname retrieved!');
        System.assertEquals('1561019567', result.expiration, 'Wrong datasetId name retrieved!');

    }


    @IsTest
    private static void getReportConfigDetailsTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBiCtrl.ReportDetails result = null;

        Test.startTest();

        System.runAs(testUser) {
            result = PowerBiCtrl.getReportConfigDetails('Treasury_Dashboard');
        }

        Test.stopTest();

        System.assertEquals(true, result.reportId != null, 'ReportId should not be null!');
        System.assertEquals(true, result.groupId != null, 'GroupId should not be null!');

    }

    @IsTest
    private static void getServicePrincipalAccessTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result= PowerBiCtrl.getServicePrincipalAccessToken(conf);

        }

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');

    }

    @IsTest
    private static void getServicePrincipalEmbedTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            result = PowerBiCtrl.getServicePrincipalEmbedToken('accessToken', 'userId', 'groupId', 'reportId', conf);
        }

        Test.stopTest();

        System.assertEquals('someToken', result.token, 'Wrong reportid retrieved!');
        System.assertEquals('1561019567', result.expiration, 'Wrong datasetId name retrieved!');

    }

    @IsTest
    private static void getServicePrincipalEmbedTokenErrorTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider.PowerBIServicePrincipalEmbedTokenErrorMock());

            result = PowerBiCtrl.getServicePrincipalEmbedToken('accessToken', 'userId', 'groupId', 'reportId', conf);
        }

        Test.stopTest();

        System.assertEquals(null, result.token, 'Wrong token retrieved!');
        System.assertEquals(null, result.expiration, 'Wrong expired on retrieved!');
        System.assertEquals('404', result.error.code, 'Wrong error code retrieved!');
        System.assertEquals('No HTTP resource was found that matches the request URI.', result.error.message, 'Wrong error message retrieved!');


    }


}