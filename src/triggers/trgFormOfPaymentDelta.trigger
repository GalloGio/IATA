trigger trgFormOfPaymentDelta on Authorized_Forms_Of_Payment__c (after insert, after update, after delete) {
	//Calls the Trigger Helper that will calculate the deltas that relates file specification and this reccord
	if (trigger.isInsert) GSS_DeltaTriggerHelper.calculateDeltas('I', Trigger.New, Trigger.New);
	if (trigger.isUpdate) GSS_DeltaTriggerHelper.calculateDeltas('U', Trigger.Old, Trigger.New);
	if (trigger.isDelete) GSS_DeltaTriggerHelper.calculateDeltas('D', Trigger.Old, Trigger.Old);
}