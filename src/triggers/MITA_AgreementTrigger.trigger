trigger MITA_AgreementTrigger on MITA_Agreement__c (after insert, before update) {

	MITA_AgreementTriggerHandler handler = new MITA_AgreementTriggerHandler();

	if(Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new);
	}
	if(Trigger.isUpdate && Trigger.isBefore){
		handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
	}
}