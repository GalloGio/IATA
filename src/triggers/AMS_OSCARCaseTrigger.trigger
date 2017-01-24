trigger AMS_OSCARCaseTrigger on Case (before update, after update, before insert, after insert) {

	if(!AMS_TriggerExecutionManager.checkExecution(Case.getSObjectType(), 'AMS_OSCARCaseTrigger')) { return; }
	
    if(trigger.isBefore){
    	if(trigger.isInsert){
            //AMS_OscarCaseTriggerHelper.fillOSCARLookup(trigger.New);
            AMS_OscarCaseTriggerHelper.removeOscarFromChild(trigger.New);
            AMS_OscarCaseTriggerHelper.checkIrregularityThreshold();
            AMS_OscarCaseTriggerHelper.copyDataFromOscar();
        }
        if(Trigger.isUpdate){
            AMS_OscarCaseTriggerHelper.blockForbbidenActions(trigger.New, trigger.oldMap);
            //AMS_OscarCaseTriggerHelper.fillOSCARLookup(trigger.New);
            AMS_OscarCaseTriggerHelper.copyDataFromOscar();
        }
    }
    if(trigger.isAfter){
    	if(trigger.isInsert){
            AMS_OscarCaseTriggerHelper.OSCARCaseCreationRules(trigger.New);
        	AMS_OscarCaseTriggerHelper.populateOscarFields(trigger.New);
            //AMS_OscarCaseTriggerHelper.createSidraIrregularities();
			AMS_OscarCaseTriggerHelper.CreateRiskChangeCode();
        }
        if(trigger.isUpdate){
            AMS_OscarCaseTriggerHelper.OSCARCaseUpdateRules(trigger.New, trigger.oldMap);
            AMS_OscarCaseTriggerHelper.populateOscarFields(trigger.New);
            //AMS_OscarCaseTriggerHelper.createSidraIrregularities();
			AMS_OscarCaseTriggerHelper.CreateRiskChangeCode();
        }
    }

}