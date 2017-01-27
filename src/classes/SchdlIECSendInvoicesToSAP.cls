/**  
  * Description: This class contains schedulable class for Sending SAP Invoices to SAP
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
global class SchdlIECSendInvoicesToSAP implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        // check if there are pending batch jobs (limit is 5)
        Integer MAX_BATCHES = 5;
        Integer iRunningBatchJobs = [
            select count()
            from AsyncApexJob
            where JobType = 'BatchApex'
            and status in ('Queued','Processing','Preparing')
        ];
        Integer iRunningBatchSFDCtoSAP = [
            select count()
            from AsyncApexJob
            where JobType = 'BatchApex'
            and ApexClassId = :IEC_SAP_Settings__c.getOrgDefaults().SFDCtoSAPBatchClassId__c
            and status in ('Queued','Processing','Preparing')
        ];
        
        // Only run the job if 
        // - the schedule interface is activated through the custom settings
        // - there is 4 or less batches running
        // - there is no batch running for the class BtchIECSendInvoicesToSAP
        if (IECConstants.SAPSettings_SAPInterfaceActive
            && iRunningBatchJobs < MAX_BATCHES
            && iRunningBatchSFDCtoSAP == 0) {
            BtchIECSendInvoicesToSAP btchProc = new BtchIECSendInvoicesToSAP();
            //*** (Thai 2016-11-02) rewrite query for new behaviour
            btchProc.query =  'select Id, Zuora_Invoice_Number__c, Status__c'
                           + ' from IEC_SAP_Invoice__c'
                           + ' where (Status__c = \'' + IECConstants.IECSAPInvoice_Status_New + '\' or Status__c like \'Retry%\')'
                           +   ' and (Number_of_Zuora_Items__c != null and Number_of_Zuora_Items__c > 0)'
                           +   (Test.isRunningTest() ? ' and Text_Print__c = \'' + IECSAPManager_tst.TEST_FLAG_SUCCESS + '\'' : '')
                           + ' order by CreatedDate';
            Database.executeBatch(btchProc, 1);
            //btchProc.query = Test.isRunningTest() 
            //    ? 'SELECT Billing_City__c, Billing_Country__c, Billing_Name__c, Billing_State__c, Billing_Street__c, Bill_To__c' +
            //        ', Billing_Zip__c, Contract_Start__c, Contract_End__c, Contract_Number__c, CurrencyIsoCode, Customer_PO__c, Dist_Chan__c' +
            //        ', Division__c, Doc_Currency__c, Doc_Type__c, Employee_Responsible__c, Error_Message__c, Order_Reason__c' +
            //        ', PO_Date__c, Pay_Method__c, Pay_Terms__c, Payment_Date__c, Id, SAP_Bill_To_Number__c, Ready_for_SAP__c' +
            //        ', SAP_Contract_Number__c, SAP_Invoice_Clearance_Date__c, SAP_Invoice_Number__c, Sales_Office__c, Payment_Method_Code__c' +
            //        ', Sales_Org__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c, Shipping_State__c, Total_Positive_Quantity__c' +
            //        ', Shipping_Street__c, Shipping_Zip__c, Status__c, Status_Date__c, Text_Print__c, VAT_number__c, Total_Quantity__c' +
            //        ', Name, Zuora_Invoice_Number__c, Billing_Country_ISO_Code__c, Warning_Message__c, Zuora_Billing_Account_ID__c' +
            //        ', Account__r.Sales_Office__c, Account__r.Payment_Term__c' +
            //        ', (SELECT Date_From__c,Date_To__c,Error_Message__c,IEC_SAP_Invoice__c,Material__c,Material_Description__c, Charge_Amount__c' +
            //            ',Profit_Center__c,Quantity__c,Status__c,Status_Date__c,Unit_Price__c,Unit_Price_Currency__c, Name, Adjusted_Charge_Amount__c ' +
            //         'FROM IEC_SAP_Invoice_Items__r) ' +
            //        'FROM IEC_SAP_Invoice__c ' +
            //        'WHERE Status__c = \'' + IECConstants.IECSAPInvoice_Status_New + '\' ' +
            //            'AND Ready_for_SAP__c = true ' +
            //            'AND (Text_Print__c = \'' + IECSAPManager_tst.TEST_FLAG_SUCCESS + '\' or Text_Print__c = \'' + IECSAPManager_tst.TEST_FLAG_ERROR + '\') ' +
            //        'ORDER by CreatedDate'
            //    : 'SELECT Billing_City__c, Billing_Country__c, Billing_Name__c, Billing_State__c, Billing_Street__c, Bill_To__c' +
            //        ', Billing_Zip__c, Contract_Start__c, Contract_End__c, Contract_Number__c, CurrencyIsoCode, Customer_PO__c, Dist_Chan__c' +
            //        ', Division__c, Doc_Currency__c, Doc_Type__c, Employee_Responsible__c, Error_Message__c, Order_Reason__c' +
            //        ', PO_Date__c, Pay_Method__c, Pay_Terms__c, Payment_Date__c, Id, SAP_Bill_To_Number__c, Ready_for_SAP__c' +
            //        ', SAP_Contract_Number__c, SAP_Invoice_Clearance_Date__c, SAP_Invoice_Number__c, Sales_Office__c, Payment_Method_Code__c' +
            //        ', Sales_Org__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c, Shipping_State__c, Total_Positive_Quantity__c' +
            //        ', Shipping_Street__c, Shipping_Zip__c, Status__c, Status_Date__c, Text_Print__c, VAT_number__c, Total_Quantity__c' +
            //        ', Name, Zuora_Invoice_Number__c, Billing_Country_ISO_Code__c, Warning_Message__c, Zuora_Billing_Account_ID__c' +
            //        ', Account__r.Sales_Office__c, Account__r.Payment_Term__c' +
            //        ', (SELECT Date_From__c,Date_To__c,Error_Message__c,IEC_SAP_Invoice__c,Material__c,Material_Description__c, Charge_Amount__c' +
            //            ',Profit_Center__c,Quantity__c,Status__c,Status_Date__c,Unit_Price__c,Unit_Price_Currency__c, Name, Adjusted_Charge_Amount__c ' +
            //         'FROM IEC_SAP_Invoice_Items__r) ' +
            //        'FROM IEC_SAP_Invoice__c ' +
            //        'WHERE Status__c = \'' + IECConstants.IECSAPInvoice_Status_New + '\' ' +
            //            'AND Ready_for_SAP__c = true ' +
            //        'ORDER by CreatedDate';
            //Database.executeBatch(btchProc, 5);
        }
        
        // This section of code will schedule the next execution X minutes from now depending on the configured setting
        
        datetime nextScheduleTime = system.now().addMinutes(IECConstants.SAPSettings_SchedulePeriod);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second());
        string cronvalue = second + ' ' + minute + ' * * * ?' ;
        string jobName = 'SchdlIECSendInvoicesToSAP ' + nextScheduleTime.format('hh:mm');
 
 
          if(Test.isRunningTest())
            jobName = 'Test_'+Datetime.now().time();
 
        system.schedule(jobName, cronvalue , new SchdlIECSendInvoicesToSAP());

 
     
        if (sc != null)
         system.abortJob(sc.getTriggerId());
    }
}