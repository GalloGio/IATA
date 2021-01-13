/**
	* Description: This class schedule the creation and deletion of EBC_Account Notification for Renewal Offering
	* Author: Sonny Leman
	*
	* Related class
	*  - BtchEBCCreateNotificationForRenewal
	*
	* Note:
	*  - For simplicity, current version need to be scheduled manually on Salesforce
	*  - Scheduled every day
	*
	* History:
	*   20160825-sl: initial version
	*
	*/

global class SchdlEBCCreateNotificationForRenewal implements Schedulable {

	global void execute(SchedulableContext sc) {
		try {
			// Only run the job if the schedule interface is activated through the custom settings

			BtchEBCCreateNotificationForRenewal.callBatchEBCCreateNotification();

			/*
			// the following is used if we want the job to auto reschedule


			// This section of code will schedule the next execution X hours from now depending on the configured setting
			Datetime nextScheduleTime = system.now().addMonths(1);
			//datetime nextScheduleTime = system.now().addMinutes(IECConstants.EBCPeriodicAgencyQuery_Period);
			string month = string.valueof(nextScheduleTime.month());
			string day = string.valueof(1);
			string hour = string.valueof(nextScheduleTime.hour());
			string minute = string.valueof(nextScheduleTime.minute());
			string second = string.valueof(nextScheduleTime.second ());
			string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
			string jobName = 'SchdlEBCCreateNotificationForRenewal ' + (Test.isRunningTest() ? 'Test' : '') + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

			System.schedule(jobName, cronvalue , new SchdlEBCCreateNotificationForRenewal());

			// this section of code will abort the current schedule job
			System.abortJob(sc.getTriggerId());
			*/
		}
		catch (Exception ex) {
			System.debug('Error on SchdlEBCCreateNotificationForRenewal. Exception:'+ ex);
			IECErrorLogger.logError(null, 'Error while starting SchdlEBCCreateNotificationForRenewal schedule.', ex.getMessage(), null, 'SchdlEBCCreateNotificationForRenewal', ex.getStackTraceString());
			//throw ex;
		}
	} // end of execute


}
