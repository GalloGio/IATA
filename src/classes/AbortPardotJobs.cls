global class AbortPardotJobs implements Schedulable {
	global void execute(SchedulableContext ctx) {
		List<AsyncApexJob> asyncJobs= [SELECT ApexClass.Name, Id, JobType, Status FROM AsyncApexJob where status = 'Processing' and ApexClass.Name = 'AsyncRequestBatchProcessor' and JobType = 'BatchApex' order by CreatedDate ASC];
		If(asyncJobs.size()>2 || Test.isRunningTest()){
			for (Integer i = 2; i < asyncJobs.size(); i++) {
				System.abortJob(asyncJobs.get(i).Id);
			}
		}
	}
}