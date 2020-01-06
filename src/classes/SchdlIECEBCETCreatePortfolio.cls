global class SchdlIECEBCETCreatePortfolio implements Database.Batchable<sObject>, Schedulable , Database.AllowsCallouts {
	global Database.QueryLocator start(Database.BatchableContext BC){
		// @todo make sure that it wont be done for files
		return Database.getQueryLocator([Select Id, Image_URL__c, Name From EBC_Resource__c Where Is_Ready__c = false AND SystemModstamp < :Datetime.now().addMinutes(-2)]);
	}

	global static void Schedule(string sch) {
		SchdlIECEBCETCreatePortfolio a = new SchdlIECEBCETCreatePortfolio();
		if (String.isBlank(sch)) {
			Datetime nextSchedules = Datetime.now().addMinutes(2);
			sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';
		}
		System.schedule('SchdlIECEBCETCreatePortfolio' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
	}

	global static void reschedule() {
		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = 'SchdlIECEBCETCreatePortfolio' LIMIT 1];
		if (ct.size() > 0) {
			System.abortJob(ct[0].Id);

			Datetime nextSchedules = Datetime.now().addMinutes(15);
			String sch = String.valueOf(nextSchedules.second()) + ' ' + String.valueOf(nextSchedules.minute()) + ' * * * ?';

			Schedule(sch);
		}
	}

	global void execute(SchedulableContext SC)  {
	   SchdlIECEBCETCreatePortfolio n = new SchdlIECEBCETCreatePortfolio();
	   Database.executeBatch(n,200);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug(scope);

		Map<String, String> filenameToUrl = EBC_Resource_TriggerHandler.getFileNameToUrlMap((List<EBC_Resource__c>)scope);
		if(filenameToUrl.size() > 0) {
			IECEBC_ETPortfolioCreate.CreatePortfolioObject(filenameToUrl);
		}
	}

	global void finish(Database.BatchableContext BC) {
		if(!Test.isRunningTest())
				SchdlIECEBCETCreatePortfolio.reschedule();
	}
}
