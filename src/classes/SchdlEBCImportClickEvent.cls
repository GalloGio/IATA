global class SchdlEBCImportClickEvent implements Database.AllowsCallouts, Schedulable {
	@future (callout=true)
	global static void futureExecute() {
		List<EBC_Click_Event__c> existingEE = [Select Event_Date_Timestamp__c From EBC_Click_Event__c Where Event_Date_Timestamp__c != null ORDER BY Event_Date_Timestamp__c DESC LIMIT 1];
		Datetime lastEventDate = Datetime.newInstance(2016, 09, 01, 01, 00, 00);
		if (existingEE.size() > 0) lastEventDate = Datetime.newInstance((Long)existingEE[0].Event_Date_Timestamp__c);

		IECEBC_ETCampaignTopLink.RetrieveClickEventProperties(lastEventDate);

	}
	// Schedulable
	global void execute(SchedulableContext SC)  {
		futureExecute();
	}
	global static void cancel() {
		cancel('SchdlEBCImportClickEvent' + (Test.isRunningTest() ? 'Test' : ''));
	}
	global static void cancel(String name) {
		CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
		System.abortJob(ct.Id);
	}

	global static void Schedule() {
		SchdlEBCImportClickEvent a = new SchdlEBCImportClickEvent();
		System.schedule('SchdlEBCImportClickEvent' + (Test.isRunningTest() ? 'Test' : ''), '0 58 * * * ?', a);
	}
}
