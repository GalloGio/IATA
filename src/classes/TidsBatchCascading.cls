public without sharing class TidsBatchCascading implements database.batchable<sObject>{
	/* Process Batch: Cascading Batch will be called directly by the TIDS validation
	and will cascade the information from Head Office Account to Branches (Normal and Virtual)
	*/
	public Id caseId;
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String recordtoprocess= TidsBatchHelper.queryBuilderAccount(this.caseId);
		return Database.getQueryLocator(recordtoprocess);
	}

	public void execute(Database.BatchableContext bc, List<Account> scope) {
		TidsBatchHelper.executeBuilderAccount(this.caseId,  scope);
	}

	public void finish(Database.BatchableContext bc) {
		//When completed update End Date
		TidsBatchHelper.finishBuilderAccount(bc, this.caseId);
	}
}