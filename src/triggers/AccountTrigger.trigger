trigger AccountTrigger on Account ( after update,
                                    before insert,
                                    before update
                                    ) {

   if(trigger.isBefore && (trigger.isInsert || trigger.isupdate )){

           // if(trigger.newmap <> null)
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



}