public with sharing class AccountStatementTransactionHandler {

	private static final Id RT_ICE_BALANCE = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Statement_Transaction__c', 'ICE_Balance') ;

	public static void onBeforeInsert(list<Account_Statement_Transaction__c> listTransaction) {
		setParentId(listTransaction);
	}

	/**
	 * Populate the parentId field based on the Parent Key, only of the parent is not provided
	 * This was created to allow fast insertions from MuleSoft
	 */
	private static void setParentId(list<Account_Statement_Transaction__c> listTransaction) {
		// find incoming trasactions with parentKey and without parentId
		map<String,Account_Statement_Transaction__c> mapKeyTransaction = new map<String,Account_Statement_Transaction__c>();
		for (Account_Statement_Transaction__c trans: listTransaction) {
			if (trans.RecordTypeId == RT_ICE_BALANCE && String.isBlank(trans.Parent__c) && String.isNotBlank(trans.Parent_Key__c)) {
				mapKeyTransaction.put(trans.Parent_Key__c, trans);
			}
		}

		// find parent Ids from keys and assign them to incoming transactions
		for (Account_Statement__c statement: [SELECT Id, Key__c FROM Account_Statement__c WHERE Key__c IN :mapKeyTransaction.keyset()]) {
			Account_Statement_Transaction__c trans = mapKeyTransaction.get(statement.Key__c);
			if (trans!=null) {
				trans.Parent__c = statement.Id;
			}
		}
	}

}