trigger trgFormOfPaymentDelta on Authorized_Forms_Of_Payment__c (after insert, after update, before delete, after delete) {
	//Calls the Trigger Helper that will calculate the deltas that relates file specification and this reccord
	if(trigger.isAfter){

		if(trigger.isInsert){

			GSS_DeltaTriggerHelper.calculateDeltas('I', Trigger.New, Trigger.New);

			AuthorizedFormsOfPaymentTriggerHelper.populatesFormOfPaymentsFields(trigger.new, false);
		}

		if(trigger.isUpdate){

			GSS_DeltaTriggerHelper.calculateDeltas('U', Trigger.Old, Trigger.New);

			AuthorizedFormsOfPaymentTriggerHelper.updatesFormOfPaymentsFields(trigger.new, trigger.oldMap);	
		}

		if(trigger.isDelete){

			GSS_DeltaTriggerHelper.calculateDeltas('D', Trigger.Old, Trigger.Old);
		}

	}

	if(trigger.isBefore){

		if(trigger.isDelete){

			AuthorizedFormsOfPaymentTriggerHelper.populatesFormOfPaymentsFields(trigger.old, true);
		}

	}

}