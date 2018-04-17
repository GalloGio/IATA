global class AMP_ChatterDigestScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		//-- SChedule next job execution
		Datetime nextScheduleTime = system.now().addHours(24);
		string month = string.valueof(nextScheduleTime.month());
		string day = string.valueof(nextScheduleTime.day());
		string hour = string.valueof(nextScheduleTime.hour());
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
		string jobName = 'AMP Chatter Email Digest ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

		System.debug(jobName);
		System.schedule(jobName, cronvalue , new AMP_ChatterDigestScheduler());
		// get the number for the day of the Week:  Monday 1..Sunday 7
		Integer dayOfWeek = Integer.valueOf(System.now().format('u'));
		if(dayOfWeek == 7) {
			Id weekId = database.executebatch(new AMP_Batch_EmailChatterDigest('weekly'));
			System.debug(weekId);
		}
		Id dayId = database.executebatch(new AMP_Batch_EmailChatterDigest('daily'));
		System.debug(dayId);
		// this section of code will abort the current schedule job
		System.abortJob(sc.getTriggerId());
	}
}
