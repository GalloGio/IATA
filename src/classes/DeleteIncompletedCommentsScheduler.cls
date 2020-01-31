global class DeleteIncompletedCommentsScheduler implements Schedulable {

	global void execute(SchedulableContext SC) {
		launchProcess();
	}

	public void launchProcess() {
		try {
			list<Comment__c> listComment = [Select Id From Comment__c where Is_incomplete__c = true];
			//and CreatedDate <= YESTERDAY
			System.debug('*** ' + listComment);
			delete listComment;

		} catch (Exception e) {
			System.debug('ERROR DeleteIncompletedCommentsScheduler: ' + e.getMessage());
			TransformationHelper.sendEmailSupport('FATAL: DeleteIncompletedCommentsScheduler in function launchProcess()  ' ,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
		}
	}

}
