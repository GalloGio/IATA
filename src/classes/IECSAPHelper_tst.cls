/**
	* Description: Test the class IECSAPHelper
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*/
@isTest
public with sharing class IECSAPHelper_tst {

	private static final String TEST_INV_NUM = 'INV0420420';
	private static final Decimal TEST_FIRSTRATEPLAN_AMOUNT = 50.0;
	private static final Decimal TEST_SECONDRATEPLAN_AMOUNT = 750.0;

	private static Account oAccount;
	private static Zuora__CustomerAccount__c oBillingAccount;

	private static IEC_SAP_Invoice__c oSAPInvoice;
	private static IEC_SAP_Invoice_Item__c oSAPInvoiceItem1;
	private static IEC_SAP_Invoice_Item__c oSAPInvoiceItem2;

	static void setupData() {

		// create customer related objects

		oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;

		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		insert oBillingAccount;

		// create test SAP Invoice
		oSAPInvoice = new IEC_SAP_Invoice__c();
		oSAPInvoice.Billing_Name__c = 'John Doe';
		oSAPInvoice.Zuora_Billing_Account_ID__c = 'A-0987654321';
		oSAPInvoice.Bill_To__c = 'BT12345';
		oSAPInvoice.Pay_Method__c = 'ICH';
		oSAPInvoice.Billing_City__c = 'Montreal';
		oSAPInvoice.Billing_Country__c = 'CA';
		oSAPInvoice.Billing_State__c = 'QC';
		oSAPInvoice.Billing_Street__c = '123 main street';
		oSAPInvoice.Billing_Zip__c = 'h1q2w3';
		oSAPInvoice.VAT_Number__c = 'VAT12345';
		oSAPInvoice.PO_Date__c = DateTime.now().date();
		oSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_New;
		oSAPInvoice.Status_Date__c = DateTime.now();
		oSAPInvoice.Total_Amount__c = TEST_SECONDRATEPLAN_AMOUNT - TEST_FIRSTRATEPLAN_AMOUNT;
		oSAPInvoice.Zuora_Invoice_Number__c = TEST_INV_NUM;
		oSAPInvoice.Zuora_Invoice_ID__c = IECUtil.NewGuid().substring(0, 32);
		oSAPInvoice.Name = TEST_INV_NUM;
		oSAPInvoice.Account__c = oAccount.Id;
		oSAPInvoice.Billing_Account__c = oBillingAccount.Id;
		oSAPInvoice.Text_Print__c = IECSAPManager_tst.TEST_FLAG_SUCCESS;
		oSAPInvoice.Number_of_Zuora_Items__c = 2;
		insert oSAPInvoice;

		oSAPInvoiceItem1 = new IEC_SAP_Invoice_Item__c();
		oSAPInvoiceItem1.IEC_SAP_Invoice__c = oSAPInvoice.Id;
		oSAPInvoiceItem1.Material__c = 'MAT123';
		oSAPInvoiceItem1.Profit_Center__c = 'PROC1234';
		oSAPInvoiceItem1.Date_From__c = Date.today().addDays(-10);
		oSAPInvoiceItem1.Date_To__c = oSAPInvoiceItem1.Date_From__c.addYears(1);
		oSAPInvoiceItem1.Quantity__c = 1;
		oSAPInvoiceItem1.Unit_Price__c = TEST_SECONDRATEPLAN_AMOUNT;
		oSAPInvoiceItem1.Charge_Amount__c = TEST_SECONDRATEPLAN_AMOUNT;
		oSAPInvoiceItem1.Status__c = IECConstants.IECSAPInvoice_Status_New;
		oSAPInvoiceItem1.Status_Date__c = DateTime.now();
		oSAPInvoiceItem1.Name = 'II-0000012345';
		insert oSAPInvoiceItem1;

		oSAPInvoiceItem2 = new IEC_SAP_Invoice_Item__c();
		oSAPInvoiceItem2.IEC_SAP_Invoice__c = oSAPInvoice.Id;
		oSAPInvoiceItem2.Material__c = 'MAT123';
		oSAPInvoiceItem2.Profit_Center__c = 'PROC1234';
		oSAPInvoiceItem2.Date_From__c = Date.today().addDays(-10);
		oSAPInvoiceItem2.Date_To__c = oSAPInvoiceItem2.Date_From__c.addYears(1);
		oSAPInvoiceItem2.Quantity__c = 1;
		oSAPInvoiceItem2.Unit_Price__c = TEST_FIRSTRATEPLAN_AMOUNT;
		oSAPInvoiceItem2.Charge_Amount__c = -TEST_FIRSTRATEPLAN_AMOUNT; // notice the minus sign
		oSAPInvoiceItem2.Status__c = IECConstants.IECSAPInvoice_Status_New;
		oSAPInvoiceItem2.Status_Date__c = DateTime.now();
		oSAPInvoiceItem2.Name = 'II-0000012346';
		insert oSAPInvoiceItem2;
	}

	/**
	 *
	 */
	static testMethod void testMethods() {

		try {
			setupData();

			IEC_SAP_Invoice__c oSAPInv = IECSAPManager.getSAPInvoiceByInvoiceNumber(TEST_INV_NUM);

						system.debug('oSAPInv ' + oSAPInv);

			system.assert(oSAPInv != null, 'The SAP Invoice should be found');
			//system.assert(oSAPInv.Ready_for_SAP__c, 'The SAP Invoice should be ready for SAP');

			// test create methods
			iataComXiSalesforceOtcWid5600Sales3.Header_element oElement = IECSAPHelper.createHeaderForInvoiceSending(oSAPInv);
			iataComXiSalesforceOtcWid5600Sales3.Address_element oAddress = IECSAPHelper.createAddressElementForInvoiceSending(oSAPInv);
			iataComXiSalesforceOtcWid5600Sales3.Item_element[] arrItemElements = IECSAPHelper.createItemElementsForInvoiceSending(oSAPInv);

			// since we simulated an upgrade, therse should only be 1 invoice item and it should be the ajusted price
			system.assertEquals(1, arrItemElements.size(), 'should only be 1 invoice item created');
			system.assertEquals(TEST_SECONDRATEPLAN_AMOUNT - TEST_FIRSTRATEPLAN_AMOUNT, Decimal.valueOf(arrItemElements[0].UnitPrice), 'The unit price that is sent should be the adjusted one');

		}
		catch (Exception ex) {
			system.assert(false, 'Shouldnt throw an error: ' + ex.getMessage());
		}
	}
}
