global class QuoteCleanUp_Scheduler implements Schedulable 
{
	global static String doSchedule(String CRON_EXP)
	{
		return System.Schedule('Quotes older than 3 months cleanup', CRON_EXP, new QuoteCleanUp_Scheduler());
	}

	global void execute(SchedulableContext sc) 
	{
		Order_Sel orderSelector = new Order_Sel();
		Order_Batch b = new Order_Batch('CleanUpQuotes', orderSelector.getQuotesOlderThan3Months());
		Database.ExecuteBatch(b);
	}
}