global class ams2gdp_Scheduler implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		Boolean isActiveAMS2GDPSync = AMS_2_GDP_Settings__c.getOrgDefaults().Activate_Sync__c;
		Integer schedule_periode = Integer.valueOf(AMS_2_GDP_Settings__c.getOrgDefaults().Schedule_Period__c);

		if(isActiveAMS2GDPSync)
		{
			run();
		}

		//-- SChedule next job execution
		Datetime nextScheduleTime = system.now().addHours(schedule_periode);
		string month = string.valueof(nextScheduleTime.month());
		string day = string.valueof(nextScheduleTime.day());
		string hour = string.valueof(nextScheduleTime.hour());
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
		string jobName = 'AMS => GDP Sync ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

		System.schedule(jobName, cronvalue , new ams2gdp_Scheduler());

		// this section of code will abort the current schedule job
		System.abortJob(sc.getTriggerId());

	}

	public static void run()
	{
		Database.executeBatch(new ams2gdp_Batch_Account(true,false,false));
	}
}