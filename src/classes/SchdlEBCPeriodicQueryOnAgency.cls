/**
	* Description: This class schedule the Agency/GDP_Products_Account_View query.
	*   The intention is simply to refresh the recent query 'cache' in Salesforce
	*
	* Author: Sonny Leman
	*
	* History:
	*   20160613-sl: initial version
	*
	* Global constants that might be added:
	*  - EBCPeriodicAgencyQuery_ScheduleActive = true, before calling executeEbcCountBatch
	*  - EBCPeriodicAgencyQuery_Period = 10 (minutes), for setting nextScheduleTime
	*
	*/

global class SchdlEBCPeriodicQueryOnAgency implements Schedulable {

	global void execute(SchedulableContext sc) {
		try {
			// Only run the job if the schedule interface is activated through the custom settings

			//optional: add here if (IECConstants.EBCPeriodicAgencyQuery_ScheduleActive)
			executeEbcCountBatch();

			// This section of code will schedule the next execution X hours from now depending on the configured setting
			Datetime nextScheduleTime = system.now().addMinutes(10);
			//datetime nextScheduleTime = system.now().addMinutes(IECConstants.EBCPeriodicAgencyQuery_Period);
			string month = string.valueof(nextScheduleTime.month());
			string day = string.valueof(nextScheduleTime.day());
			string hour = string.valueof(nextScheduleTime.hour());
			string minute = string.valueof(nextScheduleTime.minute());
			string second = string.valueof(nextScheduleTime.second ());
			string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
			string jobName = 'SchdlEBCAgencyCacheRefresh ' + (Test.isRunningTest() ? 'Test' : '') + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

			System.schedule(jobName, cronvalue , new SchdlEBCAgencyCacheRefresh());

			// this section of code will abort the current schedule job
			System.abortJob(sc.getTriggerId());
		}
		catch (Exception ex) {
			IECErrorLogger.logError(null, 'Error while starting SchdlEBCPeriodicQueryOnAgency schedule.', ex.getMessage(), null, 'SchdlEBCPeriodicQueryOnAgency', ex.getStackTraceString());
			throw ex;
		}
	} // end of execute


	// ========================================================================
	// executeEbcCountBatch()
	// this is where the query or batch (if needed) will be called
	private static void executeEbcCountBatch()
	{
		//List<AggregateResult> res1 = [SELECT COUNT_DISTINCT(Email_Address__c)
		//								FROM GDP_Products_Account_View__c ];

		List<AggregateResult> res = [SELECT COUNT_DISTINCT(Email_Address__c)
										FROM GDP_Products_Account_View__c
										WHERE Id in (select GDP_Products_Account_View__c FROM ID_Card__c)];

	} // executeGdpReplicateAccountBatch
} // end of SchdlEBCPeriodicQueryOnAgency
