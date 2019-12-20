/**
  * Description: This class contains schedulable class for compiling live usage
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
  */
global class SchdlIECCompileUsage implements Schedulable {

	global void execute(SchedulableContext sc) {

		// check if there are pending batch jobs (limit is 5)
		Integer MAX_BATCHES = 5;
		Integer iRunningBatchJobs = [
			select count()
			from AsyncApexJob
			where JobType = 'BatchApex'
			and status in ('Queued','Processing','Preparing')];

		// Check if this scheduled process is already running
		Integer iRunningScheduledUsageCompiler = [
			SELECT count()
			FROM AsyncApexJob
			WHERE JobType = 'ScheduledApex'
				AND ApexClassId = :IEC_Settings__c.getOrgDefaults().SchdlIECCompileUsage_Class_ID__c
				AND status = 'Processing']; //in ('Queued','Processing','Preparing')];


		// Only run the job if
		// - there is 4 or less batches running
		if (iRunningBatchJobs < MAX_BATCHES && iRunningScheduledUsageCompiler == 0) {

			BtchIECCompileUsage btchProc = new BtchIECCompileUsage();
			btchProc.dtTargetEndDate = Date.today();

			Database.executeBatch(btchProc, 100);
		}
		else if (iRunningBatchJobs >= MAX_BATCHES)
			throw new IECApplicationException('Cannot start scheduled process SchdlIECCompileUsage. Maximum number of Batch Apex limit reached: ' + String.valueOf(iRunningBatchJobs));
		else if (iRunningScheduledUsageCompiler > 0)
			throw new IECApplicationException('Cannot start scheduled process SchdlIECCompileUsage because it is already running or waitin (status: Queued, Processing or Preparing)');

		// This section of code will schedule the next execution X minutes from now depending on the configured setting

		datetime nextScheduleTime = system.now().addDays(1);

		string month = string.valueof(nextScheduleTime.month());
		string day = string.valueof(nextScheduleTime.day());
		string hour = string.valueof(nextScheduleTime.hour());
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second());

		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
		string jobName = 'SchdlIECCompileUsage ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
		system.schedule(jobName, cronvalue , new SchdlIECCompileUsage());

		// this section of code will abort the current schedule job
		system.abortJob(sc.getTriggerId());

	}
}
