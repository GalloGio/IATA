trigger AMS_AgencyAChangeCode on Agency_Applied_Change_code__c (before insert, after insert, after update/*before insert, before update*/) {

    if(!AMS_TriggerExecutionManager.checkExecution(Agency_Applied_Change_code__c.getSObjectType(), 'AMS_AgencyAChangeCode')) { return; }
    
    //DTULLO: Prevent trigger from running more than once
    if(AMS_AgencyAChangeCodeHandler.firstRun == true){
        AMS_AgencyAChangeCodeHandler.firstRun = false;
        if(Trigger.isBefore) {
            if(Trigger.isInsert){
                AMS_AgencyAChangeCodeHandler.handleBeforeInsert(Trigger.new);
            }
            
            if(Trigger.isUpdate){
                AMS_AgencyAChangeCodeHandler.handleBeforeUpdate(Trigger.new);
            }
        }
    
        if(Trigger.isAfter) {
            if(Trigger.isUpdate)
                AMS_AgencyAChangeCodeHandler.handleAfterUpdate(Trigger.new, trigger.OldMap);
            if(Trigger.isInsert){
                AMS_AgencyAChangeCodeHandler.handleAfterInsert(Trigger.new);
                new ANG_AgencyAChangeCodeTriggerHandler().onAfterInsert();
            }

        }
        AMS_AgencyAChangeCodeHandler.firstRun = true;
    }

}