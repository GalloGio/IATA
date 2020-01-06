global class SchdlIECEBCEmailExclusionRelClean implements Database.Batchable<sObject>, Schedulable {
	public static final Integer BATCH_SIZE = 200;

	// Batchable
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([
			SELECT Id FROM EBC_Email_Exclusion_Relation__c Where Is_Email_Changed__c = true OR EBC_Email_Exclusion__r.Is_Active__c = false
		]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
	}

	global void finish(Database.BatchableContext BC) {
	}

	// Schedulable
	global void execute(SchedulableContext SC)  {
		SchdlIECEBCEmailExclusionRelClean n = new SchdlIECEBCEmailExclusionRelClean();
		Database.executeBatch(n,SchdlIECEBCEmailExclusionRelClean.BATCH_SIZE);
	}
	global static void cancel() {
		cancel('SchdlIECEBCEmailExclusionRelClean' + (Test.isRunningTest() ? 'Test' : ''));
	}
	global static void cancel(String name) {
		CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
		System.abortJob(ct.Id);
	}

	global static void Schedule() {
		Schedule(null);
	}
	global static void Schedule(string sch) {
		SchdlIECEBCEmailExclusionRelClean a = new SchdlIECEBCEmailExclusionRelClean();
		if (String.isBlank(sch)) {
			sch = '0 0 * * * ?';
		}
		System.schedule('SchdlIECEBCEmailExclusionRelClean' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
	}
}
