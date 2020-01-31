/**
  * Description: This class contains unit tests for the Invoices webpage
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
  */
@isTest(SeeAllData=true)
public with sharing class vfIECHistInvoices_tst {

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static User usr;
	private static Zuora__ZInvoice__c oInvoice1;
	private static Zuora__ZInvoice__c oInvoice2;	// ICH invoice with no payment
	private static Zuora__Payment__c oPayment1;
	private static Zuora__PaymentInvoice__c oPaymentInvoice1;

	static void setupInvoicesAndPayments() {

		usr = IECTestUtil.createSampleGuestUserAndLogin();

		oContact = [Select Id, Name, AccountId from Contact where Id = :usr.ContactId limit 1];

		oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];

		oBillingAccount = [Select Id, Name, Zuora__Account__c from Zuora__CustomerAccount__c where	Zuora__Account__c = :oAccount.Id AND Contact__c = :usr.ContactId];

		oInvoice1 = IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 213.45);
		insert oInvoice1;

		oInvoice2 = IECTestUtil.createSampleInvoice(oBillingAccount, Date.today().addDays(-3), 42.42);
		insert oInvoice2;

		oPayment1 = IECTestUtil.createSamplePayment(oBillingAccount, 213.45, oInvoice1, 'Processed');
		insert oPayment1;

		oPaymentInvoice1 = new Zuora__PaymentInvoice__c();
		oPaymentInvoice1.Zuora__Invoice__c = oInvoice1.Id;
		oPaymentInvoice1.Zuora__Payment__c = oPayment1.Id;
		oPaymentInvoice1.Zuora__ApplyAmount__c = 213.45;
		insert oPaymentInvoice1;
	}


	static testMethod void TestHistInvoices() {
		System.debug('Unit Test: Start: TestHistInvoices');

		setupInvoicesAndPayments();

		System.runAs(usr) {

			PageReference pgRef = Page.IECHistInvoices;
			pgRef.getParameters().put(IECConstants.PARAM_INVOICE_ID, IECUtil.EncryptEncodeParameter(oInvoice1.Id));
			Test.setCurrentPage(pgRef);

			//Instantiate Controller
			vfIECHistInvoices pageController = new vfIECHistInvoices();

			system.assert(pageController.sSelectedInvoiceID == oInvoice1.Id, 'The selected invoice passed in GET parameter should be valid');

			PageReference pr = pageController.pageLoad();

			system.assert(pageController.lstInvoicesToDisplay != null && pageController.lstInvoicesToDisplay.size() == 2, 'The Invoices should be loaded');
			system.assert(pageController.iNbrRowsDisplayed == 2, 'The number of rows displayed should be 2');

			system.assert(pageController.oSelectedInvoice != null && pageController.oSelectedInvoice.Id == oInvoice1.Id, 'The Invoice1 should be selected');

			pr = pageController.showAll();
			pageController.sSelectedInvoiceID = null;
			pr = pageController.selectInvoice();
			pageController.sSelectedInvoiceID = oInvoice1.Id;
			pr = pageController.selectInvoice();
			pr = pageController.sortInvoices();
			pageController.sSortDirection = 'ASC';
			pageController.sSortByColumn = 'Zuora__TotalAmount__c';
			pr = pageController.sortInvoices();

			pr = pageController.selectPayment();
			pageController.sSelectedPaymentID = oPayment1.Id;
			pr = pageController.selectPayment();
		}
		System.debug('Unit Test: Finish: TestHistInvoices');
	}

	static testMethod void TestHistInvoices_Errors() {
		System.debug('Unit Test: Start: TestHistInvoices_Errors');

		PageReference pgRef = Page.IECHistInvoices;
		Test.setCurrentPage(pgRef);

		//Instantiate Controller
		vfIECHistInvoices pgCont = new vfIECHistInvoices();

		// Test 001: Accessing page as guest user
		pgCont.pageLoad();

		// Test 002: Sorting without specifying columns to sort with
		pgCont.sSortDirection =
			pgCont.sSortByColumn = '';
		pgCont.sortInvoices();
		System.debug('Unit Test: Finish: TestHistInvoices_Errors');
	}
}
