trigger AmazonFileTrg on AmazonFile__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {


        if(Trigger.isAfter && Trigger.isUndelete) {
                AmazonFileTrgHelper.AfterUndelete(trigger.NewMap);
        }
}