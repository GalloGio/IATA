@istest
private class ISSP_Ctrl_AccountStatementsTest {

	private static final Id RT_STATEMENT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Statement__c', 'ICE_Balance') ;
	private static final Id RT_TRANSACTION = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Statement_Transaction__c', 'ICE_Balance') ;

	private static User testUser;
	private static Contact contact;
	private static Account account;

	@testSetup
	private static void setup() {
		testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
		Portal_Applications__c app = ISSP_Ctrl_AccountStatements_AcceptTest.createAccountStatementApp(testUser);
		Portal_Application_Right__c appRight = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];

		Account account = [Select Id, Status__c from Account limit 1];
		account.Status__c = 'Approved';
		update account;

		Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id = :testUser.ContactId];
		contact.AccountId = account.Id;
		update contact;

		list<Account_Statement__c> listAccountStatements = new list<Account_Statement__c>();
		listAccountStatements.add(
			new Account_Statement__c(
				RecordTypeId = RT_STATEMENT,
				Remittance_Date__c = Date.today(),
				Group__c = 'group01',
				Period__c = 'period01',
				Operation__c = 'Operation01',
				Key__c = '010101',
				Paid__c = 100,
				Billing_Amount__c = 100,
				Amount_to_be_Paid__c = 0,
				Balance__c = 0,
				Account__c = account.Id,
				CurrencyIsoCode = 'EUR'));
		listAccountStatements.add(
			new Account_Statement__c(
				RecordTypeId = RT_STATEMENT,
				Remittance_Date__c = Date.today().addMonths(-1),
				Group__c = 'group02',
				Period__c = 'period02',
				Operation__c = 'Operation02',
				Key__c = '020202',
				Paid__c = 0,
				Billing_Amount__c = 100,
				Amount_to_be_Paid__c = 100,
				Balance__c = 100,
				Account__c = account.Id,
				CurrencyIsoCode = 'USD'));
		listAccountStatements.add(
			new Account_Statement__c(
				RecordTypeId = RT_STATEMENT,
				Remittance_Date__c = Date.today().addMonths(1),
				Group__c = 'group03',
				Period__c = 'period03',
				Operation__c = 'Operation03',
				Key__c = '030303',
				Paid__c = 50,
				Billing_Amount__c = 100,
				Amount_to_be_Paid__c = 50,
				Balance__c = 50,
				Account__c = account.Id,
				CurrencyIsoCode = 'USD'));
		insert listAccountStatements;

		list<Account_Statement_Transaction__c> listTransactions = new list<Account_Statement_Transaction__c>();
		listTransactions.add(
			new Account_Statement_Transaction__c(
				RecordTypeId = RT_TRANSACTION,
				Transaction_Id__c = '111',
				Parent__c = listAccountStatements.get(0).Id,
				Amount__c = 1000,
				Transaction_Type__c = 'Automatic Match',
				Value_Date__c = Date.today(),
				Details__c = 'detail1'
			)
		);
		listTransactions.add(
			new Account_Statement_Transaction__c(
				RecordTypeId = RT_TRANSACTION,
				Transaction_Id__c = '222',
				Parent__c = listAccountStatements.get(1).Id,
				Amount__c = 2000,
				Transaction_Type__c = 'Clawback',
				Value_Date__c = Date.today(),
				Details__c = 'detail2'
			)
		);
		listTransactions.add(
			new Account_Statement_Transaction__c(
				RecordTypeId = RT_TRANSACTION,
				Transaction_Id__c = '333',
				Parent__c = listAccountStatements.get(2).Id,
				Amount__c = 3000,
				Transaction_Type__c = 'Compensation',
				Value_Date__c = Date.today(),
				Details__c = 'detail3'
			)
		);
		insert listTransactions;
	}

	static void loadVariables() {
		testUser = [
			SELECT Id, ContactId, Contact.AccountId, Contact.Account.Status__c
			FROM User
			ORDER BY CreatedDate DESC LIMIT 1 ];
		contact = testUser.Contact;
		account = contact.Account;
	}

	@istest
	static void test_controller_AccountNotApproved() {
		loadVariables();

		account.Status__c = 'Inactive';
		update account;

		Portal_Applications__c app = ISSP_Ctrl_AccountStatements_AcceptTest.createAccountStatementApp(testUser);
		Portal_Application_Right__c appRight = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];

		Test.startTest();
		System.runAs(testUser) {
			ISSP_Ctrl_AccountStatements controller = new ISSP_Ctrl_AccountStatements();
			System.AssertEquals(1, controller.listMessages.size());
		}
		Test.stopTest();
	}

	@istest
	static void test_controller() {
		loadVariables();

		ISSP_Ctrl_AccountStatements controller;
		Test.startTest();
		System.runAs(testUser) {
			controller = new ISSP_Ctrl_AccountStatements();
			System.Assert(controller.initActions().getUrl().contains('ISSP_AccountStatement_Accept'), 'url fail: ' + controller.initActions().getUrl());
			System.AssertEquals(0, controller.listMessages.size());
			System.Assert(controller.getInstance()>'');
			System.AssertEquals(null,controller.updateAppRight());
			System.AssertEquals(false,controller.mapCurrencyFormat.isEmpty());

			//provoke an error
			controller.currentUser = new User();
			System.Assert(controller.initActions()!=null);
		}
		Test.stopTest();
	}

	@istest
	static void test_checkTermsAndConditions() {
		loadVariables();

		ISSP_Ctrl_AccountStatements controller;
		System.runAs(testUser) {
			controller = new ISSP_Ctrl_AccountStatements();
		}

		Portal_Application_Right__c appRight = [
			Select Id, Terms_Acceptance__c, Right__c
			From Portal_Application_Right__c
			limit 1];

		System.assertEquals(false, appRight.Terms_Acceptance__c);

		PageReference pageref;
		Test.startTest();
		// terms not accepted
		System.runAs(testUser) {
			pageref = controller.initActions();
		}
		System.assert(pageref!=null);

		// accept terms
		appRight.Terms_Acceptance__c = true;
		update appRight;
		System.runAs(testUser) {
			pageref = controller.initActions();
		}
		System.assert(pageref==null);

		// no rights
		appRight.Right__c = 'Access Rejected';
		update appRight;
		System.runAs(testUser) {
			pageref = controller.initActions();
		}
		System.assert(pageref!=null);
		Test.stopTest();
	}

	@istest
	static void test_WrapperStatements() {
		loadVariables();

		ISSP_Ctrl_AccountStatements controller = new ISSP_Ctrl_AccountStatements();
		list<Account_Statement__c> listStatements = [
			Select Id, Period__c, Operation__c, Name, Key__c, CurrencyIsoCode, Account__c, Amount_to_be_Paid__c, Balance__c, Billing_Amount__c, Paid__c, Remittance_Date__c, Status__c, Billing_Adjustment__c, Group__c, Account__r.Name, Account__r.Site, LastModifiedDate
			From Account_Statement__c];

		Test.startTest();
		ISSP_Ctrl_AccountStatements.WrapperStatement wrapper;
		wrapper = new ISSP_Ctrl_AccountStatements.WrapperStatement(listStatements.remove(0));
		for (Account_Statement__c statement: listStatements) {
			wrapper.addStatement(statement);
			wrapper.getShowPaymentProof();
			wrapper.getShowSettlementInfo();
			wrapper.getAmazonFileName();
		}

		wrapper.getParentStatus();
		new list<ISSP_Ctrl_AccountStatements.WrapperStatement>().sort();

		Test.stopTest();
	}

	@istest
	static void test_DetailModalPopup() {
		loadVariables();

		ISSP_Ctrl_AccountStatements controller;

		Test.startTest();
		System.runAs(testUser) {
			controller = new ISSP_Ctrl_AccountStatements();

			System.assertEquals('Approved',controller.currentUser.Contact.Account.Status__c);

			System.assert(controller.mapWrapper!=null);
			System.assert(!controller.mapWrapper.isEmpty());
			list<String> listKey = new list<String>(controller.mapWrapper.keySet());
			System.assert(!listKey.isEmpty());
			controller.selectedKey = listKey.get(0);
	
			controller.showDetailModalPopup();
			//provoke an error
			controller.currentUser = new User();
			System.Assert(controller.initActions()!=null);

			controller.closeDetailModalPopup();
		}
		Test.stopTest();
	}


	static void test_AttachModalPopup() {
		loadVariables();

		ISSP_Ctrl_AccountStatements controller;

		Test.startTest();
		System.runAs(testUser) {
			controller = new ISSP_Ctrl_AccountStatements();

			System.assertEquals('Approved',controller.currentUser.Contact.Account.Status__c);

			System.assert(controller.mapWrapper!=null);
			System.assert(!controller.mapWrapper.isEmpty());
			list<String> listKey = new list<String>(controller.mapWrapper.keySet());
			System.assert(!listKey.isEmpty());
			controller.selectedKey = listKey.get(0);
	
			controller.showAttachModalPopup();
			controller.closeAttachModalPopup();
		}
		Test.stopTest();
	}
}
