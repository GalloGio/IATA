trigger Account_Statement_Transaction on Account_Statement_Transaction__c (before insert) {

	if (Trigger.isInsert && Trigger.isBefore) {
		AccountStatementTransactionHandler.onBeforeInsert(Trigger.new);
	}

}