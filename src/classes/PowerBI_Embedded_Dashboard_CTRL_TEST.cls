@IsTest
public class PowerBI_Embedded_Dashboard_CTRL_TEST {

    @TestSetup
    private static void setup() {

        PowerBI_Cred__c cred = new PowerBI_Cred__c();
        cred.Name = 'GADM';
        cred.Dev_Configuration__c = 'GADM_PowerBI_Dev';
        cred.Prod_Configuration__c = 'GADM_PowerBI_Production';
        insert cred;

        List<PowerBI_Config__c> configsToInsert = new List<PowerBI_Config__c>();

        PowerBI_Config__c configDev = new PowerBI_Config__c();
        configDev.Name = 'GADM_PowerBI_Dev';
        configDev.ClientId__c = 'some-client-id';
        configDev.Tenant_Id__c = 'some-tennt-id';
        configDev.Username__c = 'some.username@iata.org';
        configDev.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configDev.Password__c = 'some-password';
        configsToInsert.add(configDev);

        PowerBI_Config__c configProd = new PowerBI_Config__c();
        configProd.Name = 'GADM_PowerBI_Prod';
        configProd.ClientId__c = 'some-client-id-prod';
        configProd.Tenant_Id__c = 'some-tenant-id-prod';
        configProd.Username__c = 'some.username.prod@iata.org';
        configProd.Resource__c = 'https://analysis.windows.net/powerbi/api';
        configProd.Password__c = 'some-password-prod';
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
    private static void getAccessTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];


        PowerBI_Embedded_Dashboard_CTRL.OAuthResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            result = PowerBI_Embedded_Dashboard_CTRL.getAccessToken();

        }

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('refreshTokenString', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');
    }


    //@IsTest
    private static void getAccessToken_expiredTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        Long currTime = System.currentTimeMillis()/1000;
        currTime = currTime + 200;

        Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.PowerBI');
        orgPartition.put('PowerBIaccessToken', 'access_token', 3600);
        orgPartition.put('PowerBIexpiersOn', currTime, 3600);
        orgPartition.put('PowerBIrefreshToken', 'refresh_token', 3600);

        PowerBI_Embedded_Dashboard_CTRL.OAuthResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider.PowerBIexpierdTokenMock());
            result = PowerBI_Embedded_Dashboard_CTRL.getAccessToken();

        }

        Test.stopTest();

        //values are taken from cache - no new request should occur
        System.assertEquals('access_token', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('refresh_token', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');

    }

    
    @IsTest
    private static void checkSessionDashboardCacheCoverageTest() {
        //can not be tested during deployment as session cache does not exist. Making coverage
        Boolean presentInCache;
        Test.startTest();
        presentInCache = PowerBI_Embedded_Dashboard_CTRL.checkSessionCache(UserInfo.getUserId(), 'checkSessionCacheCoverageTest');
        Test.stopTest();
        System.assertEquals(false, presentInCache, 'Key is not preset in cache');
    }


    @IsTest
    private static void getAccessToken_responseErrorTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        String errorMessage = '';

        Test.startTest();

        System.runAs(testUser) {

           try{
                Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider.PowerBItokenErrorMock());
                PowerBI_Embedded_Dashboard_CTRL.getAccessToken();

           }catch(Exception e) {
               errorMessage = e.getMessage();
            }

        }

        Test.stopTest();

        System.assertEquals(true, errorMessage.contains('user_password_expired'), 'Error should be retrieved retrieved!');
    }


    @IsTest
    private static void refreshTokenTest() {


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

        PowerBI_Embedded_Dashboard_CTRL.OAuthResult result = PowerBI_Embedded_Dashboard_CTRL.refreshToken(null);

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('refreshTokenString', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');
    }

    @IsTest
    private static void getUserDetailTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        User resultUser = new User();

        Test.startTest();

        System.runAs(testUser) {
            resultUser = PowerBI_Embedded_Dashboard_CTRL.getUserDetail(testUser.Id);
        }

        Test.stopTest();

        System.assertEquals(testUser.Id, resultUser.Id, 'Wrong user retrieved!');

    }

    @IsTest
    private static void getDatasetTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test@somedomain.com'];

        PowerBI_Embedded_Dashboard_CTRL.DatasetDetailResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            result = PowerBI_Embedded_Dashboard_CTRL.getDataset('access_token', 'datasetId');
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

        PowerBI_Embedded_Dashboard_CTRL.ReportDetailResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            result = PowerBI_Embedded_Dashboard_CTRL.getReportsDetails('access_token', 'reportId');
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

        PowerBI_Embedded_Dashboard_CTRL.EmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());

            result = PowerBI_Embedded_Dashboard_CTRL.getEmbedToken('access_token', 'federationId', 'groupId', 'reportId', 'datasetId');
        }

        Test.stopTest();

        System.assertEquals('someToken', result.token, 'Wrong reportid retrieved!');
        System.assertEquals('someTokenId', result.tokenId, 'Wrong reportname retrieved!');
        System.assertEquals('1561019567', result.expiration, 'Wrong datasetId name retrieved!');

    }

}