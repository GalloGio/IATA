trigger EF_BillingAgreementTrigger on EF_Billing_Agreement__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

        
        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            // checks if location chosen has been set in Contract Location Currency.
            EF_BillingAgreementHandler.checkLocationCurrency(Trigger.new);
            EF_BillingAgreementHandler.checkCurrencyFromContract(Trigger.new, Trigger.oldMap);
            // EF_BillingAgreementHandler.preventAgreementCreationForNotAllowed(Trigger.new);
            if(Trigger.isInsert)
            {
                EF_BillingAgreementHandler.handleWithApprovalContractInserts(Trigger.new);
                EF_BillingAgreementHandler.setClientFromRelatedContract(Trigger.new);
            } else
            {
                EF_BillingAgreementHandler.handleWithApprovalContractUpdates(Trigger.newMap, Trigger.oldMap);
                EF_BillingAgreementHandler.handleApprovedAndRejectedApprovals(Trigger.new, Trigger.oldMap);
            }
            
        } else if (Trigger.isAfter && !Trigger.isDelete)
        {
            Set<Id> withApprovalIds = EF_BillingAgreementHandler.findIdsOfWithApprovalBillingAgreements(Trigger.new);
            if(EF_BillingAgreementHandler.runOnce() && withApprovalIds.size() > 0)
            {
                List<EF_Billing_Agreement__c> toApprove = new List<EF_Billing_Agreement__c>();
                for(Id toApproveId : withApprovalIds)
                {
                    toApprove.add(Trigger.newMap.get(toApproveId));
                }
                if(toApprove.size() > 0)
                    EF_BillingAgreementHandler.startApprovalProcesses(toApprove);                
            }
        }

}