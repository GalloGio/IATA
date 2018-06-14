trigger EF_BillingAgreementTrigger on EF_Billing_Agreement__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

        
        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            List<EF_Billing_Agreement__c> onlyUnvalidatedLocations = new List<EF_Billing_Agreement__c>();
            for(EF_Billing_Agreement__c ba : Trigger.new)
            {
                if(!ba.Skip_Approval__c)
                    onlyUnvalidatedLocations.add(ba);
            }
            
            // checks if location chosen has been set in Contract Location Currency.
            EF_BillingAgreementHandler.checkLocationCurrency(onlyUnvalidatedLocations);
            EF_BillingAgreementHandler.checkCurrencyFromContract(Trigger.new, Trigger.oldMap);
            EF_Utilities.storeUpdateComments((List<sObject>) Trigger.new);
            
            if(Trigger.isInsert)
            {
                EF_BillingAgreementHandler.handleWithApprovalContractInserts(Trigger.new);
                EF_BillingAgreementHandler.setClientFromRelatedContract(Trigger.new);
                
                // for new billing agreements, E&F Status must be set to false as there can be no Active material line item related
                EF_BillingAgreementHandler.deactivateBillingAgreement(Trigger.new);
            } else
            {
                List<EF_Billing_Agreement__c> toUpdateList = new List<EF_Billing_Agreement__c>();
                for(EF_Billing_Agreement__c ba : Trigger.new)
                {
                    if(!ba.Skip_Approval__c)
                    {
                        if(EF_Utilities.findIfKeyFieldsChanged((sObject) ba, (sObject) Trigger.oldMap.get(ba.Id), schema.SObjectType.EF_Billing_Agreement__c.fields.getMap(), new List<String>{'Skip_Approval__c', 'Billing_Currency__c'}))
                        {
                            toUpdateList.add(ba);
                        }
                    }
                }
                
                if(toUpdateList.size() > 0)
                    EF_BillingAgreementHandler.handleWithApprovalContractUpdates(new Map<Id, EF_Billing_Agreement__c>(toUpdateList), Trigger.oldMap);
                // EF_BillingAgreementHandler.handleWithApprovalContractUpdates(Trigger.newMap, Trigger.oldMap);
                EF_BillingAgreementHandler.handleApprovedAndRejectedApprovals(Trigger.new, Trigger.oldMap);
                EF_BillingAgreementHandler.revertSkipApprovalIfNecessary(Trigger.new, Trigger.oldMap);
                
                // for updated billing agreements, E&F Status must be checked and prevented to be set to Active if no related Active material line item is found
                EF_BillingAgreementHandler.checkIfBillingAgreementDeactivationRequired(Trigger.newMap);
                
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

            if(Trigger.isUpdate){
                EF_BillingAgreementHandler.manageCriticalFieldChanges(Trigger.new, Trigger.oldMap);
            }
        }

}