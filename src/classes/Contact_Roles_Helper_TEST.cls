@IsTest
public class Contact_Roles_Helper_TEST {

    @TestSetup
    private static void setup() {

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

        Contact standardContact = ISSP_ObjectFactory.createNewContact();
        standardContact.AccountId = acc.Id;
        standardContact.LastName = 'test';
        standardContact.Email = 'test.gadm.standard@testgadm.com';
        standardContact.RecordTypeId = rtId;
        insert standardContact;

        Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;

        User standardUser = new User(alias = 'aaalias2',
                email = standardContact.email,
                emailencodingkey = 'UTF-8',
                firstname = standardContact.firstName,
                lastname = standardContact.lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName(standardContact.email),
                PortalRole = 'Manager',
                ProfileId = standardUserProfileId,
                License_Cost_Center__c = 'ISF005CH01',
                IsActive = true);
        insert standardUser;

    }


    @IsTest
    private static void getContactFromUserTest() {

        User testUser = [SELECT Id FROM User WHERE Email = 'test.gadm.standard@testgadm.com'];

        Test.startTest();

        Contact testContact;

        System.runAs(testUser) {
             testContact = Contact_Roles_Helper.getContactFromUser(testUser.Id);
        }

        Test.stopTest();

        System.assertEquals(false, testContact == null, 'No contact returned!');

    }

    @IsTest
    private static void getContactFromUser2Test() {

        Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;

        User standardUser = new User(alias = 'aaalias2',
                email = 'some.email@somedomain.com',
                emailencodingkey = 'UTF-8',
                firstname = 'John',
                lastname = 'Rambo',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'Asia/Dubai',
                Username = ISSP_Utilities.buildPortalUserName('some.email@somedomain.com'),
                PortalRole = 'Manager',
                ProfileId = standardUserProfileId,
                License_Cost_Center__c = 'ISF005CH01',
                IsActive = true);
        insert standardUser;

        Contact testContact;

        Test.startTest();

        System.runAs(standardUser) {
            testContact = Contact_Roles_Helper.getContactFromUser(standardUser.Id);
        }
        
        Test.stopTest();

        System.assertEquals(null, testContact.Id, 'Only empty contact should be returned if user does not have contact!');


    }

}