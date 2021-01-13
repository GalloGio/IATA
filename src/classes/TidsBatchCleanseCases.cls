global without sharing class TidsBatchCleanseCases implements database.batchable<sObject>,Schedulable  {
	/* Process Batch: Cleanse Case Batch will be called directly by the TIDS validation
	and will cascade the information from Head Office Account to Branches (Normal and Virtual)
	*/
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String recordtoprocess= TidsBatchHelper.queryBuilderCleanse();
		return Database.getQueryLocator(recordtoprocess);
	}

	public void execute(Database.BatchableContext bc, List<Case> scope) {
		TidsBatchHelper.executeBuilderCleanse(scope);
	}

	public void finish(Database.BatchableContext bc) {
		//When completed update End Date
	}

	global void execute(SchedulableContext sc) {
		TidsBatchCleanseCases b = new TidsBatchCleanseCases();
		database.executebatch(b);
	}
}