/*
* GSS Application – Create a SFDC Job to build relation between GDP File Deliveries and Subscription
* Requirement:Each time a subscription is re-built (for example at renewal), the linkage between the GDP 
* File Deliveries (a73) and the related Subscription are lost.
* Create an hourly job in SFDC that will:
*  - Fetch “GDP File Delivery” (a73) WHERE “GSS_Subscription_Detail__c” IS NOT Blank AND “Subscription__c” 
*    IS Blank
*  - Populate “Subscription__c” with value found in “GSS_Subscription_Detail__c” to re-create 
*    linkage to related subscription
*/
global class GSS_Schdl_SubscriptionRecreateLink implements Schedulable {
   //set the parameters
  
   global GSS_Schdl_SubscriptionRecreateLink(){
     System.debug('Scheduler init GSS_Schdl_SubscriptionRecreateLink');
  
   }
 
   global void execute(SchedulableContext sc) {
       
        System.debug('Scheduler exec GSS_Schdl_SubscriptionRecreateLink ' );
        GSS_Batch_SubscriptionRecreateLink BDel = new GSS_Batch_SubscriptionRecreateLink();
        ID batchprocessid = Database.executeBatch(BDel,200);
        System.debug('Returned batch process ID: ' + batchProcessId);
        //System.abortJob(sc.getTriggerId());
   }
   
   public static void reschedule() 
   {
        system.debug('Re-Schedule Job GSS_Schdl_SubscriptionRecreateLink');
      	run(true);
   }
   public static void cancel()
   {
        system.debug('Cancel Job GSS_Schdl_SubscriptionRecreateLink');
        String jobname = 'GSS_Schdl_SubscriptionRecreateLink';
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
        String jobname = 'GSS_Schdl_SubscriptionRecreateLink';
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
        
        GSS_Schdl_SubscriptionRecreateLink btch = new GSS_Schdl_SubscriptionRecreateLink();
       
        Datetime nextScheduleTime = system.now().addMinutes(5);
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