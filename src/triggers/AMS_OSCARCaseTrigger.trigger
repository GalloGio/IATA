trigger AMS_OSCARCaseTrigger on Case (before update, after update, before insert, after insert) {

    if(trigger.isBefore){
    	if(trigger.isInsert){
        	AMS_OscarCaseTriggerHelper.OSCARCaseCreationRules(trigger.New);
            AMS_OscarCaseTriggerHelper.fillOSCARLookup(trigger.New);
        }
        if(Trigger.isUpdate){
            AMS_OscarCaseTriggerHelper.OSCARCaseUpdateRules(trigger.New, trigger.oldMap);
            AMS_OscarCaseTriggerHelper.blockForbbidenActions(trigger.New, trigger.oldMap);
        	AMS_OscarCaseTriggerHelper.renameOSCAR(trigger.New);
            AMS_OscarCaseTriggerHelper.fillOSCARLookup(trigger.New);
        }
    }
    if(trigger.isAfter){
    	if(trigger.isInsert){
        	AMS_OscarCaseTriggerHelper.renameOSCAR(trigger.New);
            //AMS_OscarCaseTriggerHelper.createSidraIrregularities();
        }
        if(trigger.isUpdate){
            //AMS_OscarCaseTriggerHelper.createSidraIrregularities();
        }
    }

}