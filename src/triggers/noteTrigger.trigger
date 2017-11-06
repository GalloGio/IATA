trigger noteTrigger on Note  (before insert, before update, before delete) {
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        List<Id> lsParentIds = new List<Id>();
        for(Note t : Trigger.new) {
            lsParentIds.add(t.ParentId);
        }

        Map<Id, LocalGovernance_Meeting__c> mpLGM =
			new Map<Id, LocalGovernance_Meeting__c>([SELECT Id, Name, Local_GoverNance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsParentIds]);
        for(Note t : Trigger.new) {
			if(mpLGM.containsKey(t.ParentId) && !mpLGM.get(t.ParentId).Local_GoverNance__r.Active__c) t.addError('cannot modify for inactive groups');
        }
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        List<Id> lsParentIds = new List<Id>();
        for(Note t : Trigger.old) {
            lsParentIds.add(t.ParentId);
        }

		Map<Id, LocalGovernance_Meeting__c> mpLGM =
		new Map<Id, LocalGovernance_Meeting__c>([SELECT Id, Name, Local_GoverNance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsParentIds]);
		for(Note t : Trigger.old) {
			if(mpLGM.containsKey(t.ParentId) && !mpLGM.get(t.ParentId).Local_GoverNance__r.Active__c) t.addError('cannot modify for inactive groups');
		}
    }

}
