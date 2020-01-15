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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Membership_Function__c = 'Cargo', Financial_Assessment_Contact__c = false);

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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Membership_Function__c = 'Cargo', User_Portal_Status__c = 'Approved User', Financial_Assessment_Contact__c = true);

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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Membership_Function__c = 'Cargo', User_Portal_Status__c = 'Approved User', Financial_Assessment_Contact__c = true);
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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, Membership_Function__c = 'Cargo', User_Portal_Status__c = 'Approved User', Financial_Assessment_Contact__c = true);
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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved User', Membership_Function__c = 'Cargo');

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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved Admin', Membership_Function__c = 'Cargo');

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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved Admin', Membership_Function__c = 'Cargo');
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
		Contact contact = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id, User_Portal_Status__c = 'Approved Admin', Membership_Function__c = 'Cargo');
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
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin', Membership_Function__c = 'Cargo');
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

	@isTest
	private static void testGrantAccessToPortalAppsOnInsert() {
		Account airline  = new Account(Name='testAirline', Sector__c = 'Airline');
		insert airline;

		Portal_Application_Contact_Visibility__mdt visibility = [
				SELECT Id, Checkbox_Fieldname__c, Parent__r.MasterLabel
				FROM Portal_Application_Contact_Visibility__mdt
				WHERE Add_Service_On_Checked__c = true
				AND Parent__r.MasterLabel='Management Information Report'
				LIMIT 1];
		System.assert(visibility!=null);
		System.assert(visibility.Checkbox_Fieldname__c!=null);
		System.assert(visibility.Parent__r.MasterLabel!=null);

		// create app
		Portal_Applications__c app = new Portal_Applications__c(
			Name=visibility.Parent__r.MasterLabel
		);
		insert app;

		Test.startTest();
		Contact contact = new Contact(
			FirstName = 'fname',
			LastName = 'lname',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin'
		);
		contact.put(visibility.Checkbox_Fieldname__c,true);
		insert contact;
		Test.stopTest();

		Contact result = [
			SELECT Id,
				(SELECT Id FROM Portal_Application_Rights__r
				WHERE Portal_Application__c = :app.Id
				AND Right__c = 'Access Granted')
			FROM Contact
			WHERE Id = :contact.Id
		];
		System.assertEquals(1,result.Portal_Application_Rights__r.size());
	}

	@isTest
	private static void testallowOnlyOneDistributionRiskLeader_Insert1() {
		Account airline  = new Account(Name='testAirline', Sector__c = 'Airline');
		insert airline;

		Contact contact1 = new Contact(
			FirstName = 'fname',
			LastName = 'lname',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin',
			Airline_Credit_Risk_Manager__c = true
		);

		Contact contact2 = new Contact(
			FirstName = 'fname2',
			LastName = 'lname2',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin',
			Airline_Credit_Risk_Manager__c = true
		);

		Test.startTest();
		insert contact1;
		try {
			insert contact2;
			System.assert(false,'Exception expected');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	private static void testallowOnlyOneDistributionRiskLeader_Insert2() {
		Account airline  = new Account(Name='testAirline', Sector__c = 'Airline');
		insert airline;

		Contact contact1 = new Contact(
			FirstName = 'fname',
			LastName = 'lname',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin',
			Airline_Credit_Risk_Manager__c = true
		);

		Contact contact2 = new Contact(
			FirstName = 'fname2',
			LastName = 'lname2',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin',
			Airline_Credit_Risk_Manager__c = true
		);

		Test.startTest();
		try {
			insert new list<Contact>{contact1,contact2};
			System.assert(false,'Exception expected');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	private static void testallowOnlyOneDistributionRiskLeader_Update() {
		Account airline  = new Account(Name='testAirline', Sector__c = 'Airline');
		insert airline;

		Contact contact1 = new Contact(
			FirstName = 'fname',
			LastName = 'lname',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin',
			Airline_Credit_Risk_Manager__c = true
		);

		Contact contact2 = new Contact(
			FirstName = 'fname2',
			LastName = 'lname2',
			AccountId = airline.Id,
			Membership_Function__c = 'Cargo',
			User_Portal_Status__c = 'Approved Admin',
			Airline_Credit_Risk_Manager__c = true
		);

		Test.startTest();
		insert contact1;
		try {
			upsert new list<Contact>{contact1,contact2};
			System.assert(false,'Exception expected');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}
}
