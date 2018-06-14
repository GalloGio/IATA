/**  
  * Description: This class contains unit tests for the Schedule Job for Processing SAP Invoices
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class SchdlIECSendInvoicesToSAP_tst {

    static testMethod void testSendSAPInvoicesSchdl() {
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
    
    static testMethod void testSendSAPInvoicesBatch() {
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
    	/*
    	IEC_SAP_Invoice__c SAPInv = IECTestUtil.CreateSampleSAPInvoice(null);
    	SAPInv.Status__c = IECConstants.IECSAPInvoice_Status_New;
    	SAPInv.Billing_Country__c = 'Canada';
    	SAPInv.Billing_Country_ISO_Code__c = 'CA';
    	SAPInv.Billing_Name__c = 'Ted';
    	insert SAPInv;
    	
    	IEC_SAP_Invoice_Item__c SAPInvItem = new IEC_SAP_Invoice_Item__c (
    		Charge_Amount__c = 10
    		, Date_From__c = Date.today()
    		, Date_To__c = Date.today().addMonths(1)
    		, IEC_SAP_Invoice__c = SAPInv.Id
    		, Material__c = 'TST'
    		, Material_Description__c = 'TST'
    		, Profit_Center__c = 'TST'
    		, Quantity__c = 1
    		, Status__c = 'SAP Ready'
    		, Status_Date__c = Date.today()
    		, Unit_Price__c = 10
    		, Unit_Price_Currency__c = 'USD'
    		, Use_Contract__c = true
    	);
    	insert SAPInvItem;
        
		Test.startTest();
        // Set up batch job
		BtchIECSendInvoicesToSAP btchProc = new BtchIECSendInvoicesToSAP();
		btchProc.query = 'SELECT Billing_City__c, Billing_Country__c, Billing_Name__c, Billing_State__c, Billing_Street__c, Bill_To__c, Zuora_Invoice_ID__c' +
					', Billing_Zip__c, Contract_Start__c, Contract_End__c, Contract_Number__c, CurrencyIsoCode, Customer_PO__c, Dist_Chan__c' +
					', Division__c, Doc_Currency__c, Doc_Type__c, Employee_Responsible__c, Error_Message__c, Order_Reason__c, Total_Amount__c' +
					', PO_Date__c, Pay_Method__c, Pay_Terms__c, Payment_Date__c, Id, SAP_Bill_To_Number__c, Ready_for_SAP__c' +
					', SAP_Contract_Number__c, SAP_Invoice_Clearance_Date__c, SAP_Invoice_Number__c, Sales_Office__c, Payment_Method_Code__c' +
					', Sales_Org__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c, Shipping_State__c, Total_Positive_Quantity__c' +
					', Shipping_Street__c, Shipping_Zip__c, Status__c, Status_Date__c, Text_Print__c, VAT_number__c, Total_Quantity__c' +
					', Name, Zuora_Invoice_Number__c, Billing_Country_ISO_Code__c, Warning_Message__c, Zuora_Billing_Account_ID__c' +
                    ', Account__r.Sales_Office__c, Account__r.Payment_Term__c' +
					', (SELECT Date_From__c,Date_To__c,Error_Message__c,IEC_SAP_Invoice__c,Material__c,Material_Description__c, Charge_Amount__c' +
						',Profit_Center__c,Quantity__c,Status__c,Status_Date__c,Unit_Price__c,Unit_Price_Currency__c, Name, Adjusted_Charge_Amount__c ' +
                        ', Product__r.IEC_SAP_DocType__c, Product__r.Product_Manager_lookup__r.EmployeeNumber, Product__r.SAP_Contract_OrderReason__c ' +
					 'FROM IEC_SAP_Invoice_Items__r) ' +
					'FROM IEC_SAP_Invoice__c ' +
					'WHERE Status__c = \'' + IECConstants.IECSAPInvoice_Status_New + '\' ' +
						'AND Text_Print__c = \'' + IECSAPManager_tst.TEST_FLAG_SUCCESS + '\' ' +
					'ORDER by CreatedDate';

                System.debug('btchProc.query::'+btchProc.query);

		Database.executeBatch(btchProc, 50);
		Test.stopTest();
		*/
		//IEC_SAP_Invoice__c SAPInvUpdate = [SELECT Status__c, Error_Message__c FROM IEC_SAP_Invoice__c WHERE Id = :SAPInv.Id];
		
		//System.assertEquals(SAPInvUpdate.Status__c, IECConstants.IECSAPInvoice_Status_SentToSAP, 'Invoice Status must be Sent To SAP. Error: ' + SAPInvUpdate.Error_Message__c);
    }
}