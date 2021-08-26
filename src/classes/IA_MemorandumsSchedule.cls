/**
 * Schedulable class to be executed in a monthly basis to generate memorandum files for Interline Agreements
 * Check related class IA_MemorandumsBatch which is responsible of the actual generation and saving action
 */
global class IA_MemorandumsSchedule implements Schedulable {

	// Prepare launch for first day of each month
	global static String doSchedule() {
		String jobName = (Test.isRunningTest())? 'Test_'+Datetime.now().time() : 'Interline Agreements Memorandum ' + Date.today();
		String cron = '0 0 1 * * ?';
		return System.Schedule(jobName, cron, new IA_MemorandumsSchedule());
	}

	global void execute(SchedulableContext sc) {
		createMemorandums();
	}

	public void createMemorandums() {
		DateTime fromDate = DateTime.now().addMonths(-1);

		IA_MemorandumsBatch batch = new IA_MemorandumsBatch(fromDate);
		System.enqueueJob(batch);
	}

}
