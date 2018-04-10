trigger AuthorizedFormsOfPaymentTrigger on Authorized_Forms_Of_Payment__c (after insert, after update, after delete) {

	if(trigger.isAfter){

		if(trigger.isInsert || trigger.isUpdate){

			AuthorizedFormsOfPaymentTriggerHelper.populatesFormOfPaymentsFields(trigger.new, false);
		}

		if(trigger.isDelete){
			AuthorizedFormsOfPaymentTriggerHelper.populatesFormOfPaymentsFields(trigger.new, true);	
		}
	}


}