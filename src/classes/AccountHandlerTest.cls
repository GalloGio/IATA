@isTest
private class AccountHandlerTest {

	private static Account acc1;
    private static Account acc2;
    private static Account acc1child;
    private static Account acc2child;
    private static List<Account> listAccount;


    private static void loadAccounts() {
        acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        acc2 = new Account(Name='testAccount2', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');

        list<Account> listAccount1 = new list<Account>();
        listAccount1.add(acc1);
        listAccount1.add(acc2);
        insert listAccount1;
		listAccount = listAccount1;

        acc1 = getAccount(acc1.id);
        acc2 = getAccount(acc2.id);
        
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);

        System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Formula__c);
    }

    private static void loadAccountHierarchy() {
        acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        acc2 = new Account(Name='testAccount2', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');

        list<Account> listAccount = new list<Account>();
        listAccount.add(acc1);
        listAccount.add(acc2);
        insert listAccount;

        acc1child = new Account(Name='testAccount1 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO', ParentId = acc1.Id);
        acc2child = new Account(Name='testAccount2 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO', ParentId = acc2.Id);

        listAccount = new list<Account>();
        listAccount.add(acc1child);
        listAccount.add(acc2child);
        insert listAccount;

        acc1 = getAccount(acc1.id);
        acc2 = getAccount(acc2.id);
        acc1child = getAccount(acc1child.id);
        acc2child = getAccount(acc2child.id);		
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);

        System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Formula__c);

        System.assertEquals(false, acc1child.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal_Formula__c);

        System.assertEquals(false, acc2child.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc2child.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc2child.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc2child.Has_an_Administrator_User_Portal_Formula__c);
    }

    private static Account getAccount(Id accountId) {
        return [Select Id, Name, ParentId,
				Has_an_Administrator_User_Portal_Formula__c, Has_an_Administrator_User_Portal_Sum__c, Has_an_Administrator_User_Portal__c,
				Has_a_Financial_Assessment_Contact_Formu__c, Has_a_Financial_Assessment_Contact_Sum__c, Has_a_Financial_Assessment_Contact__c
            from Account
            where id = :accountId];
    }

	@isTest
	private static void testInsertAccount() {
		loadAccounts();
		acc1child = new Account(Name='testAccount1 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO', ParentId = acc1.Id);

		Test.startTest();
		insert acc1child;
		Test.stopTest();

		acc1 = getAccount(acc1.Id);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);

		acc1child = getAccount(acc1child.Id);
		System.assertEquals(false, acc1child.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1child.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1child.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal__c);
		System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal_Formula__c);  
		System.enqueueJob(new AsyncDML_Util(listAccount, AsyncDML_Util.DML_INSERT, false));       
	}

	@isTest
	private static void testUpdateAccount() {
		loadAccounts();
		acc1child = new Account(Name='testAccount1 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
		insert acc1child;

		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1child.Id,
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert contact;

		Test.startTest();
		acc1child.ParentId = acc1.Id;
		update acc1child;
		Test.stopTest();

		acc1 = getAccount(acc1.Id);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
		System.assertEquals(true, acc1.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(true, acc1.Has_an_Administrator_User_Portal_Formula__c);

		acc1child = getAccount(acc1child.Id);
		System.assertEquals(true, acc1child.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1child.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(true, acc1child.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(true, acc1child.Has_an_Administrator_User_Portal__c);
		System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(true, acc1child.Has_an_Administrator_User_Portal_Formula__c);
		System.enqueueJob(new AsyncDML_Util(listAccount, AsyncDML_Util.DML_UPDATE, false));
        System.enqueueJob(new AsyncDML_Util(listAccount, AsyncDML_Util.DML_UPSERT, false));
        
	}

	@isTest
	private static void testDeleteAccount() {
		loadAccounts();
		acc1child = new Account(Name='testAccount1 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO', ParentId = acc1.Id);
		insert acc1child;

		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1child.Id,
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert contact;

		Test.startTest();
		delete acc1child;
		Test.stopTest();

		acc1 = getAccount(acc1.Id);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
		System.enqueueJob(new AsyncDML_Util(listAccount, AsyncDML_Util.DML_DELETE, false));
	}

	@isTest
	private static void testUndeleteAccount() {
		loadAccounts();
		acc1child = new Account(Name='testAccount1 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO', ParentId = acc1.Id);
		insert acc1child;

		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1child.Id,
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert contact;
		delete acc1child;

		Test.startTest();
		undelete acc1child;
		Test.stopTest();

		acc1 = getAccount(acc1.Id);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
		System.assertEquals(true, acc1.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(true, acc1.Has_an_Administrator_User_Portal_Formula__c);

		acc1child = getAccount(acc1child.Id);
		System.assertEquals(true, acc1child.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1child.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(true, acc1child.Has_a_Financial_Assessment_Contact_Formu__c);
		System.assertEquals(true, acc1child.Has_an_Administrator_User_Portal__c);
		System.assertEquals(false, acc1child.Has_an_Administrator_User_Portal_Sum__c);
		System.assertEquals(true, acc1child.Has_an_Administrator_User_Portal_Formula__c);		
        System.enqueueJob(new AsyncDML_Util(listAccount, AsyncDML_Util.DML_UNDELETE, false));
	}

}