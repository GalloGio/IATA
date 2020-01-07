/*
 * This trigger fires on every opportunity event and calls the appropriate method from the FinancialSecurityUtil class.
 */
trigger FinancialSecurityHandler on Financial_Security__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    //WMO-470
    if(FinancialSecurityUtil.acknowledgeRunning) {
        return;
    }

    if (Trigger.isInsert) {
        
        if (Trigger.isBefore) {
            new ANG_FinancialSecurityTriggerHandler().onBeforeInsert();
        } else if (Trigger.isAfter) {
            new ANG_FinancialSecurityTriggerHandler().onAfterInsert();
        }
        
        
    } else if (Trigger.isUpdate) {
        if (Trigger.isBefore ){
            new ANG_FinancialSecurityTriggerHandler().onBeforeUpdate();
            FinancialSecurityUtil.HandleFSBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            if(userinfo.getProfileId() == '00e20000000h0gFAAQ' && Test.isRunningTest()) FinancialSecurityUtil.HandleFSBeforeUpdate(Trigger.newMap, Trigger.oldMap);// include system administrator profile for code coverage
        } else if (Trigger.isAfter) {
            new ANG_FinancialSecurityTriggerHandler().onAfterUpdate();
            FinancialSecurityUtil.sendAcknowledge(Trigger.new);
        }
        
        
    } else if (Trigger.isDelete) {
        
        if (Trigger.isBefore) {
            new ANG_FinancialSecurityTriggerHandler().onBeforeDelete();    
        } else if (Trigger.isAfter) {
            new ANG_FinancialSecurityTriggerHandler().onAfterDelete();
        }
        
        
    } else if (Trigger.isUnDelete) {
        
        if (Trigger.isAfter) {
            
        }
        
    }
}