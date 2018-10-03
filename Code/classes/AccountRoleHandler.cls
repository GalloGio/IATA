public class AccountRoleHandler {

    public List<Account_Role__c> triggerNew = (List<Account_Role__c>) Trigger.new;
    public List<Account_Role__c> triggerOld = (List<Account_Role__c>) Trigger.old;
    public Map<Id, Account_Role__c> newMap = (Map<Id, Account_Role__c>) Trigger.newMap;
    public Map<Id, Account_Role__c> oldMap = (Map<Id, Account_Role__c>) Trigger.oldMap;


    public void onBeforeInsert() {
        updatePaymentProviderStatus();
    }

    public void onBeforeUpdate() {
        updatePaymentProviderStatus();
    }

    public void onAfterUpdate() {
        manageAccountAsPaymentProvider();
    }

    public void onAfterDelete() {
        manageAccountAsPaymentProvider();
    }

    public void updatePaymentProviderStatus() {
        for(Account_Role__c ar : triggerNew) {
           if(ar.RecordTypeId == TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID) {
                if(ar.Effective_From_Date__c != null) {
                     if((oldMap == null) || 
                        (oldMap != null && (ar.Effective_From_Date__c != oldMap.get(ar.Id).Effective_From_Date__c))) {
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


    public void manageAccountAsPaymentProvider() {
        //account_id / account role
        Map<Id, Account_Role__c> ARsToProcess = new Map<Id, Account_Role__c>();
        String action = 'Remove';

        List<Account_Role__c> accRoleList = (trigger.isDelete) ? triggerOld : triggerNew;

        for(Account_Role__c ar : accRoleList) {
            if(ar.RecordTypeId == TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID) {
                if(trigger.isUpdate) {
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