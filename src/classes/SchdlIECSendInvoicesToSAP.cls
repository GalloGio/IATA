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