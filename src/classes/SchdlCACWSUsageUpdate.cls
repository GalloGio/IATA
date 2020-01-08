/**
  * Description: This class schedule the sync (update) on CACWeb usage counter
  *   the actual update is performed by the batch class BtchCACWSUsageUpdate
  *
  * Original Author: Abdellah Bellahssan/Bhargavi Rayavarapu
  *
  * History:
  *   20160223: initial version
  *   20160609-sl: bug fix: this should schedule another run on this class (SchdlCACWSUsageUpdate) instead of SchdlIECCompileUsage
  *
  */

global class SchdlCACWSUsageUpdate implements Schedulable {

	private static integer HOUR_DELAY_BETWEEN_JOBS = 24; // number of hours for the next scheduled run

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
				AND ApexClassId = :IEC_Settings__c.getOrgDefaults().SchdlCACWSUsageUpdate_Class_ID__c
				AND status = 'Processing']; //in ('Queued','Processing','Preparing')];


		// Only run the job if
		// - there is 4 or less batches running
		if (iRunningBatchJobs < MAX_BATCHES && iRunningScheduledUsageCompiler == 0) {

			BtchCACWSUsageUpdate btchProc = new BtchCACWSUsageUpdate();
			Database.executeBatch(btchProc, 100);
		}
		else if (iRunningBatchJobs >= MAX_BATCHES)
			throw new IECApplicationException('Cannot start scheduled process SchdlCACWSUsageUpdate. Maximum number of Batch Apex limit reached: ' + String.valueOf(iRunningBatchJobs));
		else if (iRunningScheduledUsageCompiler > 0)
			throw new IECApplicationException('Cannot start scheduled process SchdlCACWSUsageUpdate because it is already running or waitin (status: Queued, Processing or Preparing)');

		// This section of code will schedule the next execution X minutes from now depending on the configured setting

		datetime nextScheduleTime = system.now().addHours(HOUR_DELAY_BETWEEN_JOBS);

		string month = string.valueof(nextScheduleTime.month());
		string day = string.valueof(nextScheduleTime.day());
		string hour = string.valueOf(nextScheduleTime.hour());
		string minute = '10';
		string second = '0';

		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
		string jobName = 'SchdlCACWSUsageUpdate ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
		system.schedule(jobName, cronvalue , new SchdlCACWSUsageUpdate());

		// this section of code will abort the current schedule job
		system.abortJob(sc.getTriggerId());

	} // end of execute

} // end of class SchdlCACWSUsageUpdate
