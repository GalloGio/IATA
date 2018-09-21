public with sharing class NewGen_AccountRiskStatusTriggerHandler {
	public void onAfterUpdate(Account[] oldAccount, Account[] updatedAccount, Map <Id, Account> oldAccountMap) {

		Set <Id> accountSet = new Set <Id>();
		
		for (Account acc : updatedAccount) {
			if(oldAccountMap.get(acc.Id).ANG_RiskStatus__c != null && acc.ANG_RiskStatus__c != null &&
				oldAccountMap.get(acc.Id).ANG_RiskStatus__c != acc.ANG_RiskStatus__c){
				
				accountSet.add(acc.Id);
			}
		}

		if(accountSet.isEmpty()){
			return;
		}

        Map <Id, Set <String>> usersPerAccount = NewGen_Account_Statement_Helper.getUsersPerAccount(accountSet, NewGen_Account_Statement_Helper.SERVICE_RHC);

        for (Account acc : updatedAccount) {
        	Account oldAcc = oldAccountMap.get(acc.Id);
			if(oldAccountMap.get(acc.Id).ANG_RiskStatus__c != null && acc.ANG_RiskStatus__c != null &&
				oldAccountMap.get(acc.Id).ANG_RiskStatus__c != acc.ANG_RiskStatus__c){
				
				NewGen_Account_Statement_Helper.sendPushNotification(usersPerAccount.get(acc.Id), Label.NewGenApp_RiskStatusNotification, 
					new List <String> { acc.Name, String.valueOf(acc.ANG_RiskStatus__c) }, NewGen_Account_Statement_Helper.NAVIGATE_TO_RHC_RISK_PROFILE);  
			}
		}
	}
}