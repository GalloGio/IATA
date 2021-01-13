@isTest
private class IEC_MyInvoicesControllerTest
{

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static User usr;
	private static Zuora__ZInvoice__c oInvoice1;
	private static Zuora__ZInvoice__c oInvoice2;    // ICH invoice with no payment
	private static Zuora__Payment__c oPayment1;
	private static Zuora__PaymentInvoice__c oPaymentInvoice1;

	static void setupInvoicesAndPayments() {

		usr = IECTestUtil.createSampleGuestUserAndLogin();
		//insert usr;

		oContact = [Select Id, Name, AccountId from Contact where Id = :usr.ContactId limit 1];

		oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];

		oBillingAccount = [Select Id, Name, Zuora__Account__c from Zuora__CustomerAccount__c where  Zuora__Account__c = :oAccount.Id AND Contact__c = :usr.ContactId];

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

	static testMethod void test_HistInvoices() {
	System.debug('Unit Test: Start: TestHistInvoices');

		setupInvoicesAndPayments();

	System.runAs(usr) {
		PageReference pgRef = Page.IEC_MyInvoices;
		Test.setCurrentPage(pgRef);

			//Instantiate Controller
			IEC_MyInvoicesController ctrl = new IEC_MyInvoicesController();
			PageReference pr = ctrl.onLoadAction();

			//System.assertEquals(2, ctrl.invoices.size());
		}
	}

	static testMethod void test_NotLoggedIn()
	{
		IEC_MyInvoicesController ctrl = new IEC_MyInvoicesController();
		PageReference pr = ctrl.onLoadAction();
	}
}
