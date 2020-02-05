global class SchdlIECEBCRetrieveCumulativeStats implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
	public static final Integer BATCH_SIZE = 1;

	// Batchable
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([
			SELECT Id, Name, Send_Datetime__c, External_Id__c, Status__c,
											  is7dFollowUpCompleted__c
											  FROM EBC_Campaign__c
											  WHERE is7dFollowUpCompleted__c = false
											  AND Status__c = 'Sent'
											  AND External_Id__c LIKE 'FINAL_%'
		]); // @todo
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
			IECEBC_ETCampaignTrackingAsync.createCumulativeCampaignTracking((List<EBC_Campaign__c>)scope);
	}

	global void finish(Database.BatchableContext BC) {

	}

	// Schedulable
	global void execute(SchedulableContext SC)  {
		if (!Test.isRunningTest()) {
			SchdlIECEBCRetrieveCumulativeStats n = new SchdlIECEBCRetrieveCumulativeStats();
			Database.executeBatch(n,SchdlIECEBCRetrieveCumulativeStats.BATCH_SIZE);
		}
	}
	global static void cancel() {
		cancel('SchdlIECEBCRetrieveCumulativeStats' + (Test.isRunningTest() ? 'Test' : ''));
	}
	global static void cancel(String name) {
		CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
		System.abortJob(ct.Id);
	}

	global static void Schedule() {
		Schedule(null);
	}
	global static void Schedule(string sch) {
		SchdlIECEBCRetrieveCumulativeStats a = new SchdlIECEBCRetrieveCumulativeStats();
		if (String.isBlank(sch)) {
			sch = '0 0 * * * ?';
		}
		System.schedule('SchdlIECEBCRetrieveCumulativeStats' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
	}
}
