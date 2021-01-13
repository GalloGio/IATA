/**
  * Description: This class contains unit tests for the Schedule Job for Processing Zuora Payments
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

@isTest(SeeAllData=true)
private class SchdlIECProcessPayment_tst {

	static testMethod void TestProcessPaymentSchdl() {
		System.debug('Unit Test: Start: TestProcessPaymentSchdl');

		Test.startTest();
		// Set up scheduled job
		datetime nextScheduleTime = system.now().addMinutes(1);
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' * * * ?' ;
		string jobName = 'SchdlIECProcessPayment ' + nextScheduleTime.format('hh:mm');
		system.schedule(jobName, cronvalue , new SchdlIECProcessPayment());
		Test.stopTest();

		System.debug('Unit Test: Finish: TestProcessPaymentSchdl');
	}

	static testMethod void TestProcessPaymentBtch() {
		System.debug('Unit Test: Start: TestProcessPaymentBtch');

		IEC_SAP_Invoice__c SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);
		SAPInv.Status__c = IECConstants.IECSAPInvoice_Status_ZuoraReady;
		insert SAPInv;


		 IEC_SAP_Invoice__c SAPInvUpdate = [SELECT Id, Status__c FROM IEC_SAP_Invoice__c WHERE Id = :SAPInv.Id];

		Test.startTest();
		// Set up batch job
		BtchIECProcessPayment btchProc = new BtchIECProcessPayment();
		btchProc.query = 'SELECT Zuora_Billing_Account_ID__c, Zuora_Invoice_ID__c, Pay_Method__c, Total_Amount__c, Payment_Date__c, SAP_Invoice_Number__c FROM IEC_SAP_Invoice__c   WHERE Status__c = \'' + IECConstants.IECSAPInvoice_Status_ZuoraReady + '\' and Id =\''+SAPInvUpdate.Id +'\' ';
		// Only process 50 records at a time (Zuora Limitation)
		Database.executeBatch(btchProc, 50);
		Test.stopTest();

		SAPInvUpdate = [SELECT Status__c FROM IEC_SAP_Invoice__c WHERE Id = :SAPInv.Id];

		System.assertEquals(SAPInvUpdate.Status__c, IECConstants.IECSAPInvoice_Status_SentToZuora, 'Invoice Status must be Sent To Zuora');

		System.debug('Unit Test: Finish: TestProcessPaymentBtch');
	}
}
