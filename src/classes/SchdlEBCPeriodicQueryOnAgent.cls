/**
	* Description: This class schedules the Agent/ID_Card query.
	*   The intention is simply to refresh the recent query 'cache' in Salesforce
	*
	* Author: Sonny Leman
	*
	* History:
	*   20160613-sl: initial version
	*
	* Global constants that might be added:
	*  - EBCPeriodicAgentQuery_ScheduleActive = true, before calling executeEbcCountBatch
	*  - EBCPeriodicAgentQuery_Period = 10 (minutes), for setting nextScheduleTime
	*
	*/

global class SchdlEBCPeriodicQueryOnAgent {

	global void execute(SchedulableContext sc) {
		try {
			executeEbcCountBatch();

			// This section of code will schedule the next execution X hours from now depending on the configured setting
			datetime nextScheduleTime = system.now().addMinutes(10);
			//datetime nextScheduleTime = system.now().addMinutes(IECConstants.EBCPeriodicAgentQuery_Period);

			string month = string.valueof(nextScheduleTime.month());
			string day = string.valueof(nextScheduleTime.day());
			string hour = string.valueof(nextScheduleTime.hour());
			string minute = string.valueof(nextScheduleTime.minute());
			string second = string.valueof(nextScheduleTime.second ());
			string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
			string jobName = 'SchdlEBCPriodicQueryOnAgent ' + (Test.isRunningTest() ? 'Test' : '') + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

			system.schedule(jobName, cronvalue , new SchdlEBCAgencyCacheRefresh());

			// this section of code will abort the current schedule job
			system.abortJob(sc.getTriggerId());
		}
		catch (Exception ex) {
			IECErrorLogger.logError(null, 'Error while starting SchdlEBCPriodicQueryOnAgent schedule.', ex.getMessage(), null, 'SchdlEBCAgencyCacheRefresh', ex.getStackTraceString());
			throw ex;
		}
	} // end of execute


	// ========================================================================
	// executeEbcCountBatch()
	private static void executeEbcCountBatch()
	{
		List<AggregateResult> res = [SELECT COUNT_DISTINCT(Email__c)
										FROM ID_Card__c];


	} // executedEbcCountBatch

} //
