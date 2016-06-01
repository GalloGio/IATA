trigger trgBeforeInsertUpdate on Case (before insert, before update) {

//this is for INC239697
    if ((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore){      

        for(Case cse : Trigger.new){
            CS_Email2CasePremium__c code = CS_Email2CasePremium__c.getInstance(cse.OwnerProfile__c);
            
            if(code != null){
                cse.Groups__c = code.Group__c;
            }else{
                cse.Groups__c = null;
            }
        }
    }
}