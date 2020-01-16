@IsTest
public class TreasuryDashboardCtrlTest {

    @TestSetup
    private static void setup() {

        PowerBI_Cred__c cred = new PowerBI_Cred__c();
        cred.Name = 'TreasuryDashboard';
        cred.Dev_Configuration__c = 'TreasuryDashboard_PowerBI_Dev';
        cred.Prod_Configuration__c = 'TreasuryDashboard_PowerBI_Production';

        insert cred;

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

        ISSP_Record_Type_Mgmt__c rtMgmt = new ISSP_Record_Type_Mgmt__c (Name = 'Treasury Dashboard', Record_Type_Name__c = 'FDS_ICCS_Email_to_Case');
        insert rtMgmt;

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

    @IsTest
    private static void getCaseRecordTypeIdTest() {

        User testUser = [SELECT Id, ContactId FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        String caseRecordType = '';

        Test.startTest();

        System.runAs(testUser) {
            caseRecordType = TreasuryDashboardCtrl.getCaseRecordTypeId();
        }

        Test.stopTest();

        ISSP_Record_Type_Mgmt__c rtMgmt =  ISSP_Record_Type_Mgmt__c.getValues('Treasury Dashboard');
        String expectedRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', rtMgmt.Record_Type_Name__c);

        System.assertEquals(expectedRecordType, caseRecordType, 'Wrong case record type retrieved!');


    }

    @IsTest
    private static void getAccessTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');

        String  appIdentifier = conf.Application_Identifier__c;

        Cache.OrgPartition  orgPartition = Cache.Org.getPartition('local.PowerBI');
        if(orgPartition != null) {
            orgPartition.put('PowerBIaccessToken'+appIdentifier, 'someKey');
            orgPartition.put('PowerBIexpiersOn'+appIdentifier, 1573465202);
            orgPartition.put('PowerBIrefreshToken'+appIdentifier, 'someRefreshToken');
        }


        PowerBiCtrl.OAuthResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = TreasuryDashboardCtrl.getAccessToken(config);

        }

        Test.stopTest();

        System.assertEquals('testTokenString', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('refreshTokenString', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(1561019267, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');
    }


    @IsTest
    private static void getAccessToken_expiredTokenTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');

        String  appIdentifier = conf.Application_Identifier__c;

        Long expiresOn = ((System.now().getTime())/1000) + 1000;

        Cache.OrgPartition  orgPartition = Cache.Org.getPartition('local.PowerBI');
        if(orgPartition != null) {
            orgPartition.put('PowerBIaccessToken'+appIdentifier, 'someKey');
            orgPartition.put('PowerBIexpiersOn'+appIdentifier, expiresOn);
            orgPartition.put('PowerBIrefreshToken'+appIdentifier, 'someRefreshToken');
        }


        PowerBiCtrl.OAuthResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = TreasuryDashboardCtrl.getAccessToken(config);

        }

        Test.stopTest();

        System.assertEquals('someKey', result.access_token, 'Wrong access token retrieved!');
        System.assertEquals('someRefreshToken', result.refresh_token, 'Wrong refresh token retrieved!');
        System.assertEquals(expiresOn, result.expires_on, 'Wrong expires on retrieved!');
        System.assertEquals(null, result.error, 'There should be no error!');
    }


    @IsTest
    private static void getAccessToken_responseErrorTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        String errorMessage = '';

        Test.startTest();

        System.runAs(testUser) {

            try{
                Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider.PowerBItokenErrorMock());
                PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
                TreasuryDashboardCtrl.getAccessToken(config);

            }catch(Exception e) {
                errorMessage = e.getMessage();
            }

        }

        Test.stopTest();

        System.assertEquals(true, errorMessage.contains('user_password_expired'), 'Error should be retrieved retrieved!');
    }


    @IsTest
    private static void getDatasetTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        PowerBiCtrl.DatasetDetailResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = TreasuryDashboardCtrl.getDataset('access_token', 'datasetId', config);
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

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        PowerBiCtrl.ReportDetailResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = TreasuryDashboardCtrl.getReportsDetails('access_token', 'reportId',config);
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

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak.test.xyz@somedomain.xyz.com'];

        PowerBiCtrl.EmbedTokenResult result = null;

        Test.startTest();

        System.runAs(testUser) {

            Test.setMock(HttpCalloutMock.class, new PowerBICalloutMockProvider());
            PowerBI_Config__c config = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');
            result = TreasuryDashboardCtrl.getEmbedToken('access_token', 'federationId', 'groupId', 'reportId', 'datasetId',config);
        }

        Test.stopTest();

        System.assertEquals('someToken', result.token, 'Wrong reportid retrieved!');
        System.assertEquals('someTokenId', result.tokenId, 'Wrong reportname retrieved!');
        System.assertEquals('1561019567', result.expiration, 'Wrong datasetId name retrieved!');

    }

}