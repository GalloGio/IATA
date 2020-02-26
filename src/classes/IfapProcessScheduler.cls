global class IfapProcessScheduler implements Schedulable{

	public boolean isExtraExecution = false;

	global void execute(SchedulableContext SC){
		try{
			//  system.abortJob(SC.getTriggerId());
			system.debug(LoggingLevel.ERROR, 'IfapProcessScheduler '+(isExtraExecution?'Extra execution':''));

			if(isExtraExecution){
				TransformationHelper.sendEmailSupport('job aborted', 'Too many process at the same time re-running');
				system.abortJob(SC.getTriggerId());
			}
			List<AsyncApexJob> aajs = [SELECT Id FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Queued' OR Status = 'Processing')];
			if(aajs.size()>=5){
				system.debug(LoggingLevel.ERROR, 'There are already 5 processes in the queue and it\'t not possible to schedule the batch. I\'ll try again in a minute');
				launchExtraSchedule();

			}else{
				system.debug(LoggingLevel.ERROR, 'Launching batch for processing results and rejections!');
				System.enqueueJob(new IfapProcessResultsQueueable());
				System.enqueueJob(new IfapProcessRejectionsQueueable());
			}
			List<AsyncApexJob> aajsh = [SELECT Id FROM AsyncApexJob WHERE Status = 'Holding'];
			string message = 'The batch IfapProcessBatch has been scheduled but there are '+aajsh.size()+' batches in status "Holding" and no one with status "Processing" or "Queued".\n'+
					'Please have a check to ensure that everything is ok.';
			if(aajsh.size()>=10 && aajs.size()==0)
				TransformationHelper.sendEmailSupport('More than 10 Batches in Holding status', message);
		}catch(Exception e){
			TransformationHelper.sendEmailSupport('FATAL: IfapProcessScheduler', e.getMessage() + '   ' + e.getStackTraceString());
		}

	}

	public static void launchExtraSchedule() {
		IfapProcessScheduler scheduler = new IfapProcessScheduler();
		scheduler.isExtraExecution = true;
		DateTime dt = DateTime.now();
		dt = dt.addminutes(1);
		String ora = String.valueOf(dt.second() +' ' + dt.minute() + ' ' + dt.hour() + ' * * ? *');
		Id sId1 = system.schedule('IfapProcessScheduler Extra '+dt.getTime(), ora, scheduler);
	}

	public static void sendErrorEmail(String title, List<String> listErrors) {
		if ( listErrors == null || listErrors.isEmpty() ) {
			return;
		}
		Datetime n = Datetime.now();
		String processTime = ' '+n.year()+'-'+n.month()+'-'+n.day()+' '+n.hour()+':'+n.minute();
		String message = 'The batch for processing IFAP files returned the following errors: \n\n';
		for(string err : listErrors) {
			message += err+'\n';
		}
		TransformationHelper.sendEmailSupport(title + processTime, message);
	}

}
