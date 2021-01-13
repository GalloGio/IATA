global class SurveyBatchScheduler implements Schedulable {

	public List<String> errors {get;set;}
	public boolean isExtraExecution = false;


	global void execute(SchedulableContext SC){
		system.debug(LoggingLevel.ERROR, 'SurveyBatchScheduler '+(isExtraExecution?'Extra execution':''));

		if(isExtraExecution)
			system.abortJob(SC.getTriggerId());


		List<AsyncApexJob> aajs = [SELECT Id, JobType, ApexClass.Name, Status FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Queued' OR Status = 'Processing')];
		if(aajs.size()>=5){
			system.debug(LoggingLevel.ERROR, 'There are already 5 processes in the queue and it\'t not possible to schedule the batch. I\'ll try again in a minute');

			SurveyBatchScheduler scheduler = new SurveyBatchScheduler();
			scheduler.isExtraExecution = true;
			DateTime dt = DateTime.now();
			dt = dt.addminutes(1);
			String ora = String.valueOf(dt.second() +' ' + dt.minute() + ' ' + dt.hour() + ' * * ? *');
			Id sId1 = system.schedule('SurveyBatchScheduler Extra '+dt.getTime(), ora, scheduler);


		}else{
			system.debug(LoggingLevel.ERROR, 'Launching SurveyBatch!');

			SurveyBatch batch = new SurveyBatch();
			Database.executeBatch(batch, 10);
		}

	}
}
