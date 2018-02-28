public with sharing class NewGen_ANG_RHCInformationTriggerHandler {
	public void onAfterUpdate(ANG_RHC_Information__c[] oldRHCInformation, ANG_RHC_Information__c[] updatedRHCInformation, Map <Id, ANG_RHC_Information__c> oldRHCInformationMap) {

		Set <Id> informationSet = new Set <Id>();

		System.Debug(updatedRHCInformation);
		
		for (ANG_RHC_Information__c rhcinfo : updatedRHCInformation) {
			if((oldRHCInformationMap.get(rhcinfo.Id).ANG_CashCondition__c != rhcinfo.ANG_CashCondition__c)){
				informationSet.add(rhcinfo.ANG_AccountId__c);
			}
		}

		Map <Id, Account> accountMap = NewGen_Account_Statement_Helper.getAllHierarchies(informationSet);
        Map <Id, Set <String>> usersPerAccount = NewGen_Account_Statement_Helper.getUsersPerAccount(accountMap.keySet(), NewGen_Account_Statement_Helper.SERVICE_RHC);

        for (ANG_RHC_Information__c rhcinfo : updatedRHCInformation) {
			if((oldRHCInformationMap.get(rhcinfo.Id).ANG_CashCondition__c != rhcinfo.ANG_CashCondition__c)){
				
				NewGen_Account_Statement_Helper.sendPushNotification(usersPerAccount.get(rhcinfo.ANG_AccountId__c), Label.NewGenApp_CashConditionsNotification, new List <String> { rhcinfo.Name, String.valueOf(rhcinfo.ANG_CashCondition__c) });  
			}
		}
	}
}