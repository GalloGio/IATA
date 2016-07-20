/*
 * This trigger fires on every opportunity event and calls the appropriate method from the FinancialSecurityUtil class.
 */
trigger FinancialSecurityHandler on Financial_Security__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
    if (Trigger.isInsert) {
        
        if (Trigger.isBefore) {
            
        } else if (Trigger.isAfter) {
        	
        }
        
        
    } else if (Trigger.isUpdate) {
        
        if (Trigger.isBefore) {
            
            FinancialSecurityUtil.HandleFSBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            
        } else if (Trigger.isAfter) {
        	
        }
        
        
    } else if (Trigger.isDelete) {
        
        if (Trigger.isBefore) {
                        
        } else if (Trigger.isAfter) {
        	
        }
        
        
    } else if (Trigger.isUnDelete) {
        
        if (Trigger.isAfter) {
        	
        }
        
    }
}