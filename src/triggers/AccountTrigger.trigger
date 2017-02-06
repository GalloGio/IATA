trigger AccountTrigger on Account (before insert, after insert, after update, before update, before delete, after delete){
  //Delete GDS, Account Category & GDP Products When Account is deleted
   if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.crossDeleteAccountItems(Trigger.old);
 
   if(Trigger.isBefore && Trigger.isDelete) 
   {
    system.debug('old..'+Trigger.old);
    ams2gdp_TriggerHelper.crossDeleteAccountItemsBefore(Trigger.old);}

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

}