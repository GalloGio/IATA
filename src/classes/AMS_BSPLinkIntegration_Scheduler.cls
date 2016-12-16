global class AMS_BSPLinkIntegration_Scheduler implements Schedulable  {
	//ScheduleCreateCasesFromPWC
	
	private static final Integer BATCH_SCOPE = 90;
	private string sEmail;
	private list<Agency_Authorization__c> lsAuth;
	private string sProcess;
	
	private String batchName;
	
	public AMS_BSPLinkIntegration_Scheduler(string m, list<Agency_Authorization__c> ls, string sPR) {
		this.sEmail = m;
		this.lsAuth = ls;
		this.sProcess = sPR;
	}
	
	global void execute(SchedulableContext SC) {
		AMS_BSPLinkIntegration_Batch batch = new AMS_BSPLinkIntegration_Batch(sEmail, lsAuth, sProcess);
		

		//check if there are 5 active batch jobs
		//In some cases, might need to add "Status='Queued' " to the criteria
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
			Database.executeBatch(batch, BATCH_SCOPE);
		} else {
		   //schedule this same schedulable class again in 30 mins
		   AMS_BSPLinkIntegration_Scheduler bspSc = new AMS_BSPLinkIntegration_Scheduler(sEmail, lsAuth, sProcess);
		   Datetime dt = Datetime.now().addMinutes(10);
		   String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
		   Id schedId = System.Schedule('MatrixRetry'+timeForScheduler,timeForScheduler,bspSc);
		}
	}

}