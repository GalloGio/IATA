/**  
  * Description: Test the class IECSAPManager
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
public class IECSAPManager_tst {

	// flags for test behavior
	public static String TEST_FLAG_SUCCESS = 'TEST_FLAG_SUCCESS';
	public static String TEST_FLAG_ERROR = 'TEST_FLAG_ERROR';
	public static String INVOICE_ERROR_MSG = 'Simulated error for Test Class';
	public static String INVOICE_WARNING_MSG = 'Some warning msg';
	public static String INVOICE_SUCCESS_CONTRACT_NO = 'CON-012345';
	public static String INVOICE_SUCCESS_BILLTO_NO = 'B1LLT0';

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static SAP_Account__c oSAPAccount;
	
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static Zuora__Subscription__c oSubscription;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge;
	private static Zuora__Subscription__c oSubscription2;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge2;
	
	private static Zuora__ZInvoice__c oInvoice1;
	private static Zuora__ZInvoice__c oInvoice2;
	
	/** 
	 * Set up the data to be used in test
	 */
	private static void setupData(){
		
		// create customer related objects
		
		oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;
		
		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		insert oBillingAccount;
		
		oSAPAccount = IECTestUtil.CreateSampleSAPAccount(oAccount.Id);
    	insert oSAPAccount;
    	
    	// create dummy Zuora product
    	oProduct = IECTestUtil.CreateSampleProduct2('Product1');
    	oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
    	insert oProduct;
    	
    	// create dummy Zuora rate plan
    	oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct);
    	oProductRatePlan.zqu__Deleted__c = false;
    	insert oProductRatePlan;
    	
    	// create dummy Zuora rate plan #2
    	oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 2', false, oProduct);
    	oProductRatePlan2.zqu__Deleted__c = false;
    	insert oProductRatePlan2;
    	
    	// create dummy oSubscription
        oSubscription = IECTestUtil.createSampleSubscription(oAccount.Id, 'S01', Date.today().addMonths(6));
        insert oSubscription;
        
        // create dummy oSubscription charge
        oSubscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert oSubscriptionCharge;
        
        // create dummy oSubscription2
        oSubscription2 = IECTestUtil.createSampleSubscription(oAccount.Id, 'S02', Date.today().addMonths(6));
        insert oSubscription2;
        
        // create dummy oSubscription2 charge
        oSubscriptionCharge2 = IECTestUtil.createSampleSubscriptionCharge2(oSubscription2.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan2);
        insert oSubscriptionCharge2;
	}
	
	public static List<Zuora.zObject> getSampleInvoiceItems() {
		
		List<Zuora.zObject> lstInvoiceItems = new List<Zuora.zObject>();
		
		// Invoice item for 1st Invoice
		Zuora.zObject zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
		zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
		zInvoiceItem.setValue('ChargeAmount', 100);
		zInvoiceItem.setValue('ChargeDate', DateTime.now());
		zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
		zInvoiceItem.setValue('InvoiceId', oInvoice1.Zuora__External_Id__c);
		zInvoiceItem.setValue('ProductId', oProduct.zqu__ZuoraId__c);
		zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
		zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
		zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionCharge.Zuora__External_Id__c);
		zInvoiceItem.setValue('Quantity', 1);
		zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
		zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
		zInvoiceItem.setValue('TaxAmount', 0);
		zInvoiceItem.setValue('UnitPrice', 142.31);
		lstInvoiceItems.add(zInvoiceItem);
		return lstInvoiceItems;
	}

	/**
	 * Tests the sending of invoices/invoice items to SAP
	 */
    static testMethod void testSendInvoiceToSAP() {
        
        Decimal dInvoice1Amount = 142.0;
        Date dtInvoice1Date = Date.today().addDays(-5);
        /*
        Decimal dInvoice2Amount = 700.0;
        Date dtInvoice2Date = Date.today();
        */
        IEC_SAP_Invoice__c oSAPInvoice1;

		/////////////////////////////////////////////////////////////////////////////
		// Test #1 - nothing to send yet
		
		List<IEC_SAP_Invoice__c> lstSAPInvoices = IECSAPManager.getNewSAPInvoices();
		system.assert(lstSAPInvoices == null || lstSAPInvoices.size() == 0, 'There should be no test SAP Invoices to send yet');
		
		IECSAPManager.sendInvoicesToSAP(lstSAPInvoices);
		
		/////////////////////////////////////////////////////////////////////////////
		// create test data
		
		setupData();
		
		// create invoices and invoice items
		Test.startTest();
		
		IECTestUtil.InvoiceTestOrigin = 'IECSAPManager_tst';
		oInvoice1 = IECTestUtil.createSampleInvoice(oBillingAccount, dtInvoice1Date, dInvoice1Amount);
    	insert oInvoice1;
    	/*
    	oInvoice2 = IECTestUtil.createSampleInvoice(oBillingAccount, dtInvoice2Date, dInvoice2Amount);
    	insert oInvoice2;
    	*/
    	// make sure the Invoice Items have finished syncing
    	Test.stopTest();
    	
    	IECTestUtil.InvoiceTestOrigin = '';
        	
        // make sure that a IEC SAP Invoice has been created
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		
		// verify SAP Invoice
		system.assert(oSAPInvoice1 != null, 'A SAP Invoice should be created');
		system.assertEquals(IECConstants.IECSAPInvoice_Status_New, oSAPInvoice1.Status__c, 'The SAP Invoice status should be New');
//		system.assertEquals(true, oSAPInvoice1.Ready_for_SAP__c, 'The Ready_for_SAP__c should be true');
//		system.assertEquals(oInvoice1.Name, oSAPInvoice1.Name, 'The method getSAPInvoiceByInvoiceNumber should return the SAP Invoice having the same invoice number');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #2 - validation errors on SAP Invoice (field Dist Chan and Billing Country is missing)
		
		// simulate validation error
		oSAPInvoice1.Dist_Chan__c = null;
		oSAPInvoice1.Billing_Country__c = null;
		update oSAPInvoice1;
		
		IECSAPManager.sendInvoicesToSAP(IECSAPManager.getNewSAPInvoices());
		
		// reselect SAP Invoice and check status
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		//system.assertEquals(IECConstants.IECSAPInvoice_Status_ValidationError, oSAPInvoice1.Status__c, 'The SAP Invoice status should be updated to Validation Error');
		
		// fix validation error on SAP Invoice (still missing fields on Invoice Items)
		oSAPInvoice1.Dist_Chan__c = 'asdfa';
		oSAPInvoice1.Billing_Country__c = 'Canada';
		oSAPInvoice1.Billing_Name__c = 'Bungalow Bill';
		oSAPInvoice1.Error_Message__c = null;
		oSAPInvoice1.Status__c = IECConstants.IECSAPInvoice_Status_New;
		update oSAPInvoice1;
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			oSAPInvoiceItem.Error_Message__c = null;
			oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_New;
			// delete field Material (for next test case)
			oSAPInvoiceItem.Material__c = null;
			update oSAPInvoiceItem;
		}
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #3 - validation errors on invoice items (field Material is missing)
		
		IECSAPManager.sendInvoicesToSAP(IECSAPManager.getNewSAPInvoices());
		
		// reselect SAP Invoice
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		//system.assertEquals(IECConstants.IECSAPInvoice_Status_ValidationError, oSAPInvoice1.Status__c, 'The SAP Invoice status should be updated to Validation Error.');
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			//system.assertEquals(IECConstants.IECSAPInvoiceItem_Status_ValidationError, oSAPInvoiceItem.Status__c, 'The SAP Invoice Item status should be Validation Error. SAP Invoice Item Error Message: ' + oSAPInvoice1.Error_Message__c);
		}
		
		// fix validation errors on SAP Invoice Item
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			oSAPInvoiceItem.Material__c = 'MAT1234';
			oSAPInvoiceItem.Profit_Center__c = 'PC42';
			oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_New;
			// workaround: date from/to are not populated (dont know why)
			oSAPInvoiceItem.Date_From__c = oSubscription.Zuora__SubscriptionStartDate__c;
			oSAPInvoiceItem.Date_To__c = oSubscription.Zuora__SubscriptionEndDate__c;
			update oSAPInvoiceItem;
		}
		oSAPInvoice1.Status__c = IECConstants.IECSAPInvoice_Status_New;
		update oSAPInvoice1;
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #4 - simulate SAP Error
		
		// set the test flag to generate errors
		oSAPInvoice1.Text_Print__c = TEST_FLAG_ERROR;
		update oSAPInvoice1;
		IECSAPManager.sendInvoicesToSAP(IECSAPManager.getNewSAPInvoices());
		
		// reselect SAP Invoices
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		
		// make sure status is SAP Error
		//system.assertEquals(IECConstants.IECSAPInvoice_Status_SAPError, oSAPInvoice1.Status__c, 'The SAP Invoice status should be updated to SAP Error. Error Message: ' + oSAPInvoice1.Error_Message__c);
		
		// make sure test error message is in the error field
		//system.assert(String.isNotBlank(oSAPInvoice1.Error_Message__c) && oSAPInvoice1.Error_Message__c.contains(INVOICE_ERROR_MSG), 'The SAP Invoice error message should contain the test error message');
		
		// NOTE: not sure if the SAP INvoice Items status should be updated...
		// make sure that the SAP invoice items status are SAP Error
		//for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r)
		//	system.assertEquals(IECConstants.IECSAPInvoiceItem_Status_SAPError, oSAPInvoiceItem.Status__c, 'The SAP Invoice Items status shoudld be updated to SAP Error');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #5 - the interface should not try to send SAP Invoices that have validation errors
		
		lstSAPInvoices = IECSAPManager.getNewSAPInvoices();
		//system.assert(lstSAPInvoices == null || lstSAPInvoices.size() == 0, 'There should be no test SAP Invoices to send because it is in validation error');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #6 - simulate sending to SAP success
		
		// fix validation errors
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			oSAPInvoiceItem.Error_Message__c = null;
			oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_New;
			update oSAPInvoiceItem;
		}
		oSAPInvoice1.Error_Message__c = null;
		oSAPInvoice1.Status__c = IECConstants.IECSAPInvoice_Status_New;
		
		// set the test flag to simulate a success
		oSAPInvoice1.Text_Print__c = TEST_FLAG_SUCCESS;
		update oSAPInvoice1;
		
		IECSAPManager.sendInvoicesToSAP(IECSAPManager.getNewSAPInvoices());
		
		// reselect SAP Invoices
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		
		// make sure status is Sent to SAP
		//system.assertEquals(IECConstants.IECSAPInvoice_Status_SentToSAP, oSAPInvoice1.Status__c, 'The SAP Invoice status should be updated to Sent to SAP');
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			//system.assertEquals(IECConstants.IECSAPInvoiceItem_Status_SentToSAP, oSAPInvoiceItem.Status__c, 'The SAP Invoice Items status shoudld be updated to Sent to SAP');
		}
		
		// make sure we received the SAP Contract number
		//system.assert(String.isNotblank(oSAPInvoice1.SAP_Contract_Number__c), 'The SAP Contract number should be set');
		
		// make sure the test warning message has been set
		//system.assertEquals(INVOICE_WARNING_MSG, oSAPInvoice1.Warning_Message__c, 'The test warning message should bet set');
    }
    
    
    /**
	 * Tests the receiving of invoice payments from SAP
	 */
    static testMethod void testUpdateInvoicesFromSAPPayment() {

    	final String SAP_INVOICE_NO = 'SAP_INV_420';
    	final Date INV_CLEAREANCE_DATE = Date.today().addDays(-1);
    	final Decimal INV_AMOUNT = 142.0;
        final Date INV_DATE = Date.today().addDays(-5);
        /*
        final Decimal INV2_AMOUNT = 700.0;
        final Date INV2_DATE = Date.today();
    	*/
    	/////////////////////////////////////////////////////////////////////////////
		// Test #1 - nothing to receive
		
		IECSAPWebService.confirmInvoicePayments(null);
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #2 - empty parameters
		
		IECSAPWebService.PaymentConfirmationRequest oRequest = new IECSAPWebService.PaymentConfirmationRequest();
		oRequest.InvoiceClearanceDate = null;
		oRequest.ZuoraInvoiceNumber = null;
		oRequest.SAPInvoiceNumber = null;
		
		IECSAPWebService.PaymentConfirmationResponse[] oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		
		system.assert(oResponses != null && oResponses.size() == 1, 'A response should be returned');
		system.assertEquals(false, oResponses[0].Success, 'The response should not be successfull');
		system.assert(String.isNotBlank(oResponses[0].Error), 'An error message should be generated');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #3 - invoice number present but missing Invoice Clearance Date
		
		oRequest = new IECSAPWebService.PaymentConfirmationRequest();
		oRequest.InvoiceClearanceDate = null;
		oRequest.ZuoraInvoiceNumber = 'unknown_invoice_number';
		oRequest.SAPInvoiceNumber = 'unknown_sap_invoice_number';
		
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		}
		catch (Exception ex) {
			system.assert(false, 'IECSAPManager.updateInvoicesFromSAPPayment() should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
		
		system.assertEquals(false, oResponses[0].Success, 'The response should not be successfull');
		system.assertEquals(oRequest.ZuoraInvoiceNumber, oResponses[0].InvoiceNumber, 'The response Invoice Number should equal the request Zuora Invoice Number');
		system.assert(String.isNotBlank(oResponses[0].Error), 'An error message should be generated');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #4 - unknown invoice
		
		oRequest = new IECSAPWebService.PaymentConfirmationRequest();
		oRequest.InvoiceClearanceDate = Date.today().addDays(-2);
		oRequest.ZuoraInvoiceNumber = 'unknown_invoice_number';
		oRequest.SAPInvoiceNumber = 'unknown_sap_invoice_number';
		
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		}
		catch (Exception ex) {
			system.assert(false, 'IECSAPManager.updateInvoicesFromSAPPayment() should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
		
		system.assertEquals(false, oResponses[0].Success, 'The response should not be successfull');
		system.assert(String.isNotBlank(oResponses[0].Error), 'An error message should be generated');
		
		/////////////////////////////////////////////////////////////////////////////
		// create test data
		
		setupData();
		
		// create invoices and invoice items
		Test.startTest();
		
		IECTestUtil.InvoiceTestOrigin = 'IECSAPManager_tst';
		oInvoice1 = IECTestUtil.createSampleInvoice(oBillingAccount, INV_DATE, INV_AMOUNT);
    	insert oInvoice1;
    	/*
    	oInvoice2 = IECTestUtil.createSampleInvoice(oBillingAccount, INV2_DATE, INV2_AMOUNT);
    	insert oInvoice2;
    	*/
    	// make sure the Invoice Items have finished syncing
    	Test.stopTest();
    	
    	IECTestUtil.InvoiceTestOrigin = '';
    	
    	// make sure that a IEC SAP Invoice has been created
		IEC_SAP_Invoice__c oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		system.assert(oSAPInvoice1 != null, 'A SAP Invoice should be created');
		
		
		// manually flag the invoice/invoice items as being sent to SAP
		oSAPInvoice1.Status__c = IECConstants.IECSAPInvoice_Status_SentToSAP;
		oSAPInvoice1.Pay_Method__c = 'Credit Card'; // Test #5 will be done for credit card
		update oSAPInvoice1;
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_SentToSAP;
			update oSAPInvoiceItem;
		}
    	
    	/////////////////////////////////////////////////////////////////////////////
    	// Test #5 - receive a valid invoice payment confirmation (credit card)
    	
    	oRequest = new IECSAPWebService.PaymentConfirmationRequest();
		oRequest.InvoiceClearanceDate = INV_CLEAREANCE_DATE;
		oRequest.ZuoraInvoiceNumber = oInvoice1.Name;
		oRequest.SAPInvoiceNumber = SAP_INVOICE_NO;
		
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		}
		catch (Exception ex) {
			system.assert(false, 'IECSAPManager.updateInvoicesFromSAPPayment() should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
		
		// check the response
		system.assert(oResponses != null && oResponses.size() == 1, 'There should be one response');
		system.assertEquals(true, oResponses[0].Success, 'The response should be successfull');
		
		// reselect SAP Invoice
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);

		// check statuses of SAP Invoice and SAP Invoice Items
		system.assertEquals(IECConstants.IECSAPInvoice_Status_SAPPaymentConfirmationReceived, oSAPInvoice1.Status__c, 'The status of the SAP Invoice should be Payment Confirmation Received. Error generated: ' + oSAPInvoice1.Error_Message__c);
		system.assertEquals(INV_CLEAREANCE_DATE, oSAPInvoice1.SAP_Invoice_Clearance_Date__c, 'The field SAP Invoice Clearance Date should be set');
		system.assertEquals(SAP_INVOICE_NO, oSAPInvoice1.SAP_Invoice_Number__c, 'The field SAP Invoice Number should be set');

		/////////////////////////////////////////////////////////////////////////////
		// Test #6 - receive a duplicate invoice payment confirmation (same data)
		
		// send the exact same request object created in Test #5
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		}
		catch (Exception ex) {
			system.assert(false, 'IECSAPManager.updateInvoicesFromSAPPayment() should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
		
		// business rule: sending duplicate with exact same data does not produce any errors
		system.assertEquals(true, oResponses[0].Success, 'The response should be successfull');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #7 - receive a duplicate invoice payment confirmation (different data)
		
		// change data to make it different than what was received
		oRequest.InvoiceClearanceDate = Date.today().addDays(-4);
		oRequest.SAPInvoiceNumber = 'SAP_INV_007';
		
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		}
		catch (Exception ex) {
			system.assert(false, 'IECSAPManager.updateInvoicesFromSAPPayment() should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
		
		system.assertEquals(false, oResponses[0].Success, 'The response should not be successfull');
		
		/////////////////////////////////////////////////////////////////////////////
		// Test #7 - receive a valid invoice payment confirmation (ICH)
		
		// reset invoice/invoice items to before we received the confirmation
		oSAPInvoice1.Status__c = IECConstants.IECSAPInvoice_Status_SentToSAP;
		oSAPInvoice1.SAP_Invoice_Clearance_Date__c = null;
		oSAPInvoice1.SAP_Bill_To_Number__c = null;
		oSAPInvoice1.SAP_Invoice_Number__c = null;
		oSAPInvoice1.Payment_Date__c = null;
		oSAPInvoice1.Pay_Method__c = 'Other'; // simulate ICH payment
		update oSAPInvoice1;
		for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice1.IEC_SAP_Invoice_Items__r) {
			oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_SentToSAP;
			update oSAPInvoiceItem;
		}
		
		oRequest = new IECSAPWebService.PaymentConfirmationRequest();
		oRequest.InvoiceClearanceDate = INV_CLEAREANCE_DATE;
		oRequest.ZuoraInvoiceNumber = oInvoice1.Name;
		oRequest.SAPInvoiceNumber = SAP_INVOICE_NO;
		
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(new List<IECSAPWebService.PaymentConfirmationRequest>{ oRequest });
		}
		catch (Exception ex) {
			system.assert(false, 'IECSAPManager.updateInvoicesFromSAPPayment() should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
		
		// check the response
		system.assert(oResponses != null && oResponses.size() == 1, 'There should be one response');
		system.assertEquals(true, oResponses[0].Success, 'The response should be successfull');
		
		// reselect SAP Invoice
		oSAPInvoice1 = IECSAPManager.getSAPInvoiceByInvoiceNumber(oInvoice1.Name);
		
		// since the payment was ICH, the status should be update to Zuora Ready
		system.assertEquals(IECConstants.IECSAPInvoice_Status_ZuoraReady, oSAPInvoice1.Status__c, 'The status of the SAP Invoice should be Zuora Ready');
		
		// the payment date should be set
		system.assert(oSAPInvoice1.Payment_Date__c != null, 'The field Payment Date should be set');
		
		///////////////////////////////////////////////////////////
		// Test #8 - Stress test with 150 payment confirmation
		
		List<IECSAPWebService.PaymentConfirmationRequest> lstRequests = new List<IECSAPWebService.PaymentConfirmationRequest>();
		for (Integer i=0; i<100; i++) {
			lstRequests.add(oRequest);
			oRequest.SAPInvoiceNumber = IECUtil.NewGuid();
		}
		
		try {
			oResponses = IECSAPWebService.confirmInvoicePayments(lstRequests);
		}
		catch(Exception ex) {
			system.assert(false, 'Should not throw error: ' + ex.getMessage() + ' Stack: ' + ex.getStacktraceString());
		}
    }
}