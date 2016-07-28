/**
 * Schedule cleanin up of renewal notification based on a parameter in the settings
 **/
 
global class RenewalNotificationCleanUp_Scheduler implements Schedulable 
{
	// Initialize a schedule task to cleanup the renewal notification
	global static String doSchedule(String CRON_EXP)
	{
		return System.Schedule('Renewal Notifications cleanup', CRON_EXP, new RenewalNotificationCleanUp_Scheduler());
	}

	// On execution, run a batch job that is responsible of cleaning up old renewal notifications
	global void execute(SchedulableContext sc) 
	{
		Order_Sel orderSelector = new Order_Sel();
		Order_Batch b = new Order_Batch('CleanUpRenewalNotifications', orderSelector.getRenewalNotificationsForCleanUp());
		Database.ExecuteBatch(b);
	}
}