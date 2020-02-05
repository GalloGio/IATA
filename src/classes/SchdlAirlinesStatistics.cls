/*****************************************************************
@ Last Modified By : Bhargavi Rayavarapu
@ Last Modified Date : 2016-03-30
@ Description : This is the schedular class to schedule the batch 'BtchAirlinesStatistics'.
This match is to be run once in every 6 months and at 3:00 am.
*******************************************************************/
global class SchdlAirlinesStatistics implements Schedulable {

	global void execute(SchedulableContext sc) {
		// Schedule the batch
		BtchAirlinesStatistics btchProc = new BtchAirlinesStatistics();
		Database.executeBatch(btchProc, 100);

		datetime nextScheduleTime = system.now().addMonths(6);

		string month = string.valueof(nextScheduleTime.month());
		string day = string.valueof(nextScheduleTime.day());
		string hour = '3';
		string minute = '0';
		string second = '0';

		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
		string jobName = 'SchdlAirlinesStatistics ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
		system.schedule(jobName, cronvalue , new SchdlIECCompileUsage());

		// this section of code will abort the current schedule job
		system.abortJob(sc.getTriggerId());
	}
}
