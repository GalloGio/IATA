/**
 * Description: This class contains unit tests for the Payments webpage 
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
 */
@isTest(SeeAllData=true)
public with sharing class vfIECHistPayments_tst {

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static User usr;
	private static Zuora__ZInvoice__c oInvoice1;
	private static Zuora__ZInvoice__c oInvoice2;	// ICH invoice with no payment
	private static Zuora__Payment__c oPayment1;
	private static vfIECHistPayments.PaymentWrapper pw1;

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

		pw1 = new vfIECHistPayments.PaymentWrapper(oPayment1);
		
		oPaymentInvoice1 = new Zuora__PaymentInvoice__c();
		oPaymentInvoice1.Zuora__Invoice__c = oInvoice1.Id;
		oPaymentInvoice1.Zuora__Payment__c = oPayment1.Id;
		oPaymentInvoice1.Zuora__ApplyAmount__c = 213.45;
		insert oPaymentInvoice1;
	}
	
    static testMethod void TestHistPayments() {
    	System.debug('Unit Test: Start: TestHistPayments');
		
		setupInvoicesAndPayments();
		
    	System.runAs(usr) {
    		
    		PageReference pgRef = Page.IECHistPayments;
    		pgRef.getParameters().put(IECConstants.PARAM_PAYMENT_ID, IECUtil.EncryptEncodeParameter(pw1.Id));
    		Test.setCurrentPage(pgRef);
	    	
	    	//Instantiate Controller
	    	vfIECHistPayments pageController = new vfIECHistPayments();
	    	
	    	system.assert(pageController.sSelectedPaymentID == pw1.Id, 'The selected payment passed in GET parameter should be valid');
	    	
	    	PageReference pr = pageController.pageLoad();
				    	
	    	system.assert(pageController.lstPaymentsToDisplay != null && pageController.lstPaymentsToDisplay.size() == 1, 'The Payment1 should be found');
	    	system.assert(pageController.iNbrRowsDisplayed == 1, 'The number of rows displayed should be 1');
	    	
	    	system.assert(pageController.oSelectedPayment != null && pageController.oSelectedPayment.Id == pw1.Id, 'The Payment1 should be selected');
	    	
	    	pr = pageController.showAll();
	    	pageController.sSelectedPaymentID = null;
	    	pr = pageController.selectPayment();
	    	pageController.sSelectedPaymentID = pw1.Id;
	    	pr = pageController.selectPayment();
	    	pr = pageController.sortPayments();
	    	pageController.sSortDirection = 'ASC';
	    	pageController.sSortByColumn = 'Zuora__EffectiveDate__c';
	    	pr = pageController.sortPayments();
	    	
	    	pr = pageController.selectInvoice();
	    	pageController.sSelectedInvoiceID = oInvoice1.Id;
	    	pr = pageController.selectInvoice();
    	}
        System.debug('Unit Test: Finish: TestHistPayments');
	}
	
    static testMethod void TestHistPayments_Errors() {
    	System.debug('Unit Test: Start: TestHistPayments_Errors');

    	PageReference pgRef = Page.IECHistPayments;
    	Test.setCurrentPage(pgRef);
    	
    	//Instantiate Controller
        vfIECHistPayments pgCont = new vfIECHistPayments();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();
        
        System.debug('Unit Test: Finish: TestHistPayments_Errors');
    }
}