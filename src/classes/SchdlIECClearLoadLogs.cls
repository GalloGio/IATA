global with sharing class SchdlIECClearLoadLogs implements Schedulable  {

	public integer iNumberOfDays {get; set;}

	global void execute(SchedulableContext sc) {

		iNumberOfDays = (-1) * (Integer) IEC_Settings__c.getOrgDefaults().Error_Log_Keep_Duration__c;

		if (Test.isRunningTest())
			iNumberOfDays = 1;

		try {
			DateTime dtToday = DateTime.now();
			DateTime dtLastWeek = dtToday.addDays(iNumberOfDays);


			List<IEC_Error_Log__c> lErrorLogs = [
				SELECT Id
				FROM IEC_Error_Log__c
				WHERE CreatedDate < :dtLastWeek
					AND Source__c like 'DataLoader%'];

			if (lErrorLogs != null && lErrorLogs.size() > 0)
				delete lErrorLogs;
		}
		catch (Exception ex) {
			System.debug('Clear Logs exception: ' + ex.getMessage());
		}

	}

}
