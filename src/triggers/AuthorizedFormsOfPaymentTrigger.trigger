trigger AuthorizedFormsOfPaymentTrigger on Authorized_Forms_Of_Payment__c (after insert, after update, before delete) {
/*
	if(trigger.isAfter){

		if(trigger.isInsert){

			AuthorizedFormsOfPaymentTriggerHelper.populatesFormOfPaymentsFields(trigger.new, false);
		}

		if(trigger.isUpdate){

			AuthorizedFormsOfPaymentTriggerHelper.updatesFormOfPaymentsFields(trigger.new, trigger.oldMap);	
		}

	}

	if(trigger.isBefore){

		if(trigger.isDelete){

			AuthorizedFormsOfPaymentTriggerHelper.populatesFormOfPaymentsFields(trigger.old, true);

		}

	}
*/

}