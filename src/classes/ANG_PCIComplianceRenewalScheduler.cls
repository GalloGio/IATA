global class ANG_PCIComplianceRenewalScheduler implements Schedulable {
	// Will Run Every day and call ANG_PCIComplianceRenewalBatch

	private static final Integer BATCH_SCOPE = 200;

	global void execute(SchedulableContext sc) {

		//check if there are 5 active batch jobs
		//In some cases, might need to add "Status='Queued' " to the criteria
		Set<String> setStatusBatch = new Set<String>{'Processing','Preparing'};
		if(Test.isRunningTest()){
			setStatusBatch.add('Queued');
			test.enqueueBatchJobs(5);
		}
			
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status in: setStatusBatch] < 5){ 
			Database.executeBatch(new ANG_PCIComplianceRenewalBatch(), BATCH_SCOPE);
		} else {
		   //schedule this same schedulable class again in 30 mins
		   Datetime dt = Datetime.now().addMinutes(30);
		   String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
		   Id schedId = System.Schedule('ANG_PCIComplianceRenewalBatch_'+timeForScheduler,timeForScheduler,new ANG_PCIComplianceRenewalScheduler());
		}

	}

}