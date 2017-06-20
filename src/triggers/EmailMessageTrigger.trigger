trigger EmailMessageTrigger on EmailMessage (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if (Trigger.isInsert) {
        
        if (Trigger.isBefore) {
            
        } else if (Trigger.isAfter) {
            EmailMessageHandler.SetTheNOISentDateOnParentCase(Trigger.new);
            EmailMessageHandler.sendEmailToSenderWhenCaseClosed(Trigger.new);
        }
        
        
    } else if (Trigger.isUpdate) {
        
        if (Trigger.isBefore) {
            
        } else if (Trigger.isAfter) {
            
            
        }
        
        
    } else if (Trigger.isDelete) {
        
        if (Trigger.isBefore) {
            //EmailMessageHandler.PreventEmailDeletion(Trigger.Old);
        } else if (Trigger.isAfter) {
            
        }
        
        
    } else if (Trigger.isUnDelete) {
        
        if (Trigger.isAfter) {
            
        }
        
    }
}