global class SchdlEBCImportHardBounce implements Database.AllowsCallouts, Schedulable {
	// Schedulable
	global void execute(SchedulableContext SC)  {
		List<EBC_Email_Exclusion__c> existingEE = [Select Event_Date_Timestamp__c From EBC_Email_Exclusion__c Where Type__c = 'HARDBOUNCE' AND Event_Date_Timestamp__c != null ORDER BY Event_Date_Timestamp__c DESC LIMIT 1];
		Datetime lastEventDate = Datetime.newInstance(2016, 09, 01, 01, 00, 00);
		if (existingEE.size() > 0) lastEventDate = Datetime.newInstance((Long)existingEE[0].Event_Date_Timestamp__c);

		IECEBC_ETSubscriberBouncedRetrieve.RetrieveHardBounceFuture(lastEventDate);
	}
	global static void cancel() {
		cancel('SchdlEBCImportHardBounce' + (Test.isRunningTest() ? 'Test' : ''));
	}
	global static void cancel(String name) {
		CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
		System.abortJob(ct.Id);
	}

	global static void Schedule() {
		SchdlEBCImportHardBounce a = new SchdlEBCImportHardBounce();
		System.schedule('SchdlEBCImportHardBounce' + (Test.isRunningTest() ? 'Test' : ''), '0 15 * * * ?', a);
	}
}
