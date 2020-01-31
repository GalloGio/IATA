/**
  * Description: Test class for Trigger handler for the Zuora Payment Invoice object
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
@isTest(SeeAllData=true)
private class trgHndlrIECPaymentInvoice_tst {
	private static IEC_SAP_Invoice__c oSAPInv;
	private static Account oAccount;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static Zuora__ZInvoice__c oInvoice;
	private static Zuora__Payment__c oPayment;

	static void Init() {
		oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;

		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		insert oBillingAccount;

		oInvoice = IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 100);
		insert oInvoice;

		oPayment = IECTestUtil.createSamplePayment(oBillingAccount, 100, oInvoice, 'Processed');
		insert oPayment;

		oSAPInv = IECTestUtil.CreateSampleSAPInvoice(oAccount.Id);
		oSAPInv.Name = oInvoice.Name;
		oSAPInv.Payment_Date__c = null;
		insert oSAPInv;
	}

	static testMethod void TestPaymentInvoice() {
		System.debug('Unit Test: Start: TestPaymentInvoice');

		Init();

		// 001: SAP Invoice's Payment date must be initially set to Null
		system.assertEquals(oSAPInv.Payment_Date__c, null, 'Payment Date must be null.');

		Zuora__PaymentInvoice__c oPaymentInvoice = new Zuora__PaymentInvoice__c (
			Zuora__ApplyAmount__c = 100
			, Zuora__External_Id__c = IECUtil.NewGuid().substring(0, 32)
			, Zuora__Invoice__c = oInvoice.Id
			, Zuora__Payment__c = oPayment.Id
			, Zuora__RefundAmount__c = 0
		);

		insert oPaymentInvoice;

		// 002: SAP Invoice's Payment date must be filled and not empty
		List<IEC_SAP_Invoice__c> lstSAPInv = [SELECT Payment_Date__c FROM IEC_SAP_Invoice__c WHERE Id = :oSAPInv.Id];
		system.assertEquals(lstSAPInv.get(0).Payment_Date__c, oPayment.Zuora__EffectiveDate__c.date(), 'Payment Date must match.');

		System.debug('Unit Test: Finish: TestPaymentInvoice');
	}
}
