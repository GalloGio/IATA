trigger NDCAccountServiceDetailTrigger on NDC_Account_Service_Detail__c (before insert, before update, after update) {
   new NDCAccountServiceDetailTriggerHandler().handle();
}