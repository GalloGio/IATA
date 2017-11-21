public class ANG_RiskAlertPurge implements Database.Batchable<SObject>, Schedulable{

	private final Id recType = ANG_RHCHelper.RECTYPE_RISKALERT_RHC;
	private final DateTime startDate = system.now().addDays(-365);

	public void schedule(Datetime d, String jobName) {
		String sch = d.format('ss mm HH dd MM ? yyyy');
		String jobID = System.schedule(jobName, sch, this);
	}

	public void execute(SchedulableContext context){
		
		Boolean tooManyBatches = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] >= 5;
		//check if there are 5 active batch jobs
		//In some cases, might need to add "Status='Queued' " to the criteria
		if (tooManyBatches) schedule(System.now().addMinutes(10), 'Risk Alert Purge Retry - '+System.now().addMinutes(10).format());
		else Database.executeBatch(this);
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id FROM ANG_Risk_Alert__c WHERE ANG_RME_Last_Update__c < :startDate AND RecordTypeId = :recType]);
	}

	public void execute(Database.BatchableContext BC, List<ANG_Risk_Alert__c> scope) {
		delete scope;
	}
	
	public void finish(Database.BatchableContext BC) {
		//no action needed
	}
}