public with sharing class NewGenApp_AccountStatementTriggerHandler {

	public void OnAfterUpdate(Account_Statement__c[] oldAccountStatements, Account_Statement__c[] updatedAccountStatements, Map <Id, Account_Statement__c> oldAccountStatementsMap){
        
        Set <Id> accountSet = new Set <Id>();
		for (Account_Statement__c st : updatedAccountStatements) {
			// only get accounts were the Balance was changed and isn't zero.
			if((oldAccountStatementsMap.get(st.Id).Balance__c != st.Balance__c) && (st.Balance__c != 0)){
				accountSet.add(st.Account__c);
			}
		}

		Map <Id, Account> accountMap = NewGen_Account_Statement_Helper.getAllHierarchies(accountSet);
        Map <Id, Set <String>> usersPerAccount = NewGen_Account_Statement_Helper.getUsersPerAccount(accountMap.keySet(), NewGen_Account_Statement_Helper.SERVICE_ICE);

        for (Account_Statement__c st : updatedAccountStatements) {
        	// only get accounts were the Balance was changed and isn't zero.
			if((oldAccountStatementsMap.get(st.Id).Balance__c != st.Balance__c) && (st.Balance__c != 0) && st.Balance__c != null){
				NewGen_Account_Statement_Helper.sendPushNotification(usersPerAccount.get(st.Account__c), Label.NewGenApp_AccountStatementNotification, 
					new List <String> { st.Name, String.valueOf(st.Balance__c) }, NewGen_Account_Statement_Helper.NAVIGATE_TO_ICE_HOME);            	
			}
        }
	}
}