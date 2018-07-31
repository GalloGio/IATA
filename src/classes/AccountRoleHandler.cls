public class AccountRoleHandler {

    public static void updatePaymentProviderStatus(list<Account_Role__c> NewARList, Map<Id,Account_Role__c> oldARMap) {
    	
    	//account_id / account role
    	Map<Id, Account_Role__c> ARsToProcess = new Map<Id, Account_Role__c>();

    	for(Account_Role__c ar : NewARList) {
    	   if(ar.RecordTypeId == TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID) {
                if(ar.Effective_From_Date__c != null) {
                     if((oldARMap == null) || 
                        (oldARMap != null && (ar.Effective_From_Date__c != oldARMap.get(ar.Id).Effective_From_Date__c))) {
                        if(ar.Effective_From_Date__c <= Date.today()) {
                            ar.Status__c = TIP_UTils.PARTNER_STATUS_ACTIVE;
                        }
                        else if(ar.Effective_From_Date__c > Date.today()) {
                            ar.Status__c = TIP_UTils.PARTNER_STATUS_IN_PROGRESS;
                        }
                    }   
                }
                else {
                    ar.Status__c = '';
                }
            }
        }
    }


    public static void manageAccountAsPaymentProvider(list<Account_Role__c> NewARList, Boolean isUpdate) {
    	//account_id / account role
    	Map<Id, Account_Role__c> ARsToProcess = new Map<Id, Account_Role__c>();
        String action = 'Remove';

    	for(Account_Role__c ar : NewARList) {
    		if(ar.RecordTypeId == TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID) {
                if(isUpdate) {
                    if(ar.Status__c == TIP_UTils.PARTNER_STATUS_ACTIVE) {
                        action = 'Add';  
                        ARsToProcess.Put(ar.Account__c, ar); 
                    }
                    else if(ar.Status__c == null) {
                        ARsToProcess.Put(ar.Account__c, ar);
                    }
                }
                else {
                    ARsToProcess.Put(ar.Account__c, ar);
                }
    		}
     	}

     	Set<Id> accIdsToProcess = ARsToProcess.keySet();

     	List<Account> accountsToProcess = [SELECT Account_Role__c FROM Account WHERE Id in : accIdsToProcess];
     	
     	for(Account a : accountsToProcess) {
     		a.Account_Role__c = TIP_Utils.ManageMultiPicklist(a.Account_Role__c, TIP_Utils.ACCOUNT_SERVICE_PROVIDED_PAYMENT_PROVIDER, action);
     	}

     	upsert accountsToProcess;

    }

}