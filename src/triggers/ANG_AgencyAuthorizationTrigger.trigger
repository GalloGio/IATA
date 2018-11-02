trigger ANG_AgencyAuthorizationTrigger on Agency_Authorization__c (before insert, before update, after insert, after update, after delete) {

	if(!AMS_TriggerExecutionManager.checkExecution(Agency_Authorization__c.getSObjectType(), 'ANG_AgencyAuthorizationTrigger')) { return; }
	if (Trigger.isBefore) {
		if(Trigger.isInsert){
			ANG_AgencyAuthorizationTriggerHandler.handleBeforeInsert(trigger.New);
		}
		if(Trigger.isUpdate){
			ANG_AgencyAuthorizationTriggerHandler.handleBeforeUpdate(trigger.New, trigger.OldMap);
		}
	}
	if (Trigger.isAfter) {
		if(Trigger.isInsert){
			ANG_AgencyAuthorizationTriggerHandler.handleAfterInsert(trigger.New);
		}else if(Trigger.isUpdate){
			ANG_AgencyAuthorizationTriggerHandler.handleAfterUpdate(trigger.New, trigger.OldMap);
		}else if(Trigger.isDelete){
            // delete the matching Remittance__c records - with Trigger.old
            ANG_AgencyAuthorizationTriggerHandler.removeAuthorizedFormsOfPayment(trigger.Old);
        }
	}
}
