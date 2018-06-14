trigger ANG_AgencyAuthorizationTrigger on Agency_Authorization__c (before insert, before update, after delete) {

  		if(!AMS_TriggerExecutionManager.checkExecution(Agency_Authorization__c.getSObjectType(), 'ANG_AgencyAuthorizationTrigger')) { return; }

		if (Trigger.isBefore) {
			if(Trigger.isInsert){
				ANG_AgencyAuthorizationTriggerHandler.handleBeforeInsert(trigger.New);
			}
			if(Trigger.isUpdate){
				ANG_AgencyAuthorizationTriggerHandler.handleBeforeUpdate(trigger.New, trigger.OldMap);
			}
		}
        else if (Trigger.isAfter) {
            if(Trigger.isDelete){
                // delete the matching Remittance__c records - with Trigger.old
                ANG_AgencyAuthorizationTriggerHandler.removeAuthorizedFormsOfPayment(trigger.Old);
            }
        }

}
