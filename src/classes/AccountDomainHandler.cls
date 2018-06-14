public without sharing class AccountDomainHandler {

    /**
     * Constants for e-mail patterns and validity
     */
     public static final Pattern PATTERN_INACTIVE_EMAIL = pattern.compile('^(.*)(.inactive([0-9])*)$');
     public static final String PATTERN_SPLIT_EMAIL_DOMAIN = '@';
     public static final String EMPTY_STRING = null;
     public static final String VALID = 'valid';
     public static final String INVALID = 'invalid';

    /**
     * After insert part
     */
    public static void afterInsert(List<Account_Domain__c> newTrigger) {
        checkContactsEmail(newTrigger);
    }

    /**
     * After delete part
     */
    public static void afterUpdate(List<Account_Domain__c> oldTrigger) {
        checkContactsEmail(oldTrigger);
    }

    /**
        Finds all Account domains for related contacts and updates the contact field ValidContactDomainName__c
    **/
    private static void checkContactsEmail(List<Account_Domain__c> accountDomains) {
        // First extract all related accounts to the input Account Domains
        List<Id> listAccountIds = new List<Id>();
        for(Account_Domain__c accountDomain : accountDomains) {
            listAccountIds.add(accountDomain.Account__c);
        }

        // Find all contacts related to any of the input contacts plus their hierarchy
        List<Contact> listContact = [
            SELECT Id, Email, AccountId, ValidContactDomainName__c
            FROM Contact
            WHERE AccountId IN :listAccountIds
            OR Account.ParentId IN :listAccountIds
            OR Account.Parent.ParentId IN :listAccountIds
            OR Account.Parent.Parent.ParentId IN :listAccountIds
            OR Account.Parent.Parent.Parent.ParentId IN :listAccountIds
            OR Account.Parent.Parent.Parent.Parent.ParentId IN :listAccountIds];

        // Finally we have a list of contact ready to be updated
        updateValidDomainNameField(listContact);

        Integer max_limit = 200;
        if (listContact.size() < max_limit) {
            Database.update(listContact,false);
        } else {
            BatchUpdate.run(listContact, max_limit);
        }
    }

    /**
        Updates field ValidContactDomainName__c for all input contacts
    **/
    public static void updateValidDomainNameField(list<Contact> listContact) {
        // get all related account Ids
        List<Id> listAccountIds = new List<Id>();
        for(Contact contact : listContact) {
            listAccountIds.add(contact.AccountId);
        }

        map<Id,list<Id>> mapTopAccount = AccountDomainHandler.getMaxParentAccounts(listAccountIds);
        // if the map is empty nothing to do
        if (mapTopAccount.isEmpty()) return;

        // create a map with accounts telated to its top Parent Account(including their Account domains)
        Map<Id,Account> mapAccount = new map<Id,Account>();
        for (Account topAccount: [
                Select Id, (SELECT Name FROM Account_Domains__r)
                FROM Account
                WHERE id IN :mapTopAccount.keyset()]) {
            list<Id> listChildId = mapTopAccount.get(topAccount.Id);
            for (Id childId: listChildId) {
                mapAccount.put(childId,topAccount);
            }
        }
        // Get all contacts that are linked with those account IDs
        for(Contact contact : listContact) {
            Account account = mapAccount.get(contact.AccountId);
            list<Account_Domain__c> listAccountDomain = account==null? null: account.Account_Domains__r;
            contact.ValidContactDomainName__c = checkEmailValidity(contact, listAccountDomain);
        }
    }

    /**
        compares given input contact email with input account Domains
        If the email is not defined the return an empty string
        Otherwise it will return Valid or Invalid if the email matches with any of the input Account Domains
    **/
    private static String checkEmailValidity(Contact contact, list<Account_Domain__c> listAccountDomain) {
        // Some pattern that can return a "blank" validity
        if(contact.Email == '' || contact.Email == null  || listAccountDomain == null || listAccountDomain.isEmpty() || PATTERN_INACTIVE_EMAIL.matcher(contact.Email).matches()) {
            return EMPTY_STRING;
        }

        // Retrieve only the domain part from e-mail field
        String[] emailSplited = contact.Email.split(PATTERN_SPLIT_EMAIL_DOMAIN);
        String domainEmail = emailSplited[1];
        // Check if accountDomainsCom contains this domain
        for (Account_Domain__c accountDomain: listAccountDomain) {
            if (accountDomain.Name == domainEmail) {
                return VALID;
            }
        }
        return INVALID;
    }

    /**
        Returns all linked account domains to input account
        Domain Names are always linked to the top account in the hierarchy
    **/
    public static list<Account_Domain__c> getAccountDomains(Id accountId) {
        Id topAccountId = getMaxParentAccount(accountId);
        List<Account_Domain__c> listAccountDomains = [SELECT Id, Name, CreatedDate FROM Account_Domain__c WHERE Account__c = :topAccountId];
        return listAccountDomains;
    }

    /**
        Insert a domain name as a valid Account_Domain__c object to an acount
    **/
    public static void insertAccountDomain(String accountDomainName, Id accountId) {
        Id topAccountId = getMaxParentAccount(accountId);
        Account_Domain__c newAccountDomain = new Account_Domain__c(
            Name = accountDomainName,
            Account__c = topAccountId
        );
        insert newAccountDomain;
    }

    /**
        Delete a domain name
    **/
    public static void deleteAccountDomain(Id accountDomainId) {
        Account_Domain__c delAccountDomain = [SELECT Id FROM Account_Domain__c WHERE Id = :accountDomainId];
        delete delAccountDomain ;
    }

    /**
        Find Headquart account (parent top account in the hierarchy)
        For a single account
    **/
    private static Id getMaxParentAccount(Id accountId) {
        map<Id,list<Id>> mapParentAccounts = getMaxParentAccounts(new List<Id>{accountId});
        for (Id key: mapParentAccounts.keyset()) {
            return key;
        }
        return accountId;
    }

    /**
        Find Headquart account (parent top account in the hierarchy)
        For a list of accounts
    **/
    private static map<Id,list<Id>> getMaxParentAccounts(list<Id> listAccountIds) {
        map<Id,list<Id>> mapParentAccounts = new map<Id,list<Id>>();
        if (listAccountIds.isEmpty()) return mapParentAccounts;

        list<Account> listAccount = [
            Select id, Name,
                ParentId,
                Parent.ParentId,
                Parent.Parent.ParentId,
                Parent.Parent.Parent.ParentId,
                Parent.Parent.Parent.Parent.ParentId
            From Account
            Where id in :listAccountIds ];

        for (Account account: listAccount) {
            Id parentId = null;
            if (account.ParentId == null ) {
                parentId = account.Id;
            } else if (account.Parent.ParentId == null ) {
                parentId = account.ParentId;
            } else if (account.Parent.Parent.ParentId == null ) {
                parentId = account.Parent.ParentId;
            } else if (account.Parent.Parent.Parent.ParentId == null ) {
                parentId = account.Parent.Parent.ParentId;
            } else if (account.Parent.Parent.Parent.Parent.ParentId == null ) {
                parentId = account.Parent.Parent.Parent.ParentId;
            } else {
                parentId = account.Parent.Parent.Parent.Parent.ParentId;
            }
            list<Id> value = mapParentAccounts.get(parentId);
            if (value == null ) {
                value = new list<Id>();
            }
            value.add(account.Id);
            mapParentAccounts.put(parentId, value);
        }
        return mapParentAccounts;
    }

}
