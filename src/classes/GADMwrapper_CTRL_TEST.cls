@IsTest
public class GADMwrapper_CTRL_TEST {

    @TestSetup
    public static void setup() {

        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='CS',Name='Czech Republic');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'CS';
        acc.Name = 'TestAccount';
        insert acc;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.Email = 'test.gadm@testgadm.com';
        con.RecordTypeId = rtId;
        insert con;

        User newUser = new User(alias = 'aaalias',
                email = con.email,
                emailencodingkey = 'UTF-8',
                firstname = con.firstName,
                lastname = con.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                contactId = con.Id,
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(con.email),
                PortalRole = 'Manager',
                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true);
        insert newUser;


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

        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        insert contactRoles;

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Power User';
        insert contactRoles2;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
        accountContactRole.Contact__c = con.Id;
        accountContactRole.Contact_Roles__c = contactRoles.Id;
        accountContactRole.Account_Role__c = accountRole.Id;
        accountContactRole.Service_Rendered__c = 'GADM';
        accountContactRole.RecordTypeId = functionalRecordTypeId;
        insert accountContactRole;

        Account_Contact_Role__c accountContactRole1 = new Account_Contact_Role__c();
        accountContactRole1.Contact__c = con.Id;
        accountContactRole1.Contact_Roles__c = contactRoles.Id;
        accountContactRole1.Account_Role__c = accountRole.Id;
        accountContactRole1.Service_Rendered__c = 'GADM';
        accountContactRole1.RecordTypeId = groupRecordTypeId;
        insert accountContactRole1;

        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = con.Id;
        accountContactRole2.Contact_Roles__c = contactRoles2.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        insert accountContactRole2;

        //role GADM User is granted
        Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
        serviceAccess.Contact_Role__c = accountContactRole.Id;
        serviceAccess.Service__c = portalApplications.Id;
        serviceAccess.Status__c = 'Granted';
        insert serviceAccess;

        Contact_Role_Service_Access__c serviceAccess2 = new Contact_Role_Service_Access__c();
        serviceAccess2.Contact_Role__c = accountContactRole2.Id;
        serviceAccess2.Service__c = portalApplications.Id;
        serviceAccess2.Status__c = 'Granted';
        insert serviceAccess2;


    }
    

    @IsTest
    private static void getUserRolesTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm@testgadm.com'];

        Test.startTest();

        String status;

        System.runAs(testUser) {
            status = GADMwrapper_CTRL.getUserRoles(testUser.Id);
        }

        Test.stopTest();

        System.assertEquals('Granted', status, 'Access status for GADM User role should be Granted!');

    }

    @IsTest
    private static void getUserRolesNullUserIdTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm@testgadm.com'];

        Test.startTest();

        String status;

        System.runAs(testUser) {
            status = GADMwrapper_CTRL.getUserRoles(null);
        }

        Test.stopTest();

        System.assertEquals('', status, 'Empty status should be retvieved!');

    }

    @IsTest
    private static void getAccountDetailsTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm@testgadm.com'];

        Test.startTest();

        Map<String, String> accountDetailsMap;

        System.runAs(testUser) {
            accountDetailsMap = GADMwrapper_CTRL.getAccountDetails(testUser.Id);
        }

        Test.stopTest();

        System.assertEquals('Active', accountDetailsMap.get('status'), 'Wrong Account_role__c status retrieved!');
        System.assertEquals('true', accountDetailsMap.get('effective'), 'Wrong Account_role__c effectiveness retrieved!');

    }

    @IsTest
    private static void getAccountDetailsNotActiveTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm@testgadm.com'];

        Account_Role__c accountRole = [SELECT Id, Status__c FROM Account_Role__c];
        accountRole.Status__c = 'Inactive';
        update  accountRole;

        Test.startTest();

        Map<String, String> accountDetailsMap;

        System.runAs(testUser) {
            accountDetailsMap = GADMwrapper_CTRL.getAccountDetails(testUser.Id);
        }

        Test.stopTest();

        System.assertEquals('Inactive', accountDetailsMap.get('status'), 'Wrong Account_role__c status retrieved!');
        System.assertEquals('true', accountDetailsMap.get('effective'), 'Wrong Account_role__c effectiveness retrieved!');

    }

    @IsTest
    private static void getAccountDetailsNotEffectiveTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm@testgadm.com'];

        Account_Role__c accountRole = [SELECT Id, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c];
        accountRole.Effective_To_Date__c = Date.today().addDays(-1);
        update  accountRole;

        Test.startTest();

        Map<String, String> accountDetailsMap;

        System.runAs(testUser) {
            accountDetailsMap = GADMwrapper_CTRL.getAccountDetails(testUser.Id);
        }

        Test.stopTest();

        System.assertEquals('Active', accountDetailsMap.get('status'), 'Wrong Account_role__c status retrieved!');
        System.assertEquals('false', accountDetailsMap.get('effective'), 'Wrong Account_role__c effectiveness retrieved!');

    }

    @IsTest
    private static void getAccountDetailsNullUserIdTest() {
        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm@testgadm.com'];

        Test.startTest();

        Map<String, String> accountDetailsMap = new Map<String, String>();

        System.runAs(testUser) {
            accountDetailsMap = GADMwrapper_CTRL.getAccountDetails(null);
        }

        Test.stopTest();

        System.assertEquals(0, accountDetailsMap.size());
    }

    @IsTest
    private static void getAccountDetailsUserWithoutContactTest() {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User newUser = new User(alias = 'aaalias',
                email = 'some.email@some.domain.com',
                emailencodingkey = 'UTF-8',
                firstname = 'John',
                lastname = 'Rambo',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName('some.email@some.domain.com'),
                PortalRole = 'Manager',
                CommunityNickname = 'some.email@some.domain.com'.substring(0, 'some.email@some.domain.com'.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = userProfile.Id,
                License_Cost_Center__c = 'ISF005CH01',
                IsActive = true);
        insert newUser;

        Test.startTest();

        Map<String, String> accountDetailsMap = new Map<String, String>();

        System.runAs(newUser) {
            accountDetailsMap = GADMwrapper_CTRL.getAccountDetails(newUser.Id);
        }

        Test.stopTest();

        System.assertEquals(0, accountDetailsMap.size(), 'If user has no related account - no info should be retrieved!');
    }

}