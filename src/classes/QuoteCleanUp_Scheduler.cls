global class QuoteCleanUp_Scheduler implements Schedulable
{
	global static String doSchedule(String CRON_EXP)
	{
		String jobName = (Test.isRunningTest())? 'Test_'+Datetime.now().time() : 'Quotes older than 3 months cleanup';
		return System.Schedule(jobName, CRON_EXP, new QuoteCleanUp_Scheduler());
	}

	global void execute(SchedulableContext sc)
	{
		Order_Sel orderSelector = new Order_Sel();
		Order_Batch b = new Order_Batch('CleanUpQuotes', orderSelector.getQuotesOlderThan3Months());
		Database.ExecuteBatch(b);
	}
}
