trigger AccountRolesTrigger on Account_Roles__c (before insert, before update) {
    new AccountRolesTriggerHandler().handle();
}