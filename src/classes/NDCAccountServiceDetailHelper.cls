public class NDCAccountServiceDetailHelper {
    public static void ndcLogic(List<NDC_Account_Service_Detail__c> newDetails) {
        for(NDC_Account_Service_Detail__c detail : newDetails){
            if(detail.NDC_Rich_Content__c != 'Yes'){
                detail.NDC_Rich_Content_Types__c = null;
            }
            if(detail.NDC_Forms_of_Payment_Accepted__c == null || !detail.NDC_Forms_of_Payment_Accepted__c.contains('Credit Cards')){
                detail.NDC_Type_of_CC_Accepted__c = null;
            }
            
            if(Trigger.isBefore && Trigger.isUpdate){
                detail.Submittable_for_Approval__c = true;
            }
        }
    }
    
    public static void onAfterUpdate(Map<Id, NDC_Account_Service_Detail__c> oldMap, Map<Id, NDC_Account_Service_Detail__c> newMap){
    	// Delete relationships if NDC_Capable__c is false
		List<Id> notNDCCapableAccounts = new List<Id>();
    	for(NDC_Account_Service_Detail__c ndc : newMap.values()){
    		if(!ndc.NDC_Capable__c){
    			notNDCCapableAccounts.add(ndc.Id);
    		}
    	}
    	
		List<Id> accountRoleIds = new List<Id>();
		for(NDC_Account_Service_Detail__c ndcRecord :[SELECT Id, Account_Role_Service__r.Account_Role__r.Id
														FROM NDC_Account_Service_Detail__c
														WHERE Id in : notNDCCapableAccounts]){
			accountRoleIds.add(ndcRecord.Account_Role_Service__r.Account_Role__r.Id);
		}

		List<Account_Role_Relationship__c> relationshipsToDelete = [SELECT Id
												FROM Account_Role_Relationship__c
												WHERE Relationship_Type__c = 'NDC Player'
												AND (From__r.Id in : accountRoleIds
													OR To__r.Id in : accountRoleIds)];
													
    	delete relationshipsToDelete;
    }
}