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
		String queryStr = 'SELECT Id, (SELECT Id, OSCAR__C FROM AMS_Oscar_Changes_History__r) ';
		queryStr += 'FROM AMS_OSCAR__c ';
		queryStr += 'WHERE Id IN (SELECT OSCAR__C FROM AMS_Oscar_Change_History__c) ';
		queryStr += 'AND Id IN (SELECT OSCAR__C FROM Case WHERE IsClosed = true AND ClosedDate < LAST_N_MONTHS:3) LIMIT 50000';

		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<AMS_OSCAR__c> oscars) {
		List<AMS_Oscar_Change_History__c> recordsToDelete = new List<AMS_Oscar_Change_History__c>();

		for(AMS_OSCAR__c oscar : oscars) {
			for(AMS_Oscar_Change_History__c record : oscar.AMS_Oscar_Changes_History__r) {
				recordsToDelete.add(record);
			}
		}

		if(!recordsToDelete.isEmpty()) {
			delete recordsToDelete;
		}
	}

	global void finish(Database.BatchableContext BC) {

	}
}