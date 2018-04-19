global class ANG_FOPOSCARNotificationScheduler implements Schedulable {
	// Will Run Every day and send email and Portal notification if:
	//a) The FOP OSCAR is not submitted by the agent within 15 days (creation date + 15 days) => Reminder
	//b) The FOP OSCAR is not submitted by the agent within 30 days (creation date + 30 days) => Non Compliance

	// Agent hasn't submitted the FOP on the Portal if OSCAR is still assigned to one of these queues:
	private final Set<String> MASS_FOP_QUEUES = new Set<String>{'test'};
	// FOP OSCAR was mass created if Origin ius the following: 
	private final String MASSIVE_FOP_ORIGIN = 'Massive FOP Creation';

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
			//Database.executeBatch(new ANG_BatchAggregatePwcData(), BATCH_SCOPE);
		} else {
		   //schedule this same schedulable class again in 30 mins
		   Datetime dt = Datetime.now().addMinutes(30);
		   String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
		   Id schedId = System.Schedule('ANG_FOPOSCARNotificationScheduler_'+timeForScheduler,timeForScheduler,new ANG_FOPOSCARNotificationScheduler());
		}

		//List<AMS_Oscar__c> oscars = [SELECT Id, Account__c, Contact__r.Email FROM AMS_Oscar__c WHERE Origin__c = :MASSIVE_FOP_ORIGIN AND Owner.Name IN:MASSIVE_FOP_ORIGIN]
	}

}