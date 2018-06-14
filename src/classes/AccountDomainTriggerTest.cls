@isTest
public with sharing class AccountDomainTriggerTest {

    /**
     * Attributes
     */
    public static List<Account> accountsWithoutId = new List<Account>();
    public static List<Account> accounts = new List<Account>();
    public static List<Contact> contactsWithoutId = new List<Contact>();
    public static List<Account_Domain__c> accountDomainsWithoutId = new List<Account_Domain__c>();

    /**
     * Prepare data for our tests
     */
    public static void init() {

        // Create two accounts and persist them
        Account account1 = new Account(Name = 'AccountTest1');
        Account account2 = new Account(Name = 'AccountTest2');
        accountsWithoutId.add(account1);
        accountsWithoutId.add(account2);
        insert accountsWithoutId;

        // Retrieve back those accounts (with IDs now) and update linked attribute
        account1 = [SELECT Id, Name FROM Account WHERE Name = 'AccountTest1'];
        account2 = [SELECT Id, Name FROM Account WHERE Name = 'AccountTest2'];
        accounts.add(account1);
        accounts.add(account2);

        // Create three contacts
        Contact contact1 = new Contact();
        contact1.FirstName = 'Tracy';
        contact1.LastName = 'Becker';
        contact1.Email = 'tracy.becker@test1.com';
        contact1.ValidContactDomainName__c = '';
        Contact contact2 = new Contact();
        contact2.FirstName = 'Ellen';
        contact2.LastName = 'Rhodes';
        contact2.Email = 'ellen.rhodes@test2.com';
        contact2.ValidContactDomainName__c = '';
        Contact contact3 = new Contact();
        contact3.FirstName = 'Ginger';
        contact3.LastName = 'Hampton';
        contact3.Email = 'ginger.hampton@test2.com';
        contact3.ValidContactDomainName__c = '';
        Contact contact4 = new Contact();
        contact4.FirstName = 'Erin';
        contact4.LastName = 'Hayes';
        contact4.Email = 'erin.hayesn@test1.com.invalid4';
        contact4.ValidContactDomainName__c = '';

        // Affect contacts to right accounts
        contact1.AccountId = account1.Id;
        contact2.AccountId = account1.Id;
        contact3.AccountId = account2.Id;
        contact4.AccountId = account2.Id;

        // For our contacts, update linked attribute and persist it
        contactsWithoutId.add(contact1);
        contactsWithoutId.add(contact2);
        contactsWithoutId.add(contact3);
        contactsWithoutId.add(contact4);
        insert contactsWithoutId;

    }

    /**
     * After insert test trigger
     */
    @isTest
    public static void afterInsertTest() {

        // Prepare our data
        init();

        // Create three account domains
        Account_Domain__c accountDomain1 = new Account_Domain__c(Name = 'test1.com');
        Account_Domain__c accountDomain2 = new Account_Domain__c(Name = 'test2.com');
        Account_Domain__c accountDomain3 = new Account_Domain__c(Name = 'test1.com');

        // Affect account domains to right accounts
        accountDomain1.Account__c = accounts.get(0).Id;
        accountDomain2.Account__c = accounts.get(0).Id;
        accountDomain3.Account__c = accounts.get(1).Id;

        // Add them into linked attribute
        accountDomainsWithoutId.add(accountDomain1);
        accountDomainsWithoutId.add(accountDomain2);
        accountDomainsWithoutId.add(accountDomain3);

        // Begin the test
        Test.startTest();

        // Persist our new account domains
        insert accountDomainsWithoutId;

        // Stop the test
        Test.stopTest();

        // Retrieve our contacts
        Contact contact1 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'tracy.becker@test1.com'];
        Contact contact2 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'ellen.rhodes@test2.com'];
        Contact contact3 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'ginger.hampton@test2.com'];
        Contact contact4 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'erin.hayesn@test1.com.invalid4'];

        // Check that our data are correct
        System.assertEquals(AccountDomainHandler.VALID, contact1.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.VALID, contact2.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.INVALID, contact3.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.INVALID, contact4.ValidContactDomainName__c);

    }

    /**
     * After insert test trigger
     */
    @isTest
    public static void afterDeleteTest() {

        // Prepare our data
        init();

        // Create three account domains
        Account_Domain__c accountDomain1 = new Account_Domain__c(Name = 'test1.com');
        Account_Domain__c accountDomain2 = new Account_Domain__c(Name = 'test2.com');
        Account_Domain__c accountDomain3 = new Account_Domain__c(Name = 'test1.com');

        // Affect account domains to right accounts
        accountDomain1.Account__c = accounts.get(0).Id;
        accountDomain2.Account__c = accounts.get(0).Id;
        accountDomain3.Account__c = accounts.get(1).Id;

        // Add them into linked attribute
        accountDomainsWithoutId.add(accountDomain1);
        accountDomainsWithoutId.add(accountDomain2);
        accountDomainsWithoutId.add(accountDomain3);

        // Persist our account domains
        insert accountDomainsWithoutId;

        // Retrieve all account domains created just before
        List<Account_Domain__c> test123 = [SELECT Id FROM Account_Domain__c WHERE Name = 'test1.com' OR Name = 'test2.com'];

        // Begin the test
        Test.startTest();

        // Delete them all
        delete test123;

        // Stop the test
        Test.stopTest();

        // Retrieve our contacts
        Contact contact1 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'tracy.becker@test1.com'];
        Contact contact2 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'ellen.rhodes@test2.com'];
        Contact contact3 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'ginger.hampton@test2.com'];
        Contact contact4 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'erin.hayesn@test1.com.invalid4'];

        // Check that our data are correct
        System.assertEquals(AccountDomainHandler.EMPTY_STRING, contact1.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.EMPTY_STRING, contact2.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.EMPTY_STRING, contact3.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.EMPTY_STRING, contact4.ValidContactDomainName__c);

    }

}
