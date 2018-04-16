trigger eventTrigger on Event  (before insert, before update, before delete) {
	if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
		List<Id> lsWhatIds = new List<Id>();
		for(Event t : Trigger.new) {
			lsWhatIds.add(t.WhatId);
		}

		Map<Id, LocalGovernance_Meeting__c> mpLGM =
			new Map<Id, LocalGovernance_Meeting__c>([SELECT Id, Name, Local_GoverNance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsWhatIds]);
		for(Event t : Trigger.new) {
			if(mpLGM.containsKey(t.WhatId) && !mpLGM.get(t.WhatId).Local_GoverNance__r.Active__c) t.addError('cannot modify for inactive groups');
		}
	}
	if(Trigger.isBefore && Trigger.isDelete) {
		List<Id> lsWhatIds = new List<Id>();
		for(Event t : Trigger.old) {
			lsWhatIds.add(t.WhatId);
		}

		Map<Id, LocalGovernance_Meeting__c> mpLGM =
		new Map<Id, LocalGovernance_Meeting__c>([SELECT Id, Name, Local_GoverNance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsWhatIds]);
		for(Event t : Trigger.old) {
			if(mpLGM.containsKey(t.WhatId) && !mpLGM.get(t.WhatId).Local_GoverNance__r.Active__c) t.addError('cannot modify for inactive groups');
		}
	}

}
