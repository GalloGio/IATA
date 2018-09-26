global class IEC_ZuoraPricing2SAP_Scheduler implements Schedulable
{
    //****************************************************************************************************
    //  Schedule job to send Zuora pricing to SAP
    //****************************************************************************************************


    // schedule job to track changes of Zuora pricing and to send pricing information to SAP
    global static String scheduleNextJob()
    {
        //*** build unique job name
        String strJobName = 'IEC_ZuoraPricing2SAP_' + system.now().format('yyyyMMddHHmmss') + (Test.isRunningTest() ? '_test' : '');

        //*** build CRON expression
        Integer intInterval = Utility.getIntegerSetting('ZuoraPricing2SAP Schedule Frequency');
        if (intInterval == 0)
            intInterval = 1440;   // default job frequency expressed by number of minutes - 1440 for 1 day
        List<String> lstTime = system.now().addMinutes(intInterval).format('HH:mm').split(':');
        String strCRON = '0 ' + lstTime[1] + ' ' + lstTime[0] + ' * * ?';

        //*** schedule job
        return system.schedule(strJobName, strCRON , new IEC_ZuoraPricing2SAP_Scheduler());
    }


    // execute batch to track changes of Zuora pricing and to send pricing information to SAP
    global void execute(SchedulableContext sc) 
    {
        // execute batch
        Database.executeBatch(new IEC_ZuoraPricing2SAP_Batch(IEC_ZuoraPricing2SAP_Batch.processingStep1), 2000);

        //*** delete current job and reschedule
        if (sc != null)
            system.abortJob(sc.getTriggerId());
        IEC_ZuoraPricing2SAP_Scheduler.scheduleNextJob();
    }
}