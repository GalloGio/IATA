public without sharing class TidsBatchRelinquishment implements database.batchable<sObject>{
	/* Process Batch: Relinquishment  Batch will be called directly after the case TIDS approval
	and will cascade the information from Head Office Account to Branches (Normal and Virtual)
	*/
	public Id caseId;
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String recordtoprocess= TidsBatchHelper.queryBuilderRelinquishment(this.caseId);
		return Database.getQueryLocator(recordtoprocess);
	}

	public void execute(Database.BatchableContext bc, List<Account> scope) {
		TidsBatchHelper.executeBuilderRelinquishment(this.caseId,  scope);
	}

	public void finish(Database.BatchableContext bc) {
		//When completed update End Date
		TidsBatchHelper.finishBuilderRelinquishment(this.caseId);
	}
}