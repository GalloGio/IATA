//Test class coverage by PostCopyScriptTest
global class deleteScheduleDashboardsBatch Implements Database.batchable<sobject>{
	global final string scheduleQuery;
	global deleteScheduleDashboardsBatch(){

		if(Test.isRunningTest()){
			scheduleQuery = 'SELECT Id FROM CronTrigger WHERE  CronJobDetail.JobType = \'A\' OR CronJobDetail.JobType = \'8\' OR CronJobDetail.JobType = \'3\' LIMIT 10';
		}else{
			System.debug('#2 deleteScheduleDashboards');
			scheduleQuery = 'SELECT Id FROM CronTrigger WHERE  CronJobDetail.JobType = \'A\' OR CronJobDetail.JobType = \'8\' OR CronJobDetail.JobType = \'3\'';
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC){

	 return Database.getQueryLocator(scheduleQuery);
	}
	global  void execute(Database.BatchableContext BC,List<SObject> scope){
	  for(SObject cronJob : scope){
		System.debug('#3 deleteScheduleDashboards::: '+scope);
		System.abortJOb(cronJob.Id);
	  }

   }
   global void finish(Database.BatchableContext BC){
	   System.debug('deleteScheduleDashboardsBatch completed: '+BC);
   }

}