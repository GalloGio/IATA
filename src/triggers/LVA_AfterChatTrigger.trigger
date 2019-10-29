trigger LVA_AfterChatTrigger on LiveChatTranscript (before insert,after insert,before update, after update) {
    
    LVA_ChatTriggerHandler handler = new LVA_ChatTriggerHandler();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert)
            handler.onBeforeInsert();
        if(Trigger.isUpdate)
             handler.onBeforeUpdate();
    }  
    
    if(Trigger.isAfter){
         if(Trigger.isInsert)
            handler.onAfterInsert();
        if(Trigger.isUpdate)
             handler.onAfterUpdate();

        
    }

    
    
}