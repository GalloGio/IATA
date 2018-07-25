public class AccountRoleHandler {

    public static void updatePaymentProviderStatus(list<Account_Role__c> NewARList, Map<Id,Account_Role__c> oldARMap) {
    	
    	//account_id / account role
    	Map<Id, Account_Role__c> ARsToProcess = new Map<Id, Account_Role__c>();

    	for(Account_Role__c ar : NewARList) {
    		if(ar.RecordTypeId == TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID) {
    				ARsToProcess.Put(ar.Account__c, ar);
    		}
      }

     	for(Account_Role__c accRole : ARsToProcess.values()) {

     		if(accRole.Effective_From_Date__c != null && (accRole.Effective_From_Date__c != oldARMap.get(accRole.Id).Effective_From_Date__c)) {
     			if(accRole.Effective_From_Date__c <= Date.today()) {
     				accRole.Status__c = TIP_UTils.PARTNER_STATUS_ACTIVE;
     			}
     			else if(accRole.Effective_From_Date__c > Date.today()) {
     				accRole.Status__c = TIP_UTils.PARTNER_STATUS_IN_PROGRESS;
     			}
     		}
     	}

     	for(Account_Role__c accRole : ARsToProcess.values()) {

     		if(!String.isBlank(accRole.Status__c)) { //Status not empty
     			
       		//Code must be 4 chars; and cannot be empty
       		if(String.isBlank(accRole.Provider_Code__c) || accRole.Provider_Code__c.length() != 4) {
       			accRole.addError('Code is mandatory and must contain exactly 4 digits.');
       		}

       		//Location HQ are not empty
       		if(String.isBlank(accRole.HQ_Location__c)) {
       			accRole.addError('HR Location is mandatory.');
       		}
       	}
	    }
    }


    public static void manageAccountAsPaymentProvider(list<Account_Role__c> NewARList, String action) {
    	//account_id / account role
    	Map<Id, Account_Role__c> ARsToProcess = new Map<Id, Account_Role__c>();

    	for(Account_Role__c ar : NewARList) {
    		if(!String.isBlank(ar.Status__c)) {
    			if(ar.RecordTypeId == TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID) {
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