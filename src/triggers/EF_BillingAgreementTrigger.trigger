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
            EF_BillingAgreementHandler.preventAgreementCreationForNotAllowed(Trigger.new);
            if(Trigger.isInsert)
            {
                EF_BillingAgreementHandler.handleWithApprovalAccountInserts(Trigger.new);
            } else
            {
                EF_BillingAgreementHandler.handleWithApprovalAccountUpdates(Trigger.newMap, Trigger.oldMap);
                EF_BillingAgreementHandler.handleApprovedAndRejectedApprovals(Trigger.new, Trigger.oldMap);
            }
            
        } else if (Trigger.isAfter)
        {     
            if(EF_BillingAgreementHandler.runOnce())
            {
                EF_BillingAgreementHandler.startApprovalProcesses(Trigger.new);                
            }
        }

}