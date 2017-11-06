trigger localgovernanceMeetingTrigger on LocalGovernance_Meeting__c (before delete) {

	if(Trigger.isBefore && Trigger.isDelete) {
		for(LocalGovernance_Meeting__c l : Trigger.old) {
			if(!l.Local_GoverNance__r.Active__c) l.addError('cannot modify for inactive groups');
		}
	}

}
