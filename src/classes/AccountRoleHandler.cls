public class AccountRoleHandler {

    public List<Account_Role__c> triggerNew = (List<Account_Role__c>) Trigger.new;
    public List<Account_Role__c> triggerOld = (List<Account_Role__c>) Trigger.old;
    public Map<Id, Account_Role__c> newMap = (Map<Id, Account_Role__c>) Trigger.newMap;
    public Map<Id, Account_Role__c> oldMap = (Map<Id, Account_Role__c>) Trigger.oldMap;


    public void onBeforeInsert() {
        updatePaymentProviderStatus();
        updateAccountName();
        //checkForGadmDuplicatesInsert();
        fillGadmUniqueKey(true, false);
    }

    public void onBeforeUpdate() {
        updatePaymentProviderStatus();
        updateAccountName();
        //checkForGadmDuplicatesUpdate();
        fillGadmUniqueKey(false, true);
    }

    public void onAfterUpdate() {
        manageAccountAsPaymentProvider();
    }

    public void onAfterDelete() {
        manageAccountAsPaymentProvider();
    }

    public void updateAccountName(){
        Set<Id> accIds = new Set<Id>();
        for(Account_Role__c ar : triggerNew) {
            accIds.add(ar.Account__c);
        }

        Map<Id, Account> accsNameMap = new Map<Id, Account>([SELECT Id, Name From Account WHERE Id=:accIds]);
        for(Account_Role__c ar : triggerNew) {
            Account acc = accsNameMap.get(ar.Account__c);
            if (acc != null){
                ar.Account_Name__c = acc.Name;
            }
        }
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

    /*public void checkForGadmDuplicatesInsert() {

        List<Account_Roles__c> gadmParticipantRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant' LIMIT 1];
        if(! gadmParticipantRole.isEmpty()) {

            Set<Id> accountIds = new Set<Id>();
            for(Account_Role__c accountRole : triggerNew) {
                if(accountRole.Account_Roles__c == gadmParticipantRole[0].Id) {
                    accountIds.add(accountRole.Account__c);
                }

            }

            List<Account_Role__c> existingAccountRoles = [SELECT Id, Account__c, Account__r.Name FROM Account_Role__c WHERE Account__c = :accountIds AND Account_Roles__c = :gadmParticipantRole[0].Id];
            System.debug('existingAccountRoles:: ' + existingAccountRoles);
            Map<Id, List<Account_Role__c>> accountToAccountRolesMap = new Map<Id, List<Account_Role__c>>();
            for(Account_Role__c role : existingAccountRoles) {
                if(accountToAccountRolesMap.get(role.Account__c) == null) {
                    accountToAccountRolesMap.put(role.Account__c, new List<Account_Role__c>{role});
                }else{
                    accountToAccountRolesMap.get(role.Account__c).add(role);
                }
            }
            System.debug('accountToAccountRolesMap:: ' + accountToAccountRolesMap);

            for(Account_Role__c accountRole : triggerNew) {
                if(accountToAccountRolesMap.get(accountRole.Account__c) != null) {
                    accountRole.addError('Record for ' +accountToAccountRolesMap.get(accountRole.Account__c)[0].Account__r.Name + ' and GADM Participant role already exists!');
                }
            }

        }

    }

    public void checkForGadmDuplicatesUpdate() {

        List<Account_Roles__c> gadmParticipantRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant' LIMIT 1];
        if(! gadmParticipantRole.isEmpty()) {

            Set<Id> accountIds = new Set<Id>();
            for(Account_Role__c accountRole : triggerNew) {
                if(accountRole.Account_Roles__c == gadmParticipantRole[0].Id) {
                    Account_Role__c oldObj = oldMap.get(accountRole.Id);
                    if((oldObj.Account_Roles__c != accountRole.Account_Roles__c) || (oldObj.Account__c != accountRole.Account__c)) {
                        accountIds.add(accountRole.Account__c);
                    }

                }

            }

            List<Account_Role__c> existingAccountRoles = [SELECT Id, Account__c, Account__r.Name FROM Account_Role__c WHERE Account__c = :accountIds AND Account_Roles__c = :gadmParticipantRole[0].Id];
            System.debug('existingAccountRoles:: ' + existingAccountRoles);
            Map<Id, List<Account_Role__c>> accountToAccountRolesMap = new Map<Id, List<Account_Role__c>>();
            for(Account_Role__c role : existingAccountRoles) {
                if(accountToAccountRolesMap.get(role.Account__c) == null) {
                    accountToAccountRolesMap.put(role.Account__c, new List<Account_Role__c>{role});
                }else{
                    accountToAccountRolesMap.get(role.Account__c).add(role);
                }
            }
            System.debug('accountToAccountRolesMap:: ' + accountToAccountRolesMap);

            for(Account_Role__c accountRole : triggerNew) {
                if(accountToAccountRolesMap.get(accountRole.Account__c) != null) {
                    accountRole.addError('Record for ' +accountToAccountRolesMap.get(accountRole.Account__c)[0].Account__r.Name + ' and GADM Participant role already exists!');
                }
            }

        }

    }*/


    public void fillGadmUniqueKey(Boolean isInsert, Boolean isUpdate) {
        if(isInsert) {

            List<Account_Roles__c> gadmParticipantRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant' LIMIT 1];
            if(! gadmParticipantRole.isEmpty()) {

                for(Account_Role__c accountRole : triggerNew) {
                    if(accountRole.Account_Roles__c == gadmParticipantRole[0].Id) {
                        accountRole.GADM_Unique_Key__c = String.valueOf(accountRole.Account__c).left(15) + '_' + String.valueOf(accountRole.Account_Roles__c).left(15);
                    }
                }
            }

        }


        if(isUpdate) {
            List<Account_Roles__c> gadmParticipantRole = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant' LIMIT 1];
            if(! gadmParticipantRole.isEmpty()) {

                for(Account_Role__c accountRole : triggerNew) {
                    if(accountRole.Account_Roles__c == gadmParticipantRole[0].Id) {
                        accountRole.GADM_Unique_Key__c = String.valueOf(accountRole.Account__c).left(15) + '_' + String.valueOf(accountRole.Account_Roles__c).left(15);
                    }else{
                        accountRole.GADM_Unique_Key__c = '';
                    }
                }

            }

        }

    }

}