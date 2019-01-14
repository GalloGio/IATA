@isTest
public with sharing class ISSP_CompanyInformationEmaDomValTest {

    public static void init() {

        // Create two accounts and persist them
        Account account1 = new Account(Name = 'AccountTest1');
        insert account1;

        // create AccountDomains
        Account_Domain__c accDomain = new Account_Domain__c();
        accDomain.Name = 'test.com';
        accDomain.Account__c = account1.Id;
        insert accDomain;

        // Create three contacts
        Contact contact1 = new Contact();
        contact1.FirstName = 'Tracy';
        contact1.LastName = 'Becker';
        contact1.Email = 'tracy.becker@test1.com';
        contact1.ValidContactDomainName__c = '';
        contact1.AccountId = account1.Id;
        insert contact1;

        Contact contact2 = new Contact();
        contact2.FirstName = 'Ellen';
        contact2.LastName = 'Rhodes';
        contact2.Email = 'ellen.rhodes@test2.com';
        contact2.ValidContactDomainName__c = '';
        contact2.AccountId = account1.Id;
        insert contact2;
    }

    @isTest
    public static void testController() {

        Test.StartTest();
        ISSP_CompanyInformationEmaDomVal controller = new ISSP_CompanyInformationEmaDomVal();
        controller.getemaDomValUrlNew();
        controller.getemaDomValUrlDel();
        controller.goBackToCompanyInformation();
        system.assertEquals(true, controller.checkPermission()!=null);
        Test.StopTest();
    }

    @isTest
    public static void testGetDomains() {

        init();
        ISSP_CompanyInformationEmaDomVal controller = new ISSP_CompanyInformationEmaDomVal();
        controller.con = [Select Id, Name, AccountId from Contact Where Email = 'tracy.becker@test1.com'];

        Test.StartTest();
        List<Account_Domain__c> listAccDomain = controller.validEmailDomains;
        system.assertEquals(true, listAccDomain!=null);
        system.assertEquals(1, listAccDomain.size());
        Test.StopTest();
    }

    @isTest
    public static void testSetDomains() {

        init();
        Contact con = [Select Id, Name, AccountId  from Contact Where Email = 'tracy.becker@test1.com'];

        Test.StartTest();
        ISSP_CompanyInformationEmaDomVal.setAccountDomain('test2.com',con.AccountId);
        Test.StopTest();

        Account_Domain__c accDomain = [Select Id from Account_Domain__c where Name = 'test2.com' and Account__c = :con.AccountId];
        system.assert(accDomain!=null);
    }

    @isTest
    public static void testDeleteDomains() {

        init();
        Contact con = [Select Id, Name, AccountId  from Contact Where Email = 'tracy.becker@test1.com'];

        Account_Domain__c accDomain = [Select Id from Account_Domain__c limit 1];
        Id accDomainId = accDomain.Id;

        Test.StartTest();
        ISSP_CompanyInformationEmaDomVal.deleteAccountDomain(accDomainId);
        Test.StopTest();

        list<Account_Domain__c> listAccDomain = [Select Id from Account_Domain__c where id = :accDomainId];
        system.assert(listAccDomain.isEmpty());
    }


}
