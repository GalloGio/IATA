/**
 * Created by pvavruska on 6/24/2019.
 */



@IsTest
private class PortalFAQsSharingCtrlTest {
    public static Account MyAirline;
    public static List<Account> Airlines;
    public static List<Contact> Contacts;
    public static User portalUser;

    @IsTest
    static void testFAQsSharingSUCCESS() {
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        IATA_ISO_Country__c iso_swiss = new IATA_ISO_Country__c(Name = 'CH', ISO_Code__c = 'CH');
        insert iso_swiss;

        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456',
                IATA_ISO_Country__c = iso_swiss.Id,
                Sector__c = 'Airline'
        );
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Email='contact@MyAirline.com';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            PortalFAQsSharingCtrl.assignFAQsPermissions(portalUser.Id);
            List <PermissionSetAssignment> faqAssignments = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :portalUser.Id
            AND (PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX OR PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX2)];
        }
    }

    @IsTest
    static void testFAQsSharingDEFAULT() {
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456',
                Sector__c = 'Airline'
        );
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Email='contact@MyAirline.com';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){
            PortalFAQsSharingCtrl.assignFAQsPermissions(portalUser.Id);
            List <PermissionSetAssignment> faqAssignments = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: portalUser.Id
            AND (PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX OR PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX2)];
        }
    }

    @IsTest
    static void testPermsetChange(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c iso_swiss = new IATA_ISO_Country__c(Name = 'CH', ISO_Code__c = 'CH');
        IATA_ISO_Country__c iso_pt = new IATA_ISO_Country__c(Name = 'PT', ISO_Code__c = 'PT');
        
        insert new list<IATA_ISO_Country__c>{iso_swiss,iso_pt};

        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456',
                Sector__c = 'Airline',
                IATA_ISO_Country__c = iso_swiss.Id
        );
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Email='contact@MyAirline.com';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            PortalFAQsSharingCtrl.assignFAQsPermissions(portalUser.Id);

            MyAirline.IATA_ISO_Country__c = iso_pt.id;
            update MyAirline;

            PortalFAQsSharingCtrl.validateUserFAQsPermissions(portalUser.Id);


            List <PermissionSetAssignment> faqAssignments = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :portalUser.Id
            AND (PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX OR PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX2)];

        }
    }

    @IsTest
    static void testFAQsSharingCNS() {
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c iso_swiss = new IATA_ISO_Country__c(Name = 'CH', ISO_Code__c = 'CH',CNS_Country__c=true );
        insert iso_swiss;

        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456',
                IATA_ISO_Country__c = iso_swiss.Id,
                Sector__c = 'Travel Agent',
                Location_Class__c = 'R',
                CNS_Account__c = true
        );
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Email='contact@MyAirline.com';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            PortalFAQsSharingCtrl.assignFAQsPermissions(portalUser.Id);
            List <PermissionSetAssignment> faqAssignments = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :portalUser.Id
            AND (PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX OR PermissionSet.Name LIKE :PortalFAQsSharingCtrl.FAQ_PERMSET_PREFIX2)];
        }
    }
}