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
		
		//IEC_SAP_Invoice__c SAPInvUpdate = [SELECT Status__c, Error_Message__c FROM IEC_SAP_Invoice__c WHERE Id = :SAPInv.Id];
		
		//System.assertEquals(SAPInvUpdate.Status__c, IECConstants.IECSAPInvoice_Status_SentToSAP, 'Invoice Status must be Sent To SAP. Error: ' + SAPInvUpdate.Error_Message__c);
    }
}