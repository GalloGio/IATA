@isTest
public with sharing class AccountDomainContactHandlerTest {

    /**
     * Attributes
     */
    public static List<Account> accountsWithoutId = new List<Account>();
    public static List<Account> accounts = new List<Account>();
    public static List<Contact> contactsWithoutId = new List<Contact>();
    public static List<Contact> contacts = new List<Contact>();
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

        // Create three account domains
        Account_Domain__c accountDomain1 = new Account_Domain__c(Name = 'test1.com');
        Account_Domain__c accountDomain2 = new Account_Domain__c(Name = 'test2.com');
        Account_Domain__c accountDomain3 = new Account_Domain__c(Name = 'test1.com');

        // Affect account domains to right accounts
        accountDomain1.Account__c = account1.Id;
        accountDomain2.Account__c = account1.Id;
        accountDomain3.Account__c = account2.Id;

        // Add them into linked attribute
        accountDomainsWithoutId.add(accountDomain1);
        accountDomainsWithoutId.add(accountDomain2);
        accountDomainsWithoutId.add(accountDomain3);

        // Persist out account domains
        insert accountDomainsWithoutId;

    }

    /**
     * Before insert test trigger
     */
    @isTest
    public static void beforeInsertTest() {

        // Prepare our data
        init();

        // Begin the test
        Test.startTest();

        // Create two new contacts
        Contact newContact1 = new Contact();
        newContact1.FirstName = 'Joel';
        newContact1.LastName = 'Chandler';
        newContact1.Email = 'joel.chandler@test1.com';
        newContact1.ValidContactDomainName__c = AccountDomainHandler.INVALID;
        Contact newContact2 = new Contact();
        newContact2.FirstName = 'Stephen';
        newContact2.LastName = 'Burton';
        newContact2.Email = 'stephen.burton@test2.com';
        newContact2.ValidContactDomainName__c = AccountDomainHandler.INVALID;

        // Affect them to the right accounts
        newContact1.AccountId = accounts.get(0).Id;
        newContact2.AccountId = accounts.get(1).Id;

        // Add them to our collection and persist them
        contacts.add(newContact1);
        contacts.add(newContact2);
        insert contacts;

        // Retrieve our contacts
        Contact contact1 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'joel.chandler@test1.com'];
        Contact contact2 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'stephen.burton@test2.com'];

        // Check that our data are correct
        System.assertEquals(AccountDomainHandler.VALID, contact1.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.INVALID, contact2.ValidContactDomainName__c);

        // Stop the test
        Test.stopTest();

    }

    /**
     * Before update test trigger
     */
    @isTest
    public static void beforeUpdateTest() {

        // Prepare our data
        init();

        // Create two new contacts
        Contact newContact1 = new Contact();
        newContact1.FirstName = 'Joel';
        newContact1.LastName = 'Chandler';
        newContact1.Email = 'joel.chandler@test2.com';
        newContact1.ValidContactDomainName__c = AccountDomainHandler.VALID;
        Contact newContact2 = new Contact();
        newContact2.FirstName = 'Stephen';
        newContact2.LastName = 'Burton';
        newContact2.Email = 'stephen.burton@test2.com';
        newContact2.ValidContactDomainName__c = AccountDomainHandler.INVALID;

        // Affect them to the right accounts
        newContact1.AccountId = accounts.get(0).Id;
        newContact2.AccountId = accounts.get(1).Id;

        // Add them to our collection and persist them
        contacts.add(newContact1);
        contacts.add(newContact2);
        insert contacts;

        // Begin the test
        Test.startTest();

        // Retrieve our contacts
        Contact contact1 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'joel.chandler@test2.com'];
        Contact contact2 = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'stephen.burton@test2.com'];

        // Change contact1 account
        contact1.AccountId = accounts.get(1).Id;

        // Chnage contact2 e-mail
        contact2.Email = 'stephen.burton@test1.com';

        // Persist those modification
        update contact1;
        update contact2;

        // Retrieve back our contacts
        Contact contact1Updated = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'joel.chandler@test2.com'];
        Contact contact2Updated = [SELECT ValidContactDomainName__c FROM Contact WHERE Email = 'stephen.burton@test1.com'];

        // Check that our data are correct
        System.assertEquals(AccountDomainHandler.INVALID, contact1Updated.ValidContactDomainName__c);
        System.assertEquals(AccountDomainHandler.VALID, contact2Updated.ValidContactDomainName__c);

        // Stop the test
        Test.stopTest();

    }

}