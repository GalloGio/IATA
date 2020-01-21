/**
	* Description: This class contains batchable class for compiling the daily usage
	* Note: Using batch to avoid two issues:
	*		1- Supporting Callout on Schedulable Jobs
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*/
global class BtchIECCompileUsage implements Database.Batchable<sObject> {

	public Date dtTargetEndDate;

	global Iterable<sObject> start(Database.BatchableContext BC){

		// if no target end date was set, default to today
		if (dtTargetEndDate == null)
			dtTargetEndDate = Date.today();

				return IECUsageCompiler.getListOfLiveUsageToCompileDaily(dtTargetEndDate);
		}

		global void execute(Database.BatchableContext BC, List<sObject> scope){

			List<IEC_Usage_Tracker_Live__c> lstLiveUsageToCompile = new List<IEC_Usage_Tracker_Live__c>();
			for (sObject sObj : scope)
				lstLiveUsageToCompile.add((IEC_Usage_Tracker_Live__c)sObj);

		IECUsageCompiler.compileDailyUsage(lstLiveUsageToCompile);
		}

		global void finish(Database.BatchableContext BC) {
	}
}
