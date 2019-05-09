@IsTest
public class OneId_RegistrationHelper_GADM_TEST {

    @TestSetup
    private static void setup() {
        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        contactRoles.RecordTypeId = externalRecordTypeId;
        insert contactRoles;

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Service Power User';
        contactRoles2.RecordTypeId = externalRecordTypeId;
        insert contactRoles2;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting;

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2;

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Agency_User';
        setting3.Value__c = profileId;
        insert setting3;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;

        Account acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        insert acc1;

    }

    @IsTest
    private static void gadmRegistrationTest() {

        Account acc1 = [SELECT Id, Name, Type, Sector__c, ParentId FROM Account];

        String serviceName = 'GADM';

        Test.startTest();

        Contact con = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'Mr.', email='some.test@some.domain.com');

        OneId_RegistrationProcessController.registration(acc1, con, serviceName, new Map<String, String>{'isPowerUser' =>'true'});

        Test.stopTest();

    }

}