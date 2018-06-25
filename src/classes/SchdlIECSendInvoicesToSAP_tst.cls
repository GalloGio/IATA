/**  
  * Description: This class contains unit tests for the Schedule Job for Processing SAP Invoices
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class SchdlIECSendInvoicesToSAP_tst {

    @isTest
    static void testSendSAPInvoicesSchdl() {
		Test.startTest();
        // Set up scheduled job
		datetime nextScheduleTime = system.now().addMinutes(1);
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' * * * ?' ;
		string jobName = 'SchdlIECSendInvoicesToSAP ' + nextScheduleTime.format('hh:mm');
		system.schedule(jobName, cronvalue , new SchdlIECSendInvoicesToSAP());
		Test.stopTest();
    }
    
    @isTest
	static void testSendSAPInvoicesBatch() {
		//*** (Thai 2016-11-02) rewrite for new behaviour
		//*** create Zuora invoice
		Zuora__CustomerAccount__c oBillingAccount = new Zuora__CustomerAccount__c();
		List<Zuora__ZInvoice__c> lstZInvoice = new List<Zuora__ZInvoice__c>{
			  IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 100)
			, IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 100)
			, IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 100)
			, IECTestUtil.createSampleInvoice(oBillingAccount, Date.today(), 100)
		};
		lstZInvoice[0].Name = 'zzzTest Invoice 1 ' + system.now();
		lstZInvoice[1].Name = 'zzzTest Invoice 2 ' + system.now();
		lstZInvoice[2].Name = 'zzzTest Invoice 3 ' + system.now();
		lstZInvoice[3].Name = 'zzzTest Invoice 4 ' + system.now();
		insert lstZInvoice;
		List<Invoice_Item__c> lstZInvoiceItem = new List<Invoice_Item__c>{
			  new Invoice_Item__c(Invoice__c=lstZInvoice[0].Id, Zuora_ID__c='zzzTest111', Subscription_Zuora_ID__c='zzzTest Sub 1', Subscription_Number__c = 'nbr zzzTest Sub 1', Quantity__c=1, Unit_Price__c=10, Charge_Amount__c=10)
			, new Invoice_Item__c(Invoice__c=lstZInvoice[1].Id, Zuora_ID__c='zzzTest222', Subscription_Zuora_ID__c='zzzTest Sub 2', Subscription_Number__c = 'nbr zzzTest Sub 2', Quantity__c=1, Unit_Price__c=10, Charge_Amount__c=10)
			, new Invoice_Item__c(Invoice__c=lstZInvoice[2].Id, Zuora_ID__c='zzzTest333', Subscription_Zuora_ID__c='zzzTest Sub 3', Subscription_Number__c = 'nbr zzzTest Sub 3', Quantity__c=1, Unit_Price__c=10, Charge_Amount__c=10)
			, new Invoice_Item__c(Invoice__c=lstZInvoice[3].Id, Zuora_ID__c='zzzTest444', Subscription_Zuora_ID__c='zzzTest Sub 4', Subscription_Number__c = 'nbr zzzTest Sub 4', Quantity__c=1, Unit_Price__c=10, Charge_Amount__c=10)
			, new Invoice_Item__c(Invoice__c=lstZInvoice[3].Id, Zuora_ID__c='zzzTest555', Subscription_Zuora_ID__c='zzzTest Sub 5', Subscription_Number__c = 'nbr zzzTest Sub 5', Quantity__c=1, Unit_Price__c=10, Charge_Amount__c=10, Charge_Name__c='Tax')
		};
		insert lstZInvoiceItem;

		Test.startTest();
			//*** create SAP invoice -> should be done in "startTest" because of future call in Zuora__ZInvoice__c
			List<IEC_SAP_Invoice__c> lstSAPInv = new List<IEC_SAP_Invoice__c>();
			IEC_SAP_Invoice__c SAPInv;
			SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);   //*** for getNextStatus case of Skipped
			SAPInv.Zuora_Invoice_Number__c = 'zzzTest ' + system.now();   SAPInv.Number_of_Zuora_Items__c = 1;
			lstSAPInv.add(SAPInv);
			SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);   //*** for getNextStatus case of first retry
			SAPInv.Zuora_Invoice_Number__c = lstZInvoice[0].Name;   SAPInv.Number_of_Zuora_Items__c = 1;
			lstSAPInv.add(SAPInv);
			SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);   //*** for getNextStatus case of another retry
			SAPInv.Zuora_Invoice_Number__c = lstZInvoice[1].Name;   SAPInv.Number_of_Zuora_Items__c = 1;   SAPInv.Status__c = 'Retry 1';
			lstSAPInv.add(SAPInv);
			SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);   //*** for getNextStatus case of no more retry
			SAPInv.Zuora_Invoice_Number__c = lstZInvoice[2].Name;   SAPInv.Number_of_Zuora_Items__c = 1;   SAPInv.Status__c = 'Retry 99';
			lstSAPInv.add(SAPInv);
			SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);   //*** for getNextStatus case of not to process
			SAPInv.Zuora_Invoice_Number__c = lstZInvoice[3].Name;   SAPInv.Number_of_Zuora_Items__c = 1;   SAPInv.Status__c = 'Processed';
			lstSAPInv.add(SAPInv);
			upsert lstSAPInv Zuora_Invoice_Number__c;
			
			//*** test batch -> skip tests for statuses Processed and Processed with Error
			BtchIECSendInvoicesToSAP btchProc = new BtchIECSendInvoicesToSAP();
			btchProc.query =  'select Id, Zuora_Invoice_Number__c, Status__c'
			               + ' from IEC_SAP_Invoice__c'
			               + ' where Zuora_Invoice_Number__c like \'zzzTest%\''
			               + ' order by CreatedDate';
			Database.executeBatch(btchProc, 10);
		Test.stopTest();
    }
}