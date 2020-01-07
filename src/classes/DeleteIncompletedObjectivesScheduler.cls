global class DeleteIncompletedObjectivesScheduler implements Schedulable {

	global void execute(SchedulableContext SC) {
		launchProcess();
	}

	public void launchProcess() {
		try {
			list<Objective__c> listObjective = [Select Id From Objective__c where is_Incomplete__c  = true ];
			//and CreatedDate <= YESTERDAY
			System.debug('*** ' + listObjective);
			delete listObjective;

		} catch (Exception e) {
			System.debug('ERROR DeleteIncompletedObjectivesScheduler: ' + e.getMessage());
			TransformationHelper.sendEmailSupport('FATAL: DeleteIncompletedObjectivesScheduler in function launchProcess()  ' ,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
		}
	}

}
