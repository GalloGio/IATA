global class InterlineAgreementsMemorandumsSchedule implements Schedulable {

	// Prepare launch for first day of each month
	global static String doSchedule() {
		String jobName = (Test.isRunningTest())? 'Test_'+Datetime.now().time() : 'Interline Agreements Memorandum ' + Date.today();
		String cron = '0 0 1 * * ?';
		return System.Schedule(jobName, cron, new InterlineAgreementsMemorandumsSchedule());
	}

	global void execute(SchedulableContext sc) {
		createMemorandums();
	}

	public void createMemorandums() {
		DateTime fromDate = DateTime.now().addMonths(-1);

		InterlineAgreementsMemorandumsBatch batch = new InterlineAgreementsMemorandumsBatch(fromDate);
		System.enqueueJob(batch);
	}

}
