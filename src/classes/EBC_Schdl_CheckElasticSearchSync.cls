/*
* Retrieve Now_Date Count for Agent and Agency from Elastic
* Requirement:         Count of Agency Now_Date = TODAY
* Count of Agency Now_Date != TODAY
* Count of Agent Now_Date = TODAY
* Count of Agent Now_Date != TODAY
* Log the results in EBC Setup (Record Name = Default)
* Create 1 new Section on Page Layout called “Elastic Refresh – Control Values”

* Create 4 new fields placed under this new section
* -         Elastic Count Control – Agency/Today
* -         Elastic Count Control – Agency/Not Today
* -         Elastic Count Control – Agent/Today
* -         Elastic Count Control – Agent/Not Today
* Call to Elastic runs daily at 11:30AM Montreal Time.
*/
global class EBC_Schdl_CheckElasticSearchSync implements Schedulable {
   //set the parameters
  
   global EBC_Schdl_CheckElasticSearchSync(){
     System.debug('Scheduler init EBC_Schdl_CheckElasticSearchSync');
  
   }
 
   global void execute(SchedulableContext sc) {
       
        System.debug('Scheduler exec EBC_Schdl_CheckElasticSearchSync ' );
        EBC_Batch_CheckElasticSearchSync BDel = new EBC_Batch_CheckElasticSearchSync();
        ID batchprocessid = Database.executeBatch(BDel,200);
        System.debug('Returned batch process ID: ' + batchProcessId);
        //System.abortJob(sc.getTriggerId());
   }
   
   public static void reschedule() 
   {
        system.debug('Re-Schedule Job EBC_Schdl_CheckElasticSearchSync');
        run(true);
   }
   public static void cancel()
   {
        system.debug('Cancel Job EBC_Schdl_CheckElasticSearchSync');
        String jobname = 'EBC_Schdl_CheckElasticSearchSync';
        if (Test.isRunningTest()) jobname +='_Test';
        List<CronTrigger> ctlist = new List<CronTrigger>();
        ctlist = [ SELECT Id
              FROM CronTrigger 
              Where CronJobDetail.Name = :jobname LIMIT 1];
        if (ctlist.size()==0) return;
        System.abortJob(ctlist[0].Id);
           
    }
    private static void run(Boolean isYetToComplete) {
        //
        String jobname = 'EBC_Schdl_CheckElasticSearchSync';
        if (Test.isRunningTest()) jobname +='_Test';
        String sch = '0 0 8 * * ?';
        List<CronTrigger> ctlist = new List<CronTrigger>();
        ctlist = [ SELECT Id
              ,CronJobDetail.Id
              ,CronJobDetail.Name
              ,CronJobDetail.JobType 
              FROM CronTrigger 
              Where CronJobDetail.Name = :jobname LIMIT 1];
        
        //if exist it means it is currently processing 
        system.debug('****Job****' + jobname);
        if (ctlist.size()>0 && !isYetToComplete) return;
        
        if (ctlist.size()>0) cancel();
        
        system.debug('****Schedule Job****');
        
        EBC_Schdl_CheckElasticSearchSync btch = new EBC_Schdl_CheckElasticSearchSync();
       
        Datetime nextScheduleTime = system.now().addHours(3);
        string month = string.valueof(nextScheduleTime.month());
        string day = string.valueof(nextScheduleTime.day());
        string hour = string.valueof(nextScheduleTime.hour());
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
        
        system.debug('****jobname****'+jobname);
        system.debug('****cronvalue****'+cronvalue);
        system.debug('****btch****'+btch);
        
    String jobID = System.schedule(jobname, cronvalue, btch);
  }
    
}