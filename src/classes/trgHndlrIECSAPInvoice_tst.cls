/**
  * Description: This class contains unit tests for the (SAP Invoice) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

@isTest(SeeAllData=true)
private class trgHndlrIECSAPInvoice_tst {
	private static IEC_SAP_Invoice__c oSAPInv;
	private static Account oAcc;
	private static Zuora__CustomerAccount__c oBillingAcc;

	static void Init() {
		oAcc = IECTestUtil.createSampleAccount();
		insert oAcc;

		oBillingAcc = IECTestUtil.createSampleBillingAccount(oAcc);
		insert oBillingAcc;

		oSAPInv = IECTestUtil.CreateSampleSAPInvoice(oAcc.Id);
		oSAPInv.Status__c = IECConstants.IECSAPInvoice_Status_SentToSAP;
		insert oSAPInv;
	}

	static testMethod void TestSAPInvoice() {
		System.debug('Unit Test: Start: TestSAPInvoice');

		/*
		 * NOTE: Commented on 2014/07/14 following feedback from David. Will be used in the future when we create inexisting users in SAP, but it's not the case now.
		 *
		Init();

		Test.startTest();

		// Fake SAP Payment Confirmation
		oSAPInv.Status__c = IECConstants.IECSAPInvoice_Status_SAPPaymentConfirmationReceived;
		oSAPInv.SAP_Bill_To_Number__c = '23948atra09t';
		update oSAPInv;

		Test.stopTest();

		// 001: Make sure that SAP Account has been created for this SAP Invoice's Account
		List<SAP_Account__c> lstSAPAcc =
			[SELECT Id
			FROM SAP_Account__c
			WHERE Account__c = :oAcc.Id
				AND SAP_Account_type__c = :IECConstants.SAPAccount_InvoiceType_Invoices
				AND SAP_ID__c = :oSAPInv.SAP_Bill_To_Number__c];
		system.assertNotEquals(lstSAPAcc.size(), 0, 'No SAP Accounts found for this SAP Invoice\'s Accuont');
		System.debug('Unit Test: Finish: TestSAPInvoice');
		*/
	}
}
