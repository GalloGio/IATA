global class AMS_OscarChangeHistoryCleanBatch implements Database.Batchable<sObject>, Schedulable {

	private Integer batchScope {get;set;}

	public AMS_OscarChangeHistoryCleanBatch(Integer batchScope) {
		this.batchScope = batchScope;
	}

		public static void start(String cron, Integer scope) {
        if(!Test.isRunningTest()) {
            System.schedule('AMS Oscar Changes Clean Batch', cron, new AMS_OscarChangeHistoryCleanBatch (scope));
        }else{
            System.schedule('AMS Oscar Changes Clean  Batch TEST', cron, new AMS_OscarChangeHistoryCleanBatch (scope));
        }        
    }

    public static void stop(){
        String sJobName = '';
        if(!Test.isRunningTest()) {
            sJobName = 'AMS Oscar Changes Clean Batch';
        }else{
            sJobName = 'AMS Oscar Changes Clean Batch TEST';
        }
        
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }

	global void execute(SchedulableContext sc) {
		Database.executeBatch(this, this.batchScope);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<Technical_Logs__c> logs = [SELECT Id, Record__c 
										FROM Technical_Logs__c
										WHERE Operation__c = 'Rollback' AND CreatedDate < LAST_N_MONTHS:3 LIMIT 50000];

		Set<Id> oscarIds = new Set<Id>();
		for(Technical_Logs__c log : logs) {
			oscarIds.add(log.Record__c);
		}

		List<Case> closedCases = [SELECT OSCAR__C 
								  FROM Case
								  WHERE IsClosed = true AND ClosedDate < LAST_N_MONTHS:3 AND OSCAR__C <> null AND OSCAR__C IN :oscarIds LIMIT 50000];

		Set<Id> logsToDelete = new Set<Id>();
		for(Case cse : closedCases) {
			if(oscarIds.contains(cse.OSCAR__C)) {
				logsToDelete.add(cse.OSCAR__C);
			}
		}

		String queryStr = 'SELECT Id FROM Technical_Logs__c WHERE Record__c IN :logsToDelete AND Record__c <> null';

		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<Technical_Logs__c> logs) {

		if(!logs.isEmpty()) {
			delete logs;
		}
	}

	global void finish(Database.BatchableContext BC) {

	}
}