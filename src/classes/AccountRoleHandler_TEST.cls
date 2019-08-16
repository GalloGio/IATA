@IsTest
public class AccountRoleHandler_TEST {

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
        acc.Name = 'Test account gadm';
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
        acc2.Name = 'Test account gadm 2';
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

        Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        User testUser = createUser('Petr', 'Novak', standardUserProfileId);
        insert testUser;

        //GADM service
        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        //GADM Participang Account Role
        Account_Roles__c gadmParticipantAccountRole = new Account_Roles__c();
        gadmParticipantAccountRole.Name = 'GADM Participant';
        insert gadmParticipantAccountRole;

        Account_Roles__c isspAccountRole = new Account_Roles__c();
        isspAccountRole.Name = 'ISSP';
        insert isspAccountRole;
        Id masterRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.Account__c = acc.Id;
        accountRole.Account_Roles__c = gadmParticipantAccountRole.Id;
        accountRole.RecordTypeId = masterRecordType;
        insert accountRole;

        Account_Role__c accountRole2 = new Account_Role__c();
        accountRole2.Account__c = acc2.Id;
        accountRole2.Account_Roles__c = isspAccountRole.Id;
        accountRole.RecordTypeId = masterRecordType;
        insert accountRole2;

    }

    private static User createUser(String firstName, String lastName, Id profileId) {
        User testUser = new User();
        testUser.alias = 'dsfsdfds';
        testUser.email = firstName+'.'+lastName+'@somedomain.org';
        testUser.emailencodingkey = 'UTF-8';
        testUser.firstname = firstName;
        testUser.lastname = lastname;
        testUser.languagelocalekey = 'en_US';
        testUser.localesidkey = 'en_US';
        testUser.timezonesidkey = 'Asia/Dubai';
        testUser.Username = firstName+'.'+lastName+'@somedomain.org';
        testUser.PortalRole = 'Manager';
        testUser.CommunityNickname = (firstName + lastName).substring(0,8);
        testUser.ProfileId = profileId;
        testUser.License_Cost_Center__c = 'ISF005CH01';
        testUser.IsActive = true;

        return testUser;
    }


    @IsTest
    private static void checkGadmDuplicatesInsertTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak@somedomain.org'];

        Id masterRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account Gadm'];
        Account_Roles__c gadmParticipantAccountRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant'];

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            Account_Role__c newAccountRole = new Account_Role__c();
            newAccountRole.Account__c = testAccount.Id;
            newAccountRole.Account_Roles__c = gadmParticipantAccountRole.Id;
            newAccountRole.RecordTypeId = masterRecordType;

            try {

                insert newAccountRole;

            } catch (Exception e) {

                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();

        System.assertEquals(true, errorMessage.contains('DUPLICATE_VALUE'), 'Inserting duplicate account role for GADM Participant role was not caught!');
    }

    @IsTest
    private static void checkGadmDuplicatesInsert2Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak@somedomain.org'];

        Id masterRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account Gadm'];
        Account_Roles__c issp = [SELECT Id FROM Account_Roles__c WHERE Name = 'ISSP'];

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            Account_Role__c newAccountRole = new Account_Role__c();
            newAccountRole.Account__c = testAccount.Id;
            newAccountRole.Account_Roles__c = issp.Id;
            newAccountRole.RecordTypeId = masterRecordType;

            try {

                insert newAccountRole;

            } catch (Exception e) {

                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();
        System.assertEquals(false, errorMessage.contains('DUPLICATE_VALUE'), 'Inserting account role for non GADM Participant role should not raise duplicate error!');
    }

    @IsTest
    private static void checkGadmDuplicatesInsert3Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak@somedomain.org'];
        Id masterRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account Gadm 2'];
        Account_Roles__c gadmParticipantAccountRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant'];

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            Account_Role__c newAccountRole = new Account_Role__c();
            newAccountRole.Account__c = testAccount.Id;
            newAccountRole.Account_Roles__c = gadmParticipantAccountRole.Id;
            newAccountRole.RecordTypeId = masterRecordType;

            try {

                insert newAccountRole;

            } catch (Exception e) {

                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();

        System.assertEquals(false, errorMessage.contains('DUPLICATE_VALUE'), 'Inserting account role for non GADM Participant role should not raise duplicate error!');
    }

    @IsTest
    private static void checkGadmDuplicatesUpdateTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak@somedomain.org'];

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account Gadm 2'];
        Account_Roles__c gadmParticipantAccountRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant'];

        Account_Role__c existingIssAccountRole = [SELECT Id, Account_Roles__c, Account_Roles__r.Name FROM Account_Role__c WHERE Account__c = :testAccount.Id];

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {


            try {

                existingIssAccountRole.Account_Roles__c = gadmParticipantAccountRole.Id;
                update existingIssAccountRole;

            } catch (Exception e) {

                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();

        System.assertEquals(false, errorMessage.contains('DUPLICATE_VALUE'), 'Update should be OK if no GADM Participant account role exists for account!');
    }

    @IsTest
    private static void checkGadmDuplicatesUpdate2Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak@somedomain.org'];

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account Gadm 2'];
        Account_Roles__c gadmParticipantAccountRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant'];

        Account_Role__c existingIssAccountRole = [SELECT Id, Account_Roles__c, Any_Other_Information__c  FROM Account_Role__c WHERE Account__c = :testAccount.Id];


        existingIssAccountRole.Account_Roles__c = gadmParticipantAccountRole.Id;
        update existingIssAccountRole;

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {


            try {

                existingIssAccountRole.Any_Other_Information__c = 'Test';
                update existingIssAccountRole;

            } catch (Exception e) {

                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();

        System.assertEquals(false, errorMessage.contains('DUPLICATE_VALUE'), 'Update other then Account roles field should be OK!');
    }

    @IsTest
    private static void checkGadmDuplicatesUpdate3Test() {

        User testUser = [SELECT Id FROM User WHERE Email = 'petr.novak@somedomain.org'];

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test account Gadm'];
        Account_Roles__c issp = [SELECT Id FROM Account_Roles__c WHERE Name = 'ISSP'];
        Account_Role__c accountRole = [SELECT Id FROM Account_Role__c WHERE Account__c = :testAccount.Id];

        Test.startTest();

        String errorMessage = '';

        System.runAs(testUser) {

            try {

                accountRole.Account_Roles__c = issp.Id;
                update accountRole;

            } catch (Exception e) {

                errorMessage = e.getMessage();

            }

        }

        Test.stopTest();

        System.assertEquals(false, errorMessage.contains('DUPLICATE_VALUE'), 'Inserting account role for non GADM Participant role should not raise duplicate error!');
    }


}