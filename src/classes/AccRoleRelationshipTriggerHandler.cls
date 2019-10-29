public with sharing class AccRoleRelationshipTriggerHandler {
    public static Boolean bypassTrigger = false;
   
    private final List<Account_Role_Relationship__c> new_records;
    private final List<Account_Role_Relationship__c> old_records;
    private final Map<Id, Account_Role_Relationship__c> new_map;
    private final Map<Id, Account_Role_Relationship__c> old_map;
    
    public AccRoleRelationshipTriggerHandler()  {
        this.new_records = Trigger.new;
        this.old_records = Trigger.old;
        this.new_map = (Map<Id, Account_Role_Relationship__c>) Trigger.newMap;
        this.old_map = (Map<Id, Account_Role_Relationship__c>) Trigger.oldMap;
    }
    
    public void handle() {
        if (bypassTrigger) { return; }
        if (Trigger.isAfter  && Trigger.isInsert) {
            afterInsert();
        } else if (Trigger.isAfter  && Trigger.isDelete) {
            afterDelete();
        }
    }
    
    private void afterInsert() {
        NDC_AccountRoleRelationshipHelper.OneId_emailCreatedConnection(new_records);
    }
    
    private void afterDelete() {
        NDC_AccountRoleRelationshipHelper.OneId_emailDeletedConnection(old_records);
    }
}