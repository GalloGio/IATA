/**
 * Created by pvavruska on 6/3/2019.
 */

@IsTest
public with sharing class PortalProfileCtrlTest {

    public static Account MyAirline;
    public static List<Account> Airlines;
    public static List<Contact> Contacts;
    public static User portalUser;

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

            Map<String, List<PortalProfileCtrl.FieldWrapper>> contactWrappers = PortalProfileCtrl.getFieldsMap('MyProfile');
            System.assert(!contactWrappers.isEmpty());

            Map<String, List<PortalProfileCtrl.FieldWrapper>> companyWrappers = PortalProfileCtrl.getFieldsMap('CompanyProfile');
            System.assert(!companyWrappers.isEmpty());

            Map<String, List<PortalProfileCtrl.FieldWrapper>> contactAccWrappers = PortalProfileCtrl.getFieldsMap('MyProfileAccFields');
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


            List<PortalProfileCtrl.ContactWrapper> contacts = PortalProfileCtrl.getAccountContacts(0);
            List<PortalProfileCtrl.ContactWrapper> searchResults = PortalProfileCtrl.searchAccountContacts('searchQuery',0);
            List<Account> branches = PortalProfileCtrl.getCompanyBranches(0);
            List<Account> searchBranches = PortalProfileCtrl.searchCompanyBranches('test',0);



            System.assert(!contacts.isEmpty());
            System.assert(!branches.isEmpty());
        }
    }

    //WMO-699 - ACAMBAS: Begin
    @IsTest
    static void testInvoiceTabInfo() {

        Account MyAgency = new Account(
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
                Name='MyAgency',
                SIS_ID__c='12345',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAgency;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = MyAgency.Id;
        con.Email='contact@MyAgency.com';
        insert con;

        portalUser = ISSP_ObjectFactory.createPortalUser(con);

        Customer_Invoice__c newInv = new Customer_Invoice__c(Invoice_ID__c = 'id-123', Billed_Member_Id__c = '12345',
                                                             Billing_Member_IS_Sub_Status__c = 'IATA OFFICE', Invoice_Status__c = 'Unpaid Invoice');
        insert newInv;

        System.runAs(portalUser) {
            Map<String, List<PortalProfileCtrl.FieldWrapper>> branchFields = PortalProfileCtrl.getInvoicesListFields(PortalProfileCtrl.IATA_INVOICE_TYPE);
            List<Customer_Invoice__c> invoices = PortalProfileCtrl.getCustomerInvoices();
            PortalProfileCtrl.isCountryEligibleForPaymentLink();

            System.assert(!invoices.isEmpty());
        }
    }
    //WMO-699 - ACAMBAS: End

}