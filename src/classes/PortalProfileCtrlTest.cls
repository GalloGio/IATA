/**
 * Created by pvavruska on 6/3/2019.
 */

@IsTest
public with sharing class PortalProfileCtrlTest {

    public static Account MyAirline;
    public static List<Account> Airlines;
    public static List<Contact> Contacts;
    public static User portalUser;

    @testSetup static void setup() {
    	Account newAcc = new Account(Name='Account Test CSP Utils');
    	insert newAcc;

    	Contact newCon = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
    	insert newCon;

    	User newUser = ISSP_ObjectFactory.createPortalUser(newCon);


    	ID_Card__c idc= new ID_Card__c();
    	idc.recordtypeid= RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');
    	idc.Name_on_ID_Card__c='test card 1';
    	idc.related_contact__C=newCon.id;
    	idc.ver_number__c='123123';
    	idc.Valid_From_Date__c=system.today().addDays(-200);
    	idc.valid_to_Date__C=system.today().addDays(200);

    	insert idc;

    }

    @IsTest
    static void testProfileInfo(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Email='contact@MyAirline.com';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);


        System.runAs(portalUser){
            Account airline = PortalProfileCtrl.getCompanyInfo(MyAirline.Id);

            Boolean canEdit = PortalProfileCtrl.canEditBasics();

            System.assert(canEdit == false);

            System.assert(airline.Id == MyAirline.Id);

            List<PortalProfileCtrl.CardWrapper> contactWrappers = PortalProfileCtrl.getFieldsMap('MyProfile');
            System.assert(!contactWrappers.isEmpty());

            List<PortalProfileCtrl.CardWrapper> companyWrappers = PortalProfileCtrl.getFieldsMap('CompanyProfile');
            System.assert(!companyWrappers.isEmpty());

            List<PortalProfileCtrl.CardWrapper> contactAccWrappers = PortalProfileCtrl.getFieldsMap('MyProfileAccFields');
            System.assert(!contactAccWrappers.isEmpty());

        }
    }

    @IsTest
    static void testBranchesAndContactsTabsInfo(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Email='contact@MyAirline.com';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs(portalUser){

            Map<String, List<PortalProfileCtrl.FieldWrapper>> branchFields = PortalProfileCtrl.getBranchesListFields();
            Map<String, List<PortalProfileCtrl.FieldWrapper>> contactFields = PortalProfileCtrl.getContactsListFields();
            List<PortalProfileCtrl.FieldWrapper> createContactFields = PortalProfileCtrl.getContactFieldsToInsert();


            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0, 15);
            List<PortalProfileCtrl.ContactWrapper> searchResults = PortalProfileCtrl.searchAccountContacts('searchQuery',0);
            List<Account> branches = PortalProfileCtrl.getCompanyBranches(0);
            List<Account> searchBranches = PortalProfileCtrl.searchCompanyBranches('test',0);

            Boolean hasAnnualRevalidation = PortalProfileCtrl.hasAnnualRevalidation();

            System.assert(!hasAnnualRevalidation);
            System.assert(!contacts.isEmpty());
            System.assert(!branches.isEmpty());
        }
    }

    @IsTest
    static void testUserAccessManagementApprove(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Salutation = 'Dear';
        con.Title = 'Eng.';
        con.Phone = '123456789';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs(portalUser){
            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0, 15);

            contacts[0].selected = true;
            ApexMessageHandling contactsToApprove = PortalProfileCtrl.approve(JSON.serialize(contacts), 'Approved Admin');
        }
    }

    @IsTest
    static void testUserAccessManagementInactiveWithApplications(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Salutation = 'Dear';
        con.Title = 'Eng.';
        con.Phone = '123456789';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        Portal_Applications__c serviceTest = new Portal_Applications__c (
            Name = 'serviceTest3',
            requestable__c=true,
            Agency__c = true,
            Hide_on_Homepage__c = false,
            Critical_Service__c = true
        );
        insert serviceTest;

        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = serviceTest.id,
            Right__c = 'Access Granted',
            Contact__c = con.Id
		);
        insert appRight;

        System.runAs(portalUser){
            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0, 15);

            contacts[0].selected = true;
            ApexMessageHandling contactsToDeactivate = PortalProfileCtrl.inactivate(JSON.serialize(contacts), 'Retired');
        }
    }

    @IsTest
    static void testUserAccessManagementInactiveWithAccountRole(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Salutation = 'Dear';
        con.Title = 'Eng.';
        con.Phone = '123456789';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        Account_Role__c accRole = new Account_Role__c(
            RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID,
            Account__c = MyAirline.Id
        );
        insert accRole;

        Account_Contact_Role__c contactRole = new Account_Contact_Role__c(
            Account__c = MyAirline.Id,
            Contact__c = con.Id,
            Account_Role__c = accRole.Id,
            Contact_Role__c = 'Primary Contact',
            Service_Rendered__c = 'TIP'
        );
        insert contactRole;

        System.runAs(portalUser){
            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0, 15);

            contacts[0].selected = true;
            ApexMessageHandling contactsToDeactivate = PortalProfileCtrl.inactivate(JSON.serialize(contacts), 'Retired');
        }
    }

    @IsTest
    static void testUserAccessManagementInactiveWithProducts(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Salutation = 'Dear';
        con.Title = 'Eng.';
        con.Phone = '123456789';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs(portalUser){
            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0, 15);

            contacts[0].selected = true;
            contacts[0].hasProducts = true;
            ApexMessageHandling contactsToApprove = PortalProfileCtrl.inactivate(JSON.serialize(contacts), 'Retired');
        }
    }

        @IsTest
    static void testUserAccessManagementInactiveSuccess(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAirline.Id;
        con.Salutation = 'Dear';
        con.Title = 'Eng.';
        con.Phone = '123456789';
        insert con;

        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        System.runAs(portalUser){
            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0, 15);

            contacts[0].selected = true;
            ApexMessageHandling contactsToDeactivate = PortalProfileCtrl.inactivate(JSON.serialize(contacts), 'Retired');
        }
    }       

    @IsTest
    static void testGetFilteredProfileResultsPage(){

    	PortalSearchFilterWrapper testPSFW = new PortalSearchFilterWrapper();

    	testPSFW.searchText = 'MyAirline';
    	testPSFW.profileComponent =  new PortalSearchFilterWrapper.profileComponent();
    	testPSFW.profileComponent.show = true;
    	testPSFW.profileComponent.loading = false;
    	testPSFW.profileComponent.highlight = true;
    	testPSFW.profileComponent.profileStatusFilter = '';
    	testPSFW.profileComponent.profileTypeFilter = '';
    	testPSFW.profileComponent.profileCountryFilter = '';

    	User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

    	System.runAs(usr){
    		String serialized = JSON.serialize(testPSFW);
    		CSP_Utils.PagedResult testPagedResult = PortalProfileCtrl.getFilteredProfileResultsPage(serialized);
    		System.assert (testPagedResult.recordsString != null);

    		String serialized2 = JSON.serialize(testPSFW);
    		testPSFW.profileComponent.profileStatusFilter = 'Approved Admin';
    		CSP_Utils.PagedResult testPagedResult1 = PortalProfileCtrl.getFilteredProfileResultsPage(serialized2);
    		System.assert (testPagedResult1.recordsString != null);

    		String serialized3 = JSON.serialize(testPSFW);
    		testPSFW.profileComponent.profileTypeFilter = 'Contact';
    		CSP_Utils.PagedResult testPagedResult2 = PortalProfileCtrl.getFilteredProfileResultsPage(serialized3);
    		System.assert (testPagedResult2.recordsString != null);

    		String serialized4 = JSON.serialize(testPSFW);
    		testPSFW.profileComponent.profileCountryFilter = 'Portugal';
    		CSP_Utils.PagedResult testPagedResult3 = PortalProfileCtrl.getFilteredProfileResultsPage(serialized4);
    		System.assert (testPagedResult3.recordsString != null);
    	}
    }
}