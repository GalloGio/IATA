/**
	* Description: This class schedule the Agency/GDP_Products_Account_View query.
	*   The intention is simply to refresh the recent query 'cache' in Salesforce
	*
	* Author: Sonny Leman
	*
	* History:
	*   20160607-sl: initial version
	*
	* Global constants used:
	*  - EBCPeriodicAgencyQuery_ScheduleActive
	*  - EBCPeriodicAgencyQuery_Period
	*
	*/

global class SchdlEBCAgencyCacheRefresh implements Schedulable {
		global void execute(SchedulableContext sc) {
				try {
						// Only run the job if the schedule interface is activated through the custom settings
						if (true)
						{
						//if (IECConstants.EBCPeriodicAgencyQuery_ScheduleActive)
								executeEbcCountBatch();
						}

						// This section of code will schedule the next execution X hours from now depending on the configured setting
						datetime nextScheduleTime = system.now().addMinutes(10);
						//datetime nextScheduleTime = system.now().addMinutes(IECConstants.EBCPeriodicAgencyQuery_Period);
						string month = string.valueof(nextScheduleTime.month());
						string day = string.valueof(nextScheduleTime.day());
						string hour = string.valueof(nextScheduleTime.hour());
						string minute = string.valueof(nextScheduleTime.minute());
						string second = string.valueof(nextScheduleTime.second ());
						string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
						string jobName = 'SchdlEBCAgencyCacheRefresh ' + (Test.isRunningTest() ? 'Test' : '') + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

						system.schedule(jobName, cronvalue , new SchdlEBCAgencyCacheRefresh());

						// this section of code will abort the current schedule job
						system.abortJob(sc.getTriggerId());
				}
				catch (Exception ex) {
						IECErrorLogger.logError(null, 'Error while starting SchdlEBCAgencyCacheRefresh schedule.', ex.getMessage(), null, 'SchdlEBCAgencyCacheRefresh', ex.getStackTraceString());
						throw ex;
				}
		} // end of execute


		// ========================================================================
		// executeEbcCountBatch()
		// this is made public to ease the call in testing
		public static void executeEbcCountBatch()
		{
				BtchEBCCountGdpAgencies btchProc = new BtchEBCCountGdpAgencies();
				btchProc.query = 'SELECT COUNT() FROM GDP_Products_Account_View__c '
			+ ' ';
			 Database.executeBatch(btchProc);
		} // executeGdpReplicateAccountBatch
}
