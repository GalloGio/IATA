trigger trgBeforeInsertUpdate on Case (before insert, before update) {

//INC239697
    if ((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore) {

        for (Case cse : Trigger.new) {

            CS_Email2CasePremium__c code;

            if (cse.OwnerProfile__c != null && cse.OwnerProfile__c != '')
                code = CS_Email2CasePremium__c.getInstance(cse.OwnerProfile__c);

            if (code != null) {
                cse.Groups__c = code.Group__c;
            } else if(cse.CNSCase__c == false){
                cse.Groups__c = 'Default';
            }
        }

    }
}
