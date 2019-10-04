/**
 * Created by ukaya01 on 26/08/2019.
 */

@isTest
public class PortalRegistrationFirstLevelCtrlTest {

    @testSetup
    static void setup(){

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting;

        //Create ISO Countries
        List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c>();
        IATA_ISO_Country__c c1 = new IATA_ISO_Country__c (
                Name = 'Test_Country_01',
                ISO_Code__c = 'CZ'
        );
        countryList.add(c1);

        IATA_ISO_Country__c c2 = new IATA_ISO_Country__c (
                Name = 'NO COUNTRY',
                ISO_Code__c = 'XX'
        );
        countryList.add(c2);
        insert countryList;


        //Create Bucket Account for Country c1
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        Account acc1 = new Account();
        acc1.RecordTypeId = rtHQ;
        acc1.Name='Bucket Airline1';
        acc1.ACLI_Status__c = 'Active Company';
        acc1.MITA_Member__c = true;
        acc1.BIETA_Member__c = true;
        acc1.Airline_designator__c = 'AA';
        acc1.IATACode__c = '4321';
        acc1.Airline_Prefix__c = '765';
        acc1.Sector__c = 'Airline';
        acc1.Category__c = 'Passenger and Cargo';
        acc1.is_general_public_account__c = true;

        Account acc2 = new Account();
        acc2.RecordTypeId = rtHQ;
        acc2.Name='Bucket Airline2';
        acc2.ACLI_Status__c = 'Active Company';
        acc2.MITA_Member__c = true;
        acc2.BIETA_Member__c = true;
        acc2.Airline_designator__c = 'AA';
        acc2.IATACode__c = '3210';
        acc2.Airline_Prefix__c = '654';
        acc2.Sector__c = 'Airline';
        acc2.Category__c = 'Passenger and Cargo';
        acc2.IATA_ISO_Country__c = c2.Id;
        acc2.is_general_public_account__c = true;

        Account acc3 = new Account();
        acc3.RecordTypeId = rtHQ;
        acc3.Name='Bucket Hotel1';
        acc3.ACLI_Status__c = 'Active Company';
        acc3.MITA_Member__c = true;
        acc3.BIETA_Member__c = true;
        acc3.Sector__c = 'Accommodation';
        acc3.Category__c = 'Hotel';
        acc3.IATA_ISO_Country__c = c2.Id;
        acc3.is_general_public_account__c = true;

        Account acc4 = new Account();
        acc4.RecordTypeId = rtHQ;
        acc4.Name='Bucket GP1';
        acc4.ACLI_Status__c = 'Active Company';
        acc4.MITA_Member__c = true;
        acc4.BIETA_Member__c = true;
        acc4.Sector__c = 'General Public';
        acc4.Category__c = 'Student';
        acc4.IATA_ISO_Country__c = c2.Id;
        acc4.is_general_public_account__c = true;

        List<Account> accList = new List<Account>{acc1, acc2, acc3, acc4};
        insert accList;

        for(Account acc : accList){
            acc.isPartner = true;
        }

        update accList;

        //Create existing contacts under the bucket accounts
        Contact con1 = new Contact();
        con1.firstName = 'contact1_firstName';
        con1.lastName = 'contact1_lastName';
        con1.AccountId = acc1.Id;
        con1.Email='contact1@bucketairline.com';
        con1.Preferred_Language__c = 'Spanish';

        Contact con2 = new Contact();
        con2.firstName = 'contact2_firstName';
        con2.lastName = 'contact2_lastName';
        con2.AccountId = acc1.Id;
        con2.Email='contact2@bucketairline.com';

        Contact con3 = new Contact();
        con3.firstName = 'contact3_firstName';
        con3.lastName = 'contact3_lastName';
        con3.AccountId = acc2.Id;
        con3.Email='contact3@bucketairline.com';

        Contact con4 = new Contact();
        con4.firstName = 'contact4_firstName';
        con4.lastName = 'contact4_lastName';
        con4.AccountId = acc3.Id;
        con4.Email='contact4@buckethotel.com';

        Contact con5 = new Contact();
        con5.firstName = 'contact5_firstName';
        con5.lastName = 'contact5_lastName';
        con5.AccountId = acc4.Id;
        con5.Email='contact5@bucketgp.com';

        insert new List<Contact>{con1, con2, con3, con4, con5};

        //Create portal user
        User portalUser1 = ISSP_ObjectFactory.createPortalUser(con1);
        User portalUser2 = ISSP_ObjectFactory.createPortalUser(con4);
        User portalUser3 = ISSP_ObjectFactory.createPortalUser(con5);



    }

    @isTest
    static void testHelperMethods(){

        Test.StartTest();

        PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists(null);
        PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists('Airline');
        PortalRegistrationFirstLevelCtrl.getMetadataCustomerType('Passenger_and_Cargo');

        Test.StopTest();

    }

    @isTest
    static void testGetConfig(){

        Test.StartTest();

        PortalRegistrationFirstLevelCtrl.RegistrationConfig config = PortalRegistrationFirstLevelCtrl.getConfig();
        System.assertEquals(config != null, true);

        Test.StopTest();

    }

    @isTest
    static void testGetUserInformationFromEmail(){

        Test.StartTest();

        PortalRegistrationFirstLevelCtrl.UserInformation userInfo1 = PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail('contact1@bucketairline.com');
        System.assertEquals(userInfo1.hasExistingContact == true, true);
        System.assertEquals(userInfo1.hasExistingUser == true, true);
        System.assertEquals(userInfo1.isEmailAddressAvailable == false, true);

        PortalRegistrationFirstLevelCtrl.UserInformation userInfo2 = PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail('contact2@bucketairline.com');
        System.assertEquals(userInfo2.hasExistingContact == true, true);
        System.assertEquals(userInfo2.hasExistingUser == false, true);
        System.assertEquals(userInfo2.isEmailAddressAvailable == true, true);

        PortalRegistrationFirstLevelCtrl.UserInformation userInfo3 = PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail('newcontact1@bucketairline.com');
        System.assertEquals(userInfo3.hasExistingContact == false, true);
        System.assertEquals(userInfo3.hasExistingUser == false, true);
        System.assertEquals(userInfo3.isEmailAddressAvailable == true, true);

        Test.StopTest();

    }

    @isTest
    static void testSimulateRegisterForExistingContact(){

        Test.StartTest();

        Contact con = [SELECT Id, AccountId FROM contact WHERE lastName = 'contact2_lastName' LIMIT 1];

        string registrationJson = '{"category": "",' +
                '"country": "",' +
                '"email": "contact2@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "",' +
                '"language": "en_us",' +
                '"lastName": "",' +
                '"phone": "",' +
                '"sector": "",' +
                '"selectedCustomerType": "",' +
                '"termsAndUsage": true}';

        string customerTypeJson = '{}';

        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.simulateRegister(registrationJson, customerTypeJson, con.Id, con.AccountId);
        System.assertEquals(result.isSuccess == true, true);

        registrationJson = '{"category": "",' +
                '"country": "",' +
                '"email": "contact2@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "",' +
                '"language": "en_us",' +
                '"lastName": "",' +
                '"phone": "",' +
                '"sector": "",' +
                '"selectedCustomerType": "",' +
                '"termsAndUsage": false}';

        result = PortalRegistrationFirstLevelCtrl.simulateRegister(registrationJson, customerTypeJson, con.Id, con.AccountId);
        System.assertEquals(result.isSuccess == false, true);

        Test.stopTest();

    }

    @isTest
    static void testSimulateRegisterForNewContact(){

        Test.StartTest();

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CZ' LIMIT 1];

        GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType = PortalRegistrationFirstLevelCtrl.getMetadataCustomerType('Passenger_and_Cargo');

        string registrationJson = '{"category": "Passenger_and_Cargo",' +
                '"country": "' + country.Id + '",' +
                '"email": "newcontact1@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "newContactName1",' +
                '"language": "en_us",' +
                '"lastName": "newContactLastName1",' +
                '"phone": "",' +
                '"sector": "Airline",' +
                '"selectedCustomerType": "Passenger_and_Cargo",' +
                '"termsAndUsage": true}';

        string customerTypeJson = '{"Can_Account_Be_Created__c": true,' +
                '"Created_Account_Category__c": "Passenger and Cargo",' +
                '"Created_Account_Sector__c": "Airline",' +
                '"DeveloperName": "Passenger_and_Cargo",' +
                '"Display_Country__c": true,' +
                '"Display_Submit_for_Account_Creation__c": true,' +
                '"Fields_Displayed__c": "Name,Sector__c,Category__c,BillingStreet,IATACode__c,Airline_designator__c,Airline_Prefix__c",' +
                '"Fields_Targeted_Partial_Match__c": "IATACode__c,Airline_designator__c,Airline_Prefix__c",' +
                '"Filter_on_Record_Type__c": "IATA_Airline,IATA_Airline_BR",' +
                '"Id": "' + selectedMetadataCustomerType.Id + '",' +
                '"MasterLabel": "Passenger and Cargo",' +
                '"Parent__c": "Airline",' +
                '"Search_Option__c": "User Search",' +
                '"Type__c": "Category"}';


        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.simulateRegister(registrationJson, customerTypeJson, null, null);
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == true, true);

        registrationJson = '{"category": "Passenger_and_Cargo",' +
                '"country": "' + country.Id + '",' +
                '"email": "newcontact1@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "",' +
                '"language": "en_us",' +
                '"lastName": "newContactLastName1",' +
                '"phone": "",' +
                '"sector": "Airline",' +
                '"selectedCustomerType": "Passenger_and_Cargo",' +
                '"termsAndUsage": true}';

        result = PortalRegistrationFirstLevelCtrl.simulateRegister(registrationJson, customerTypeJson, null, null);
        System.assertEquals(result.isSuccess == false, true);

        Test.stopTest();

    }

    @isTest
    static void testSimulateRegisterForNewContactForExistingBucketAccount(){

        Test.StartTest();

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'XX' LIMIT 1];

        GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType = PortalRegistrationFirstLevelCtrl.getMetadataCustomerType('Passenger_and_Cargo');

        string registrationJson = '{"category": "Passenger_and_Cargo",' +
                '"country": "' + country.Id + '",' +
                '"email": "newcontact3@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "newContactName3",' +
                '"language": "en_us",' +
                '"lastName": "newContactLastName3",' +
                '"phone": "",' +
                '"sector": "Airline",' +
                '"selectedCustomerType": "Passenger_and_Cargo",' +
                '"termsAndUsage": true}';

        string customerTypeJson = '{"Can_Account_Be_Created__c": true,' +
                '"Created_Account_Category__c": "Passenger and Cargo",' +
                '"Created_Account_Sector__c": "Airline",' +
                '"DeveloperName": "Passenger_and_Cargo",' +
                '"Display_Country__c": true,' +
                '"Display_Submit_for_Account_Creation__c": true,' +
                '"Fields_Displayed__c": "Name,Sector__c,Category__c,BillingStreet,IATACode__c,Airline_designator__c,Airline_Prefix__c",' +
                '"Fields_Targeted_Partial_Match__c": "IATACode__c,Airline_designator__c,Airline_Prefix__c",' +
                '"Filter_on_Record_Type__c": "IATA_Airline,IATA_Airline_BR",' +
                '"Id": "' + selectedMetadataCustomerType.Id + '",' +
                '"MasterLabel": "Passenger and Cargo",' +
                '"Parent__c": "Airline",' +
                '"Search_Option__c": "User Search",' +
                '"Type__c": "Category"}';


        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.simulateRegister(registrationJson, customerTypeJson, null, null);
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == true, true);

        Test.stopTest();

    }

    @isTest
    static void registerForExistingContact(){

        Test.StartTest();

        Contact con = [SELECT Id, AccountId FROM contact WHERE lastName = 'contact2_lastName' LIMIT 1];

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CZ' LIMIT 1];

        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
        params.email = 'contact2@bucketairline.com';
        params.firstName = 'contact2_firstName';
        params.lastName = 'contact2_lastName';
        params.country = country.Id;
        params.phone = '';
        params.language = '';
        params.contactId = con.Id;
        params.accountId = con.AccountId;
        params.isNewAccount = false;
        params.selectedCustomerType = 'Passenger_and_Cargo';
        params.registrationTime = string.valueOf(DateTime.now());

        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.register(params, 'Admin1234!');
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == true, true);

        Test.stopTest();
    }

    @isTest
    static void testRegisterForNewContact() {

        Test.StartTest();

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CZ' LIMIT 1];

        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
        params.email = 'newcontact1@bucketairline.com';
        params.firstName = 'newContactName1';
        params.lastName = 'newContactLastName1';
        params.country = country.Id;
        params.phone = '';
        params.language = '';
        params.contactId = null;
        params.accountId = null;
        params.isNewAccount = true;
        params.selectedCustomerType = 'Passenger_and_Cargo';
        params.registrationTime = string.valueOf(DateTime.now());

        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.register(params, 'Admin1234!');
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == true, true);

        Test.stopTest();
    }

    @isTest
    static void testRegisterForNewContactForExistingBucketAccount(){

        Test.StartTest();

        Account acc = [SELECT Id FROM Account WHERE Name = 'Bucket Airline2' LIMIT 1];

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'XX' LIMIT 1];

        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
        params.email = 'newcontact1@bucketairline.com';
        params.firstName = 'newContactName1';
        params.lastName = 'newContactLastName1';
        params.country = country.Id;
        params.phone = '';
        params.language = '';
        params.contactId = null;
        params.accountId = acc.Id;
        params.isNewAccount = false;
        params.selectedCustomerType = 'Passenger_and_Cargo';
        params.registrationTime = string.valueOf(DateTime.now());

        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.register(params, 'Admin1234!');
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == true, true);

        params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
        result = PortalRegistrationFirstLevelCtrl.register(params, 'Admin1234!');
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == false, true);

        Test.stopTest();

    }

    @isTest
    static void testGetRegistrationConfirmationConfig(){

        Contact con = [SELECT Id, AccountId FROM contact WHERE lastName = 'contact4_lastName' LIMIT 1];

        User portalUser = [SELECT Id FROM User WHERE contactId = :con.Id LIMIT 1];

        System.runAs(portalUser){
            Test.StartTest();

            PortalRegistrationFirstLevelCtrl.RegistrationConfirmationConfig config = PortalRegistrationFirstLevelCtrl.getRegistrationConfirmationConfig();
            System.assertEquals(config != null, true);

            Test.StopTest();
        }

    }

    @isTest
    static void testGetRegistrationConfirmationConfigForGeneralPublicAccount(){

        Contact con = [SELECT Id, AccountId FROM contact WHERE lastName = 'contact5_lastName' LIMIT 1];

        User portalUser = [SELECT Id FROM User WHERE contactId = :con.Id LIMIT 1];

        System.runAs(portalUser){
            Test.StartTest();

            PortalRegistrationFirstLevelCtrl.RegistrationConfirmationConfig config = PortalRegistrationFirstLevelCtrl.getRegistrationConfirmationConfig();
            System.assertEquals(config != null, true);

            Test.StopTest();
        }

    }

    @isTest
    static void testUpdateContactInfo(){

        Test.StartTest();

        Contact con = [SELECT Id, AccountId FROM contact WHERE lastName = 'contact4_lastName' LIMIT 1];

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'XX' LIMIT 1];

        string registrationJson = '{"category": "Passenger_and_Cargo",' +
                '"contactId": "' + con.Id + '",' +
                '"country": "' + country.Id + '",' +
                '"email": "contact1@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "contact1_firstName",' +
                '"language": "English",' +
                '"lastName": "contact1_lastName",' +
                '"phone": "",' +
                '"sector": "Airline",' +
                '"selectedCustomerType": "Passenger_and_Cargo"}';

        string customerTypeJson = '{}';

        PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.updateContactInfo(registrationJson, customerTypeJson, true);
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == true, true);

        registrationJson = '{"category": "Passenger_and_Cargo",' +
                '"contactId": null,' +
                '"country": "' + country.Id + '",' +
                '"email": "contact66@bucketairline.com",' +
                '"extraChoice": "",' +
                '"firstName": "contact66_firstName",' +
                '"language": "English",' +
                '"lastName": "contact66_lastName",' +
                '"phone": "",' +
                '"sector": "Airline",' +
                '"selectedCustomerType": "Passenger_and_Cargo"}';

        result = PortalRegistrationFirstLevelCtrl.updateContactInfo(registrationJson, customerTypeJson, true);
        system.debug('result: ' + result);
        System.assertEquals(result.isSuccess == false, true);

        Test.stopTest();

    }

}