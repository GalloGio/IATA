trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();

    if(Trigger.isBefore) {
        if(Trigger.isInsert) handler.onBeforeInsert();
                
        if(Trigger.isUpdate) handler.onBeforeUpdate();
        
        if(Trigger.isDelete) handler.onBeforeDelete();     
    } else {
        if(Trigger.isInsert) handler.onAfterInsert();
                    
        if(Trigger.isUpdate) handler.onAfterUpdate();
                
        if(Trigger.isDelete) handler.onAfterDelete(); 
                
        if(Trigger.isUnDelete) handler.onUndelete();           
    }      
}