trigger trgBeforeInsertUpdate on Case (before insert, before update) {

//INC239697
    if ((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore) {

        for (Case cse : Trigger.new) {
            cse.CNSCase__c=true;
            
            CS_Email2CasePremium__c code;

            if (cse.OwnerProfile__c != null && cse.OwnerProfile__c != '')
                code = CS_Email2CasePremium__c.getInstance(cse.OwnerProfile__c);

            if (code != null) {
                cse.Groups__c = code.Group__c;
            } else {
                cse.Groups__c = 'Default';
            }
        }
        
        //CNS -- define when a case created on the portal can be considered as a CNS Case. 
        //Agents with CNSAcount__c = true cases will be allways CNS cases,
        //Airlines or other types of accounts will lead to other rule, which is:
        //if ??????
        CNS_CaseHandler.ManageCNSCaseOnBeforeInsertUpdate(Trigger.new);
    }
}