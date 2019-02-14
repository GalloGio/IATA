trigger LVA_AfterChatTrigger on LiveChatTranscript (before insert,after insert) {
    
    LVA_BeforeChatTriggerHandler handler = new LVA_BeforeChatTriggerHandler();
    
    if(Trigger.isBefore){
        handler.onBeforeInsert();
    }  
    
    if(Trigger.isAfter){
        LVA_AfterChatTriggerHandler.ProcessLiveChatTranscript(Trigger.New);
    }
    
}