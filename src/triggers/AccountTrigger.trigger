trigger AccountTrigger on Account (before insert, after insert, after update, before update, before delete, after delete, after undelete){
  
  NewGen_AccountRiskStatusTriggerHandler newgenHandler = new NewGen_AccountRiskStatusTriggerHandler();
  NewGenApp_Custom_Settings__c newgenCS = NewGenApp_Custom_Settings__c.getOrgDefaults();

  if(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'AccountTrigger')) { return; }
  
  //NOT NEEDED ANYMORE AS PER NEWGEN-796 - DTULLO: added to skip trigger execution if aggreagating data for PwC
  //if(AMS_Batch_AggregatePwcData.bIsAMS_Batch_AggregatePwcDataRunning){return;}
  
  
  if(trigger.isBefore && (trigger.isInsert || trigger.isupdate )){

    AccountTriggerHelper.copyInfoFromHqToBranchOnInsertAndUpdate(trigger.New, trigger.OldMap);
    AccountTriggerHelper.CopyCountry(trigger.New, trigger.oldmap); 
    AccountTriggerHelper.AccountNoDuplicateBranch(trigger.New, trigger.OldMap);
    AccountTriggerHelper.SectorCatToIndType(trigger.New, trigger.OldMap);
   
    TIP_Utils.validateUniqueIATACodeForTIP(trigger.new, trigger.OldMap);
  }

  if(trigger.isAfter && trigger.isUpdate){
    //trgCopyInfoFromHQToBROnHQUpdate trgCopyInfoFromHQToBROnHQUpdatetest
    if(trigger.newmap <> null)
    AccountTriggerHelper.CopyFromHqToBRAfterUpdate(trigger.newMap);
    if(newgenCS.Push_Notifications_State__c){
      newgenHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);  
    }
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
    TIP_Utils.setAssessmentDate(Trigger.new, Trigger.oldMap);
  }
  else if(Trigger.isAfter && Trigger.isUpdate){
    AMS_AccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    //Custom history tracking
    ANG_TrackingHistory.trackHistory(Trigger.newMap, Trigger.oldMap, 'Account', 'ANG_Account_Tracking_History__c');
    
  }


  //ANG triggers
  ANG_AccountTriggerHandler angHandler = new ANG_AccountTriggerHandler();
  if(Trigger.isBefore && Trigger.isInsert) angHandler.onBeforeInsert();
  else if (Trigger.isAfter && Trigger.isInsert) angHandler.onAfterInsert();
  else if(Trigger.isBefore && Trigger.isUpdate) angHandler.onBeforeUpdate();
  else if(Trigger.isAfter && Trigger.isUpdate) angHandler.onAfterUpdate();
  else if(Trigger.isBefore && Trigger.isDelete) angHandler.onBeforeDelete();
  else if(Trigger.isAfter && Trigger.isDelete) angHandler.onAfterDelete();


  if(Trigger.isAfter && Trigger.isUpdate){
    //E&F Account After Update - Handles account inactivation
    EF_AccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    //E&F Notification of fields identified as critical. List of fields set on custom setting.
    EF_AccountTriggerHandler.manageCriticalFieldChanges(Trigger.new, Trigger.oldMap);
  } 
//Delete GDS, Account Category & GDP Products When Account is deleted
   if(Trigger.isAfter && Trigger.isDelete) ams2gdp_TriggerHelper.crossDeleteAccountItems(Trigger.old);
 
   if(Trigger.isBefore && Trigger.isDelete) 
   {
    system.debug('old..'+Trigger.old);
    ams2gdp_TriggerHelper.crossDeleteAccountItemsBefore(Trigger.old);}
    //SIS Integration trigger
    if(Trigger.isBefore && Trigger.isInsert){
        ISSP_SIS_AccountHandler.beforeInsert(Trigger.new);
    } 
    if(Trigger.isAfter && Trigger.isInsert){
        ISSP_SIS_AccountHandler.afterInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        ISSP_SIS_AccountHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
    //Trigger the platform events
    if(trigger.isAfter)
    	PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Account__e', 'Account', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
}