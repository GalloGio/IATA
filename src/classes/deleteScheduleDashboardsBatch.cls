//Test class coverage by PostCopyScriptTest
global class deleteScheduleDashboardsBatch Implements Database.batchable<sobject>{
	global final string scheduleQuery;
	global deleteScheduleDashboardsBatch(){

		scheduleQuery = 'SELECT Id FROM CronTrigger WHERE  CronJobDetail.JobType = \'A\' OR CronJobDetail.JobType = \'8\' OR CronJobDetail.JobType = \'3\'';
	}

	global Database.QueryLocator start(Database.BatchableContext BC){

	 return Database.getQueryLocator(scheduleQuery);
	}
	global  void execute(Database.BatchableContext BC,List<SObject> scope){
	  for(SObject cronJob : scope){
		System.abortJOb(cronJob.Id);
	  }

   }
   global void finish(Database.BatchableContext BC){
	   System.debug('deleteScheduleDashboardsBatch completed: '+BC);
   }

}