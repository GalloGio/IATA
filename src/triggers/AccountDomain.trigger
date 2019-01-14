trigger AccountDomain on Account_Domain__c(after insert, after delete) {

    // Call right method in our handler
    if (Trigger.isAfter && Trigger.isInsert) {
        AccountDomainHandler.afterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isDelete) {
        AccountDomainHandler.afterUpdate(Trigger.old);
    }

}