global class AMS_BatchScheduler_AggregatePwcData implements Schedulable{
	//private static final Integer BATCH_SCOPE = 49;
	private static final Integer BATCH_SCOPE = 200; //new batch handles 200
	
	global void execute(SchedulableContext SC) {
		//check if there are 5 active batch jobs
		//In some cases, might need to add "Status='Queued' " to the criteria
		set<string> setStatusBatch = new set<string>{'Processing','Preparing'};
		if(test.isRunningTest()){
			setStatusBatch.add('Queued');
			test.enqueueBatchJobs(5);
		}
			
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status in: setStatusBatch] < 5){ 
			//Database.executeBatch(new AMS_Batch_AggregatePwcData(), BATCH_SCOPE);
			Database.executeBatch(new ANG_BatchAggregatePwcData(), BATCH_SCOPE);
		} else {
		   //schedule this same schedulable class again in 30 mins
		   Datetime dt = Datetime.now().addMinutes(30);
		   String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
		   Id schedId = System.Schedule('AMS_BatchScheduler_AggregatePwcData_'+timeForScheduler,timeForScheduler,new AMS_BatchScheduler_AggregatePwcData());
		}
	}
}