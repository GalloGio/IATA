trigger AccountTrigger on Account (before insert, after insert, after update, before update){

  if(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'AccountTrigger')) { return; }

  if(trigger.isBefore && (trigger.isInsert || trigger.isupdate )){

    AccountTriggerHelper.copyInfoFromHqToBranchOnInsertAndUpdate(trigger.New, trigger.OldMap);
    AccountTriggerHelper.CopyCountry(trigger.New, trigger.oldmap); 
    AccountTriggerHelper.AccountNoDuplicateBranch(trigger.New, trigger.OldMap);
    AccountTriggerHelper.SectorCatToIndType(trigger.New, trigger.OldMap);
   
  }

  if(trigger.isAfter && trigger.isUpdate){
    //trgCopyInfoFromHQToBROnHQUpdate trgCopyInfoFromHQToBROnHQUpdatetest
    if(trigger.newmap <> null)
    AccountTriggerHelper.CopyFromHqToBRAfterUpdate(trigger.newMap);  
  }

  //AMS triggers
  if(Trigger.isBefore && Trigger.isInsert){
    AMS_AccountTriggerHandler.handleBeforeInsert(Trigger.new);
  } 
  else if (Trigger.isAfter && Trigger.isInsert){
    AMS_AccountTriggerHandler.handleAfterInsert(Trigger.new);
  }
  else if(Trigger.isBefore && Trigger.isUpdate){
    AMS_AccountTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
  }
  else if(Trigger.isAfter && Trigger.isUpdate){
    AMS_AccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    
  }

  if(Trigger.isAfter && Trigger.isUpdate){
    //E&F Account After Update - Handles account inactivation
    EF_AccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    //E&F Notification of fields identified as critical. List of fields set on custom setting.
    EF_AccountTriggerHandler.manageCriticalFieldChanges(Trigger.new, Trigger.oldMap);
  }

}