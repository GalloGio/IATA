@isTest
private class ContactHandlerTest {

	private static Account acc1;
    private static Account acc2;
    private static Account acc1child;
    private static Account acc2child;

    private static void loadAccounts() {
        acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        acc2 = new Account(Name='testAccount2', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');

        list<Account> listAccount = new list<Account>();
        listAccount.add(acc1);
        listAccount.add(acc2);
        insert listAccount;

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

	private static Account getAccount(Id accountId) {
        return [Select Id, Name, ParentId,
				Has_an_Administrator_User_Portal_Formula__c, Has_an_Administrator_User_Portal_Sum__c, Has_an_Administrator_User_Portal__c,
				Has_a_Financial_Assessment_Contact_Formu__c, Has_a_Financial_Assessment_Contact_Sum__c, Has_a_Financial_Assessment_Contact__c
            from Account
            where id = :accountId];
    }

	@isTest
    private static void testHasFinancialAssessment1() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Financial_Assessment_Contact__c = false);

        Test.startTest();
        insert contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasFinancialAssessment2() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Financial_Assessment_Contact__c = true);

        Test.startTest();
        insert contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasFinancialAssessment3() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Financial_Assessment_Contact__c = true);
        insert contact;

        Test.startTest();
        contact.Financial_Assessment_Contact__c = false;
        update contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasFinancialAssessment4() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Financial_Assessment_Contact__c = true);
        insert contact;

        Test.startTest();
        contact.AccountId = acc2.Id;
        update contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
        acc2 = getAccount(acc2.Id);
        System.assertEquals(true, acc2.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(true, acc2.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasAdmin1() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Active');

        Test.startTest();
        insert contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasAdmin2() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved Admin');

        Test.startTest();
        insert contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(true, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(true, acc1.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasAdmin3() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved Admin');
        insert contact;

        Test.startTest();
        contact.User_Portal_Status__c = 'Active';
        contact.Community__c = 'ISS Customer Portal';
        update contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);
    }

    @isTest
    private static void testHasAdmin4() {
        loadAccounts();
        Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved Admin');
        insert contact;

        Test.startTest();
        contact.AccountId = acc2.Id;
        update contact;
        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(false, acc1.Has_an_Administrator_User_Portal_Formula__c);

        acc2 = getAccount(acc2.Id);
        System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Sum__c);
		System.assertEquals(false, acc2.Has_a_Financial_Assessment_Contact_Formu__c);
        System.assertEquals(true, acc2.Has_an_Administrator_User_Portal__c);
        System.assertEquals(false, acc2.Has_an_Administrator_User_Portal_Sum__c);
        System.assertEquals(true, acc2.Has_an_Administrator_User_Portal_Formula__c);
    }

	@isTest
	private static void testDeleteContact() {
		loadAccounts();
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id,
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert contact;

		acc1 = getAccount(acc1.Id);
		System.assertEquals(true, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(true, acc1.Has_an_Administrator_User_Portal__c);

		Test.startTest();
		delete contact;
		Test.stopTest();

		acc1 = getAccount(acc1.Id);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);
	}

	@isTest
	private static void testUndeleteContact() {
		loadAccounts();
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id,
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert contact;
		delete contact;

		acc1 = getAccount(acc1.Id);
		System.assertEquals(false, acc1.Has_a_Financial_Assessment_Contact__c);
		System.assertEquals(false, acc1.Has_an_Administrator_User_Portal__c);

		Test.startTest();
        try {
            undelete contact;
        } catch(Exception e){}
		
		Test.stopTest();
	}

}