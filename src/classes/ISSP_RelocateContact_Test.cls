@isTest
private class ISSP_RelocateContact_Test {

    static testMethod void testController_NoContact() {
        Test.StartTest();
        ISSP_RelocateContact ctrl = new ISSP_RelocateContact(null);
        PageReference pageref = ctrl.initAction();
        Test.StopTest();
        System.assert(pageref!=null,'redirection page expected');
    }

    static testMethod void testController_ValidContact_NoAccountHierarchy() {
        Account account = new Account(Name='test');
        insert account;
        
        Contact contact = new Contact(
            Salutation = 'Mr.',
            FirstName= 'first',
            LastName= 'last',
            AccountId = account.id);
        insert contact;

        ApexPages.StandardController stdController = new ApexPages.StandardController(contact);
        Apexpages.currentPage().getParameters().put('id', contact.Id);
        
        Test.StartTest();
        ISSP_RelocateContact ctrl = new ISSP_RelocateContact(stdController);
        PageReference pageref = ctrl.initAction();
        Boolean result = ctrl.getIsMapAccountsEmpty();
        ctrl.selectedAccountId = contact.Id;
        ctrl.RelocateContact();
        ctrl.getReturnPage();
        Test.StopTest();
        
        System.assert(pageref==null,'no redirection expected');
        System.assert(result,'map account must be empty');
    }

    static testMethod void testControllerValidRelocation() {
        Account account1 = new Account(Name='test1', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_HQ);
        insert account1;
        Account account2 = new Account(Name='test2', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_BR, ParentId=account1.Id);
        insert account2;
        
        Contact contact = new Contact(
            Salutation = 'Mr.',
            FirstName= 'first',
            LastName= 'last',
            AccountId = account1.id);
        insert contact;

        ApexPages.StandardController stdController = new ApexPages.StandardController(contact);
        Apexpages.currentPage().getParameters().put('id', contact.Id);
        
        Test.StartTest();
        ISSP_RelocateContact ctrl = new ISSP_RelocateContact(stdController);
        ctrl.initAction();
        System.assert(ctrl.getIsMapAccountsEmpty()==false,'map account must be filled');
        ctrl.selectedAccountId = account2.id;
        ctrl.selectAccount();
        ctrl.getListOptionAccount();
        ctrl.RelocateContact();
        Test.StopTest();
        
        contact = [SELECT AccountId FROM Contact WHERE id=:contact.Id];
        System.assert(contact.AccountId==account2.Id,'account relocation failed');
    }
    
    static testMethod void testControllerValidRelocation_Exception() {
        Account account1 = new Account(Name='test1', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_HQ);
        insert account1;
        Account account2 = new Account(Name='test2', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_BR, ParentId=account1.Id);
        insert account2;
        
        Contact contact = new Contact(
            Salutation = 'Mr.',
            FirstName= 'first',
            LastName= 'last',
            AccountId = account1.id);
        insert contact;

        ApexPages.StandardController stdController = new ApexPages.StandardController(contact);
        Apexpages.currentPage().getParameters().put('id', contact.Id);
        
        Test.StartTest();
        ISSP_RelocateContact ctrl = new ISSP_RelocateContact(stdController);
        ctrl.initAction();
        ctrl.contact = null;
        ctrl.RelocateContact();
        Test.StopTest();
    }
    
    static testMethod void testController_testHierarchy() {
        Account account1 = new Account(Name='test1', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_HQ);
        insert account1;
        
        Contact contact = new Contact(
            Salutation = 'Mr.',
            FirstName= 'first',
            LastName= 'last',
            AccountId = account1.id);
        insert contact;

        ApexPages.StandardController stdController = new ApexPages.StandardController(contact);
        Apexpages.currentPage().getParameters().put('id', contact.Id);
        ISSP_RelocateContact ctrl = new ISSP_RelocateContact(stdController);
        
        Test.StartTest();
        ctrl.getMapHierarchyAccounts(account1.id);
        Account account2 = new Account(Name='test2', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_BR, ParentId=account1.Id);
        insert account2;
        ctrl.getMapHierarchyAccounts(account2.id);
        Account account3 = new Account(Name='test3', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_BR, ParentId=account2.Id);
        insert account3;
        ctrl.getMapHierarchyAccounts(account3.id);
        Account account4 = new Account(Name='test4', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_BR, ParentId=account3.Id);
        insert account4;
        ctrl.getMapHierarchyAccounts(account4.id);
        Account account5 = new Account(Name='test5', RecordTypeId=ISSP_RelocateContact.RECORDTYPE_AIRLINE_BR, ParentId=account4.Id);
        insert account5;
        ctrl.getMapHierarchyAccounts(account5.id);
        Test.StopTest();
    }
}